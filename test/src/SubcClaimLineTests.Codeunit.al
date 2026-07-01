codeunit 50507 "CONS Subc Claim Line Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

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
}
