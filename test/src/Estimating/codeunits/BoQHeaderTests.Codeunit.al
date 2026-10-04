namespace Construction.Test;

using Construction.Estimating;
using Construction.Setup;
using System.TestLibraries.Utilities;

codeunit 64025 "CONS BoQ Header Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure Insert_BlankNo_TakesNumberFromSeries()
    var
        BoQHeader: Record "CONS BoQ Header";
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a BoQ number series in Construction Setup
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        // [WHEN] a BoQ is inserted without a number
        BoQHeader.Init();
        BoQHeader.Insert(true);
        // [THEN] it is numbered from the series and remembers the series
        Assert.AreNotEqual('', BoQHeader."No.", 'number assigned');
        Assert.AreEqual(ConstructionSetup."BoQ Nos.", BoQHeader."No. Series", 'series remembered');
    end;

    [Test]
    procedure Insert_BlankNoWithoutSeries_Errors()
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        // [GIVEN] no BoQ number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        // [WHEN] a BoQ is inserted without a number
        BoQHeader.Init();
        asserterror BoQHeader.Insert(true);
        // [THEN] the user is told to set up the series
        Assert.ExpectedError('Bill of Quantities Nos.');
    end;

    [Test]
    procedure Insert_ManualNo_KeepsNumber()
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        // [GIVEN] no BoQ number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        // [WHEN] a BoQ is inserted with an explicit number (API / demo path)
        BoQHeader.Init();
        BoQHeader."No." := 'MANUAL-BOQ';
        BoQHeader.Insert(true);
        // [THEN] the number is kept and no series is required
        Assert.AreEqual('MANUAL-BOQ', BoQHeader."No.", 'manual number kept');
        Assert.AreEqual('', BoQHeader."No. Series", 'no series used');
    end;

    [Test]
    procedure Delete_RemovesLines()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
    begin
        // [GIVEN] a BoQ with two lines
        TestLibrary.Initialize();
        BoQHeader.Init();
        BoQHeader."No." := TestLibrary.NewCode();
        BoQHeader.Insert(true);
        InsertLine(BoQHeader."No.", 10000);
        InsertLine(BoQHeader."No.", 20000);
        // [WHEN] the BoQ is deleted
        BoQHeader.Delete(true);
        // [THEN] its lines are deleted with it
        BoQLine.SetRange("Document No.", BoQHeader."No.");
        Assert.RecordIsEmpty(BoQLine);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer)
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.Init();
        BoQLine."Document No." := DocumentNo;
        BoQLine."Line No." := LineNo;
        BoQLine.Insert(true);
    end;
}
