codeunit 50505 "CONS Retention Mgt Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

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
    procedure CalcRetention_Rounds()
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        // [GIVEN] an amount whose retention is not a whole number (1000 * 3.33% = 33.3)
        // [WHEN]/[THEN] the result is rounded to currency precision
        Assert.AreEqual(33.3, RetentionMgt.CalcRetention(1000, 3.33), 'retention is rounded');
    end;
}
