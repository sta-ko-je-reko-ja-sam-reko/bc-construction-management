namespace Construction.Test;

using Construction.ProgressBilling;
using Construction.Setup;
using Microsoft.Projects.Project.Job;
using System.TestLibraries.Utilities;

codeunit 64027 "CONS Prog Bill Header Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure ValidateProjectNo_CopiesBillToAndDefaultRetention()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
    begin
        // [GIVEN] a project with a bill-to customer and a 5% default retention in setup
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        TestLibrary.SetDefaultRetention(5);
        // [WHEN] the project is chosen on a new application
        Header.Validate("Project No.", Job."No.");
        // [THEN] the customer and the default retention are filled in
        Assert.AreEqual(Job."Bill-to Customer No.", Header."Bill-to Customer No.", 'bill-to customer from the project');
        Assert.AreEqual(5, Header."Retention %", 'default retention from setup');
    end;

    [Test]
    procedure ValidateProjectNo_KeepsManualRetention()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Header: Record "CONS Progress Billing Header";
    begin
        // [GIVEN] a 5% default retention but an application already at 7.5%
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        TestLibrary.SetDefaultRetention(5);
        Header."Retention %" := 7.5;
        // [WHEN] the project is chosen
        Header.Validate("Project No.", Job."No.");
        // [THEN] the manually entered retention is kept
        Assert.AreEqual(7.5, Header."Retention %", 'manual retention kept');
    end;

    [Test]
    procedure ValidateProjectNo_Unchanged_DoesNothing()
    var
        Header: Record "CONS Progress Billing Header";
        xHeader: Record "CONS Progress Billing Header";
        Logic: Codeunit "CONS Prog. Bill Header Logic";
    begin
        // [GIVEN] the project is unchanged between Rec and xRec
        TestLibrary.Initialize();
        TestLibrary.SetDefaultRetention(5);
        Header."Project No." := 'SAME';
        Header."Bill-to Customer No." := 'KEEP';
        xHeader."Project No." := 'SAME';
        // [WHEN] the validation runs
        Logic.Validate_ProjectNo(Header, xHeader);
        // [THEN] nothing is overwritten
        Assert.AreEqual('KEEP', Header."Bill-to Customer No.", 'customer untouched');
        Assert.AreEqual(0, Header."Retention %", 'retention untouched');
    end;

    [Test]
    procedure Insert_ApplicationNoIsSequentialPerProject()
    var
        Header: Record "CONS Progress Billing Header";
        ProjectA: Code[20];
        ProjectB: Code[20];
    begin
        // [GIVEN] two projects
        TestLibrary.Initialize();
        ProjectA := TestLibrary.NewCode();
        ProjectB := TestLibrary.NewCode();
        // [WHEN] two applications are created for A and one for B
        // [THEN] each project numbers its applications 1, 2, ... independently
        Assert.AreEqual(1, InsertHeader(ProjectA), 'first application of A');
        Assert.AreEqual(2, InsertHeader(ProjectA), 'second application of A');
        Assert.AreEqual(1, InsertHeader(ProjectB), 'first application of B');
        Header.SetRange("Project No.", ProjectA);
        Assert.RecordCount(Header, 2);
    end;

    [Test]
    procedure Insert_BlankNo_TakesNumberFromSeries()
    var
        Header: Record "CONS Progress Billing Header";
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        // [GIVEN] a progress billing number series
        TestLibrary.Initialize();
        TestLibrary.SetupNumberSeries();
        ConstructionSetup.Get();
        // [WHEN] an application is inserted without a number
        Header.Init();
        Header.Insert(true);
        // [THEN] it is numbered from the series
        Assert.AreNotEqual('', Header."No.", 'number assigned');
        Assert.AreEqual(ConstructionSetup."Progress Billing Nos.", Header."No. Series", 'series remembered');
    end;

    [Test]
    procedure Insert_BlankNoWithoutSeries_Errors()
    var
        Header: Record "CONS Progress Billing Header";
    begin
        // [GIVEN] no progress billing number series
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        // [WHEN] an application is inserted without a number
        Header.Init();
        asserterror Header.Insert(true);
        // [THEN] the missing series is reported
        Assert.ExpectedError('Progress Billing Nos.');
    end;

    [Test]
    procedure Delete_RemovesLines()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] an application with a line
        TestLibrary.Initialize();
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header.Insert(true);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Insert(true);
        // [WHEN] the application is deleted
        Header.Delete(true);
        // [THEN] its lines are deleted with it
        Line.SetRange("Document No.", Header."No.");
        Assert.RecordIsEmpty(Line);
    end;

    [Test]
    procedure Certify_LocksLines()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
        NewLine: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] an open application with one line
        CreateLockTestDocument(Header, Line);

        // [WHEN] the application is certified
        Header.Certify();

        // [THEN] its lines can no longer be changed, added or deleted
        Assert.AreEqual(Header.Status::Certified, Header.Status, 'certified');
        Line.Validate("This Period Amount", 999);
        asserterror Line.Modify(true);
        Assert.ExpectedError('Reopen the application first');
        NewLine.Init();
        NewLine."Document No." := Header."No.";
        NewLine."Line No." := 20000;
        asserterror NewLine.Insert(true);
        Assert.ExpectedError('Reopen the application first');
        Line.Get(Line."Document No.", Line."Line No.");
        asserterror Line.Delete(true);
        Assert.ExpectedError('Reopen the application first');
    end;

    [Test]
    procedure Reopen_UnlocksLines()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] a certified application
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
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] an invoiced application
        CreateLockTestDocument(Header, Line);
        Header.Status := Header.Status::Invoiced;
        Header.Modify();

        // [WHEN] it is reopened
        asserterror Header.Reopen();

        // [THEN] it is refused and the application stays locked
        Assert.ExpectedError('cannot be reopened');
    end;

    [Test]
    procedure Certify_AlreadyCertified_Errors()
    var
        Header: Record "CONS Progress Billing Header";
        Line: Record "CONS Progress Billing Line";
    begin
        // [GIVEN] a certified application
        CreateLockTestDocument(Header, Line);
        Header.Certify();

        // [WHEN] it is certified again
        asserterror Header.Certify();

        // [THEN] only open documents can be certified
        Assert.ExpectedError('Status');
    end;

    local procedure CreateLockTestDocument(var Header: Record "CONS Progress Billing Header"; var Line: Record "CONS Progress Billing Line")
    begin
        TestLibrary.Initialize();
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Project No." := TestLibrary.NewCode();
        Header.Insert(true);
        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate("Scheduled Value", 1000);
        Line.Validate("This Period Amount", 100);
        Line.Insert(true);
    end;

    local procedure InsertHeader(ProjectNo: Code[20]): Integer
    var
        Header: Record "CONS Progress Billing Header";
    begin
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Project No." := ProjectNo;
        Header.Insert(true);
        exit(Header."Application No.");
    end;
}
