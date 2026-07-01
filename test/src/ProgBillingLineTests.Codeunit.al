codeunit 50504 "CONS Prog Billing Line Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

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
}
