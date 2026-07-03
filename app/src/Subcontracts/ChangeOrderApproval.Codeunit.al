namespace Construction.Subcontracts;

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
}
