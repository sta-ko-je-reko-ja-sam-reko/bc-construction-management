namespace Construction.Test;

using Construction.Setup;
using Construction.Subcontracts;
using System.TestLibraries.Utilities;

codeunit 64015 "CONS Subcontract Header Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure ValidateVendorNo_Unchanged_LeavesRetention()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        xSubcontractHeader: Record "CONS Subcontract Header";
        Logic: Codeunit "CONS Subcontract Header Logic";
    begin
        // [GIVEN] the vendor is unchanged between Rec and xRec (early-exit guard, no setup read)
        SubcontractHeader."Buy-from Vendor No." := 'V-001';
        SubcontractHeader."Retention %" := 7.5;
        xSubcontractHeader."Buy-from Vendor No." := 'V-001';
        // [WHEN] the vendor validation runs
        Logic.Validate_VendorNo(SubcontractHeader, xSubcontractHeader);
        // [THEN] the existing retention % is left untouched (no default applied)
        Assert.AreEqual(7.5, SubcontractHeader."Retention %", 'Retention % unchanged when vendor is unchanged');
    end;

    [Test]
    procedure ValidateVendorNo_RetentionAlreadySet_KeepsIt()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        xSubcontractHeader: Record "CONS Subcontract Header";
        Logic: Codeunit "CONS Subcontract Header Logic";
    begin
        // [GIVEN] a new vendor is chosen but a retention % is already entered (guard before setup read)
        SubcontractHeader."Buy-from Vendor No." := 'V-002';
        SubcontractHeader."Retention %" := 10;
        xSubcontractHeader."Buy-from Vendor No." := 'V-001';
        // [WHEN] the vendor validation runs
        Logic.Validate_VendorNo(SubcontractHeader, xSubcontractHeader);
        // [THEN] the manually entered retention % is preserved (setup default not pulled)
        Assert.AreEqual(10, SubcontractHeader."Retention %", 'Existing non-zero retention % is preserved on vendor change');
    end;

    [Test]
    procedure ValidateVendorNo_NewVendor_TakesDefaultRetention()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        xSubcontractHeader: Record "CONS Subcontract Header";
        Logic: Codeunit "CONS Subcontract Header Logic";
    begin
        // [GIVEN] a 5% default retention in setup and a subcontract without retention
        TestLibrary.Initialize();
        TestLibrary.SetDefaultRetention(5);
        SubcontractHeader."Buy-from Vendor No." := 'V-002';
        xSubcontractHeader."Buy-from Vendor No." := '';
        // [WHEN] the subcontractor is chosen
        Logic.Validate_VendorNo(SubcontractHeader, xSubcontractHeader);
        // [THEN] the default retention is applied
        Assert.AreEqual(5, SubcontractHeader."Retention %", 'default retention applied');
    end;

    [Test]
    procedure Insert_BlankNo_TakesNumberFromSeries()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a subcontract number series
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        // [WHEN] a subcontract is inserted without a number
        SubcontractHeader.Init();
        SubcontractHeader.Insert(true);
        // [THEN] it is numbered from the series
        Assert.AreNotEqual('', SubcontractHeader."No.", 'number assigned');
        Assert.AreEqual(ConstructionSetup."Subcontract Nos.", SubcontractHeader."No. Series", 'series remembered');
    end;

    [Test]
    procedure Insert_BlankNoWithoutSeries_Errors()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
    begin
        // [GIVEN] no subcontract number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        // [WHEN] a subcontract is inserted without a number
        SubcontractHeader.Init();
        asserterror SubcontractHeader.Insert(true);
        // [THEN] the missing series is reported
        Assert.ExpectedError('Subcontract Nos.');
    end;

    [Test]
    procedure Delete_RemovesLines()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        // [GIVEN] a subcontract with a scope line
        TestLibrary.Initialize();
        SubcontractHeader.Init();
        SubcontractHeader."No." := TestLibrary.NewCode();
        SubcontractHeader.Insert(true);
        SubcontractLine.Init();
        SubcontractLine."Document No." := SubcontractHeader."No.";
        SubcontractLine."Line No." := 10000;
        SubcontractLine.Insert(true);
        // [WHEN] the subcontract is deleted
        SubcontractHeader.Delete(true);
        // [THEN] its lines are deleted with it
        SubcontractLine.SetRange("Document No.", SubcontractHeader."No.");
        Assert.RecordIsEmpty(SubcontractLine);
    end;

    [Test]
    procedure SubcontractValue_SumsLineAmounts()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
    begin
        // [GIVEN] a subcontract with scope lines of 10 x 250 and 3 x 100
        TestLibrary.Initialize();
        SubcontractHeader.Init();
        SubcontractHeader."No." := TestLibrary.NewCode();
        SubcontractHeader.Insert(true);
        InsertLine(SubcontractHeader."No.", 10000, 10, 250);
        InsertLine(SubcontractHeader."No.", 20000, 3, 100);
        // [WHEN] the subcontract value is calculated
        SubcontractHeader.CalcFields("Subcontract Value");
        // [THEN] it is the sum of the line amounts
        Assert.AreEqual(2800, SubcontractHeader."Subcontract Value", 'subcontract value');
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; Qty: Decimal; UnitCost: Decimal)
    var
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        SubcontractLine.Init();
        SubcontractLine."Document No." := DocumentNo;
        SubcontractLine."Line No." := LineNo;
        SubcontractLine.Quantity := Qty;
        SubcontractLine."Unit Cost" := UnitCost;
        SubcontractLine.Insert(true);
    end;
}
