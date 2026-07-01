codeunit 50502 "CONS Cost Forecast Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure Compute_UnderBudget()
    var
        Forecast: Codeunit "CONS Cost Forecast";
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
    begin
        // [GIVEN] Budget 1000, Actual 300, Committed 200
        // [WHEN] the forecast is computed
        Forecast.Compute(1000, 300, 200, ETC, EAC, Variance);
        // [THEN] ETC/EAC/Variance follow the formulae
        Assert.AreEqual(500, ETC, 'ETC = Budget - Actual - Committed');
        Assert.AreEqual(1000, EAC, 'EAC = Actual + Committed + ETC');
        Assert.AreEqual(0, Variance, 'Variance = Budget - EAC');
    end;

    [Test]
    procedure Compute_Overrun_ClampsETCAndShowsNegativeVariance()
    var
        Forecast: Codeunit "CONS Cost Forecast";
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
    begin
        // [GIVEN] Budget 1000 but Actual 800 + Committed 400 already exceed it
        // [WHEN] the forecast is computed
        Forecast.Compute(1000, 800, 400, ETC, EAC, Variance);
        // [THEN] ETC is clamped at zero and the variance signals an overrun
        Assert.AreEqual(0, ETC, 'ETC is clamped at 0 when already over budget');
        Assert.AreEqual(1200, EAC, 'EAC = Actual + Committed when ETC is 0');
        Assert.AreEqual(-200, Variance, 'Variance is negative on a forecast overrun');
    end;
}
