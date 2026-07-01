codeunit 50506 "CONS Subcontract Line Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure ValidateAmounts_ComputesLineAmount()
    var
        Line: Record "CONS Subcontract Line";
        Logic: Codeunit "CONS Subcontract Line Logic";
    begin
        // [GIVEN] a subcontract line: quantity 10, unit cost 250
        Line.Quantity := 10;
        Line."Unit Cost" := 250;
        // [WHEN] the amount is recalculated (logic tested directly — no database)
        Logic.Validate_Amounts(Line);
        // [THEN] line amount = quantity * unit cost
        Assert.AreEqual(2500, Line."Line Amount", 'Line Amount = quantity * unit cost');
    end;
}
