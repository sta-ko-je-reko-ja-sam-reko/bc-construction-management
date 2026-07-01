namespace Construction.Subcontracts;

using System.Automation;

codeunit 50282 "CONS Change Order Wf Demo"
{
    // Demo-data: builds a ready-to-use change-order approval workflow (send -> pending -> create &
    // send requests; approved -> release/apply; rejected/cancelled -> reopen). Not called anywhere
    // yet — the product's assisted setup will offer to run this and enable the workflow.
    Access = Public;

    /// <summary>Creates the demo change-order approval workflow (disabled; the caller enables it).</summary>
    /// <returns>The code of the created (or existing) workflow.</returns>
    procedure CreateChangeOrderApprovalWorkflow(): Code[20]
    var
        Workflow: Record Workflow;
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        SendStep: Integer;
        PendingStep: Integer;
        CreateReqStep: Integer;
        SendReqStep: Integer;
        ApproveStep: Integer;
        RejectStep: Integer;
        RejectReopenStep: Integer;
        CancelStep: Integer;
        CancelReopenStep: Integer;
    begin
        if Workflow.Get(WorkflowCodeTok) then
            exit(Workflow.Code);

        Workflow.Init();
        Workflow.Code := WorkflowCodeTok;
        Workflow.Description := WorkflowDescTxt;
        Workflow.Insert(true);

        SendStep := InsertEventStep(Workflow, ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode(), 0);
        PendingStep := InsertResponseStep(Workflow, WorkflowResponseHandling.SetStatusToPendingApprovalCode(), SendStep);
        CreateReqStep := InsertResponseStep(Workflow, WorkflowResponseHandling.CreateApprovalRequestsCode(), PendingStep);
        SendReqStep := InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode(), CreateReqStep);

        ApproveStep := InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(), SendReqStep);
        InsertResponseStep(Workflow, ChangeOrderWorkflow.ApplyChangeOrderResponseCode(), ApproveStep);

        RejectStep := InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(), SendReqStep);
        RejectReopenStep := InsertResponseStep(Workflow, WorkflowResponseHandling.RejectAllApprovalRequestsCode(), RejectStep);
        InsertResponseStep(Workflow, ChangeOrderWorkflow.ReopenChangeOrderResponseCode(), RejectReopenStep);

        CancelStep := InsertEventStep(Workflow, ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode(), SendReqStep);
        CancelReopenStep := InsertResponseStep(Workflow, WorkflowResponseHandling.CancelAllApprovalRequestsCode(), CancelStep);
        InsertResponseStep(Workflow, ChangeOrderWorkflow.ReopenChangeOrderResponseCode(), CancelReopenStep);

        exit(Workflow.Code);
    end;

    local procedure InsertEventStep(var Workflow: Record Workflow; FunctionName: Code[128]; PreviousStepID: Integer): Integer
    begin
        exit(InsertStep(Workflow, true, FunctionName, PreviousStepID));
    end;

    local procedure InsertResponseStep(var Workflow: Record Workflow; FunctionName: Code[128]; PreviousStepID: Integer): Integer
    begin
        exit(InsertStep(Workflow, false, FunctionName, PreviousStepID));
    end;

    local procedure InsertStep(var Workflow: Record Workflow; IsEvent: Boolean; FunctionName: Code[128]; PreviousStepID: Integer): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.Init();
        WorkflowStep."Workflow Code" := Workflow.Code;
        WorkflowStep.ID := NextStepID(Workflow.Code);
        WorkflowStep."Previous Workflow Step ID" := PreviousStepID;
        WorkflowStep."Entry Point" := PreviousStepID = 0;
        if IsEvent then
            WorkflowStep.Type := WorkflowStep.Type::"Event"
        else
            WorkflowStep.Type := WorkflowStep.Type::Response;
        WorkflowStep."Function Name" := FunctionName;
        WorkflowStep.Insert(true);
        exit(WorkflowStep.ID);
    end;

    local procedure NextStepID(WorkflowCode: Code[20]): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.SetRange("Workflow Code", WorkflowCode);
        if WorkflowStep.FindLast() then
            exit(WorkflowStep.ID + 1);
        exit(1);
    end;

    var
        WorkflowCodeTok: Label 'CONSCHGAPPR', Locked = true;
        WorkflowDescTxt: Label 'Construction change order approval';
}
