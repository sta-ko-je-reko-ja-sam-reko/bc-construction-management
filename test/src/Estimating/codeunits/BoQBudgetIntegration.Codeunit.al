namespace Construction.Test;

using Construction.Estimating;
using Construction.Setup;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Resources.Resource;
using System.TestLibraries.Utilities;

/// <summary>
/// Integration tests for the estimate-to-budget push (CONS BoQ Create Budget): real Project (Job) Planning Lines
/// are created on a project created with the Microsoft Library - Job.
/// </summary>
codeunit 64003 "CONS BoQ Budget Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryResource: Codeunit "Library - Resource";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    [HandlerFunctions('BudgetMessageHandler')]
    procedure CreateBudget_PushesPlanningLineAndAwardsBoQ()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
        GLAccountNo: Code[20];
    begin
        // [GIVEN] a project task and a costed, cost-type-only position line (5 x 100, markup 20%) on its BoQ
        Initialize(Job, JobTask);
        GLAccountNo := TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 5, 100, 20);

        // [WHEN] the BoQ budget is pushed to the project
        CreateBudget.CreateBudget(BoQHeader);

        // [THEN] one Budget planning line on the task posts to the cost type's G/L account at the BoQ cost and price
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange("Job Task No.", JobTask."Job Task No.");
        Assert.RecordCount(JobPlanningLine, 1);
        JobPlanningLine.FindFirst();
        Assert.AreEqual(JobPlanningLine."Line Type"::Budget, JobPlanningLine."Line Type", 'line type');
        Assert.AreEqual(JobPlanningLine.Type::"G/L Account", JobPlanningLine.Type, 'type');
        Assert.AreEqual(GLAccountNo, JobPlanningLine."No.", 'cost type default G/L account');
        Assert.AreEqual(5, JobPlanningLine.Quantity, 'quantity');
        Assert.AreEqual(100, JobPlanningLine."Unit Cost", 'unit cost');
        Assert.AreEqual(120, JobPlanningLine."Unit Price", 'unit price carries the markup');
        Assert.AreEqual(500, JobPlanningLine."Total Cost", 'total cost');

        // [THEN] the BoQ line records the link, the header is Awarded and the user is told how many lines were created
        BoQLine.Get(BoQLine."Document No.", BoQLine."Line No.");
        Assert.AreEqual(JobPlanningLine."Line No.", BoQLine."Linked Job Planning Line No.", 'link recorded');
        BoQHeader.Get(BoQHeader."No.");
        Assert.AreEqual(BoQHeader.Status::Awarded, BoQHeader.Status, 'pushing the budget awards the BoQ');
        Assert.ExpectedMessage('1 project planning line(s)', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('BudgetMessageHandler')]
    procedure CreateBudget_IsIdempotent()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a BoQ whose budget has already been pushed once
        Initialize(Job, JobTask);
        TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 5, 100, 0);
        CreateBudget.CreateBudget(BoQHeader);

        // [WHEN] the budget is pushed a second time
        // [THEN] nothing is created and the user is told there is nothing to push
        asserterror CreateBudget.CreateBudget(BoQHeader);
        Assert.ExpectedError('no costed position lines');

        JobPlanningLine.SetRange("Job No.", Job."No.");
        Assert.RecordCount(JobPlanningLine, 1);
    end;

    [Test]
    [HandlerFunctions('BudgetMessageHandler')]
    procedure CreateBudget_ResourceLine_PlansTheResource()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Resource: Record Resource;
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a BoQ position line for a resource (8 hours at 45)
        Initialize(Job, JobTask);
        LibraryResource.CreateResourceNew(Resource);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 8, 45, 0);
        BoQLine.Type := BoQLine.Type::Resource;
        BoQLine."No." := Resource."No.";
        BoQLine."Unit of Measure Code" := Resource."Base Unit of Measure";
        BoQLine.Modify();

        // [WHEN] the budget is pushed
        CreateBudget.CreateBudget(BoQHeader);

        // [THEN] the planning line plans that resource at the estimated quantity and cost
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.FindFirst();
        Assert.AreEqual(JobPlanningLine.Type::Resource, JobPlanningLine.Type, 'type');
        Assert.AreEqual(Resource."No.", JobPlanningLine."No.", 'resource');
        Assert.AreEqual(8, JobPlanningLine.Quantity, 'quantity');
        Assert.AreEqual(45, JobPlanningLine."Unit Cost", 'estimated unit cost wins over the resource card');
    end;

    [Test]
    [HandlerFunctions('BudgetMessageHandler')]
    procedure CreateBudget_SkipsHeadingsAndZeroQuantity_NumbersLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] two costed position lines, one zero-quantity position line and a heading
        Initialize(Job, JobTask);
        TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 1, 10, 0);
        CreatePositionLine(BoQLine, BoQHeader, 20000, JobTask."Job Task No.", 0, 10, 0);
        CreatePositionLine(BoQLine, BoQHeader, 30000, JobTask."Job Task No.", 2, 10, 0);
        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := 40000;
        BoQLine."Line Type" := BoQLine."Line Type"::Heading;
        BoQLine."Project Task No." := JobTask."Job Task No.";
        BoQLine.Quantity := 9;
        BoQLine.Insert();

        // [WHEN] the budget is pushed
        CreateBudget.CreateBudget(BoQHeader);

        // [THEN] only the two costed position lines become planning lines, numbered 10000 and 20000
        JobPlanningLine.SetRange("Job No.", Job."No.");
        Assert.RecordCount(JobPlanningLine, 2);
        JobPlanningLine.FindLast();
        Assert.AreEqual(20000, JobPlanningLine."Line No.", 'planning lines are numbered in steps of 10000');
        BoQLine.Get(BoQHeader."No.", 20000);
        Assert.AreEqual(0, BoQLine."Linked Job Planning Line No.", 'zero-quantity line not pushed');
        Assert.ExpectedMessage('2 project planning line(s)', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('BudgetMessageHandler')]
    procedure CreateBudget_UsesBoQStartingDateAsPlanningDate()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a BoQ with a starting date 10 days after the work date
        Initialize(Job, JobTask);
        TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        BoQHeader."Starting Date" := WorkDate() + 10;
        BoQHeader.Modify();
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 1, 10, 0);

        // [WHEN] the budget is pushed
        CreateBudget.CreateBudget(BoQHeader);

        // [THEN] the planning line is dated on the BoQ starting date
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.FindFirst();
        Assert.AreEqual(WorkDate() + 10, JobPlanningLine."Planning Date", 'planning date from the BoQ');
    end;

    [Test]
    procedure CreateBudget_NoProject_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a BoQ that is not linked to a project
        Initialize(Job, JobTask);
        CreateBoQ(BoQHeader, '');
        // [WHEN] the budget is pushed
        asserterror CreateBudget.CreateBudget(BoQHeader);
        // [THEN] the missing project is reported
        Assert.ExpectedError('Project No.');
    end;

    [Test]
    procedure CreateBudget_LineWithoutTask_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        JobPlanningLine: Record "Job Planning Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a costed position line without a project task
        Initialize(Job, JobTask);
        TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, '', 1, 10, 0);
        // [WHEN] the budget is pushed
        asserterror CreateBudget.CreateBudget(BoQHeader);
        // [THEN] the missing task is reported and nothing is planned
        Assert.ExpectedError('Project Task No.');
        JobPlanningLine.SetRange("Job No.", Job."No.");
        Assert.RecordIsEmpty(JobPlanningLine);
    end;

    [Test]
    procedure CreateBudget_CostTypeWithoutAccount_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        CreateBudget: Codeunit "CONS BoQ Create Budget";
    begin
        // [GIVEN] a cost-type-only line whose cost type has no default G/L account
        Initialize(Job, JobTask);
        TestLibrary.ClearCostTypeGLAccount(Enum::"CONS Cost Type"::Material);
        CreateBoQ(BoQHeader, Job."No.");
        CreatePositionLine(BoQLine, BoQHeader, 10000, JobTask."Job Task No.", 1, 10, 0);
        // [WHEN] the budget is pushed
        asserterror CreateBudget.CreateBudget(BoQHeader);
        // [THEN] the missing cost type account is reported
        Assert.ExpectedError('Default G/L Account No.');
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        LibraryVariableStorage.Clear();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreateBoQ(var BoQHeader: Record "CONS BoQ Header"; ProjectNo: Code[20])
    begin
        BoQHeader.Init();
        BoQHeader."No." := TestLibrary.NewCode();
        BoQHeader."Project No." := ProjectNo;
        BoQHeader.Insert(true);
    end;

    local procedure CreatePositionLine(var BoQLine: Record "CONS BoQ Line"; BoQHeader: Record "CONS BoQ Header"; LineNo: Integer; JobTaskNo: Code[20]; Qty: Decimal; UnitCost: Decimal; Markup: Decimal)
    begin
        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := LineNo;
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Type := BoQLine.Type::" ";
        BoQLine."Cost Type" := BoQLine."Cost Type"::Material;
        BoQLine."Project Task No." := JobTaskNo;
        BoQLine.Validate("Markup %", Markup);
        BoQLine.Validate("Unit Cost", UnitCost);
        BoQLine.Validate(Quantity, Qty);
        BoQLine.Insert(true);
    end;

    [MessageHandler]
    procedure BudgetMessageHandler(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}
