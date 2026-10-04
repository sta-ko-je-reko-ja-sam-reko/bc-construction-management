namespace Construction.ProgressBilling;

using Construction.Core;
using Microsoft.Projects.Project.Planning;

codeunit 60158 "CONS Prog. Billing Seed"
{
    Access = Public;

    /// <summary>
    /// Seeds schedule-of-values lines on the application from the project's billable planning
    /// lines. Idempotent: a planning line already represented (by Job Planning Line No.) is skipped.
    /// </summary>
    /// <param name="ProgBillingHeader">The application to seed schedule-of-values lines onto.</param>
    internal procedure SeedFromProject(var ProgBillingHeader: Record "CONS Progress Billing Header")
    var
        JobPlanningLine: Record "Job Planning Line";
        ProgBillingLine: Record "CONS Progress Billing Line";
        LicenseMgt: Codeunit "CONS License Mgt.";
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
        ProgBillingHeader.TestField("Project No.");

        JobPlanningLine.SetRange("Job No.", ProgBillingHeader."Project No.");
        JobPlanningLine.SetFilter("Line Type", '%1|%2',
            JobPlanningLine."Line Type"::Billable, JobPlanningLine."Line Type"::"Both Budget and Billable");
        if JobPlanningLine.FindSet() then
            repeat
                if not LineExists(ProgBillingHeader."No.", JobPlanningLine."Line No.") then begin
                    InsertLine(ProgBillingHeader, ProgBillingLine, JobPlanningLine);
                    Created += 1;
                end;
            until JobPlanningLine.Next() = 0;

        if Created = 0 then
            Message(NothingToSeedMsg)
        else
            Message(SeededMsg, Created);
    end;

    local procedure LineExists(DocumentNo: Code[20]; JobPlanningLineNo: Integer): Boolean
    var
        ProgBillingLine: Record "CONS Progress Billing Line";
    begin
        ProgBillingLine.SetRange("Document No.", DocumentNo);
        ProgBillingLine.SetRange("Job Planning Line No.", JobPlanningLineNo);
        exit(not ProgBillingLine.IsEmpty());
    end;

    local procedure InsertLine(ProgBillingHeader: Record "CONS Progress Billing Header"; var ProgBillingLine: Record "CONS Progress Billing Line"; JobPlanningLine: Record "Job Planning Line")
    begin
        ProgBillingLine.Init();
        ProgBillingLine."Document No." := ProgBillingHeader."No.";
        ProgBillingLine."Line No." := NextLineNo(ProgBillingHeader."No.");
        ProgBillingLine."Job Task No." := JobPlanningLine."Job Task No.";
        ProgBillingLine."Job Planning Line No." := JobPlanningLine."Line No.";
        ProgBillingLine.Description := JobPlanningLine.Description;
        ProgBillingLine."Retention %" := ProgBillingHeader."Retention %";
        ProgBillingLine.Validate("Scheduled Value", JobPlanningLine."Line Amount");
        ProgBillingLine.Validate("Previous Amount", PreviousCompletedToDate(ProgBillingHeader, JobPlanningLine."Line No."));
        ProgBillingLine.Insert(true);
    end;

    /// <summary>
    /// Returns the value completed to date on the same planning line in the latest earlier application of the project that
    /// has been certified or invoiced (draft applications do not count). That cumulative value is this application's
    /// "previous" amount, so each application only bills the work done since the last certified one.
    /// </summary>
    local procedure PreviousCompletedToDate(ProgBillingHeader: Record "CONS Progress Billing Header"; JobPlanningLineNo: Integer): Decimal
    var
        PriorHeader: Record "CONS Progress Billing Header";
        PriorLine: Record "CONS Progress Billing Line";
    begin
        if ProgBillingHeader."Application No." <= 1 then
            exit(0);
        PriorHeader.SetCurrentKey("Project No.", "Application No.");
        PriorHeader.SetRange("Project No.", ProgBillingHeader."Project No.");
        PriorHeader.SetRange("Application No.", 1, ProgBillingHeader."Application No." - 1);
        PriorHeader.SetFilter(Status, '<>%1', PriorHeader.Status::Open);
        PriorHeader.SetFilter("No.", '<>%1', ProgBillingHeader."No.");
        PriorHeader.Ascending(false);
        if PriorHeader.FindSet() then
            repeat
                PriorLine.SetRange("Document No.", PriorHeader."No.");
                PriorLine.SetRange("Job Planning Line No.", JobPlanningLineNo);
                if PriorLine.FindFirst() then
                    exit(PriorLine."Completed To Date");
            until PriorHeader.Next() = 0;
        exit(0);
    end;

    local procedure NextLineNo(DocumentNo: Code[20]): Integer
    var
        ProgBillingLine: Record "CONS Progress Billing Line";
    begin
        ProgBillingLine.SetRange("Document No.", DocumentNo);
        if ProgBillingLine.FindLast() then
            exit(ProgBillingLine."Line No." + 10000);
        exit(10000);
    end;

    var
        SeededMsg: Label '%1 schedule-of-values line(s) were created.', Comment = '%1 = count';
        NothingToSeedMsg: Label 'There are no billable planning lines to seed (or they are already on this application).';
}
