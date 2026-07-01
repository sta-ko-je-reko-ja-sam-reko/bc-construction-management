codeunit 50501 "CONS BoQ Line Logic Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure ValidateAmounts_Position_ComputesTotals()
    var
        BoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a position line: quantity 10, unit cost 100, markup 20%
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Quantity := 10;
        BoQLine."Unit Cost" := 100;
        BoQLine."Markup %" := 20;
        // [WHEN] amounts are recalculated (logic tested directly — no database)
        Logic.Validate_Amounts(BoQLine);
        // [THEN] totals and marked-up price are computed
        Assert.AreEqual(1000, BoQLine."Total Cost", 'Total Cost = qty * unit cost');
        Assert.AreEqual(120, BoQLine."Unit Price", 'Unit Price = unit cost * (1 + markup%)');
        Assert.AreEqual(1200, BoQLine."Total Price", 'Total Price = qty * unit price');
    end;

    [Test]
    procedure ValidateAmounts_NonPosition_Zeroes()
    var
        BoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a heading line with quantity/cost set
        BoQLine."Line Type" := BoQLine."Line Type"::Heading;
        BoQLine.Quantity := 10;
        BoQLine."Unit Cost" := 100;
        BoQLine."Markup %" := 20;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(BoQLine);
        // [THEN] non-position lines carry no amounts
        Assert.AreEqual(0, BoQLine."Total Cost", 'Heading carries no Total Cost');
        Assert.AreEqual(0, BoQLine."Total Price", 'Heading carries no Total Price');
    end;

    [Test]
    procedure ValidateType_Changed_ClearsNo()
    var
        BoQLine: Record "CONS BoQ Line";
        xBoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a line whose Type changes from Resource to Item
        BoQLine.Type := BoQLine.Type::Item;
        BoQLine."No." := 'ABC';
        xBoQLine.Type := xBoQLine.Type::Resource;
        // [WHEN] Type is validated
        Logic.Validate_Type(BoQLine, xBoQLine);
        // [THEN] the now-mismatched No. is cleared
        Assert.AreEqualText('', BoQLine."No.", 'No. is cleared when Type changes');
    end;
}
