namespace Construction.ProgressBilling;

using Construction.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;

codeunit 50154 "CONS Prog. Bill Header Logic" implements "CONS IProgBillingHeader"
{
    Access = Public;

    procedure Trigger_OnInsert(var ProgBillingHeader: Record "CONS Progress Billing Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if ProgBillingHeader."No." = '' then begin
            ConstructionSetup.Get();
            ConstructionSetup.TestField("Progress Billing Nos.");
            ProgBillingHeader."No. Series" := ConstructionSetup."Progress Billing Nos.";
            ProgBillingHeader."No." := NoSeries.GetNextNo(ProgBillingHeader."No. Series");
        end;
        if (ProgBillingHeader."Application No." = 0) and (ProgBillingHeader."Project No." <> '') then
            ProgBillingHeader."Application No." := NextApplicationNo(ProgBillingHeader."Project No.");
    end;

    procedure Trigger_OnDelete(var ProgBillingHeader: Record "CONS Progress Billing Header")
    var
        ProgBillingLine: Record "CONS Progress Billing Line";
    begin
        ProgBillingLine.SetRange("Document No.", ProgBillingHeader."No.");
        ProgBillingLine.DeleteAll(true);
    end;

    procedure Validate_ProjectNo(var ProgBillingHeader: Record "CONS Progress Billing Header"; xProgBillingHeader: Record "CONS Progress Billing Header")
    var
        Job: Record Job;
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        if ProgBillingHeader."Project No." = xProgBillingHeader."Project No." then
            exit;
        if ProgBillingHeader."Project No." = '' then
            exit;
        if Job.Get(ProgBillingHeader."Project No.") then
            ProgBillingHeader."Bill-to Customer No." := Job."Bill-to Customer No.";
        if (ProgBillingHeader."Retention %" = 0) and ConstructionSetup.Get() then
            ProgBillingHeader."Retention %" := ConstructionSetup."Default Retention %";
    end;

    local procedure NextApplicationNo(ProjectNo: Code[20]): Integer
    var
        ProgBillingHeader: Record "CONS Progress Billing Header";
    begin
        ProgBillingHeader.SetCurrentKey("Project No.", "Application No.");
        ProgBillingHeader.SetRange("Project No.", ProjectNo);
        if ProgBillingHeader.FindLast() then
            exit(ProgBillingHeader."Application No." + 1);
        exit(1);
    end;
}
