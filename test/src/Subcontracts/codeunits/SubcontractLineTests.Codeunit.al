namespace Construction.Test;

using Construction.Subcontracts;
using System.TestLibraries.Utilities;

codeunit 64006 "CONS Subcontract Line Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

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

    [Test]
    procedure ValidateAmounts_Rounds()
    var
        Line: Record "CONS Subcontract Line";
        Logic: Codeunit "CONS Subcontract Line Logic";
    begin
        // [GIVEN] a line whose amount is not a whole cent (1.5 x 3.333 = 4.9995)
        Line.Quantity := 1.5;
        Line."Unit Cost" := 3.333;
        // [WHEN] the amount is recalculated
        Logic.Validate_Amounts(Line);
        // [THEN] it is rounded to 0.01
        Assert.AreEqual(5, Line."Line Amount", 'Line Amount rounded');
    end;

    [Test]
    procedure TableValidate_RecalculatesOnQuantityAndCost()
    var
        Line: Record "CONS Subcontract Line";
    begin
        // [GIVEN] a line with unit cost 40
        Line.Validate("Unit Cost", 40);
        // [WHEN] the quantity is entered
        Line.Validate(Quantity, 7);
        // [THEN] the field trigger recalculates the amount
        Assert.AreEqual(280, Line."Line Amount", 'Line Amount via field trigger');
    end;

    [Test]
    procedure Insert_RecalculatesLineAmount()
    var
        Line: Record "CONS Subcontract Line";
    begin
        // [GIVEN] a line whose quantity and cost were assigned without validation (import / API path)
        TestLibrary.Initialize();
        Line.Init();
        Line."Document No." := TestLibrary.NewCode();
        Line."Line No." := 10000;
        Line.Quantity := 4;
        Line."Unit Cost" := 12.5;
        // [WHEN] it is inserted
        Line.Insert(true);
        // [THEN] the insert trigger computes the amount
        Assert.AreEqual(50, Line."Line Amount", 'Line Amount computed on insert');
    end;
}
