codeunit 50503 "CONS BoQ Budget Tests"
{
    // Integration tests for the estimate->budget push (CONS BoQ Create Budget).
    // Unlike the logic unit tests, these exercise real Project (Job) Planning Line
    // creation and therefore require a database (run in the bcconstr28 container /
    // any CRONUS-based sandbox). Each test runs in its own rolled-back transaction.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "CONS Assert";
        GLAccountNo: Code[20];
        JobNo: Code[20];
        JobTaskNo: Code[20];

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateBudget_PushesPlanningLineAndAwardsBoQ()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a project, a costed cost-type-only position line on its BoQ
        Initialize();
        CreateBoQWithPositionLine(BoQHeader, BoQLine, 5, 100);

        // [WHEN] the BoQ budget is pushed to the project
        CreateBudget.CreateBudget(BoQHeader);

        // [THEN] a Budget planning line exists on the task with the line's quantity/cost
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        JobPlanningLine.SetRange("Line Type", JobPlanningLine."Line Type"::Budget);
        Assert.IsTrue(JobPlanningLine.FindFirst(), 'a Budget planning line should have been created');
        Assert.AreEqual(5, JobPlanningLine.Quantity, 'planning line quantity comes from the BoQ line');
        Assert.AreEqual(100, JobPlanningLine."Unit Cost", 'planning line unit cost comes from the BoQ line');

        // [THEN] the BoQ line records the link and the header is Awarded
        BoQLine.Get(BoQLine."Document No.", BoQLine."Line No.");
        Assert.IsTrue(BoQLine."Linked Job Planning Line No." <> 0, 'the BoQ line should record the linked planning line');
        BoQHeader.Get(BoQHeader."No.");
        Assert.AreEqual(BoQHeader.Status::Awarded.AsInteger(), BoQHeader.Status.AsInteger(), 'pushing the budget awards the BoQ');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateBudget_IsIdempotent()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a BoQ whose budget has already been pushed once
        Initialize();
        CreateBoQWithPositionLine(BoQHeader, BoQLine, 5, 100);
        CreateBudget.CreateBudget(BoQHeader);

        // [WHEN] the budget is pushed a second time
        // [THEN] nothing is created and the user is told there is nothing to push
        asserterror CreateBudget.CreateBudget(BoQHeader);
        Assert.ExpectedError('no costed position lines');

        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        JobPlanningLine.SetRange("Line Type", JobPlanningLine."Line Type"::Budget);
        Assert.AreEqual(1, JobPlanningLine.Count(), 'the second push must not create duplicate planning lines');
    end;

    local procedure Initialize()
    begin
        GLAccountNo := EnsureGLAccount();
        EnsureCostTypeSetup(GLAccountNo);
        CreateProjectWithTask();
    end;

    local procedure CreateBoQWithPositionLine(var BoQHeader: Record "CONS BoQ Header"; var BoQLine: Record "CONS BoQ Line"; Qty: Decimal; UnitCost: Decimal)
    begin
        BoQHeader.Init();
        BoQHeader."No." := 'TEST-BOQ';
        BoQHeader."Project No." := JobNo;
        BoQHeader.Insert(true);   // Trigger_OnInsert exits early because "No." is set

        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := 10000;
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Type := BoQLine.Type::" ";              // cost-type-only line -> uses default G/L account
        BoQLine."Cost Type" := BoQLine."Cost Type"::Material;
        BoQLine."Project Task No." := JobTaskNo;
        BoQLine.Quantity := Qty;
        BoQLine."Unit Cost" := UnitCost;
        BoQLine."Total Cost" := Qty * UnitCost;
        BoQLine.Insert(true);
    end;

    local procedure EnsureGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get('CONS-TEST-GL') then
            exit(GLAccount."No.");
        GLAccount.Init();
        GLAccount."No." := 'CONS-TEST-GL';
        GLAccount.Name := 'Construction Test Account';
        GLAccount."Account Type" := GLAccount."Account Type"::Posting;
        GLAccount."Direct Posting" := true;
        GLAccount.Insert(true);
        exit(GLAccount."No.");
    end;

    local procedure EnsureCostTypeSetup(GLNo: Code[20])
    var
        CostTypeSetup: Record "CONS Cost Type Setup";
    begin
        if not CostTypeSetup.Get(CostTypeSetup."Cost Type"::Material) then begin
            CostTypeSetup.Init();
            CostTypeSetup."Cost Type" := CostTypeSetup."Cost Type"::Material;
            CostTypeSetup.Insert(true);
        end;
        CostTypeSetup."Default G/L Account No." := GLNo;
        CostTypeSetup.Modify(true);
    end;

    local procedure CreateProjectWithTask()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        JobNo := 'CONS-TEST-JOB';
        if not Job.Get(JobNo) then begin
            Job.Init();
            Job."No." := JobNo;          // manual No. -> skips the JOB No. Series
            Job.Insert(true);
        end;

        JobTaskNo := '1000';
        if not JobTask.Get(JobNo, JobTaskNo) then begin
            JobTask.Init();
            JobTask."Job No." := JobNo;
            JobTask."Job Task No." := JobTaskNo;
            JobTask."Job Task Type" := JobTask."Job Task Type"::Posting;
            JobTask.Insert(true);
        end;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        // the push reports "n planning line(s) created" — confirm it actually said something
        Assert.IsTrue(Message <> '', 'budget push should report a result message');
    end;
}
