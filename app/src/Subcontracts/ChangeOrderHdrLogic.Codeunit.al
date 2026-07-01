namespace Construction.Subcontracts;

using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;

codeunit 50275 "CONS Change Order Hdr Logic" implements "CONS IChangeOrderHeader"
{
    Access = Public;

    procedure Trigger_OnInsert(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if ChangeOrderHeader."No." <> '' then
            exit;
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Change Order Nos.");
        ChangeOrderHeader."No. Series" := ConstructionSetup."Change Order Nos.";
        ChangeOrderHeader."No." := NoSeries.GetNextNo(ChangeOrderHeader."No. Series");
    end;

    procedure Trigger_OnDelete(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ChangeOrderLine: Record "CONS Change Order Line";
    begin
        ChangeOrderLine.SetRange("Document No.", ChangeOrderHeader."No.");
        ChangeOrderLine.DeleteAll(true);
    end;

    procedure Apply(var ChangeOrderHeader: Record "CONS Change Order Header")
    begin
        ChangeOrderHeader.TestField("Project No.");
        if ChangeOrderHeader.Status = ChangeOrderHeader.Status::Approved then
            Error(AlreadyAppliedErr);

        case ChangeOrderHeader."Change Type" of
            ChangeOrderHeader."Change Type"::Owner:
                ApplyToContractValue(ChangeOrderHeader);
            ChangeOrderHeader."Change Type"::Subcontract:
                ApplyToSubcontract(ChangeOrderHeader);
        end;

        PushToBudget(ChangeOrderHeader);

        ChangeOrderHeader.Status := ChangeOrderHeader.Status::Approved;
        ChangeOrderHeader.Modify(true);
    end;

    local procedure ApplyToContractValue(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        Job: Record Job;
    begin
        ChangeOrderHeader.CalcFields("Total Amount");
        Job.SetLoadFields("CONS Contract Value");
        Job.Get(ChangeOrderHeader."Project No.");
        Job."CONS Contract Value" += ChangeOrderHeader."Total Amount";
        Job.Modify(true);
    end;

    local procedure ApplyToSubcontract(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ChangeOrderLine: Record "CONS Change Order Line";
        SubcontractHeader: Record "CONS Subcontract Header";
    begin
        ChangeOrderHeader.TestField("Subcontract No.");
        SubcontractHeader.Get(ChangeOrderHeader."Subcontract No.");
        ChangeOrderLine.SetRange("Document No.", ChangeOrderHeader."No.");
        if ChangeOrderLine.FindSet() then
            repeat
                AddSubcontractVariationLine(SubcontractHeader, ChangeOrderLine);
            until ChangeOrderLine.Next() = 0;
    end;

    local procedure AddSubcontractVariationLine(SubcontractHeader: Record "CONS Subcontract Header"; ChangeOrderLine: Record "CONS Change Order Line")
    var
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        SubcontractLine.Init();
        SubcontractLine."Document No." := SubcontractHeader."No.";
        SubcontractLine."Line No." := NextSubcontractLineNo(SubcontractHeader."No.");
        SubcontractLine."Job Task No." := ChangeOrderLine."Job Task No.";
        SubcontractLine.Description := ChangeOrderLine.Description;
        SubcontractLine."Cost Type" := ChangeOrderLine."Cost Type";
        SubcontractLine.Quantity := 1;
        SubcontractLine.Validate("Unit Cost", ChangeOrderLine.Amount);
        SubcontractLine.Insert(true);
    end;

    local procedure NextSubcontractLineNo(SubcontractNo: Code[20]): Integer
    var
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        SubcontractLine.SetRange("Document No.", SubcontractNo);
        if SubcontractLine.FindLast() then
            exit(SubcontractLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure PushToBudget(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ChangeOrderLine: Record "CONS Change Order Line";
        CostTypeSetup: Record "CONS Cost Type Setup";
        JobPlanningLine: Record "Job Planning Line";
    begin
        ChangeOrderLine.SetRange("Document No.", ChangeOrderHeader."No.");
        ChangeOrderLine.SetFilter("Job Task No.", '<>%1', '');
        if not ChangeOrderLine.FindSet() then
            exit;
        repeat
            if (ChangeOrderLine.Amount <> 0) and CostTypeSetup.Get(ChangeOrderLine."Cost Type") and (CostTypeSetup."Default G/L Account No." <> '') then
                CreateBudgetLine(ChangeOrderHeader."Project No.", ChangeOrderLine, CostTypeSetup."Default G/L Account No.", JobPlanningLine);
        until ChangeOrderLine.Next() = 0;
    end;

    local procedure CreateBudgetLine(ProjectNo: Code[20]; ChangeOrderLine: Record "CONS Change Order Line"; GLAccountNo: Code[20]; var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.Init();
        JobPlanningLine.Validate("Job No.", ProjectNo);
        JobPlanningLine.Validate("Job Task No.", ChangeOrderLine."Job Task No.");
        JobPlanningLine."Line No." := NextPlanningLineNo(ProjectNo, ChangeOrderLine."Job Task No.");
        JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::Budget);
        JobPlanningLine.Validate("Planning Date", WorkDate());
        JobPlanningLine.Validate(Type, JobPlanningLine.Type::"G/L Account");
        JobPlanningLine.Validate("No.", GLAccountNo);
        JobPlanningLine.Validate(Quantity, 1);
        JobPlanningLine.Validate("Unit Cost", ChangeOrderLine.Amount);
        if ChangeOrderLine.Description <> '' then
            JobPlanningLine.Description := CopyStr(ChangeOrderLine.Description, 1, MaxStrLen(JobPlanningLine.Description));
        JobPlanningLine.Insert(true);
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

    var
        AlreadyAppliedErr: Label 'This change order has already been applied.';
}
