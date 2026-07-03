namespace Construction.Subcontracts;

using Construction.Core;
using System.Automation;

/// <summary>
/// Base-app subscriber proxy — hooks Microsoft publishers (Approvals Mgmt., Workflow Event/Response Handling)
/// that fire for EVERY user in the tenant. Entitled Unlicensed (via permission set "CONS Base Subs" →
/// entitlement "CONS Base Ent") so the subscription never errors for anyone. Pure proxy: each body is a guard
/// plus a one-line delegation. The guard asks the swappable access policy (resolved through the Unlicensed-
/// entitled Service Locator) whether the user has effective EXECUTE on the reaction implementation
/// "CONS Subc Wf Reactions" — a module-gated object — so a user who does not own the Subcontracts module returns
/// early and the standard approval/workflow work runs untouched. The per-feature (Enabled) tier check lives in
/// that reaction, not here. Split from the own-event proxies in "CONS Change Order Workflow" /
/// "CONS Change Order Approval" per the one-origin-per-codeunit rule.
/// </summary>
codeunit 50283 "CONS Subc Base Subscribers"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', true, true)]
    local procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().PopulateApprovalEntryArgument(RecRef, ApprovalEntryArgument, WorkflowStepInstance);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', true, true)]
    local procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().SetStatusToPendingApproval(RecRef, Variant, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', true, true)]
    local procedure AddWorkflowEventsToLibrary()
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().AddWorkflowEventsToLibrary();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventPredecessorsToLibrary, '', true, true)]
    local procedure AddWorkflowEventPredecessors(EventFunctionName: Code[128])
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().AddWorkflowEventPredecessors(EventFunctionName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowTableRelationsToLibrary, '', true, true)]
    local procedure AddWorkflowTableRelations()
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().AddWorkflowTableRelations();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnAddWorkflowResponsesToLibrary, '', true, true)]
    local procedure AddWorkflowResponsesToLibrary()
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().AddWorkflowResponsesToLibrary();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnExecuteWorkflowResponse, '', true, true)]
    local procedure ExecuteWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Subc Wf Reactions") then
            exit;
        ServiceLocator.SubcWfReactions().ExecuteWorkflowResponses(ResponseWorkflowStepInstance, ResponseExecuted, Variant, xVariant);
    end;
}
