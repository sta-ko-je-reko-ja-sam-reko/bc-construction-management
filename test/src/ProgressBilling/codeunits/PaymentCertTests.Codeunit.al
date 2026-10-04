namespace Construction.Test;

using Construction.ProgressBilling;
using System.TestLibraries.Utilities;
using System.Utilities;

/// <summary>The Payment Certificate report dataset: one header block per application with its schedule-of-values lines.</summary>
codeunit 64034 "CONS Payment Cert Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure PaymentCertificate_DatasetContainsApplicationAndLines()
    var
        Header: Record "CONS Progress Billing Header";
        OtherHeader: Record "CONS Progress Billing Header";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        OutStr: OutStream;
        InStr: InStream;
        DatasetBuilder: TextBuilder;
        DatasetLine: Text;
        Dataset: Text;
    begin
        // [GIVEN] an application with two described lines, and another application
        TestLibrary.Initialize();
        CreateApplication(Header);
        InsertLine(Header."No.", 10000, 'Foundations certified');
        InsertLine(Header."No.", 20000, 'Steel frame certified');
        CreateApplication(OtherHeader);
        InsertLine(OtherHeader."No.", 10000, 'Other application line');

        // [WHEN] the payment certificate is rendered (dataset only) for the first application
        Header.SetRecFilter();
        RecRef.GetTable(Header);
        TempBlob.CreateOutStream(OutStr);
        Report.SaveAs(Report::"CONS Payment Certificate", '', ReportFormat::Xml, OutStr, RecRef);
        TempBlob.CreateInStream(InStr);
        while not InStr.EOS() do begin
            InStr.ReadText(DatasetLine);
            DatasetBuilder.Append(DatasetLine);
        end;
        Dataset := DatasetBuilder.ToText();

        // [THEN] it contains that application and its lines only
        Assert.IsTrue(Dataset.Contains(Header."No."), 'application number printed');
        Assert.IsTrue(Dataset.Contains('Foundations certified'), 'first line printed');
        Assert.IsTrue(Dataset.Contains('Steel frame certified'), 'second line printed');
        Assert.IsFalse(Dataset.Contains('Other application line'), 'other applications are not printed');
    end;

    local procedure CreateApplication(var Header: Record "CONS Progress Billing Header")
    begin
        Header.Init();
        Header."No." := TestLibrary.NewCode();
        Header."Project No." := TestLibrary.NewCode();
        Header."Retention %" := 5;
        Header.Insert(true);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; LineDescription: Text[100])
    var
        Line: Record "CONS Progress Billing Line";
    begin
        Line.Init();
        Line."Document No." := DocumentNo;
        Line."Line No." := LineNo;
        Line.Description := LineDescription;
        Line.Validate("Scheduled Value", 1000);
        Line.Validate("This Period Amount", 250);
        Line.Insert(true);
    end;
}
