namespace Construction.Subcontracts;

using System.Automation;

/// <summary>
/// Reaction seam for the change-order approval &amp; workflow behaviour that the base-app subscriber proxy
/// (<c>CONS Subc Base Subscribers</c>) forwards to. Resolved through <c>CONS Service Locator</c> so the
/// implementation is swappable in tests / dependent apps, and so the proxy stays a pure guard-plus-one-line
/// delegation. The default implementation is <c>CONS Subc Wf Reactions</c>; each of its methods guards on the
/// Subcontracts feature being enabled before doing any work.
/// </summary>
interface "CONS ISubc Wf Reactions"
{
    /// <summary>Populates the approval entry argument for a change-order document sent for approval.</summary>
    procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance");

    /// <summary>Sets a change order to Pending Approval when approval is requested.</summary>
    procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean);

    /// <summary>Registers the change-order workflow events in the workflow event library.</summary>
    procedure AddWorkflowEventsToLibrary();

    /// <summary>Registers the predecessor relationships between the change-order workflow events.</summary>
    procedure AddWorkflowEventPredecessors(EventFunctionName: Code[128]);

    /// <summary>Registers the change-order table relation used by the workflow engine.</summary>
    procedure AddWorkflowTableRelations();

    /// <summary>Registers the change-order workflow responses (apply / reopen) in the response library.</summary>
    procedure AddWorkflowResponsesToLibrary();

    /// <summary>Executes a change-order workflow response (apply / reopen) when the engine reaches it.</summary>
    procedure ExecuteWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant);
}
