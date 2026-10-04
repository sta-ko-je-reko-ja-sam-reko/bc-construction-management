namespace Construction.Test;

using Construction.CostControl;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Project.Planning;
using Microsoft.Purchases.Document;
using System.TestLibraries.Utilities;

/// <summary>
/// Integration tests for the cost roll-up behind the Project Cost Control page: budget from the task's planning
/// lines, committed cost from open purchase lines, actual cost from posted project usage, and % complete.
/// </summary>
codeunit 64026 "CONS Cost Forecast Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJob: Codeunit "Library - Job";
        LibraryPurchase: Codeunit "Library - Purchase";

    [Test]
    procedure CalcForecast_BudgetOnly_ETCIsBudget()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Forecast: Codeunit "CONS Cost Forecast";
        Budget: Decimal;
        Committed: Decimal;
        Actual: Decimal;
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
        PctComplete: Decimal;
    begin
        // [GIVEN] a task with a budget planning line of 4 x 250
        Initialize(Job, JobTask);
        CreateBudgetLine(JobTask, 4, 250);

        // [WHEN] the forecast is calculated
        Forecast.CalcForecast(JobTask, Budget, Committed, Actual, ETC, EAC, Variance, PctComplete);

        // [THEN] the budget is the planned cost and is still entirely to complete
        Assert.AreEqual(1000, Budget, 'budget from the planning line');
        Assert.AreEqual(0, Committed, 'nothing committed');
        Assert.AreEqual(0, Actual, 'nothing spent');
        Assert.AreEqual(1000, ETC, 'ETC = budget');
        Assert.AreEqual(1000, EAC, 'EAC = budget');
        Assert.AreEqual(0, PctComplete, 'nothing complete');
    end;

    [Test]
    procedure CommittedCost_SumsOpenPurchaseLinesOfTheTaskOnly()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        OtherJobTask: Record "Job Task";
        Forecast: Codeunit "CONS Cost Forecast";
        Expected: Decimal;
    begin
        // [GIVEN] two open purchase order lines on the task and one on another task of the same project
        Initialize(Job, JobTask);
        LibraryJob.CreateJobTask(Job, OtherJobTask);
        Expected := CreateCommittedLine(JobTask, 300) + CreateCommittedLine(JobTask, 200);
        CreateCommittedLine(OtherJobTask, 999);

        // [WHEN]/[THEN] the committed cost is the outstanding amount of the task's own purchase lines
        Assert.AreEqual(Expected, Forecast.CommittedCost(JobTask), 'committed cost of the task');
        Assert.AreNotEqual(0, Expected, 'committed lines carry an outstanding amount');
    end;

    [Test]
    procedure CalcForecast_WithPostedUsage_RollsUpActualAndPercent()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobLedgerEntry: Record "Job Ledger Entry";
        Forecast: Codeunit "CONS Cost Forecast";
        Budget: Decimal;
        Committed: Decimal;
        Actual: Decimal;
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
        PctComplete: Decimal;
    begin
        // [GIVEN] a budget of 1000 and posted resource usage on the task
        Initialize(Job, JobTask);
        CreateBudgetLine(JobTask, 4, 250);
        PostUsage(JobTask, 2, 100);
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        JobLedgerEntry.SetRange("Job Task No.", JobTask."Job Task No.");
        JobLedgerEntry.CalcSums("Total Cost (LCY)");

        // [WHEN] the forecast is calculated
        Forecast.CalcForecast(JobTask, Budget, Committed, Actual, ETC, EAC, Variance, PctComplete);

        // [THEN] actual cost is the posted usage, ETC/EAC follow, and % complete is actual / budget
        Assert.AreEqual(JobLedgerEntry."Total Cost (LCY)", Actual, 'actual = posted usage cost');
        Assert.AreEqual(200, Actual, 'usage of 2 x 100');
        Assert.AreEqual(800, ETC, 'ETC = budget - actual');
        Assert.AreEqual(1000, EAC, 'EAC = actual + ETC');
        Assert.AreEqual(0, Variance, 'on budget');
        Assert.AreEqual(20, PctComplete, '% complete = 200 / 1000');
    end;

    [Test]
    procedure CalcForecast_ManualPercentComplete_Wins()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Forecast: Codeunit "CONS Cost Forecast";
        Budget: Decimal;
        Committed: Decimal;
        Actual: Decimal;
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
        PctComplete: Decimal;
    begin
        // [GIVEN] a budgeted task whose % complete is entered manually as 35
        Initialize(Job, JobTask);
        CreateBudgetLine(JobTask, 1, 1000);
        JobTask."CONS % Complete" := 35;
        JobTask.Modify();

        // [WHEN] the forecast is calculated
        Forecast.CalcForecast(JobTask, Budget, Committed, Actual, ETC, EAC, Variance, PctComplete);

        // [THEN] the manual progress is reported instead of the cost-based one
        Assert.AreEqual(35, PctComplete, 'manual % complete wins');
    end;

    [Test]
    procedure CalcForecast_CommittedOverBudget_ShowsOverrun()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Forecast: Codeunit "CONS Cost Forecast";
        Budget: Decimal;
        Committed: Decimal;
        Actual: Decimal;
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
        PctComplete: Decimal;
    begin
        // [GIVEN] a budget of 100 and a purchase commitment far above it
        Initialize(Job, JobTask);
        CreateBudgetLine(JobTask, 1, 100);
        CreateCommittedLine(JobTask, 5000);

        // [WHEN] the forecast is calculated
        Forecast.CalcForecast(JobTask, Budget, Committed, Actual, ETC, EAC, Variance, PctComplete);

        // [THEN] nothing is left to complete and the variance is the overrun
        Assert.AreEqual(0, ETC, 'ETC clamped at zero');
        Assert.AreEqual(Committed, EAC, 'EAC = committed');
        Assert.AreEqual(Budget - Committed, Variance, 'variance = budget - committed');
        Assert.IsTrue(Variance < 0, 'overrun is negative');
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreateBudgetLine(JobTask: Record "Job Task"; Qty: Decimal; UnitCost: Decimal)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        LibraryJob.CreateJobPlanningLine(JobTask, JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), Qty, JobPlanningLine);
        JobPlanningLine.Validate("Unit Cost", UnitCost);
        JobPlanningLine.Modify(true);
    end;

    local procedure CreateCommittedLine(JobTask: Record "Job Task"; DirectUnitCost: Decimal): Decimal
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Job No.", JobTask."Job No.");
        PurchaseLine.Validate("Job Task No.", JobTask."Job Task No.");
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
        exit(PurchaseLine."Outstanding Amount (LCY)");
    end;

    local procedure PostUsage(JobTask: Record "Job Task"; Qty: Decimal; UnitCost: Decimal)
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        LibraryJob.CreateJobJournalLineForType(LibraryJob.UsageLineTypeBlank(), LibraryJob.ResourceType(), JobTask, JobJournalLine);
        JobJournalLine.Validate(Quantity, Qty);
        JobJournalLine.Validate("Unit Cost", UnitCost);
        JobJournalLine.Modify(true);
        LibraryJob.PostJobJournal(JobJournalLine);
    end;
}
