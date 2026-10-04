namespace Construction.Test;

using Construction.Core;
using Construction.Equipment;
using Construction.Estimating;
using Construction.Setup;
using Microsoft.Foundation.NoSeries;
using System.Environment.Configuration;
using System.TestLibraries.Utilities;

codeunit 64023 "CONS Guided Setup Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure PopulateSteps_ListsFoundationThenSixFeatures()
    var
        TempSetupStep: Record "CONS Setup Step" temporary;
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] the assisted setup hub opens
        TestLibrary.Initialize();
        // [WHEN] the step list is built
        GuidedSetup.PopulateSteps(TempSetupStep);
        // [THEN] Foundation comes first without a toggle, followed by the six switchable features
        Assert.AreEqual(7, TempSetupStep.Count(), 'one Foundation step and six feature steps');
        TempSetupStep.Get(1);
        Assert.AreEqual(Enum::"CONS Module"::Foundation, TempSetupStep.Module, 'step 1 is Foundation');
        Assert.IsFalse(TempSetupStep."Has Toggle", 'Foundation cannot be switched off');
        Assert.AreEqual(Page::"CONS Construction Setup", TempSetupStep."Setup Page ID", 'Foundation opens Construction Setup');
        TempSetupStep.Get(7);
        Assert.AreEqual(Enum::"CONS Feature"::Scheduling, TempSetupStep.Feature, 'Scheduling is the last step');
        Assert.IsTrue(TempSetupStep."Has Toggle", 'features have a toggle');
    end;

    [Test]
    procedure PopulateSteps_StatusFollowsFeatureState()
    var
        TempSetupStep: Record "CONS Setup Step" temporary;
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] Estimating enabled, Cost Control disabled
        TestLibrary.Initialize();
        TestLibrary.SetFeature(Enum::"CONS Feature"::Estimating, true);
        TestLibrary.SetFeature(Enum::"CONS Feature"::CostControl, false);
        // [WHEN] the step list is built
        GuidedSetup.PopulateSteps(TempSetupStep);
        // [THEN] an enabled feature is Completed and a disabled one is Not Started
        TempSetupStep.Get(2);
        Assert.IsTrue(TempSetupStep.Enabled, 'Estimating enabled');
        Assert.AreEqual(TempSetupStep.Status::Completed, TempSetupStep.Status, 'Estimating completed');
        TempSetupStep.Get(3);
        Assert.IsFalse(TempSetupStep.Enabled, 'Cost Control disabled');
        Assert.AreEqual(TempSetupStep.Status::"Not Started", TempSetupStep.Status, 'Cost Control not started');
    end;

    [Test]
    procedure PopulateSteps_FoundationCompletedOnceBoQSeriesAssigned()
    var
        TempSetupStep: Record "CONS Setup Step" temporary;
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] no construction number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        GuidedSetup.PopulateSteps(TempSetupStep);
        TempSetupStep.Get(1);
        // [THEN] Foundation is Not Started
        Assert.AreEqual(TempSetupStep.Status::"Not Started", TempSetupStep.Status, 'Foundation not started without series');

        // [WHEN] the number series are assigned and the list is rebuilt
        TestLibrary.SetupNumberSeries();
        GuidedSetup.PopulateSteps(TempSetupStep);
        // [THEN] Foundation is Completed (and the rebuild replaced, not duplicated, the steps)
        TempSetupStep.Get(1);
        Assert.AreEqual(TempSetupStep.Status::Completed, TempSetupStep.Status, 'Foundation completed with series');
        Assert.AreEqual(7, TempSetupStep.Count(), 'rebuild does not duplicate steps');
    end;

    [Test]
    procedure ApplyWizardChoices_Foundation_CreatesAndAssignsAllSeries()
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Record "No. Series";
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] Construction Setup without number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();

        // [WHEN] the Foundation wizard runs with "create number series"
        GuidedSetup.ApplyWizardChoices(Enum::"CONS Module"::Foundation, Enum::"CONS Feature"::Estimating, false, false, true, false);

        // [THEN] every document series exists and is assigned
        ConstructionSetup.Get();
        Assert.AreEqual('CONS-BOQ', ConstructionSetup."BoQ Nos.", 'BoQ series');
        Assert.AreEqual('CONS-PCERT', ConstructionSetup."Progress Cert. Nos.", 'progress certificate series');
        Assert.AreEqual('CONS-PBILL', ConstructionSetup."Progress Billing Nos.", 'progress billing series');
        Assert.AreEqual('CONS-SUBC', ConstructionSetup."Subcontract Nos.", 'subcontract series');
        Assert.AreEqual('CONS-SCLM', ConstructionSetup."Subcontract Claim Nos.", 'claim series');
        Assert.AreEqual('CONS-CO', ConstructionSetup."Change Order Nos.", 'change order series');
        NoSeries.Get('CONS-BOQ');
        Assert.IsTrue(NoSeries."Default Nos.", 'series allows default numbers');
    end;

    [Test]
    procedure ApplyWizardChoices_KeepsSeriesAlreadyAssigned()
    var
        ConstructionSetup: Record "CONS Construction Setup";
        GuidedSetup: Codeunit "CONS Guided Setup";
        ExistingSeries: Code[20];
    begin
        // [GIVEN] the user already assigned their own number series
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        ExistingSeries := ConstructionSetup."Subcontract Nos.";

        // [WHEN] the Subcontracts wizard runs with "create number series"
        GuidedSetup.ApplyWizardChoices(Enum::"CONS Module"::Subcontracts, Enum::"CONS Feature"::Subcontracts, false, false, true, false);

        // [THEN] the existing assignment is preserved (idempotent, never overwrites)
        ConstructionSetup.Get();
        Assert.AreEqual(ExistingSeries, ConstructionSetup."Subcontract Nos.", 'existing series kept');
    end;

    [Test]
    procedure ApplyWizardChoices_Equipment_AssignsEquipmentSeries()
    var
        EquipmentSetup: Record "CONS Equipment Setup";
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] Equipment Setup without a number series
        TestLibrary.Initialize();
        EquipmentSetup.InitSetup();
        EquipmentSetup.Get();
        EquipmentSetup."Equipment Nos." := '';
        EquipmentSetup.Modify();

        // [WHEN] the Equipment wizard runs with "create number series"
        GuidedSetup.ApplyWizardChoices(Enum::"CONS Module"::"Equipment & Plant", Enum::"CONS Feature"::Equipment, false, false, true, false);

        // [THEN] the equipment series is created and assigned
        EquipmentSetup.Get();
        Assert.AreEqual('CONS-EQP', EquipmentSetup."Equipment Nos.", 'equipment series');
    end;

    [Test]
    procedure ApplyWizardChoices_Toggle_EnablesFeature()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] Cost Control disabled
        TestLibrary.Initialize();
        TestLibrary.SetFeature(Enum::"CONS Feature"::CostControl, false);

        // [WHEN] the Cost Control wizard runs with "enable"
        GuidedSetup.ApplyWizardChoices(Enum::"CONS Module"::"Cost Control", Enum::"CONS Feature"::CostControl, true, true, false, false);

        // [THEN] the feature is enabled
        Assert.IsTrue(FeatureMgt.IsEnabled(Enum::"CONS Feature"::CostControl), 'Cost Control enabled by the wizard');
    end;

    [Test]
    procedure ApplyWizardChoices_DemoData_SeedsAndCreatesSeries()
    var
        BoQHeader: Record "CONS BoQ Header";
        ConstructionSetup: Record "CONS Construction Setup";
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        // [GIVEN] no number series and no demo data
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();

        // [WHEN] the Estimating wizard runs with "load demo data" only
        GuidedSetup.ApplyWizardChoices(Enum::"CONS Module"::Estimating, Enum::"CONS Feature"::Estimating, false, false, false, true);

        // [THEN] the demo BoQ is seeded and the BoQ series is created as a prerequisite
        Assert.IsTrue(BoQHeader.Get('CONS-DEMO-BOQ'), 'demo BoQ seeded');
        ConstructionSetup.Get();
        Assert.AreEqual('CONS-BOQ', ConstructionSetup."BoQ Nos.", 'demo data implies the series');
    end;

    [Test]
    procedure RegisterAssistedSetup_IsIdempotent()
    var
        GuidedSetup: Codeunit "CONS Guided Setup";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        // [GIVEN]/[WHEN] the assisted setup is registered twice (install, then upgrade)
        GuidedSetup.RegisterAssistedSetup();
        GuidedSetup.RegisterAssistedSetup();
        // [THEN] it is listed on the Assisted Setup page
        Assert.IsTrue(GuidedExperience.Exists(Enum::"Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"CONS Setup Hub"), 'assisted setup registered');
    end;

    [Test]
    procedure ConstructionSetup_InitSetup_IsIdempotent()
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a setup with a value
        TestLibrary.Initialize();
        TestLibrary.SetDefaultRetention(7.5);
        // [WHEN] InitSetup runs again
        ConstructionSetup.InitSetup();
        // [THEN] the existing singleton is kept, not reset
        ConstructionSetup.Get();
        Assert.AreEqual(7.5, ConstructionSetup."Default Retention %", 'existing setup kept');
        Assert.AreEqual(1, ConstructionSetup.Count(), 'single setup record');
    end;
}
