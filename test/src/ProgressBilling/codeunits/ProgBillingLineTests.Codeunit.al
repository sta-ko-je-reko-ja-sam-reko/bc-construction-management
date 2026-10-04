namespace Construction.Test;

using Construction.ProgressBilling;
using System.TestLibraries.Utilities;

codeunit 64004 "CONS Prog Billing Line Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure ValidateAmounts_ComputesProgressRetentionAndNetDue()
    var
        Line: Record "CONS Progress Billing Line";
        Logic: Codeunit "CONS Prog. Billing Line Logic";
    begin
        // [GIVEN] a SoV line: scheduled 10000, previous 2000, this period 3000, stored 500, retention 10%
        Line."Scheduled Value" := 10000;
        Line."Previous Amount" := 2000;
        Line."This Period Amount" := 3000;
        Line."Stored Materials" := 500;
        Line."Retention %" := 10;
        // [WHEN] amounts are recalculated (logic tested directly — no database)
        Logic.Validate_Amounts(Line);
        // [THEN] completed-to-date, % complete, retention and net due follow the formulae
        Assert.AreEqual(5500, Line."Completed To Date", 'Completed To Date = previous + this period + stored');
        Assert.AreEqual(55, Line."% Complete", '% Complete = completed-to-date / scheduled value * 100');
        Assert.AreEqual(350, Line."Retention This Period", 'Retention = (this period + stored) * retention %');
        Assert.AreEqual(3150, Line."Net Due This Period", 'Net Due = (this period + stored) - retention');
    end;

    [Test]
    procedure ValidateAmounts_ZeroScheduledValue_NoDivideByZero()
    var
        Line: Record "CONS Progress Billing Line";
        Logic: Codeunit "CONS Prog. Billing Line Logic";
    begin
        // [GIVEN] a line with no scheduled value but a this-period amount
        Line."Scheduled Value" := 0;
        Line."This Period Amount" := 1000;
        Line."Retention %" := 5;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] % complete is zero (no divide-by-zero) and retention/net due still compute
        Assert.AreEqual(0, Line."% Complete", '% Complete is 0 when scheduled value is 0');
        Assert.AreEqual(50, Line."Retention This Period", 'retention still computes on the billed amount');
        Assert.AreEqual(950, Line."Net Due This Period", 'net due = billed - retention');
    end;

    [Test]
    procedure ValidateAmounts_PercentCompleteRoundsToTwoDecimals()
    var
        Line: Record "CONS Progress Billing Line";
        Logic: Codeunit "CONS Prog. Billing Line Logic";
    begin
        // [GIVEN] 1000 of 3000 completed (33.333...%)
        Line."Scheduled Value" := 3000;
        Line."This Period Amount" := 1000;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] % complete is rounded to two decimals
        Assert.AreEqual(33.33, Line."% Complete", '% complete rounded');
    end;

    [Test]
    procedure ValidateAmounts_OverBilling_PercentAboveHundred()
    var
        Line: Record "CONS Progress Billing Line";
        Logic: Codeunit "CONS Prog. Billing Line Logic";
    begin
        // [GIVEN] a line billed beyond its scheduled value (variation not yet in the schedule)
        Line."Scheduled Value" := 1000;
        Line."Previous Amount" := 900;
        Line."This Period Amount" := 300;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] the over-billing is visible as more than 100% complete
        Assert.AreEqual(120, Line."% Complete", 'over-billing shows above 100%');
    end;

    [Test]
    procedure ValidateAmounts_RetentionRounded()
    var
        Line: Record "CONS Progress Billing Line";
        Logic: Codeunit "CONS Prog. Billing Line Logic";
    begin
        // [GIVEN] a period amount of 1234.56 with 2.5% retention (30.864)
        Line."This Period Amount" := 1234.56;
        Line."Retention %" := 2.5;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] retention is rounded and net due is the exact remainder
        Assert.AreEqual(30.86, Line."Retention This Period", 'retention rounded');
        Assert.AreEqual(1203.7, Line."Net Due This Period", 'net due = billed - rounded retention');
    end;

    [Test]
    procedure TableValidate_ThisPeriodAmount_RecalculatesLine()
    var
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] a line with scheduled value 2000 and 10% retention
        Line.Validate("Scheduled Value", 2000);
        Line.Validate("Retention %", 10);
        // [WHEN] the period amount is entered on the table
        Line.Validate("This Period Amount", 500);
        // [THEN] the field trigger recalculated the line
        Assert.AreEqual(25, Line."% Complete", '% complete via field trigger');
        Assert.AreEqual(50, Line."Retention This Period", 'retention via field trigger');
        Assert.AreEqual(450, Line."Net Due This Period", 'net due via field trigger');
    end;

    [Test]
    procedure InsertLine_InheritsHeaderRetentionAndRecalculates()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] an application with 5% retention and a line priced before insert (period amount 1000, no own retention)
        CreateHeader(Header, 5);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate("This Period Amount", 1000);
        // [WHEN] the line is inserted
        Line.Insert(true);
        // [THEN] it inherits the header retention and the retention/net due reflect it
        Assert.AreEqual(5, Line."Retention %", 'retention % inherited');
        Assert.AreEqual(50, Line."Retention This Period", 'retention recalculated with the inherited %');
        Assert.AreEqual(950, Line."Net Due This Period", 'net due recalculated with the inherited %');
    end;

    [Test]
    procedure InsertLine_KeepsOwnRetention()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] an application with 5% retention and a line with its own 3%
        CreateHeader(Header, 5);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate("Retention %", 3);
        // [WHEN] the line is inserted
        Line.Insert(true);
        // [THEN] the line keeps its own retention %
        Assert.AreEqual(3, Line."Retention %", 'own retention % kept');
    end;

    [Test]
    procedure HeaderTotals_SumLines()
    var
        Header: Record "CONS Progress Billing Header";
    begin
        // [GIVEN] an application at 10% retention with two lines of 1000 and 500 this period
        CreateHeader(Header, 10);
        InsertLine(Header."No.", 10000, 4000, 1000);
        InsertLine(Header."No.", 20000, 1000, 500);
        // [WHEN] the header totals are calculated
        Header.CalcFields("Scheduled Value", "This Period Amount", "Retention This Period", "Net Due This Period");
        // [THEN] they are the sums of the lines
        Assert.AreEqual(5000, Header."Scheduled Value", 'scheduled value');
        Assert.AreEqual(1500, Header."This Period Amount", 'this period');
        Assert.AreEqual(150, Header."Retention This Period", 'retention');
        Assert.AreEqual(1350, Header."Net Due This Period", 'net due');
    end;

    local procedure CreateHeader(var Header: Record "CONS Progress Billing Header"; RetentionPct: Decimal)
    begin
        TestLibrary.Initialize();
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Retention %" := RetentionPct;
        Header.Insert(true);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; ScheduledValue: Decimal; ThisPeriod: Decimal)
    var
        Line: Record "CONS Progress Billing Line";
    begin
        Line.Init();
        Line."Document No." := DocumentNo;
        Line."Line No." := LineNo;
        Line.Validate("Scheduled Value", ScheduledValue);
        Line.Validate("This Period Amount", ThisPeriod);
        Line.Insert(true);
    end;
}
