namespace Construction.Subcontracts;

using Construction.Core;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendForApprovalCode(), Database::"CONS Change Order Header", SendEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelForApprovalCode(), Database::"CONS Change Order Header", CancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventPredecessorsToLibrary, '', false, false)]
    local procedure AddWorkflowEventPredecessors(EventFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        if EventFunctionName = RunWorkflowOnCancelForApprovalCode() then
            WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelForApprovalCode(), RunWorkflowOnSendForApprovalCode());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowTableRelationsToLibrary, '', false, false)]
    local procedure AddWorkflowTableRelations()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ApprovalEntry: Record "Approval Entry";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(Database::"CONS Change Order Header", ChangeOrderHeader.FieldNo("No."), Database::"Approval Entry", ApprovalEntry.FieldNo("Document No."));
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnAddWorkflowResponsesToLibrary, '', false, false)]
    local procedure AddWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(ApplyChangeOrderResponseCode(), Database::"CONS Change Order Header", ApplyResponseDescTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(ReopenChangeOrderResponseCode(), Database::"CONS Change Order Header", ReopenResponseDescTxt, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnExecuteWorkflowResponse, '', false, false)]
    local procedure ExecuteWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if ResponseExecuted then
            exit;
        case ResponseWorkflowStepInstance."Function Name" of
            ApplyChangeOrderResponseCode():
                begin
                    ChangeOrderHeader := Variant;
                    ChangeOrderHeader.Apply();
                    ResponseExecuted := true;
                end;
            ReopenChangeOrderResponseCode():
                begin
                    ChangeOrderHeader := Variant;
                    ChangeOrderHeader.Validate(Status, ChangeOrderHeader.Status::Open);
                    ChangeOrderHeader.Modify(true);
                    ResponseExecuted := true;
                end;
        end;
    end;

    var
        SendEventDescTxt: Label 'Approval of a change order is requested.';
        CancelEventDescTxt: Label 'A change order approval request is cancelled.';
        ApplyResponseDescTxt: Label 'Apply (release) the change order.';
        ReopenResponseDescTxt: Label 'Reopen the change order.';
}
