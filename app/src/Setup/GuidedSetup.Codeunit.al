namespace Construction.Setup;

using Construction.Core;
using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Subcontracts;
using Microsoft.Foundation.NoSeries;
using System.Environment.Configuration;
using System.Media;

codeunit 50019 "CONS Guided Setup"
{
    Access = Internal;

    /// <summary>
    /// Orchestrates the construction assisted setup: registers the guide on Microsoft's Assisted
    /// Setup list, fills the ordered feature list for the hub, runs the per-feature wizard, and
    /// applies the user's choices (enable, number series, demo data). The session is NOT restarted
    /// here — the hub restarts once on close (see CONS Feature Mgt.).
    /// </summary>

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        FoundationNameTxt: Label 'Foundation (Core)';
        FoundationDescTxt: Label 'Master setup shared by every module: number series for documents, retention and posting accounts, and the AI (MCP) connection. Set this up first.';
        EstimatingNameTxt: Label 'Estimating';
        EstimatingDescTxt: Label 'Bill of Quantities estimating and the conversion of an approved estimate into a project budget.';
        CostControlNameTxt: Label 'Cost Control';
        CostControlDescTxt: Label 'Cost breakdown structure, committed cost, and cost-to-complete / estimate-at-completion forecasting.';
        ProgressBillingNameTxt: Label 'Progress Billing';
        ProgressBillingDescTxt: Label 'Progress billing applications, payment certificates and retention on customer invoices.';
        SubcontractsNameTxt: Label 'Subcontracts';
        SubcontractsDescTxt: Label 'Subcontracts, subcontractor progress claims, change orders / variations and subcontractor retention.';
        EquipmentNameTxt: Label 'Equipment & Plant';
        EquipmentDescTxt: Label 'Equipment register, cost and hire rates, usage posting to projects, maintenance and meters.';
        SchedulingNameTxt: Label 'Scheduling & Resource Planning';
        SchedulingDescTxt: Label 'Task scheduling with dependencies, crew/resource assignment and the project Gantt.';
        AssistedSetupTitleTxt: Label 'Set up Construction Management';
        AssistedSetupShortTitleTxt: Label 'Construction Setup', MaxLength = 50;
        AssistedSetupDescTxt: Label 'Enable the construction features you bought, create their number series and optionally load demo data, so you can start working. The session may restart at the end.';
        BoQSeriesTxt: Label 'Bill of Quantities', MaxLength = 100;
        ProgCertSeriesTxt: Label 'Progress Certificates', MaxLength = 100;
        ProgBillSeriesTxt: Label 'Progress Billing Applications', MaxLength = 100;
        SubcSeriesTxt: Label 'Subcontracts', MaxLength = 100;
        SubcClaimSeriesTxt: Label 'Subcontractor Claims', MaxLength = 100;
        ChangeOrderSeriesTxt: Label 'Change Orders', MaxLength = 100;
        EquipSeriesTxt: Label 'Equipment', MaxLength = 100;
        BoQCodeTok: Label 'CONS-BOQ', Locked = true, MaxLength = 20;
        BoQStartTok: Label 'BOQ000001', Locked = true, MaxLength = 20;
        ProgCertCodeTok: Label 'CONS-PCERT', Locked = true, MaxLength = 20;
        ProgCertStartTok: Label 'PCERT00001', Locked = true, MaxLength = 20;
        ProgBillCodeTok: Label 'CONS-PBILL', Locked = true, MaxLength = 20;
        ProgBillStartTok: Label 'PBILL00001', Locked = true, MaxLength = 20;
        SubcCodeTok: Label 'CONS-SUBC', Locked = true, MaxLength = 20;
        SubcStartTok: Label 'SUBC000001', Locked = true, MaxLength = 20;
        SubcClaimCodeTok: Label 'CONS-SCLM', Locked = true, MaxLength = 20;
        SubcClaimStartTok: Label 'SCLM000001', Locked = true, MaxLength = 20;
        ChangeOrderCodeTok: Label 'CONS-CO', Locked = true, MaxLength = 20;
        ChangeOrderStartTok: Label 'CO00000001', Locked = true, MaxLength = 20;
        EquipCodeTok: Label 'CONS-EQP', Locked = true, MaxLength = 20;
        EquipStartTok: Label 'EQ00000001', Locked = true, MaxLength = 20;

    /// <summary>Registers the construction assisted setup on Microsoft's Assisted Setup list, idempotently. Call from install and upgrade.</summary>
    procedure RegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if GuidedExperience.Exists(Enum::"Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"CONS Setup Hub") then
            exit;
        GuidedExperience.InsertAssistedSetup(
            AssistedSetupTitleTxt,
            AssistedSetupShortTitleTxt,
            AssistedSetupDescTxt,
            5,
            ObjectType::Page,
            Page::"CONS Setup Hub",
            Enum::"Assisted Setup Group"::DoMoreWithBC,
            '',
            Enum::"Video Category"::Uncategorized,
            '');
    end;

    /// <summary>Marks the construction assisted setup complete (called when the hub closes).</summary>
    procedure MarkAssistedSetupComplete()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"CONS Setup Hub");
    end;

    /// <summary>Fills the hub's step buffer with the ordered list of features and computes each step's status. Call on hub open and after each wizard run.</summary>
    /// <param name="TempSetupStep">The temporary buffer to populate.</param>
    procedure PopulateSteps(var TempSetupStep: Record "CONS Setup Step" temporary)
    begin
        TempSetupStep.Reset();
        TempSetupStep.DeleteAll();

        AddCoreStep(TempSetupStep, 1, Enum::"CONS Module"::Foundation, FoundationNameTxt, FoundationDescTxt, Page::"CONS Construction Setup");
        AddFeatureStep(TempSetupStep, 2, Enum::"CONS Module"::Estimating, Enum::"CONS Feature"::Estimating, EstimatingNameTxt, EstimatingDescTxt, Page::"CONS Estimating Setup");
        AddFeatureStep(TempSetupStep, 3, Enum::"CONS Module"::"Cost Control", Enum::"CONS Feature"::CostControl, CostControlNameTxt, CostControlDescTxt, Page::"CONS Cost Control Setup");
        AddFeatureStep(TempSetupStep, 4, Enum::"CONS Module"::"Progress Billing", Enum::"CONS Feature"::ProgressBilling, ProgressBillingNameTxt, ProgressBillingDescTxt, Page::"CONS Progress Billing Setup");
        AddFeatureStep(TempSetupStep, 5, Enum::"CONS Module"::Subcontracts, Enum::"CONS Feature"::Subcontracts, SubcontractsNameTxt, SubcontractsDescTxt, Page::"CONS Subcontracts Setup");
        AddFeatureStep(TempSetupStep, 6, Enum::"CONS Module"::"Equipment & Plant", Enum::"CONS Feature"::Equipment, EquipmentNameTxt, EquipmentDescTxt, Page::"CONS Equipment Setup");
        AddFeatureStep(TempSetupStep, 7, Enum::"CONS Module"::"Scheduling & Resource Planning", Enum::"CONS Feature"::Scheduling, SchedulingNameTxt, SchedulingDescTxt, Page::"CONS Scheduling Setup");
    end;

    local procedure AddCoreStep(var TempSetupStep: Record "CONS Setup Step" temporary; StepNo: Integer; Module: Enum "CONS Module"; Name: Text[100]; Description: Text[250]; SetupPageId: Integer)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := StepNo;
        TempSetupStep.Module := Module;
        TempSetupStep."Has Toggle" := false;
        TempSetupStep.Name := Name;
        TempSetupStep.Description := Description;
        TempSetupStep."Setup Page ID" := SetupPageId;
        TempSetupStep.Enabled := true;
        if FoundationIsSetUp() then
            TempSetupStep.Status := TempSetupStep.Status::Completed
        else
            TempSetupStep.Status := TempSetupStep.Status::"Not Started";
        TempSetupStep.Insert();
    end;

    local procedure AddFeatureStep(var TempSetupStep: Record "CONS Setup Step" temporary; StepNo: Integer; Module: Enum "CONS Module"; Feature: Enum "CONS Feature"; Name: Text[100]; Description: Text[250]; SetupPageId: Integer)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := StepNo;
        TempSetupStep.Module := Module;
        TempSetupStep.Feature := Feature;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep.Name := Name;
        TempSetupStep.Description := Description;
        TempSetupStep."Setup Page ID" := SetupPageId;
        TempSetupStep.Enabled := FeatureMgt.IsEnabled(Feature);
        if TempSetupStep.Enabled then
            TempSetupStep.Status := TempSetupStep.Status::Completed
        else
            TempSetupStep.Status := TempSetupStep.Status::"Not Started";
        TempSetupStep.Insert();
    end;

    /// <summary>Foundation is "set up" once at least the primary document number series is assigned.</summary>
    local procedure FoundationIsSetUp(): Boolean
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        ConstructionSetup.SetLoadFields("BoQ Nos.");
        if not ConstructionSetup.Get() then
            exit(false);
        exit(ConstructionSetup."BoQ Nos." <> '');
    end;

    /// <summary>Runs the per-feature wizard for the selected step (modal), then returns to the hub.</summary>
    /// <param name="TempSetupStep">The step the user selected in the hub.</param>
    procedure RunWizardForStep(var TempSetupStep: Record "CONS Setup Step" temporary)
    var
        Wizard: Page "CONS Feature Setup Wizard";
    begin
        Wizard.SetContext(TempSetupStep.Module, TempSetupStep.Feature, TempSetupStep."Has Toggle",
            TempSetupStep.Name, TempSetupStep.Description, TempSetupStep.Enabled);
        Wizard.RunModal();
    end;

    /// <summary>
    /// Applies the wizard's choices for one feature: enables/disables it (toggleable features only),
    /// creates and assigns its number series, and loads its demo data — per the checkboxes the user
    /// ticked. Refreshes application areas but does NOT restart the session (the hub does that once).
    /// </summary>
    procedure ApplyWizardChoices(Module: Enum "CONS Module"; Feature: Enum "CONS Feature"; HasToggle: Boolean; DoEnable: Boolean; DoNoSeries: Boolean; DoDemoData: Boolean)
    var
        DemoData: Codeunit "CONS Demo Data";
    begin
        if HasToggle then begin
            FeatureMgt.SetEnabled(Feature, DoEnable);
            FeatureMgt.RefreshExperienceAreas();
        end;
        if DoNoSeries or DoDemoData then
            SetupNumberSeries(Module);
        if DoDemoData then
            DemoData.CreateDemoData(Module);
    end;

    /// <summary>Creates and assigns the number series the module needs, if not already assigned. Idempotent. Cost Control and Scheduling have no document number series, so they are intentionally absent from the case.</summary>
    local procedure SetupNumberSeries(Module: Enum "CONS Module")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        EquipmentSetup: Record "CONS Equipment Setup";
    begin
        case Module of
            Module::Foundation:
                begin
                    ConstructionSetup.InitSetup();
                    ConstructionSetup.Get();
                    AssignSeries(ConstructionSetup."BoQ Nos.", BoQCodeTok, BoQSeriesTxt, BoQStartTok);
                    AssignSeries(ConstructionSetup."Progress Cert. Nos.", ProgCertCodeTok, ProgCertSeriesTxt, ProgCertStartTok);
                    AssignSeries(ConstructionSetup."Progress Billing Nos.", ProgBillCodeTok, ProgBillSeriesTxt, ProgBillStartTok);
                    AssignSeries(ConstructionSetup."Subcontract Nos.", SubcCodeTok, SubcSeriesTxt, SubcStartTok);
                    AssignSeries(ConstructionSetup."Subcontract Claim Nos.", SubcClaimCodeTok, SubcClaimSeriesTxt, SubcClaimStartTok);
                    AssignSeries(ConstructionSetup."Change Order Nos.", ChangeOrderCodeTok, ChangeOrderSeriesTxt, ChangeOrderStartTok);
                    ConstructionSetup.Modify(true);
                end;
            Module::Estimating:
                begin
                    ConstructionSetup.InitSetup();
                    ConstructionSetup.Get();
                    AssignSeries(ConstructionSetup."BoQ Nos.", BoQCodeTok, BoQSeriesTxt, BoQStartTok);
                    ConstructionSetup.Modify(true);
                end;
            Module::"Progress Billing":
                begin
                    ConstructionSetup.InitSetup();
                    ConstructionSetup.Get();
                    AssignSeries(ConstructionSetup."Progress Cert. Nos.", ProgCertCodeTok, ProgCertSeriesTxt, ProgCertStartTok);
                    AssignSeries(ConstructionSetup."Progress Billing Nos.", ProgBillCodeTok, ProgBillSeriesTxt, ProgBillStartTok);
                    ConstructionSetup.Modify(true);
                end;
            Module::Subcontracts:
                begin
                    ConstructionSetup.InitSetup();
                    ConstructionSetup.Get();
                    AssignSeries(ConstructionSetup."Subcontract Nos.", SubcCodeTok, SubcSeriesTxt, SubcStartTok);
                    AssignSeries(ConstructionSetup."Subcontract Claim Nos.", SubcClaimCodeTok, SubcClaimSeriesTxt, SubcClaimStartTok);
                    AssignSeries(ConstructionSetup."Change Order Nos.", ChangeOrderCodeTok, ChangeOrderSeriesTxt, ChangeOrderStartTok);
                    ConstructionSetup.Modify(true);
                end;
            Module::"Equipment & Plant":
                begin
                    EquipmentSetup.InitSetup();
                    EquipmentSetup.Get();
                    AssignSeries(EquipmentSetup."Equipment Nos.", EquipCodeTok, EquipSeriesTxt, EquipStartTok);
                    EquipmentSetup.Modify(true);
                end;
        end;
    end;

    /// <summary>Assigns SeriesCode to the target field if blank, creating the No. Series (and its line) first if it does not exist. Idempotent.</summary>
    local procedure AssignSeries(var TargetField: Code[20]; SeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20])
    begin
        if TargetField <> '' then
            exit;
        EnsureNoSeries(SeriesCode, Description, StartingNo);
        TargetField := SeriesCode;
    end;

    local procedure EnsureNoSeries(SeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(SeriesCode) then
            exit;
        NoSeries.Init();
        NoSeries.Code := SeriesCode;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := SeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := StartingNo;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
    end;
}
