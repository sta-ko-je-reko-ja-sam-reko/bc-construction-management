namespace Construction.Test;

using Construction.Core;
using Construction.Retention;
using Construction.Setup;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;

/// <summary>
/// Shared setup for the Construction Management tests: resets the swappable seams (access policy, retention and
/// subcontract workflow reactions) to a deterministic state, switches features on and off without the setup
/// pages' session restart, and builds the project, number series and posting-account context the integration
/// tests need.
/// </summary>
codeunit 64000 "CONS Test Library"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryJob: Codeunit "Library - Job";
        LibraryUtility: Codeunit "Library - Utility";

    /// <summary>
    /// Resets the Service Locator to a known state: an access policy that grants everything (so the result never
    /// depends on the permissions of the user running the tests) and the default retention and subcontract
    /// workflow reactions. The Service Locator is single-instance, so a fake injected by one test would otherwise
    /// leak into the next.
    /// </summary>
    procedure Initialize()
    var
        TestAccessPolicy: Codeunit "CONS Test Access Policy";
        RetentionLogic: Codeunit "CONS Retention Logic";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        TestAccessPolicy.SetAllow(true);
        ServiceLocator.ImplementAccessPolicy(TestAccessPolicy);
        ServiceLocator.ImplementRetentionReactions(RetentionLogic);
        ServiceLocator.ImplementSubcWfReactions(SubcWfReactions);
    end;

    /// <summary>Makes the injected access policy grant (true) or deny (false) every permission check.</summary>
    /// <param name="Allow">Whether the policy grants access.</param>
    procedure SetAccessAllowed(Allow: Boolean)
    var
        TestAccessPolicy: Codeunit "CONS Test Access Policy";
    begin
        TestAccessPolicy.SetAllow(Allow);
    end;

    /// <summary>Switches a feature on or off through the feature facade (no application-area refresh, no restart).</summary>
    /// <param name="Feature">The feature.</param>
    /// <param name="Enabled">The new Enabled state.</param>
    procedure SetFeature(Feature: Enum "CONS Feature"; Enabled: Boolean)
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        FeatureMgt.SetEnabled(Feature, Enabled);
    end;

    /// <summary>Switches every construction feature on.</summary>
    procedure EnableAllFeatures()
    var
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"CONS Feature".Ordinals() do
            SetFeature(Enum::"CONS Feature".FromInteger(Ordinal), true);
    end;

    /// <summary>Creates a construction project with a customer and one posting task.</summary>
    /// <param name="Job">Returns the project.</param>
    /// <param name="JobTask">Returns the posting task.</param>
    procedure CreateProjectWithTask(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        LibraryJob.CreateJob(Job);
        Job."CONS Construction Project" := true;
        Job.Status := Job.Status::Open;
        Job.Modify(true);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    /// <summary>Points every construction document number series at a default, manual-allowed series.</summary>
    procedure SetupNumberSeries()
    var
        ConstructionSetup: Record "CONS Construction Setup";
        SeriesCode: Code[20];
    begin
        SeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
        ConstructionSetup.InitSetup();
        ConstructionSetup.Get();
        ConstructionSetup."BoQ Nos." := SeriesCode;
        ConstructionSetup."Progress Cert. Nos." := SeriesCode;
        ConstructionSetup."Progress Billing Nos." := SeriesCode;
        ConstructionSetup."Subcontract Nos." := SeriesCode;
        ConstructionSetup."Subcontract Claim Nos." := SeriesCode;
        ConstructionSetup."Change Order Nos." := SeriesCode;
        ConstructionSetup.Modify();
    end;

    /// <summary>Removes every construction document number series from Construction Setup.</summary>
    procedure ClearNumberSeries()
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        ConstructionSetup.InitSetup();
        ConstructionSetup.Get();
        ConstructionSetup."BoQ Nos." := '';
        ConstructionSetup."Progress Cert. Nos." := '';
        ConstructionSetup."Progress Billing Nos." := '';
        ConstructionSetup."Subcontract Nos." := '';
        ConstructionSetup."Subcontract Claim Nos." := '';
        ConstructionSetup."Change Order Nos." := '';
        ConstructionSetup.Modify();
    end;

    /// <summary>Creates postable G/L accounts for revenue, retention receivable/payable and subcontract cost and assigns them in Construction Setup.</summary>
    procedure SetupPostingAccounts()
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        ConstructionSetup.InitSetup();
        ConstructionSetup.Get();
        ConstructionSetup."Revenue Account" := LibraryERM.CreateGLAccountWithSalesSetup();
        ConstructionSetup."Retention Receivable Acc." := LibraryERM.CreateGLAccountWithSalesSetup();
        ConstructionSetup."Subcontract Cost Account" := LibraryERM.CreateGLAccountWithPurchSetup();
        ConstructionSetup."Retention Payable Acc." := LibraryERM.CreateGLAccountWithPurchSetup();
        ConstructionSetup.Modify();
    end;

    /// <summary>Sets the default retention percentage in Construction Setup.</summary>
    /// <param name="RetentionPct">The default retention %.</param>
    procedure SetDefaultRetention(RetentionPct: Decimal)
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        ConstructionSetup.InitSetup();
        ConstructionSetup.Get();
        ConstructionSetup."Default Retention %" := RetentionPct;
        ConstructionSetup.Modify();
    end;

    /// <summary>Gives a cost type a new postable default G/L account and returns it.</summary>
    /// <param name="CostType">The cost type.</param>
    /// <returns>The G/L account number.</returns>
    procedure SetCostTypeGLAccount(CostType: Enum "CONS Cost Type"): Code[20]
    var
        CostTypeSetup: Record "CONS Cost Type Setup";
    begin
        if not CostTypeSetup.Get(CostType) then begin
            CostTypeSetup.Init();
            CostTypeSetup."Cost Type" := CostType;
            CostTypeSetup.Insert();
        end;
        CostTypeSetup."Default G/L Account No." := LibraryERM.CreateGLAccountWithPurchSetup();
        CostTypeSetup.Modify();
        exit(CostTypeSetup."Default G/L Account No.");
    end;

    /// <summary>Removes the default G/L account from a cost type.</summary>
    /// <param name="CostType">The cost type.</param>
    procedure ClearCostTypeGLAccount(CostType: Enum "CONS Cost Type")
    var
        CostTypeSetup: Record "CONS Cost Type Setup";
    begin
        if not CostTypeSetup.Get(CostType) then begin
            CostTypeSetup.Init();
            CostTypeSetup."Cost Type" := CostType;
            CostTypeSetup.Insert();
        end;
        CostTypeSetup."Default G/L Account No." := '';
        CostTypeSetup.Modify();
    end;

    /// <summary>Returns a new unique code for test documents and master records.</summary>
    /// <returns>A unique code.</returns>
    procedure NewCode(): Code[20]
    begin
        exit(LibraryUtility.GenerateGUID());
    end;
}
