namespace Construction.Subcontracts;

using Construction.Core;
using System.Automation;

codeunit 50281 "CONS Change Order Approval"
{
    Access = Public;

    /// <summary>Returns whether an enabled approval workflow exists for sending a change order for approval.</summary>
    procedure IsWorkflowEnabled(var ChangeOrderHeader: Record "CONS Change Order Header"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(ChangeOrderHeader, ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode()));
    end;

    /// <summary>Sends the change order into its approval workflow.</summary>
    procedure SendForApproval(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
    begin
        ChangeOrderWorkflow.OnSendChangeOrderForApproval(ChangeOrderHeader);
    end;

    /// <summary>Cancels the change order's pending approval request.</summary>
    procedure CancelApprovalRequest(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
    begin
        ChangeOrderWorkflow.OnCancelChangeOrderForApproval(ChangeOrderHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', false, false)]
    local procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if RecRef.Number <> Database::"CONS Change Order Header" then
            exit;
        RecRef.SetTable(ChangeOrderHeader);
        ChangeOrderHeader.CalcFields("Total Amount");
        ApprovalEntryArgument."Table ID" := Database::"CONS Change Order Header";
        ApprovalEntryArgument."Document No." := ChangeOrderHeader."No.";
        ApprovalEntryArgument.Amount := ChangeOrderHeader."Total Amount";
        ApprovalEntryArgument."Amount (LCY)" := ChangeOrderHeader."Total Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', false, false)]
    local procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if RecRef.Number <> Database::"CONS Change Order Header" then
            exit;
        RecRef.SetTable(ChangeOrderHeader);
        ChangeOrderHeader.Validate(Status, ChangeOrderHeader.Status::"Pending Approval");
        ChangeOrderHeader.Modify(true);
        Variant := ChangeOrderHeader;
        IsHandled := true;
    end;
}
