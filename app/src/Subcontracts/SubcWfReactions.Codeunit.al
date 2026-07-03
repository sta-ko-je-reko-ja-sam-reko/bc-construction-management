namespace Construction.Subcontracts;

using Construction.Core;
using System.Automation;

/// <summary>
/// Default implementation of <c>CONS ISubc Wf Reactions</c> — the change-order approval &amp; workflow behaviour
/// that the base-app subscriber proxy (<c>CONS Subc Base Subscribers</c>) forwards to through the Service Locator.
/// This is where the actual work lives (per the polymorphic-table-logic pattern), so the proxy stays a pure
/// guard-plus-delegation. Each method's first line is the <c>Feature Mgt.IsEnabled</c> guard, so a disabled
/// Subcontracts feature reacts to nothing.
/// </summary>
codeunit 50284 "CONS Subc Wf Reactions" implements "CONS ISubc Wf Reactions"
{
    Access = Public;

    procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
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

    procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
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

    procedure AddWorkflowEventsToLibrary()
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        WorkflowEventHandling.AddEventToLibrary(ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode(), Database::"CONS Change Order Header", SendEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode(), Database::"CONS Change Order Header", CancelEventDescTxt, 0, false);
    end;

    procedure AddWorkflowEventPredecessors(EventFunctionName: Code[128])
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if EventFunctionName = ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode() then
            WorkflowEventHandling.AddEventPredecessor(ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode(), ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode());
    end;

    procedure AddWorkflowTableRelations()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ApprovalEntry: Record "Approval Entry";
        WorkflowSetup: Codeunit "Workflow Setup";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        WorkflowSetup.InsertTableRelation(Database::"CONS Change Order Header", ChangeOrderHeader.FieldNo("No."), Database::"Approval Entry", ApprovalEntry.FieldNo("Document No."));
    end;

    procedure AddWorkflowResponsesToLibrary()
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        WorkflowResponseHandling.AddResponseToLibrary(ChangeOrderWorkflow.ApplyChangeOrderResponseCode(), Database::"CONS Change Order Header", ApplyResponseDescTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(ChangeOrderWorkflow.ReopenChangeOrderResponseCode(), Database::"CONS Change Order Header", ReopenResponseDescTxt, 'GROUP 0');
    end;

    procedure ExecuteWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if ResponseExecuted then
            exit;
        case ResponseWorkflowStepInstance."Function Name" of
            ChangeOrderWorkflow.ApplyChangeOrderResponseCode():
                begin
                    ChangeOrderHeader := Variant;
                    ChangeOrderHeader.Apply();
                    ResponseExecuted := true;
                end;
            ChangeOrderWorkflow.ReopenChangeOrderResponseCode():
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
