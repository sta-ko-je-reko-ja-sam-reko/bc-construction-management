namespace Construction.Test;

using Construction.Setup;
using Construction.Subcontracts;
using System.TestLibraries.Utilities;

codeunit 64014 "CONS Change Order Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure Apply_BlankProjectNo_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        Logic: Codeunit "CONS Change Order Hdr Logic";
    begin
        // [GIVEN] a change order with no project assigned (in memory, no database write)
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := 'CO-T-001';
        ChangeOrderHeader."Project No." := '';
        // [WHEN] the change order is applied
        asserterror Logic.Apply(ChangeOrderHeader);
        // [THEN] the missing project guard (TestField "Project No.") fires before any database access
        Assert.ExpectedError('Project No.');
    end;

    [Test]
    procedure Apply_AlreadyApproved_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        Logic: Codeunit "CONS Change Order Hdr Logic";
    begin
        // [GIVEN] a change order that has already been applied (Status = Approved), project set
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := 'CO-T-002';
        ChangeOrderHeader."Project No." := 'PROJ-T';
        ChangeOrderHeader.Status := ChangeOrderHeader.Status::Approved;
        // [WHEN] the change order is applied a second time
        asserterror Logic.Apply(ChangeOrderHeader);
        // [THEN] the already-applied guard fires before any contract/budget posting
        Assert.ExpectedError('already been applied');
    end;

    [Test]
    procedure Apply_SubcontractTypeWithoutSubcontract_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        Logic: Codeunit "CONS Change Order Hdr Logic";
    begin
        // [GIVEN] a subcontract variation that does not name the subcontract
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := 'CO-T-003';
        ChangeOrderHeader."Project No." := 'PROJ-T';
        ChangeOrderHeader."Change Type" := ChangeOrderHeader."Change Type"::Subcontract;
        // [WHEN] it is applied
        asserterror Logic.Apply(ChangeOrderHeader);
        // [THEN] the missing subcontract is reported
        Assert.ExpectedError('Subcontract No.');
    end;

    [Test]
    procedure Insert_BlankNo_TakesNumberFromSeries()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a change order number series
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        // [WHEN] a change order is inserted without a number
        ChangeOrderHeader.Init();
        ChangeOrderHeader.Insert(true);
        // [THEN] it is numbered from the series
        Assert.AreNotEqual('', ChangeOrderHeader."No.", 'number assigned');
        Assert.AreEqual(ConstructionSetup."Change Order Nos.", ChangeOrderHeader."No. Series", 'series remembered');
    end;

    [Test]
    procedure Insert_BlankNoWithoutSeries_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
    begin
        // [GIVEN] no change order number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        // [WHEN] a change order is inserted without a number
        ChangeOrderHeader.Init();
        asserterror ChangeOrderHeader.Insert(true);
        // [THEN] the missing series is reported
        Assert.ExpectedError('Change Order Nos.');
    end;

    [Test]
    procedure Delete_RemovesLines()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        ChangeOrderLine: Record "CONS Change Order Line";
    begin
        // [GIVEN] a change order with a line
        TestLibrary.Initialize();
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := TestLibrary.NewCode();
        ChangeOrderHeader.Insert(true);
        ChangeOrderLine.Init();
        ChangeOrderLine."Document No." := ChangeOrderHeader."No.";
        ChangeOrderLine."Line No." := 10000;
        ChangeOrderLine.Amount := 100;
        ChangeOrderLine.Insert(true);
        // [WHEN] the change order is deleted
        ChangeOrderHeader.Delete(true);
        // [THEN] its lines are deleted with it
        ChangeOrderLine.SetRange("Document No.", ChangeOrderHeader."No.");
        Assert.RecordIsEmpty(ChangeOrderLine);
    end;

    [Test]
    procedure TotalAmount_SumsLines()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
    begin
        // [GIVEN] a change order with an addition of 1500 and an omission of -400
        TestLibrary.Initialize();
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := TestLibrary.NewCode();
        ChangeOrderHeader.Insert(true);
        InsertLine(ChangeOrderHeader."No.", 10000, 1500);
        InsertLine(ChangeOrderHeader."No.", 20000, -400);
        // [WHEN] the total is calculated
        ChangeOrderHeader.CalcFields("Total Amount");
        // [THEN] additions and omissions net off
        Assert.AreEqual(1100, ChangeOrderHeader."Total Amount", 'net change order value');
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; Amount: Decimal)
    var
        ChangeOrderLine: Record "CONS Change Order Line";
    begin
        ChangeOrderLine.Init();
        ChangeOrderLine."Document No." := DocumentNo;
        ChangeOrderLine."Line No." := LineNo;
        ChangeOrderLine.Amount := Amount;
        ChangeOrderLine.Insert(true);
    end;
}
