namespace Construction.Test;

using Construction.Setup;
using Construction.Subcontracts;
using System.TestLibraries.Utilities;

codeunit 64029 "CONS Subc Claim Header Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure ValidateSubcontractNo_CopiesProjectVendorAndRetention()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] a subcontract with a project, subcontractor and 5% retention
        TestLibrary.Initialize();
        CreateSubcontract(SubcontractHeader, 5);
        // [WHEN] the subcontract is chosen on a claim
        SubcClaimHeader."Subcontract No." := SubcontractHeader."No.";
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] project, vendor and retention come from the subcontract
        Assert.AreEqual(SubcontractHeader."Project No.", SubcClaimHeader."Project No.", 'project');
        Assert.AreEqual(SubcontractHeader."Buy-from Vendor No.", SubcClaimHeader."Buy-from Vendor No.", 'vendor');
        Assert.AreEqual(5, SubcClaimHeader."Retention %", 'retention');
    end;

    [Test]
    procedure ValidateSubcontractNo_KeepsClaimRetention()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] a subcontract at 5% and a claim already at 2.5%
        TestLibrary.Initialize();
        CreateSubcontract(SubcontractHeader, 5);
        SubcClaimHeader."Retention %" := 2.5;
        // [WHEN] the subcontract is chosen
        SubcClaimHeader."Subcontract No." := SubcontractHeader."No.";
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] the claim keeps its own retention
        Assert.AreEqual(2.5, SubcClaimHeader."Retention %", 'claim retention kept');
    end;

    [Test]
    procedure ValidateSubcontractNo_Unchanged_NoCopy()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] the subcontract is unchanged between Rec and xRec (early-exit, no header lookup)
        SubcClaimHeader."Subcontract No." := 'SC-001';
        SubcClaimHeader."Project No." := 'PRE-SET';
        xSubcClaimHeader."Subcontract No." := 'SC-001';
        // [WHEN] the subcontract validation runs
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] previously assigned project is not overwritten
        Assert.AreEqual('PRE-SET', SubcClaimHeader."Project No.", 'Project No. untouched when subcontract is unchanged');
    end;

    [Test]
    procedure ValidateSubcontractNo_Blank_NoCopy()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] the subcontract is cleared (set to blank); guard exits before any header lookup
        SubcClaimHeader."Subcontract No." := '';
        SubcClaimHeader."Project No." := 'PRE-SET';
        xSubcClaimHeader."Subcontract No." := 'SC-001';
        // [WHEN] the subcontract validation runs
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] no copy happens, project is left as-is
        Assert.AreEqual('PRE-SET', SubcClaimHeader."Project No.", 'Project No. untouched when subcontract is blanked');
    end;

    [Test]
    procedure Insert_ClaimNoIsSequentialPerSubcontract()
    var
        SubcontractA: Code[20];
        SubcontractB: Code[20];
    begin
        // [GIVEN] two subcontracts
        TestLibrary.Initialize();
        SubcontractA := TestLibrary.NewCode();
        SubcontractB := TestLibrary.NewCode();
        // [WHEN]/[THEN] each subcontract numbers its claims 1, 2, ... independently
        Assert.AreEqual(1, InsertClaim(SubcontractA), 'first claim of A');
        Assert.AreEqual(2, InsertClaim(SubcontractA), 'second claim of A');
        Assert.AreEqual(1, InsertClaim(SubcontractB), 'first claim of B');
    end;

    [Test]
    procedure Insert_BlankNo_TakesNumberFromSeries()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a claim number series
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        // [WHEN] a claim is inserted without a number
        SubcClaimHeader.Init();
        SubcClaimHeader.Insert(true);
        // [THEN] it is numbered from the series
        Assert.AreEqual(ConstructionSetup."Subcontract Claim Nos.", SubcClaimHeader."No. Series", 'series remembered');
        Assert.AreNotEqual('', SubcClaimHeader."No.", 'number assigned');
    end;

    [Test]
    procedure Delete_RemovesLines()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a claim with a line
        TestLibrary.Initialize();
        SubcClaimHeader.Init();
        SubcClaimHeader."No." := TestLibrary.NewCode();
        SubcClaimHeader.Insert(true);
        SubcClaimLine.Init();
        SubcClaimLine."Document No." := SubcClaimHeader."No.";
        SubcClaimLine."Line No." := 10000;
        SubcClaimLine.Insert(true);
        // [WHEN] the claim is deleted
        SubcClaimHeader.Delete(true);
        // [THEN] its lines are deleted with it
        SubcClaimLine.SetRange("Document No.", SubcClaimHeader."No.");
        Assert.RecordIsEmpty(SubcClaimLine);
    end;

    [Test]
    procedure Certify_LocksLines()
    var
        Header: Record "CONS Subc Claim Header";
        Line: Record "CONS Subc Claim Line";
        NewLine: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] an open claim with one line
        CreateLockTestDocument(Header, Line);

        // [WHEN] the claim is certified
        Header.Certify();

        // [THEN] its lines can no longer be changed, added or deleted
        Assert.AreEqual(Header.Status::Certified, Header.Status, 'certified');
        Line.Validate("This Period Amount", 999);
        asserterror Line.Modify(true);
        Assert.ExpectedError('Reopen the claim first');
        NewLine.Init();
        NewLine."Document No." := Header."No.";
        NewLine."Line No." := 20000;
        asserterror NewLine.Insert(true);
        Assert.ExpectedError('Reopen the claim first');
        Line.Get(Line."Document No.", Line."Line No.");
        asserterror Line.Delete(true);
        Assert.ExpectedError('Reopen the claim first');
    end;

    [Test]
    procedure Reopen_UnlocksLines()
    var
        Header: Record "CONS Subc Claim Header";
        Line: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a certified claim
        CreateLockTestDocument(Header, Line);
        Header.Certify();

        // [WHEN] it is reopened
        Header.Reopen();

        // [THEN] it is Open and its lines can be changed again
        Assert.AreEqual(Header.Status::Open, Header.Status, 'reopened');
        Line.Get(Line."Document No.", Line."Line No.");
        Line.Validate("This Period Amount", 450);
        Line.Modify(true);
        Line.Get(Line."Document No.", Line."Line No.");
        Assert.AreEqual(450, Line."This Period Amount", 'line changed after reopening');
    end;

    [Test]
    procedure Reopen_Invoiced_Errors()
    var
        Header: Record "CONS Subc Claim Header";
        Line: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] an invoiced claim
        CreateLockTestDocument(Header, Line);
        Header.Status := Header.Status::Invoiced;
        Header.Modify();

        // [WHEN] it is reopened
        asserterror Header.Reopen();

        // [THEN] it is refused and the claim stays locked
        Assert.ExpectedError('cannot be reopened');
    end;

    [Test]
    procedure Certify_AlreadyCertified_Errors()
    var
        Header: Record "CONS Subc Claim Header";
        Line: Record "CONS Subc Claim Line";
    begin
        // [GIVEN] a certified claim
        CreateLockTestDocument(Header, Line);
        Header.Certify();

        // [WHEN] it is certified again
        asserterror Header.Certify();

        // [THEN] only open documents can be certified
        Assert.ExpectedError('Status');
    end;

    local procedure CreateLockTestDocument(var Header: Record "CONS Subc Claim Header"; var Line: Record "CONS Subc Claim Line")
    begin
        TestLibrary.Initialize();
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Subcontract No." := TestLibrary.NewCode();
        Header.Insert(true);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate("Scheduled Value", 1000);
        Line.Validate("This Period Amount", 100);
        Line.Insert(true);
    end;

    local procedure CreateSubcontract(var SubcontractHeader: Record "CONS Subcontract Header"; RetentionPct: Decimal)
    begin
        SubcontractHeader.Init();
        SubcontractHeader."No." := TestLibrary.NewCode();
        SubcontractHeader."Project No." := TestLibrary.NewCode();
        SubcontractHeader."Buy-from Vendor No." := TestLibrary.NewCode();
        SubcontractHeader."Retention %" := RetentionPct;
        SubcontractHeader.Insert(true);
    end;

    local procedure InsertClaim(SubcontractNo: Code[20]): Integer
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
    begin
        SubcClaimHeader.Init();
        SubcClaimHeader."No." := TestLibrary.NewCode();
        SubcClaimHeader."Subcontract No." := SubcontractNo;
        SubcClaimHeader.Insert(true);
        exit(SubcClaimHeader."Claim No.");
    end;
}
