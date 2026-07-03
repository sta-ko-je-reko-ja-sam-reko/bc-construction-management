namespace Construction.Subcontracts;

using System.Automation;

codeunit 50280 "CONS Change Order Workflow"
{
    Access = Public;

    procedure RunWorkflowOnSendForApprovalCode(): Code[128]
    begin
        exit('CONSRUNWORKFLOWONSENDCHANGEORDERFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelForApprovalCode(): Code[128]
    begin
        exit('CONSRUNWORKFLOWONCANCELCHANGEORDERAPPROVAL');
    end;

    procedure ApplyChangeOrderResponseCode(): Code[128]
    begin
        exit('CONSAPPLYCHANGEORDER');
    end;

    procedure ReopenChangeOrderResponseCode(): Code[128]
    begin
        exit('CONSREOPENCHANGEORDER');
    end;

    /// <summary>Raised when a change order is sent for approval; the workflow event subscribes to it.</summary>
    [IntegrationEvent(false, false)]
    procedure OnSendChangeOrderForApproval(var ChangeOrderHeader: Record "CONS Change Order Header")
    begin
    end;

    /// <summary>Raised when a change order approval request is cancelled; the workflow event subscribes to it.</summary>
    [IntegrationEvent(false, false)]
    procedure OnCancelChangeOrderForApproval(var ChangeOrderHeader: Record "CONS Change Order Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CONS Change Order Workflow", OnSendChangeOrderForApproval, '', false, false)]
    local procedure HandleSendForApproval(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendForApprovalCode(), ChangeOrderHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CONS Change Order Workflow", OnCancelChangeOrderForApproval, '', false, false)]
    local procedure HandleCancelForApproval(var ChangeOrderHeader: Record "CONS Change Order Header")
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelForApprovalCode(), ChangeOrderHeader);
    end;
}
