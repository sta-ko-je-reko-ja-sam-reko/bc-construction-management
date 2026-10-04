namespace Construction.Test;

using Construction.Retention;
using System.TestLibraries.Utilities;

codeunit 64005 "CONS Retention Mgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure CalcRetention_ComputesPercentage()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] a billed amount of 3500 and 10% retention
        // [WHEN]/[THEN] the withheld amount is 350 (pure function, no DB)
        Assert.AreEqual(350, RetentionMgt.CalcRetention(3500, 10), 'retention = amount * pct / 100');
    end;

    [Test]
    procedure CalcRetention_ZeroPercent_IsZero()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] a billed amount but no retention percentage
        // [WHEN]/[THEN] nothing is withheld
        Assert.AreEqual(0, RetentionMgt.CalcRetention(3500, 0), 'no retention when pct is 0');
    end;

    [Test]
    procedure CalcRetention_NegativePercent_IsZero()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] a nonsensical negative retention percentage
        // [WHEN]/[THEN] nothing is withheld (never a negative retention)
        Assert.AreEqual(0, RetentionMgt.CalcRetention(3500, -5), 'no retention when pct is negative');
    end;

    [Test]
    procedure CalcRetention_Rounds()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] an amount whose retention is not a whole cent (1234.56 * 3.33% = 41.110848)
        // [WHEN]/[THEN] the result is rounded to the amount precision
        Assert.AreEqual(41.11, RetentionMgt.CalcRetention(1234.56, 3.33), 'retention is rounded to 0.01');
    end;

    [Test]
    procedure CalcRetention_CreditAmount_IsNegative()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] a negative (credited) billed amount
        // [WHEN]/[THEN] the retention follows the sign of the billed amount
        Assert.AreEqual(-50, RetentionMgt.CalcRetention(-1000, 5), 'retention on a credit is negative');
    end;

    [Test]
    procedure InsertWithheld_StoresPositiveOpenEntry()
    var
        RetentionEntry: Record "CONS Retention Entry";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        EntryNo: Integer;
    begin
        // [GIVEN] a withheld amount passed with a negative sign
        TestLibrary.Initialize();
        // [WHEN] it is recorded
        EntryNo := RetentionMgt.InsertWithheld('P1', "CONS Retention Direction"::Receivable, 'DOC1', WorkDate(), 'C1', 'GL1', 3, -125, WorkDate() + 30);
        // [THEN] the entry holds the absolute amount, is open, and carries every reference
        RetentionEntry.Get(EntryNo);
        Assert.AreEqual(125, RetentionEntry.Amount, 'withheld amount is stored positive');
        Assert.IsTrue(RetentionEntry.Open, 'withheld retention is open');
        Assert.AreEqual(RetentionEntry."Entry Type"::Withheld, RetentionEntry."Entry Type", 'entry type');
        Assert.AreEqual('C1', RetentionEntry."Account No.", 'account');
        Assert.AreEqual('GL1', RetentionEntry."G/L Account No.", 'G/L account');
        Assert.AreEqual(3, RetentionEntry."Application No.", 'application no.');
        Assert.AreEqual(WorkDate() + 30, RetentionEntry."Due Date", 'due date');
    end;

    [Test]
    procedure InsertWithheld_ZeroAmount_WritesNothing()
    var
        RetentionEntry: Record "CONS Retention Entry";
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] a zero retention amount
        TestLibrary.Initialize();
        RetentionEntry.SetRange("Document No.", 'ZERODOC');
        // [WHEN] it is recorded
        // [THEN] no entry is written and 0 is returned
        Assert.AreEqual(0, RetentionMgt.InsertWithheld('P1', "CONS Retention Direction"::Payable, 'ZERODOC', WorkDate(), 'V1', '', 0, 0, 0D), 'no entry no.');
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    [Test]
    procedure InsertReleased_StoresNegativeClosedEntry()
    var
        RetentionEntry: Record "CONS Retention Entry";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        EntryNo: Integer;
    begin
        // [GIVEN] a released amount passed positive
        TestLibrary.Initialize();
        // [WHEN] it is recorded
        EntryNo := RetentionMgt.InsertReleased('P1', "CONS Retention Direction"::Receivable, 'DOC2', WorkDate(), 'C1', 'GL1', 0, 40);
        // [THEN] the entry reduces the balance (negative) and is closed
        RetentionEntry.Get(EntryNo);
        Assert.AreEqual(-40, RetentionEntry.Amount, 'released amount is stored negative');
        Assert.IsFalse(RetentionEntry.Open, 'release entries are closed');
        Assert.AreEqual(RetentionEntry."Entry Type"::Released, RetentionEntry."Entry Type", 'entry type');
    end;

    [Test]
    procedure InsertReleased_ZeroAmount_WritesNothing()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN]/[WHEN] a zero release is recorded
        TestLibrary.Initialize();
        // [THEN] nothing is written
        Assert.AreEqual(0, RetentionMgt.InsertReleased('P1', "CONS Retention Direction"::Receivable, 'DOC3', WorkDate(), 'C1', '', 0, 0), 'no entry no.');
    end;

    [Test]
    procedure OutstandingRetention_WithheldMinusReleased_PerDirection()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
        ProjectNo: Code[20];
    begin
        // [GIVEN] receivable 300 + 200 withheld and 150 released, plus 999 payable on the same project
        TestLibrary.Initialize();
        ProjectNo := TestLibrary.NewCode();
        RetentionMgt.InsertWithheld(ProjectNo, "CONS Retention Direction"::Receivable, 'D1', WorkDate(), 'C1', '', 1, 300, 0D);
        RetentionMgt.InsertWithheld(ProjectNo, "CONS Retention Direction"::Receivable, 'D2', WorkDate(), 'C1', '', 2, 200, 0D);
        RetentionMgt.InsertReleased(ProjectNo, "CONS Retention Direction"::Receivable, 'D3', WorkDate(), 'C1', '', 0, 150);
        RetentionMgt.InsertWithheld(ProjectNo, "CONS Retention Direction"::Payable, 'D4', WorkDate(), 'V1', '', 0, 999, 0D);

        // [WHEN]/[THEN] the outstanding balance is per direction: receivable 350, payable 999
        Assert.AreEqual(350, RetentionMgt.OutstandingRetention(ProjectNo, "CONS Retention Direction"::Receivable), 'receivable outstanding');
        Assert.AreEqual(999, RetentionMgt.OutstandingRetention(ProjectNo, "CONS Retention Direction"::Payable), 'payable outstanding');
    end;

    [Test]
    procedure OutstandingForAccount_FiltersBySubcontractor()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
        ProjectNo: Code[20];
    begin
        // [GIVEN] payable retention held for two subcontractors on one project
        TestLibrary.Initialize();
        ProjectNo := TestLibrary.NewCode();
        RetentionMgt.InsertWithheld(ProjectNo, "CONS Retention Direction"::Payable, 'D1', WorkDate(), 'V1', '', 0, 100, 0D);
        RetentionMgt.InsertWithheld(ProjectNo, "CONS Retention Direction"::Payable, 'D2', WorkDate(), 'V2', '', 0, 70, 0D);
        RetentionMgt.InsertReleased(ProjectNo, "CONS Retention Direction"::Payable, 'D3', WorkDate(), 'V1', '', 0, 30);

        // [WHEN]/[THEN] each subcontractor only sees their own outstanding balance
        Assert.AreEqual(70, RetentionMgt.OutstandingForAccount(ProjectNo, "CONS Retention Direction"::Payable, 'V1'), 'V1 outstanding');
        Assert.AreEqual(70, RetentionMgt.OutstandingForAccount(ProjectNo, "CONS Retention Direction"::Payable, 'V2'), 'V2 outstanding');
        Assert.AreEqual(140, RetentionMgt.OutstandingRetention(ProjectNo, "CONS Retention Direction"::Payable), 'project total');
    end;
}
