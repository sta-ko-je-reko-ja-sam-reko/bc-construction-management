namespace Construction.Test;

using Construction.Core;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;
using System.Automation;
using System.TestLibraries.Utilities;

/// <summary>Change order approval workflow: the workflow codes, the demo workflow builder and the default workflow reactions (CONS Subc Wf Reactions).</summary>
codeunit 64032 "CONS Change Order Wf Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure WorkflowCodes_AreDistinct()
    var
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        Codes: List of [Code[128]];
    begin
        // [GIVEN]/[WHEN] the four workflow event and response codes are read
        Codes.Add(ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode());
        AddDistinct(Codes, ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode());
        AddDistinct(Codes, ChangeOrderWorkflow.ApplyChangeOrderResponseCode());
        AddDistinct(Codes, ChangeOrderWorkflow.ReopenChangeOrderResponseCode());
        // [THEN] they are four different codes
        Assert.AreEqual(4, Codes.Count(), 'workflow codes are distinct');
    end;

    [Test]
    procedure CreateApprovalWorkflow_BuildsStepsOnce()
    var
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        ChangeOrderWfDemo: Codeunit "CONS Change Order Wf Demo";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        WorkflowCode: Code[20];
    begin
        // [GIVEN] no change order approval workflow
        TestLibrary.Initialize();
        if Workflow.Get('CONSCHGAPPR') then
            Workflow.Delete(true);

        // [WHEN] the demo workflow is created twice
        WorkflowCode := ChangeOrderWfDemo.CreateChangeOrderApprovalWorkflow();
        Assert.AreEqual(WorkflowCode, ChangeOrderWfDemo.CreateChangeOrderApprovalWorkflow(), 'second call returns the same workflow');

        // [THEN] one workflow with 12 steps and a single entry point (send for approval) exists
        WorkflowStep.SetRange("Workflow Code", WorkflowCode);
        Assert.RecordCount(WorkflowStep, 12);
        WorkflowStep.SetRange("Entry Point", true);
        Assert.RecordCount(WorkflowStep, 1);
        WorkflowStep.FindFirst();
        Assert.AreEqual(ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode(), WorkflowStep."Function Name", 'entry point is the send event');
        WorkflowStep.SetRange("Entry Point");
        WorkflowStep.SetRange("Function Name", ChangeOrderWorkflow.ApplyChangeOrderResponseCode());
        Assert.RecordCount(WorkflowStep, 1);
        WorkflowStep.SetRange("Function Name", ChangeOrderWorkflow.ReopenChangeOrderResponseCode());
        Assert.RecordCount(WorkflowStep, 2);
    end;

    [Test]
    procedure IsWorkflowEnabled_NoWorkflow_IsFalse()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ChangeOrderApproval: Codeunit "CONS Change Order Approval";
    begin
        // [GIVEN] a change order and no enabled change order workflow
        TestLibrary.Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        // [WHEN]/[THEN] sending for approval is not available
        Assert.IsFalse(ChangeOrderApproval.IsWorkflowEnabled(ChangeOrderHeader), 'no workflow enabled');
    end;

    [Test]
    procedure SetStatusToPendingApproval_ChangeOrder_IsHandled()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        RecRef: RecordRef;
        Variant: Variant;
        IsHandled: Boolean;
    begin
        // [GIVEN] Subcontracts enabled and an open change order
        Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        RecRef.GetTable(ChangeOrderHeader);

        // [WHEN] the workflow sets it to pending approval
        SubcWfReactions.SetStatusToPendingApproval(RecRef, Variant, IsHandled);

        // [THEN] the change order is Pending Approval and the standard handling is skipped
        Assert.IsTrue(IsHandled, 'handled');
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::"Pending Approval", ChangeOrderHeader.Status, 'pending approval');
    end;

    [Test]
    procedure SetStatusToPendingApproval_FeatureDisabled_NotHandled()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        RecRef: RecordRef;
        Variant: Variant;
        IsHandled: Boolean;
    begin
        // [GIVEN] an open change order and Subcontracts switched off
        Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        TestLibrary.SetFeature(Enum::"CONS Feature"::Subcontracts, false);
        RecRef.GetTable(ChangeOrderHeader);

        // [WHEN] the workflow sets it to pending approval
        SubcWfReactions.SetStatusToPendingApproval(RecRef, Variant, IsHandled);

        // [THEN] a disabled feature reacts to nothing
        Assert.IsFalse(IsHandled, 'not handled');
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::Open, ChangeOrderHeader.Status, 'still open');
    end;

    [Test]
    procedure SetStatusToPendingApproval_OtherTable_NotHandled()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        RecRef: RecordRef;
        Variant: Variant;
        IsHandled: Boolean;
    begin
        // [GIVEN] Subcontracts enabled and a record of another table in the workflow
        Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        RecRef.GetTable(Job);
        // [WHEN] the workflow sets it to pending approval
        SubcWfReactions.SetStatusToPendingApproval(RecRef, Variant, IsHandled);
        // [THEN] the change order reaction leaves it to its own handler
        Assert.IsFalse(IsHandled, 'other tables are not handled');
    end;

    [Test]
    procedure PopulateApprovalEntryArgument_CarriesDocumentAndAmount()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ApprovalEntryArgument: Record "Approval Entry";
        WorkflowStepInstance: Record "Workflow Step Instance";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        RecRef: RecordRef;
    begin
        // [GIVEN] a change order of 2000 + 350
        Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        InsertLine(ChangeOrderHeader."No.", 10000, 2000);
        InsertLine(ChangeOrderHeader."No.", 20000, 350);
        RecRef.GetTable(ChangeOrderHeader);

        // [WHEN] the approval entry argument is populated
        SubcWfReactions.PopulateApprovalEntryArgument(RecRef, ApprovalEntryArgument, WorkflowStepInstance);

        // [THEN] the approver sees the change order and its value
        Assert.AreEqual(Database::"CONS Change Order Header", ApprovalEntryArgument."Table ID", 'table');
        Assert.AreEqual(ChangeOrderHeader."No.", ApprovalEntryArgument."Document No.", 'document');
        Assert.AreEqual(2350, ApprovalEntryArgument.Amount, 'amount');
        Assert.AreEqual(2350, ApprovalEntryArgument."Amount (LCY)", 'amount LCY');
    end;

    [Test]
    procedure ExecuteResponse_Reopen_SetsStatusOpen()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        WorkflowStepInstance: Record "Workflow Step Instance";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        Variant: Variant;
        ResponseExecuted: Boolean;
    begin
        // [GIVEN] a change order pending approval and a Reopen response step
        Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        ChangeOrderHeader.Status := ChangeOrderHeader.Status::"Pending Approval";
        ChangeOrderHeader.Modify();
        WorkflowStepInstance."Function Name" := ChangeOrderWorkflow.ReopenChangeOrderResponseCode();
        Variant := ChangeOrderHeader;

        // [WHEN] the response is executed (for example after a rejection)
        SubcWfReactions.ExecuteWorkflowResponses(WorkflowStepInstance, ResponseExecuted, Variant, Variant);

        // [THEN] the change order is open again
        Assert.IsTrue(ResponseExecuted, 'response executed');
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::Open, ChangeOrderHeader.Status, 'reopened');
    end;

    [Test]
    procedure ExecuteResponse_Apply_AppliesChangeOrder()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
        WorkflowStepInstance: Record "Workflow Step Instance";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        Variant: Variant;
        ResponseExecuted: Boolean;
    begin
        // [GIVEN] an approved-by-workflow owner change order of 800 on a project worth 10000
        Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        Job."CONS Contract Value" := 10000;
        Job.Modify();
        CreateChangeOrder(ChangeOrderHeader, Job."No.");
        InsertLine(ChangeOrderHeader."No.", 10000, 800);
        WorkflowStepInstance."Function Name" := ChangeOrderWorkflow.ApplyChangeOrderResponseCode();
        Variant := ChangeOrderHeader;

        // [WHEN] the Apply response is executed
        SubcWfReactions.ExecuteWorkflowResponses(WorkflowStepInstance, ResponseExecuted, Variant, Variant);

        // [THEN] the change order is applied to the contract value and approved
        Assert.IsTrue(ResponseExecuted, 'response executed');
        Job.Get(Job."No.");
        Assert.AreEqual(10800, Job."CONS Contract Value", 'contract value raised');
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::Approved, ChangeOrderHeader.Status, 'approved');
    end;

    [Test]
    procedure ExecuteResponse_AlreadyExecuted_DoesNothing()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        WorkflowStepInstance: Record "Workflow Step Instance";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
        Variant: Variant;
        ResponseExecuted: Boolean;
    begin
        // [GIVEN] a pending change order and a response another subscriber already executed
        Initialize();
        CreateChangeOrder(ChangeOrderHeader, '');
        ChangeOrderHeader.Status := ChangeOrderHeader.Status::"Pending Approval";
        ChangeOrderHeader.Modify();
        WorkflowStepInstance."Function Name" := ChangeOrderWorkflow.ReopenChangeOrderResponseCode();
        Variant := ChangeOrderHeader;
        ResponseExecuted := true;

        // [WHEN] the reaction runs
        SubcWfReactions.ExecuteWorkflowResponses(WorkflowStepInstance, ResponseExecuted, Variant, Variant);

        // [THEN] it does not execute the response a second time
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::"Pending Approval", ChangeOrderHeader.Status, 'unchanged');
    end;

    [Test]
    procedure AddToLibrary_RegistersEventsAndResponses()
    var
        WorkflowEvent: Record "Workflow Event";
        WorkflowResponse: Record "Workflow Response";
        ChangeOrderWorkflow: Codeunit "CONS Change Order Workflow";
        SubcWfReactions: Codeunit "CONS Subc Wf Reactions";
    begin
        // [GIVEN] Subcontracts enabled
        Initialize();
        // [WHEN] the workflow library asks for the construction events and responses
        SubcWfReactions.AddWorkflowEventsToLibrary();
        SubcWfReactions.AddWorkflowResponsesToLibrary();
        // [THEN] the send/cancel events and the apply/reopen responses are available to workflow designers
        Assert.IsTrue(WorkflowEvent.Get(ChangeOrderWorkflow.RunWorkflowOnSendForApprovalCode()), 'send event registered');
        Assert.IsTrue(WorkflowEvent.Get(ChangeOrderWorkflow.RunWorkflowOnCancelForApprovalCode()), 'cancel event registered');
        Assert.IsTrue(WorkflowResponse.Get(ChangeOrderWorkflow.ApplyChangeOrderResponseCode()), 'apply response registered');
        Assert.IsTrue(WorkflowResponse.Get(ChangeOrderWorkflow.ReopenChangeOrderResponseCode()), 'reopen response registered');
    end;

    local procedure Initialize()
    begin
        TestLibrary.Initialize();
        TestLibrary.SetFeature(Enum::"CONS Feature"::Subcontracts, true);
    end;

    local procedure CreateChangeOrder(var ChangeOrderHeader: Record "CONS Change Order Header"; ProjectNo: Code[20])
    begin
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := TestLibrary.NewCode();
        ChangeOrderHeader."Project No." := ProjectNo;
        ChangeOrderHeader."Change Type" := ChangeOrderHeader."Change Type"::Owner;
        ChangeOrderHeader.Insert(true);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; Amount: Decimal)
    var
        ChangeOrderLine: Record "CONS Change Order Line";
    begin
        ChangeOrderLine.Init();
        ChangeOrderLine."Document No." := DocumentNo;
        ChangeOrderLine."Line No." := LineNo;
        ChangeOrderLine.Amount := Amount;
        ChangeOrderLine.Insert(true);
    end;

    local procedure AddDistinct(var Codes: List of [Code[128]]; NewCode: Code[128])
    begin
        if not Codes.Contains(NewCode) then
            Codes.Add(NewCode);
    end;
}
