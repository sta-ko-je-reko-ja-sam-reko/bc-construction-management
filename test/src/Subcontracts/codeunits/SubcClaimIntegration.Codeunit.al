namespace Construction.Test;

using Construction.Core;
using Construction.CostControl;
using Construction.Retention;
using Construction.Setup;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.TestLibraries.Utilities;

/// <summary>
/// Integration tests for subcontractor claims end to end: claim lines seeded from the subcontract scope, the draft
/// purchase invoice with its negative retention line, real Purch.-Post posting that writes the payable retention
/// entry, and the payable retention release invoice.
/// </summary>
codeunit 64031 "CONS Subc Claim Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromSubcontract_CreatesOneLinePerScopeLine()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimLine: Record "CONS Subc Claim Line";
        SubcClaimSeed: Codeunit "CONS Subc Claim Seed";
    begin
        // [GIVEN] a subcontract at 5% retention with scope lines of 10 x 300 and 1 x 1200
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 5);
        InsertScopeLine(SubcontractHeader."No.", 10000, JobTask."Job Task No.", 10, 300);
        InsertScopeLine(SubcontractHeader."No.", 20000, JobTask."Job Task No.", 1, 1200);
        CreateClaim(SubcClaimHeader, SubcontractHeader);

        // [WHEN] the claim is seeded from the subcontract
        SubcClaimSeed.SeedFromSubcontract(SubcClaimHeader);

        // [THEN] each scope line becomes a claim line valued at its line amount, with the claim retention
        SubcClaimLine.SetRange("Document No.", SubcClaimHeader."No.");
        Assert.RecordCount(SubcClaimLine, 2);
        SubcClaimLine.SetRange("Subcontract Line No.", 10000);
        SubcClaimLine.FindFirst();
        Assert.AreEqual(3000, SubcClaimLine."Scheduled Value", 'scheduled value = scope line amount');
        Assert.AreEqual(5, SubcClaimLine."Retention %", 'claim retention');
        Assert.AreEqual(JobTask."Job Task No.", SubcClaimLine."Job Task No.", 'task copied');
        Assert.ExpectedMessage('2 claim line(s)', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromSubcontract_IsIdempotent()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimLine: Record "CONS Subc Claim Line";
        SubcClaimSeed: Codeunit "CONS Subc Claim Seed";
    begin
        // [GIVEN] a claim already seeded from its subcontract
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        InsertScopeLine(SubcontractHeader."No.", 10000, JobTask."Job Task No.", 1, 500);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        SubcClaimSeed.SeedFromSubcontract(SubcClaimHeader);
        LibraryVariableStorage.DequeueText();

        // [WHEN] it is seeded again
        SubcClaimSeed.SeedFromSubcontract(SubcClaimHeader);

        // [THEN] no duplicates are created
        SubcClaimLine.SetRange("Document No.", SubcClaimHeader."No.");
        Assert.RecordCount(SubcClaimLine, 1);
        Assert.ExpectedMessage('no subcontract scope lines', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateInvoice_BuildsCostAndRetentionLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        ConstructionSetup: Record "CONS Construction Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
        InvoiceNo: Code[20];
    begin
        // [GIVEN] a claim at 10% retention with 1500 claimed this period on one line and nothing on another
        Initialize(Job, JobTask);
        ConstructionSetup.Get();
        CreateSubcontract(SubcontractHeader, Job."No.", 10);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLine(SubcClaimHeader, 10000, 1500);
        InsertClaimLine(SubcClaimHeader, 20000, 0);

        // [WHEN] the draft purchase invoice is created
        SubcClaimHeader.Certify();
        InvoiceNo := SubcClaimInvoice.CreateInvoice(SubcClaimHeader);

        // [THEN] it is for the subcontractor, stamped with claim/project/retention
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceNo);
        Assert.AreEqual(SubcontractHeader."Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.", 'vendor');
        Assert.AreEqual(SubcClaimHeader."No.", PurchaseHeader."CONS Subc Claim No.", 'claim stamped');
        Assert.AreEqual(Job."No.", PurchaseHeader."CONS Project No.", 'project stamped');
        Assert.AreEqual(150, PurchaseHeader."CONS Retention Amount", 'retention stamped');

        // [THEN] one cost line of 1500 and one negative retention line of -150
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", InvoiceNo);
        Assert.RecordCount(PurchaseLine, 2);
        PurchaseLine.SetRange("No.", ConstructionSetup."Subcontract Cost Account");
        PurchaseLine.FindFirst();
        Assert.AreEqual(1500, PurchaseLine."Direct Unit Cost", 'cost line');
        PurchaseLine.SetRange("No.", ConstructionSetup."Retention Payable Acc.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(-150, PurchaseLine."Direct Unit Cost", 'retention line is negative');

        // [THEN] the claim is Invoiced
        SubcClaimHeader.Get(SubcClaimHeader."No.");
        Assert.AreEqual(SubcClaimHeader.Status::Invoiced, SubcClaimHeader.Status, 'claim invoiced');
    end;

    [Test]
    procedure CreateInvoice_AlreadyInvoiced_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
    begin
        // [GIVEN] an invoiced claim
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLine(SubcClaimHeader, 10000, 100);
        SubcClaimHeader.Status := SubcClaimHeader.Status::Invoiced;
        SubcClaimHeader.Modify();
        // [WHEN] it is invoiced again
        asserterror SubcClaimInvoice.CreateInvoice(SubcClaimHeader);
        // [THEN] it is refused
        Assert.ExpectedError('already been invoiced');
    end;

    [Test]
    procedure CreateInvoice_NoPeriodAmounts_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
    begin
        // [GIVEN] a claim that claims nothing this period
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLine(SubcClaimHeader, 10000, 0);
        // [WHEN] it is invoiced
        SubcClaimHeader.Certify();
        asserterror SubcClaimInvoice.CreateInvoice(SubcClaimHeader);
        // [THEN] the user is told there is nothing to invoice
        Assert.ExpectedError('nothing to invoice');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostInvoice_RecordsPayableRetention_ThenReleaseClearsIt()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        RetentionEntry: Record "CONS Retention Entry";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
        SubcRetentionRelease: Codeunit "CONS Subc Retention Release";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        PostedInvoiceNo: Code[20];
        PostedReleaseNo: Code[20];
    begin
        // [GIVEN] a draft claim invoice of 4000 with 5% retention
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 5);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLine(SubcClaimHeader, 10000, 4000);
        SubcClaimHeader.Certify();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, SubcClaimInvoice.CreateInvoice(SubcClaimHeader));

        // [WHEN] the vendor invoice number is entered and the invoice is posted with the standard Purch.-Post
        PostedInvoiceNo := PostPurchaseInvoice(PurchaseHeader);

        // [THEN] the posted invoice carries the stamps and a withheld payable entry of 200 is recorded for the subcontractor
        PurchInvHeader.Get(PostedInvoiceNo);
        Assert.AreEqual(200, PurchInvHeader."CONS Retention Amount", 'retention carried to the posted invoice');
        RetentionEntry.SetRange("Document No.", PostedInvoiceNo);
        RetentionEntry.FindFirst();
        Assert.AreEqual(200, RetentionEntry.Amount, 'withheld payable retention');
        Assert.AreEqual(RetentionEntry.Direction::Payable, RetentionEntry.Direction, 'payable');
        Assert.AreEqual(SubcontractHeader."Buy-from Vendor No.", RetentionEntry."Account No.", 'subcontractor');
        Assert.AreEqual(200, RetentionMgt.OutstandingForAccount(Job."No.", "CONS Retention Direction"::Payable, SubcontractHeader."Buy-from Vendor No."), 'outstanding for the subcontractor');

        // [WHEN] the subcontract's full outstanding retention is released and the release invoice posted
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, SubcRetentionRelease.ReleaseFullOutstanding(SubcontractHeader."No."));
        Assert.IsTrue(PurchaseHeader."CONS Retention Is Release", 'flagged as release');
        Assert.AreEqual(200, PurchaseHeader."CONS Retention Amount", 'release amount');
        PostedReleaseNo := PostPurchaseInvoice(PurchaseHeader);

        // [THEN] a released entry of -200 brings the subcontractor's outstanding retention to zero
        RetentionEntry.SetRange("Document No.", PostedReleaseNo);
        RetentionEntry.FindFirst();
        Assert.AreEqual(-200, RetentionEntry.Amount, 'released entry');
        Assert.AreEqual(0, RetentionMgt.OutstandingForAccount(Job."No.", "CONS Retention Direction"::Payable, SubcontractHeader."Buy-from Vendor No."), 'nothing outstanding');
    end;

    [Test]
    procedure CreateReleaseInvoice_OtherSubcontractorsRetention_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        SubcRetentionRelease: Codeunit "CONS Subc Retention Release";
        VendorNo: Code[20];
    begin
        // [GIVEN] 300 payable retention held for another subcontractor on the project
        Initialize(Job, JobTask);
        RetentionMgt.InsertWithheld(Job."No.", "CONS Retention Direction"::Payable, 'D1', WorkDate(), LibraryPurchase.CreateVendorNo(), '', 0, 300, 0D);
        VendorNo := LibraryPurchase.CreateVendorNo();
        // [WHEN] retention is released to a subcontractor who has none held
        asserterror SubcRetentionRelease.CreateReleaseInvoice(Job."No.", VendorNo, 100);
        // [THEN] it is refused — one subcontractor cannot be paid another's retention
        Assert.ExpectedError('exceeds the outstanding retention');
    end;

    [Test]
    procedure ReleaseFullOutstanding_NothingHeld_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcRetentionRelease: Codeunit "CONS Subc Retention Release";
    begin
        // [GIVEN] a subcontract with no retention held
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 5);
        // [WHEN] its full outstanding retention is released
        asserterror SubcRetentionRelease.ReleaseFullOutstanding(SubcontractHeader."No.");
        // [THEN] it is refused
        Assert.ExpectedError('no outstanding retention');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateInvoice_LinksCostLineToProjectTask()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        ConstructionSetup: Record "CONS Construction Setup";
        PurchaseLine: Record "Purchase Line";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
        InvoiceNo: Code[20];
    begin
        // [GIVEN] a claim line of 1500 on a project task, at 10% retention
        Initialize(Job, JobTask);
        ConstructionSetup.Get();
        CreateSubcontract(SubcontractHeader, Job."No.", 10);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLineOnTask(SubcClaimHeader, 10000, JobTask."Job Task No.", 1500);

        // [WHEN] the draft purchase invoice is created
        SubcClaimHeader.Certify();
        InvoiceNo := SubcClaimInvoice.CreateInvoice(SubcClaimHeader);

        // [THEN] the cost line is linked to the project task, the retention line is not
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", InvoiceNo);
        PurchaseLine.SetRange("No.", ConstructionSetup."Subcontract Cost Account");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Job."No.", PurchaseLine."Job No.", 'cost line on the project');
        Assert.AreEqual(JobTask."Job Task No.", PurchaseLine."Job Task No.", 'cost line on the task');
        PurchaseLine.SetRange("No.", ConstructionSetup."Retention Payable Acc.");
        PurchaseLine.FindFirst();
        Assert.AreEqual('', PurchaseLine."Job No.", 'retention is a balance-sheet line, not project cost');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostInvoice_PostsSubcontractCostToProjectLedger()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        PurchaseHeader: Record "Purchase Header";
        JobLedgerEntry: Record "Job Ledger Entry";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
        CostForecast: Codeunit "CONS Cost Forecast";
        Budget: Decimal;
        Committed: Decimal;
        Actual: Decimal;
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
        PctComplete: Decimal;
    begin
        // [GIVEN] a claim of 4000 on a project task with 5% retention, invoiced
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 5);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLineOnTask(SubcClaimHeader, 10000, JobTask."Job Task No.", 4000);
        SubcClaimHeader.Certify();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, SubcClaimInvoice.CreateInvoice(SubcClaimHeader));

        // [WHEN] the invoice is posted
        PostPurchaseInvoice(PurchaseHeader);

        // [THEN] the full claimed amount (before retention) is project usage on the task
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        JobLedgerEntry.SetRange("Job Task No.", JobTask."Job Task No.");
        JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Usage);
        Assert.RecordCount(JobLedgerEntry, 1);
        JobLedgerEntry.FindFirst();
        Assert.AreEqual(4000, JobLedgerEntry."Total Cost (LCY)", 'subcontract cost on the project ledger');

        // [THEN] cost control shows it as actual cost
        JobTask.Get(JobTask."Job No.", JobTask."Job Task No.");
        CostForecast.CalcForecast(JobTask, Budget, Committed, Actual, ETC, EAC, Variance, PctComplete);
        Assert.AreEqual(4000, Actual, 'actual cost includes the subcontract claim');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromSubcontract_SuccessiveClaims_CarryPreviousAmount()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        FirstClaim: Record "CONS Subc Claim Header";
        SecondClaim: Record "CONS Subc Claim Header";
        ThirdClaim: Record "CONS Subc Claim Header";
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a subcontract scope line of 8000 and a first claim that certified 1000
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        InsertScopeLine(SubcontractHeader."No.", 10000, JobTask."Job Task No.", 1, 8000);
        CreateSeededClaim(FirstClaim, SubcontractHeader, 1000, FirstClaim.Status::Certified);

        // [WHEN] a second claim is seeded and claims 3000 (then invoiced)
        CreateSeededClaim(SecondClaim, SubcontractHeader, 3000, SecondClaim.Status::Invoiced);

        // [THEN] it starts from the 1000 already certified
        FindClaimLine(SubcClaimLine, SecondClaim."No.");
        Assert.AreEqual(2, SecondClaim."Claim No.", 'second claim');
        Assert.AreEqual(1000, SubcClaimLine."Previous Amount", 'previous = completed to date on claim 1');
        Assert.AreEqual(4000, SubcClaimLine."Completed To Date", 'completed to date = 1000 + 3000');
        Assert.AreEqual(50, SubcClaimLine."% Complete", '% complete is cumulative');

        // [WHEN] a third claim is seeded
        CreateSeededClaim(ThirdClaim, SubcontractHeader, 0, ThirdClaim.Status::Open);

        // [THEN] it carries the cumulative 4000 forward
        FindClaimLine(SubcClaimLine, ThirdClaim."No.");
        Assert.AreEqual(4000, SubcClaimLine."Previous Amount", 'previous is cumulative to date');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SeedFromSubcontract_DraftPriorClaim_IsNotCarried()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        FirstClaim: Record "CONS Subc Claim Header";
        SecondClaim: Record "CONS Subc Claim Header";
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a first claim that is still an uncertified draft with 1000 entered
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        InsertScopeLine(SubcontractHeader."No.", 10000, JobTask."Job Task No.", 1, 8000);
        CreateSeededClaim(FirstClaim, SubcontractHeader, 1000, FirstClaim.Status::Open);

        // [WHEN] a second claim is seeded
        CreateSeededClaim(SecondClaim, SubcontractHeader, 0, SecondClaim.Status::Open);

        // [THEN] the draft is not treated as previously certified work
        FindClaimLine(SubcClaimLine, SecondClaim."No.");
        Assert.AreEqual(0, SubcClaimLine."Previous Amount", 'draft claims are not carried forward');
    end;

    [Test]
    procedure CreateInvoice_OpenClaim_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
    begin
        // [GIVEN] a claim that has not been certified
        Initialize(Job, JobTask);
        CreateSubcontract(SubcontractHeader, Job."No.", 0);
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        InsertClaimLine(SubcClaimHeader, 10000, 100);
        // [WHEN] it is invoiced
        asserterror SubcClaimInvoice.CreateInvoice(SubcClaimHeader);
        // [THEN] invoicing is refused until the claim is certified
        Assert.ExpectedError('must be certified before it can be invoiced');
    end;

    local procedure CreateSeededClaim(var SubcClaimHeader: Record "CONS Subc Claim Header"; SubcontractHeader: Record "CONS Subcontract Header"; ThisPeriod: Decimal; NewStatus: Enum "CONS Subc Claim Status")
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
        SubcClaimSeed: Codeunit "CONS Subc Claim Seed";
    begin
        CreateClaim(SubcClaimHeader, SubcontractHeader);
        SubcClaimSeed.SeedFromSubcontract(SubcClaimHeader);
        LibraryVariableStorage.DequeueText();
        FindClaimLine(SubcClaimLine, SubcClaimHeader."No.");
        SubcClaimLine.Validate("This Period Amount", ThisPeriod);
        SubcClaimLine.Modify(true);
        SubcClaimHeader.Status := NewStatus;
        SubcClaimHeader.Modify(true);
    end;

    local procedure FindClaimLine(var SubcClaimLine: Record "CONS Subc Claim Line"; DocumentNo: Code[20])
    begin
        SubcClaimLine.Reset();
        SubcClaimLine.SetRange("Document No.", DocumentNo);
        SubcClaimLine.SetRange("Subcontract Line No.", 10000);
        SubcClaimLine.FindFirst();
    end;

    local procedure InsertClaimLineOnTask(SubcClaimHeader: Record "CONS Subc Claim Header"; LineNo: Integer; JobTaskNo: Code[20]; ThisPeriod: Decimal)
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.Init();
        SubcClaimLine."Document No." := SubcClaimHeader."No.";
        SubcClaimLine."Line No." := LineNo;
        SubcClaimLine."Job Task No." := JobTaskNo;
        SubcClaimLine."Retention %" := SubcClaimHeader."Retention %";
        SubcClaimLine.Validate("Scheduled Value", 10000);
        SubcClaimLine.Validate("This Period Amount", ThisPeriod);
        SubcClaimLine.Insert(true);
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        LibraryVariableStorage.Clear();
        TestLibrary.SetupPostingAccounts();
        TestLibrary.SetFeature(Enum::"CONS Feature"::Subcontracts, true);
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreateSubcontract(var SubcontractHeader: Record "CONS Subcontract Header"; ProjectNo: Code[20]; RetentionPct: Decimal)
    begin
        SubcontractHeader.Init();
        SubcontractHeader."No." := TestLibrary.NewCode();
        SubcontractHeader."Project No." := ProjectNo;
        SubcontractHeader."Buy-from Vendor No." := LibraryPurchase.CreateVendorNo();
        SubcontractHeader."Retention %" := RetentionPct;
        SubcontractHeader.Insert(true);
    end;

    local procedure InsertScopeLine(DocumentNo: Code[20]; LineNo: Integer; JobTaskNo: Code[20]; Qty: Decimal; UnitCost: Decimal)
    var
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        SubcontractLine.Init();
        SubcontractLine."Document No." := DocumentNo;
        SubcontractLine."Line No." := LineNo;
        SubcontractLine."Job Task No." := JobTaskNo;
        SubcontractLine.Description := 'Scope';
        SubcontractLine.Validate(Quantity, Qty);
        SubcontractLine.Validate("Unit Cost", UnitCost);
        SubcontractLine.Insert(true);
    end;

    local procedure CreateClaim(var SubcClaimHeader: Record "CONS Subc Claim Header"; SubcontractHeader: Record "CONS Subcontract Header")
    begin
        SubcClaimHeader.Init();
        SubcClaimHeader."No." := TestLibrary.NewCode();
        SubcClaimHeader.Validate("Subcontract No.", SubcontractHeader."No.");
        SubcClaimHeader."Posting Date" := WorkDate();
        SubcClaimHeader.Insert(true);
    end;

    local procedure InsertClaimLine(SubcClaimHeader: Record "CONS Subc Claim Header"; LineNo: Integer; ThisPeriod: Decimal)
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.Init();
        SubcClaimLine."Document No." := SubcClaimHeader."No.";
        SubcClaimLine."Line No." := LineNo;
        SubcClaimLine."Retention %" := SubcClaimHeader."Retention %";
        SubcClaimLine.Validate("Scheduled Value", 10000);
        SubcClaimLine.Validate("This Period Amount", ThisPeriod);
        SubcClaimLine.Insert(true);
    end;

    local procedure PostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        PurchaseHeader.Validate("Vendor Invoice No.", TestLibrary.NewCode());
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}
