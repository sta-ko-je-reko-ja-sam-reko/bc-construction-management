namespace Construction.Test;

using Construction.Core;
using Construction.ProgressBilling;
using Construction.Retention;
using Construction.Setup;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

/// <summary>
/// Integration tests for progress billing end to end: schedule-of-values seeding from the project's billable
/// planning lines, the draft sales invoice with its negative retention line, real Sales-Post posting that writes
/// the receivable retention entry, and the retention release invoice.
/// </summary>
codeunit 64028 "CONS Prog Billing Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJob: Codeunit "Library - Job";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromProject_CreatesLinesFromBillablePlanningLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
        BillableLine: Record "Job Planning Line";
        BothLine: Record "Job Planning Line";
        BudgetLine: Record "Job Planning Line";
        ProgBillingSeed: Codeunit "CONS Prog. Billing Seed";
    begin
        // [GIVEN] a project with a Billable, a Both Budget and Billable, and a Budget-only planning line
        Initialize(Job, JobTask);
        CreatePlanningLine(JobTask, BillableLine."Line Type"::Billable, 2, 1500, BillableLine);
        CreatePlanningLine(JobTask, BothLine."Line Type"::"Both Budget and Billable", 1, 800, BothLine);
        CreatePlanningLine(JobTask, BudgetLine."Line Type"::Budget, 1, 999, BudgetLine);
        CreateApplication(Header, Job, 10);

        // [WHEN] the application is seeded from the project
        ProgBillingSeed.SeedFromProject(Header);

        // [THEN] one schedule-of-values line per billable planning line, valued at its line amount, with the header retention
        Line.SetRange("Document No.", Header."No.");
        Assert.RecordCount(Line, 2);
        Line.SetRange("Job Planning Line No.", BillableLine."Line No.");
        Line.FindFirst();
        Assert.AreEqual(BillableLine."Line Amount", Line."Scheduled Value", 'scheduled value = planning line amount');
        Assert.AreEqual(JobTask."Job Task No.", Line."Job Task No.", 'task copied');
        Assert.AreEqual(10, Line."Retention %", 'header retention copied');
        Line.SetRange("Job Planning Line No.", BudgetLine."Line No.");
        Assert.RecordIsEmpty(Line);
        Assert.ExpectedMessage('2 schedule-of-values line(s)', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromProject_IsIdempotent()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
        PlanningLine: Record "Job Planning Line";
        ProgBillingSeed: Codeunit "CONS Prog. Billing Seed";
    begin
        // [GIVEN] an application already seeded from the project
        Initialize(Job, JobTask);
        CreatePlanningLine(JobTask, PlanningLine."Line Type"::Billable, 1, 1000, PlanningLine);
        CreateApplication(Header, Job, 0);
        ProgBillingSeed.SeedFromProject(Header);
        LibraryVariableStorage.DequeueText();

        // [WHEN] it is seeded again
        ProgBillingSeed.SeedFromProject(Header);

        // [THEN] no duplicates are created and the user is told there was nothing to seed
        Line.SetRange("Document No.", Header."No.");
        Assert.RecordCount(Line, 1);
        Assert.ExpectedMessage('no billable planning lines', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateInvoice_BuildsRevenueAndRetentionLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        ConstructionSetup: Record "CONS Construction Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
        InvoiceNo: Code[20];
    begin
        // [GIVEN] an application at 10% retention: one line 1000 this period + 200 stored, one line with nothing this period
        Initialize(Job, JobTask);
        ConstructionSetup.Get();
        CreateApplication(Header, Job, 10);
        InsertLine(Header, 10000, 5000, 1000, 200);
        InsertLine(Header, 20000, 3000, 0, 0);

        // [WHEN] the draft sales invoice is created
        InvoiceNo := ProgBillingInvoice.CreateInvoice(Header);

        // [THEN] the invoice bills the customer, is stamped with application/project/retention
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, InvoiceNo);
        Assert.AreEqual(Job."Bill-to Customer No.", SalesHeader."Sell-to Customer No.", 'customer');
        Assert.AreEqual(Header."No.", SalesHeader."CONS Progress Billing No.", 'application stamped');
        Assert.AreEqual(Job."No.", SalesHeader."CONS Project No.", 'project stamped');
        Assert.AreEqual(120, SalesHeader."CONS Retention Amount", 'retention amount stamped');
        Assert.IsFalse(SalesHeader."CONS Retention Is Release", 'not a release');

        // [THEN] one revenue line of 1200 and one negative retention line of -120
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", InvoiceNo);
        Assert.RecordCount(SalesLine, 2);
        SalesLine.SetRange("No.", ConstructionSetup."Revenue Account");
        SalesLine.FindFirst();
        Assert.AreEqual(1200, SalesLine."Unit Price", 'revenue = this period + stored materials');
        SalesLine.SetRange("No.", ConstructionSetup."Retention Receivable Acc.");
        SalesLine.FindFirst();
        Assert.AreEqual(-120, SalesLine."Unit Price", 'retention line is negative');

        // [THEN] the application is Invoiced
        Header.Get(Header."No.");
        Assert.AreEqual(Header.Status::Invoiced, Header.Status, 'application invoiced');
        Assert.ExpectedMessage(InvoiceNo, LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateInvoice_NoRetention_NoRetentionLine()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        SalesLine: Record "Sales Line";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
        InvoiceNo: Code[20];
    begin
        // [GIVEN] an application without retention
        Initialize(Job, JobTask);
        CreateApplication(Header, Job, 0);
        InsertLine(Header, 10000, 5000, 700, 0);

        // [WHEN] the draft sales invoice is created
        InvoiceNo := ProgBillingInvoice.CreateInvoice(Header);

        // [THEN] it has only the revenue line
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", InvoiceNo);
        Assert.RecordCount(SalesLine, 1);
    end;

    [Test]
    procedure CreateInvoice_AlreadyInvoiced_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
    begin
        // [GIVEN] an application that has already been invoiced
        Initialize(Job, JobTask);
        CreateApplication(Header, Job, 0);
        InsertLine(Header, 10000, 5000, 700, 0);
        Header.Status := Header.Status::Invoiced;
        Header.Modify();
        // [WHEN] it is invoiced again
        asserterror ProgBillingInvoice.CreateInvoice(Header);
        // [THEN] it is refused
        Assert.ExpectedError('already been invoiced');
    end;

    [Test]
    procedure CreateInvoice_NoPeriodAmounts_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
    begin
        // [GIVEN] an application whose lines bill nothing this period
        Initialize(Job, JobTask);
        CreateApplication(Header, Job, 10);
        InsertLine(Header, 10000, 5000, 0, 0);
        // [WHEN] it is invoiced
        asserterror ProgBillingInvoice.CreateInvoice(Header);
        // [THEN] the user is told there is nothing to invoice
        Assert.ExpectedError('nothing to invoice');
    end;

    [Test]
    procedure CreateInvoice_NoRevenueAccount_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        ConstructionSetup: Record "CONS Construction Setup";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
    begin
        // [GIVEN] Construction Setup without a revenue account
        Initialize(Job, JobTask);
        ConstructionSetup.Get();
        ConstructionSetup."Revenue Account" := '';
        ConstructionSetup.Modify();
        CreateApplication(Header, Job, 10);
        InsertLine(Header, 10000, 5000, 100, 0);
        // [WHEN] the application is invoiced
        asserterror ProgBillingInvoice.CreateInvoice(Header);
        // [THEN] the missing account is reported
        Assert.ExpectedError('Revenue Account');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostInvoice_RecordsWithheldReceivableRetention()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetentionEntry: Record "CONS Retention Entry";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] a draft progress invoice of 2000 with 5% retention
        Initialize(Job, JobTask);
        CreateApplication(Header, Job, 5);
        InsertLine(Header, 10000, 10000, 2000, 0);
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, ProgBillingInvoice.CreateInvoice(Header));

        // [WHEN] the invoice is posted with the standard Sales-Post
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [THEN] the posted invoice carries the stamps and the subscriber recorded a withheld receivable entry of 100
        SalesInvoiceHeader.Get(PostedInvoiceNo);
        Assert.AreEqual(100, SalesInvoiceHeader."CONS Retention Amount", 'retention carried to the posted invoice');
        RetentionEntry.SetRange("Document No.", PostedInvoiceNo);
        Assert.RecordCount(RetentionEntry, 1);
        RetentionEntry.FindFirst();
        Assert.AreEqual(100, RetentionEntry.Amount, 'withheld retention');
        Assert.AreEqual(RetentionEntry.Direction::Receivable, RetentionEntry.Direction, 'receivable');
        Assert.AreEqual(Header."Application No.", RetentionEntry."Application No.", 'application no.');
        Assert.AreEqual(Job."Bill-to Customer No.", RetentionEntry."Account No.", 'customer');
        Assert.AreEqual(100, RetentionMgt.OutstandingRetention(Job."No.", "CONS Retention Direction"::Receivable), 'outstanding retention');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostInvoice_FeatureDisabled_NoRetentionEntry()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        SalesHeader: Record "Sales Header";
        RetentionEntry: Record "CONS Retention Entry";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] a draft progress invoice with retention, then Progress Billing is switched off
        Initialize(Job, JobTask);
        CreateApplication(Header, Job, 5);
        InsertLine(Header, 10000, 10000, 2000, 0);
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, ProgBillingInvoice.CreateInvoice(Header));
        TestLibrary.SetFeature(Enum::"CONS Feature"::ProgressBilling, false);

        // [WHEN] the invoice is posted
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [THEN] the disabled feature does not react to the posting
        RetentionEntry.SetRange("Document No.", PostedInvoiceNo);
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ReleaseRetention_PostedReleaseClearsOutstanding()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
        ConstructionSetup: Record "CONS Construction Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RetentionEntry: Record "CONS Retention Entry";
        ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
        RetentionRelease: Codeunit "CONS Retention Release";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        PostedReleaseNo: Code[20];
    begin
        // [GIVEN] a posted progress invoice that withheld 100 retention
        Initialize(Job, JobTask);
        ConstructionSetup.Get();
        CreateApplication(Header, Job, 5);
        InsertLine(Header, 10000, 10000, 2000, 0);
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, ProgBillingInvoice.CreateInvoice(Header));
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] the full outstanding retention is released
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, RetentionRelease.ReleaseFullOutstanding(Job."No."));

        // [THEN] the release invoice bills 100 on the retention receivable account and is flagged as a release
        Assert.IsTrue(SalesHeader."CONS Retention Is Release", 'flagged as release');
        Assert.AreEqual(100, SalesHeader."CONS Retention Amount", 'release amount');
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        Assert.AreEqual(ConstructionSetup."Retention Receivable Acc.", SalesLine."No.", 'retention receivable account');
        Assert.AreEqual(100, SalesLine."Unit Price", 'release line amount');

        // [WHEN] the release invoice is posted
        PostedReleaseNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [THEN] a released entry of -100 brings the outstanding retention to zero
        RetentionEntry.SetRange("Document No.", PostedReleaseNo);
        RetentionEntry.FindFirst();
        Assert.AreEqual(-100, RetentionEntry.Amount, 'released entry');
        Assert.AreEqual(0, RetentionMgt.OutstandingRetention(Job."No.", "CONS Retention Direction"::Receivable), 'nothing outstanding');
    end;

    [Test]
    procedure CreateReleaseInvoice_ExceedsOutstanding_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        RetentionRelease: Codeunit "CONS Retention Release";
    begin
        // [GIVEN] 50 receivable retention outstanding on the project
        Initialize(Job, JobTask);
        RetentionMgt.InsertWithheld(Job."No.", "CONS Retention Direction"::Receivable, 'D1', WorkDate(), Job."Bill-to Customer No.", '', 1, 50, 0D);
        // [WHEN] 60 is released
        asserterror RetentionRelease.CreateReleaseInvoice(Job."No.", 60);
        // [THEN] the release is refused
        Assert.ExpectedError('exceeds the outstanding retention');
    end;

    [Test]
    procedure CreateReleaseInvoice_ZeroAmount_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        RetentionRelease: Codeunit "CONS Retention Release";
    begin
        // [GIVEN] a project
        Initialize(Job, JobTask);
        // [WHEN] a zero release is requested
        asserterror RetentionRelease.CreateReleaseInvoice(Job."No.", 0);
        // [THEN] it is refused
        Assert.ExpectedError('no outstanding retention');
    end;

    [Test]
    procedure ReleaseFullOutstanding_NothingHeld_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        RetentionRelease: Codeunit "CONS Retention Release";
    begin
        // [GIVEN] a project with no retention held
        Initialize(Job, JobTask);
        // [WHEN] the full outstanding retention is released
        asserterror RetentionRelease.ReleaseFullOutstanding(Job."No.");
        // [THEN] it is refused
        Assert.ExpectedError('no outstanding retention');
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        LibraryVariableStorage.Clear();
        TestLibrary.SetupPostingAccounts();
        TestLibrary.SetFeature(Enum::"CONS Feature"::ProgressBilling, true);
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreatePlanningLine(JobTask: Record "Job Task"; LineType: Enum "Job Planning Line Line Type"; Qty: Decimal; UnitPrice: Decimal; var JobPlanningLine: Record "Job Planning Line")
    begin
        LibraryJob.CreateJobPlanningLine(JobTask, LineType, JobPlanningLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), Qty, JobPlanningLine);
        JobPlanningLine.Validate("Unit Price", UnitPrice);
        JobPlanningLine.Modify(true);
    end;

    local procedure CreateApplication(var Header: Record "CONS Progress Billing Header"; Job: Record Job; RetentionPct: Decimal)
    begin
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header.Validate("Project No.", Job."No.");
        Header."Retention %" := RetentionPct;
        Header."Posting Date" := WorkDate();
        Header.Insert(true);
    end;

    local procedure InsertLine(Header: Record "CONS Progress Billing Header"; LineNo: Integer; ScheduledValue: Decimal; ThisPeriod: Decimal; StoredMaterials: Decimal)
    var
        Line: Record "CONS Progress Billing Line";
    begin
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := LineNo;
        Line."Retention %" := Header."Retention %";
        Line.Validate("Scheduled Value", ScheduledValue);
        Line.Validate("This Period Amount", ThisPeriod);
        Line.Validate("Stored Materials", StoredMaterials);
        Line.Insert(true);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}
