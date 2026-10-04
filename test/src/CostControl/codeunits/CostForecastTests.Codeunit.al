namespace Construction.Test;

using Construction.CostControl;
using System.TestLibraries.Utilities;

codeunit 64002 "CONS Cost Forecast Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

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

    [Test]
    procedure Compute_ExactlyConsumed_ZeroETCAndVariance()
    var
        Forecast: Codeunit "CONS Cost Forecast";
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
    begin
        // [GIVEN] actual + committed exactly equal the budget
        // [WHEN] the forecast is computed
        Forecast.Compute(750, 500, 250, ETC, EAC, Variance);
        // [THEN] nothing is left to spend and there is no variance
        Assert.AreEqual(0, ETC, 'ETC is zero');
        Assert.AreEqual(750, EAC, 'EAC equals the budget');
        Assert.AreEqual(0, Variance, 'no variance');
    end;

    [Test]
    procedure Compute_NoBudget_SpendIsAllOverrun()
    var
        Forecast: Codeunit "CONS Cost Forecast";
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
    begin
        // [GIVEN] an unbudgeted task with actual 120 and committed 30
        // [WHEN] the forecast is computed
        Forecast.Compute(0, 120, 30, ETC, EAC, Variance);
        // [THEN] the whole spend is an overrun
        Assert.AreEqual(0, ETC, 'ETC is zero');
        Assert.AreEqual(150, EAC, 'EAC = actual + committed');
        Assert.AreEqual(-150, Variance, 'variance = -spend');
    end;

    [Test]
    procedure Compute_NothingSpent_ETCIsWholeBudget()
    var
        Forecast: Codeunit "CONS Cost Forecast";
        ETC: Decimal;
        EAC: Decimal;
        Variance: Decimal;
    begin
        // [GIVEN] a budget of 2500 and no actual or committed cost
        // [WHEN] the forecast is computed
        Forecast.Compute(2500, 0, 0, ETC, EAC, Variance);
        // [THEN] the whole budget is still to complete
        Assert.AreEqual(2500, ETC, 'ETC = budget');
        Assert.AreEqual(2500, EAC, 'EAC = budget');
        Assert.AreEqual(0, Variance, 'no variance');
    end;
}
