namespace Construction.Test;

using Construction.Estimating;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using System.TestLibraries.Utilities;

codeunit 64001 "CONS BoQ Line Logic Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryResource: Codeunit "Library - Resource";

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
    procedure ValidateAmounts_RoundsTotalsToAmountPrecision()
    var
        BoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a position line whose totals are not whole cents: 3.333 x 10.01, markup 12.5%
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Quantity := 3.333;
        BoQLine."Unit Cost" := 10.01;
        BoQLine."Markup %" := 12.5;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(BoQLine);
        // [THEN] totals are rounded to 0.01 (33.36333 -> 33.36; 3.333 * 11.26125 = 37.53375 -> 37.53)
        Assert.AreEqual(33.36, BoQLine."Total Cost", 'Total Cost rounded');
        Assert.AreEqual(11.26125, BoQLine."Unit Price", 'Unit Price keeps full precision');
        Assert.AreEqual(37.53, BoQLine."Total Price", 'Total Price rounded');
    end;

    [Test]
    procedure ValidateAmounts_NegativeMarkup_DiscountsPrice()
    var
        BoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a position line priced below cost (markup -10%)
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Quantity := 2;
        BoQLine."Unit Cost" := 50;
        BoQLine."Markup %" := -10;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(BoQLine);
        // [THEN] the price is below cost
        Assert.AreEqual(45, BoQLine."Unit Price", 'Unit Price = 50 * 0.9');
        Assert.AreEqual(90, BoQLine."Total Price", 'Total Price = 2 * 45');
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
        Assert.AreEqual(0, BoQLine."Unit Price", 'Heading carries no Unit Price');
        Assert.AreEqual(0, BoQLine."Total Price", 'Heading carries no Total Price');
    end;

    [Test]
    procedure ValidateLineType_ToComment_ClearsAmounts()
    var
        BoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a costed position line
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Quantity := 4;
        BoQLine."Unit Cost" := 25;
        Logic.Validate_Amounts(BoQLine);
        // [WHEN] it is turned into a comment line
        BoQLine."Line Type" := BoQLine."Line Type"::Comment;
        Logic.Validate_LineType(BoQLine);
        // [THEN] its amounts no longer count towards the estimate
        Assert.AreEqual(0, BoQLine."Total Cost", 'comment carries no cost');
        Assert.AreEqual(0, BoQLine."Total Price", 'comment carries no price');
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
        Assert.AreEqual('', BoQLine."No.", 'No. is cleared when Type changes');
    end;

    [Test]
    procedure ValidateType_Unchanged_KeepsNo()
    var
        BoQLine: Record "CONS BoQ Line";
        xBoQLine: Record "CONS BoQ Line";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a line re-validated with the same Type
        BoQLine.Type := BoQLine.Type::Item;
        BoQLine."No." := 'ABC';
        xBoQLine.Type := xBoQLine.Type::Item;
        // [WHEN] Type is validated
        Logic.Validate_Type(BoQLine, xBoQLine);
        // [THEN] No. is kept
        Assert.AreEqual('ABC', BoQLine."No.", 'No. is kept when Type does not change');
    end;

    [Test]
    procedure ValidateNo_Resource_CopiesNameUnitAndCost()
    var
        BoQLine: Record "CONS BoQ Line";
        Resource: Record Resource;
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a resource with a name, base unit and unit cost 42
        LibraryResource.CreateResourceNew(Resource);
        Resource.Name := 'Concrete crew';
        Resource."Unit Cost" := 42;
        Resource.Modify();
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Quantity := 2;
        BoQLine.Type := BoQLine.Type::Resource;
        BoQLine."No." := Resource."No.";
        // [WHEN] the No. is validated
        Logic.Validate_No(BoQLine);
        // [THEN] description, unit of measure and cost come from the resource, and totals are recalculated
        Assert.AreEqual(Resource.Name, BoQLine.Description, 'description from resource');
        Assert.AreEqual(Resource."Base Unit of Measure", BoQLine."Unit of Measure Code", 'unit from resource');
        Assert.AreEqual(42, BoQLine."Unit Cost", 'unit cost from resource');
        Assert.AreEqual(84, BoQLine."Total Cost", 'total recalculated');
    end;

    [Test]
    procedure ValidateNo_Item_KeepsManualUnitCost()
    var
        BoQLine: Record "CONS BoQ Line";
        Item: Record Item;
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] an item with unit cost 10, and a line where the estimator already priced the item at 12
        LibraryInventory.CreateItem(Item);
        Item."Unit Cost" := 10;
        Item.Modify();
        BoQLine.Type := BoQLine.Type::Item;
        BoQLine."No." := Item."No.";
        BoQLine."Unit Cost" := 12;
        // [WHEN] the No. is validated
        Logic.Validate_No(BoQLine);
        // [THEN] the description is copied but the estimator's unit cost is kept
        Assert.AreEqual(Item.Description, BoQLine.Description, 'description from item');
        Assert.AreEqual(Item."Base Unit of Measure", BoQLine."Unit of Measure Code", 'unit from item');
        Assert.AreEqual(12, BoQLine."Unit Cost", 'manual unit cost kept');
    end;

    [Test]
    procedure ValidateNo_GLAccount_CopiesName()
    var
        BoQLine: Record "CONS BoQ Line";
        GLAccount: Record "G/L Account";
        Logic: Codeunit "CONS BoQ Line Logic";
    begin
        // [GIVEN] a G/L account
        GLAccount.Get(LibraryERM.CreateGLAccountNo());
        BoQLine.Type := BoQLine.Type::"G/L Account";
        BoQLine."No." := GLAccount."No.";
        // [WHEN] the No. is validated
        Logic.Validate_No(BoQLine);
        // [THEN] the account name becomes the description
        Assert.AreEqual(GLAccount.Name, BoQLine.Description, 'description from G/L account');
    end;

    [Test]
    procedure InsertLine_InheritsHeaderDefaultMarkup()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
    begin
        // [GIVEN] a BoQ whose default markup is 15%
        CreateHeader(BoQHeader, 15);
        // [WHEN] a line without its own markup is inserted
        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := 10000;
        BoQLine.Insert(true);
        // [THEN] the line takes the header's default markup
        Assert.AreEqual(15, BoQLine."Markup %", 'default markup inherited');
    end;

    [Test]
    procedure InsertLine_InheritedMarkupRepricesLine()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
    begin
        // [GIVEN] a BoQ whose default markup is 10%, and a line costed (4 x 50) before it is inserted
        CreateHeader(BoQHeader, 10);
        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := 10000;
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Validate("Unit Cost", 50);
        BoQLine.Validate(Quantity, 4);
        // [WHEN] the line is inserted and inherits the header markup
        BoQLine.Insert(true);
        // [THEN] its price reflects the inherited markup (not the 0% it was priced with before insert)
        Assert.AreEqual(10, BoQLine."Markup %", 'default markup inherited');
        Assert.AreEqual(55, BoQLine."Unit Price", 'unit price includes the inherited markup');
        Assert.AreEqual(220, BoQLine."Total Price", 'total price includes the inherited markup');
    end;

    [Test]
    procedure InsertLine_KeepsOwnMarkup()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
    begin
        // [GIVEN] a BoQ whose default markup is 15%
        CreateHeader(BoQHeader, 15);
        // [WHEN] a line with its own 8% markup is inserted
        BoQLine.Init();
        BoQLine."Document No." := BoQHeader."No.";
        BoQLine."Line No." := 10000;
        BoQLine."Markup %" := 8;
        BoQLine.Insert(true);
        // [THEN] the line keeps its markup
        Assert.AreEqual(8, BoQLine."Markup %", 'own markup kept');
    end;

    [Test]
    procedure TableValidate_UsesInjectedLogic()
    var
        BoQLine: Record "CONS BoQ Line";
        FakeLogic: Codeunit "CONS Test BoQ Line Logic";
    begin
        // [GIVEN] a BoQ line with a fake logic implementation injected through Define()
        BoQLine.Define(FakeLogic);
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine."Unit Cost" := 100;
        // [WHEN] Quantity is validated on the table
        BoQLine.Validate(Quantity, 3);
        // [THEN] the table trigger delegated to the fake (which marks Total Cost with -1) instead of the default logic
        Assert.AreEqual(-1, BoQLine."Total Cost", 'table trigger delegates to the injected implementation');
    end;

    [Test]
    procedure TableValidate_DefaultLogicComputesTotals()
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        // [GIVEN] a position line on the table (default logic)
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Validate("Markup %", 10);
        BoQLine.Validate("Unit Cost", 20);
        // [WHEN] Quantity is validated
        BoQLine.Validate(Quantity, 5);
        // [THEN] the field triggers recalculate cost and price
        Assert.AreEqual(100, BoQLine."Total Cost", 'Total Cost via field trigger');
        Assert.AreEqual(110, BoQLine."Total Price", 'Total Price via field trigger');
    end;

    [Test]
    procedure HeaderTotals_SumPositionLines()
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        // [GIVEN] a BoQ with two position lines (cost 100 / price 120 and cost 50 / price 50) and a heading
        CreateHeader(BoQHeader, 0);
        InsertLine(BoQHeader."No.", 10000, 10, 10, 20);
        InsertLine(BoQHeader."No.", 20000, 5, 10, 0);
        InsertHeading(BoQHeader."No.", 30000);
        // [WHEN] the header totals are calculated
        BoQHeader.CalcFields("Total Cost", "Total Price");
        // [THEN] they are the sums of the lines
        Assert.AreEqual(150, BoQHeader."Total Cost", 'header Total Cost');
        Assert.AreEqual(170, BoQHeader."Total Price", 'header Total Price');
    end;

    local procedure CreateHeader(var BoQHeader: Record "CONS BoQ Header"; DefaultMarkup: Decimal)
    begin
        TestLibrary.Initialize();
        BoQHeader.Init();
        BoQHeader."No." := TestLibrary.NewCode();
        BoQHeader."Default Markup %" := DefaultMarkup;
        BoQHeader.Insert(true);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; Qty: Decimal; UnitCost: Decimal; Markup: Decimal)
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.Init();
        BoQLine."Document No." := DocumentNo;
        BoQLine."Line No." := LineNo;
        BoQLine."Line Type" := BoQLine."Line Type"::Position;
        BoQLine.Validate("Markup %", Markup);
        BoQLine.Validate("Unit Cost", UnitCost);
        BoQLine.Validate(Quantity, Qty);
        BoQLine.Insert(true);
    end;

    local procedure InsertHeading(DocumentNo: Code[20]; LineNo: Integer)
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.Init();
        BoQLine."Document No." := DocumentNo;
        BoQLine."Line No." := LineNo;
        BoQLine.Validate("Line Type", BoQLine."Line Type"::Heading);
        BoQLine.Insert(true);
    end;
}
