namespace Construction.Estimating;

using Construction.Core;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Projects.Project.Planning;

codeunit 50057 "CONS BoQ Create Budget"
{
    TableNo = "CONS BoQ Header";

    trigger OnRun()
    begin
        CreateBudget(Rec);
    end;

    /// <summary>
    /// Generates Project (Job) Planning Lines of type Budget from a Bill of Quantities'
    /// Position lines, onto the linked project's tasks. Idempotent: lines already pushed
    /// (Linked Project Planning Line No. &lt;&gt; 0) are skipped. Sets the BoQ to Awarded.
    /// </summary>
    /// <param name="BoQHeader">The Bill of Quantities whose position lines are pushed to the project budget.</param>
    internal procedure CreateBudget(var BoQHeader: Record "CONS BoQ Header")
    var
        BoQLine: Record "CONS BoQ Line";
        LicenseMgt: Codeunit "CONS License Mgt.";
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Estimating);
        BoQHeader.TestField("Project No.");

        BoQLine.SetRange("Document No.", BoQHeader."No.");
        BoQLine.SetRange("Line Type", BoQLine."Line Type"::Position);
        BoQLine.SetRange("Linked Job Planning Line No.", 0);
        if BoQLine.FindSet() then
            repeat
                if BoQLine.Quantity <> 0 then begin
                    CreatePlanningLine(BoQHeader, BoQLine);
                    Created += 1;
                end;
            until BoQLine.Next() = 0;

        if Created = 0 then
            Error(NothingToPushErr);

        BoQHeader.Validate(Status, BoQHeader.Status::Awarded);
        BoQHeader.Modify(true);
        Message(BudgetCreatedMsg, Created, BoQHeader."Project No.");
    end;

    local procedure CreatePlanningLine(BoQHeader: Record "CONS BoQ Header"; var BoQLine: Record "CONS BoQ Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        CostTypeSetup: Record "CONS Cost Type Setup";
    begin
        BoQLine.TestField("Project Task No.");

        JobPlanningLine.Init();
        JobPlanningLine.Validate("Job No.", BoQHeader."Project No.");
        JobPlanningLine.Validate("Job Task No.", BoQLine."Project Task No.");
        JobPlanningLine."Line No." := NextPlanningLineNo(BoQHeader."Project No.", BoQLine."Project Task No.");
        JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::Budget);
        JobPlanningLine.Validate("Planning Date", PlanningDate(BoQHeader));

        case BoQLine.Type of
            BoQLine.Type::Resource:
                begin
                    JobPlanningLine.Validate(Type, JobPlanningLine.Type::Resource);
                    JobPlanningLine.Validate("No.", BoQLine."No.");
                end;
            BoQLine.Type::Item:
                begin
                    JobPlanningLine.Validate(Type, JobPlanningLine.Type::Item);
                    JobPlanningLine.Validate("No.", BoQLine."No.");
                end;
            BoQLine.Type::"G/L Account":
                begin
                    JobPlanningLine.Validate(Type, JobPlanningLine.Type::"G/L Account");
                    JobPlanningLine.Validate("No.", BoQLine."No.");
                end;
            BoQLine.Type::" ":
                begin
                    CostTypeSetup.Get(BoQLine."Cost Type");
                    CostTypeSetup.TestField("Default G/L Account No.");
                    JobPlanningLine.Validate(Type, JobPlanningLine.Type::"G/L Account");
                    JobPlanningLine.Validate("No.", CostTypeSetup."Default G/L Account No.");
                end;
        end;

        if BoQLine."Unit of Measure Code" <> '' then
            JobPlanningLine.Validate("Unit of Measure Code", BoQLine."Unit of Measure Code");
        JobPlanningLine.Validate(Quantity, BoQLine.Quantity);
        JobPlanningLine.Validate("Unit Cost", BoQLine."Unit Cost");
        JobPlanningLine.Validate("Unit Price", BoQLine."Unit Price");
        if BoQLine.Description <> '' then
            JobPlanningLine.Description := CopyStr(BoQLine.Description, 1, MaxStrLen(JobPlanningLine.Description));
        JobPlanningLine.Insert(true);

        BoQLine."Linked Job Planning Line No." := JobPlanningLine."Line No.";
        BoQLine.Modify();
    end;

    local procedure NextPlanningLineNo(JobNo: Code[20]; JobTaskNo: Code[20]): Integer
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        if JobPlanningLine.FindLast() then
            exit(JobPlanningLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure PlanningDate(BoQHeader: Record "CONS BoQ Header"): Date
    begin
        if BoQHeader."Starting Date" <> 0D then
            exit(BoQHeader."Starting Date");
        exit(WorkDate());
    end;

    var
        NothingToPushErr: Label 'There are no costed position lines to push to the project budget (or they were already pushed).';
        BudgetCreatedMsg: Label '%1 project planning line(s) were created on project %2.', Comment = '%1 = count, %2 = project no.';
}
