namespace Construction.Test;

using Construction.Subcontracts;
using System.TestLibraries.Utilities;

codeunit 64007 "CONS Subc Claim Line Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure ValidateAmounts_ComputesProgressRetentionAndNetPayable()
    var
        Line: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line: scheduled 8000, previous 1000, this period 2000, retention 5%
        Line."Scheduled Value" := 8000;
        Line."Previous Amount" := 1000;
        Line."This Period Amount" := 2000;
        Line."Retention %" := 5;
        // [WHEN] amounts are recalculated (logic tested directly — no database)
        Logic.Validate_Amounts(Line);
        // [THEN] completed-to-date, % complete, retention and net payable follow the formulae
        Assert.AreEqual(3000, Line."Completed To Date", 'Completed To Date = previous + this period');
        Assert.AreEqual(37.5, Line."% Complete", '% Complete = completed-to-date / scheduled value * 100');
        Assert.AreEqual(100, Line."Retention This Period", 'Retention = this period * retention %');
        Assert.AreEqual(1900, Line."Net Payable This Period", 'Net Payable = this period - retention');
    end;

    [Test]
    procedure ValidateAmounts_ZeroScheduledValue_PercentIsZero()
    var
        Line: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line with no scheduled value (division-by-zero guard path)
        Line."Scheduled Value" := 0;
        Line."Previous Amount" := 500;
        Line."This Period Amount" := 250;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] completed-to-date still accrues but % complete is forced to zero
        Assert.AreEqual(750, Line."Completed To Date", 'Completed To Date = previous + this period');
        Assert.AreEqual(0, Line."% Complete", '% Complete = 0 when scheduled value is zero');
    end;

    [Test]
    procedure ValidateAmounts_ZeroRetention_NetEqualsPeriod()
    var
        Line: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line with a 0% retention rate
        Line."Scheduled Value" := 4000;
        Line."This Period Amount" := 1000;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] no retention is withheld and net payable equals the period amount
        Assert.AreEqual(0, Line."Retention This Period", 'No retention withheld at 0%');
        Assert.AreEqual(1000, Line."Net Payable This Period", 'Net payable equals period amount when retention is 0%');
        Assert.AreEqual(25, Line."% Complete", '% Complete = 1000 / 4000 * 100');
    end;

    [Test]
    procedure ValidateAmounts_RetentionRounded()
    var
        Line: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a period amount of 999.99 with 7% retention (69.9993)
        Line."This Period Amount" := 999.99;
        Line."Retention %" := 7;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] retention is rounded and net payable is the exact remainder
        Assert.AreEqual(70, Line."Retention This Period", 'retention rounded');
        Assert.AreEqual(929.99, Line."Net Payable This Period", 'net payable');
    end;

    [Test]
    procedure TriggerOnInsert_RetentionSet_NotOverwritten()
    var
        Line: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line that already carries a retention % (guard exits before reading the header)
        Line."Document No." := 'CLAIM-T';
        Line."Line No." := 10000;
        Line."Retention %" := 8;
        // [WHEN] the insert trigger logic runs
        Logic.Trigger_OnInsert(Line);
        // [THEN] the line keeps its own retention % (header default not inherited)
        Assert.AreEqual(8, Line."Retention %", 'Line retention % is kept when already non-zero on insert');
    end;

    [Test]
    procedure InsertLine_InheritsHeaderRetentionAndRecalculates()
    var
        Header: Record "CONS Subc Claim Header";
        Line: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a claim with 10% retention and a line priced before insert (period amount 600, no own retention)
        TestLibrary.Initialize();
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Retention %" := 10;
        Header.Insert(true);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate("This Period Amount", 600);
        // [WHEN] the line is inserted
        Line.Insert(true);
        // [THEN] it inherits the claim retention and its retention/net payable reflect it
        Assert.AreEqual(10, Line."Retention %", 'retention % inherited');
        Assert.AreEqual(60, Line."Retention This Period", 'retention recalculated with the inherited %');
        Assert.AreEqual(540, Line."Net Payable This Period", 'net payable recalculated with the inherited %');
    end;
}
