namespace Construction.Test;

using Construction.Core;
using Construction.Retention;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

/// <summary>
/// The base-app subscriber proxy (CONS Retention Subscribers) on posted Sales/Purchase invoice inserts: it must
/// forward to the retention reactions only when the access policy says the user owns the module, and the default
/// reactions must then write the retention sub-ledger.
/// </summary>
codeunit 64021 "CONS Retention Subscr Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    procedure SalesInvoiceInsert_UserOwnsModule_ForwardsToReactions()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FakeReactions: Codeunit "CONS Test Retention Reactions";
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        // [GIVEN] fake retention reactions and an access policy that grants the module
        Initialize();
        ServiceLocator.ImplementRetentionReactions(FakeReactions);

        // [WHEN] a posted sales invoice header is inserted
        InsertSalesInvoiceHeader(SalesInvoiceHeader, '', 0, false);

        // [THEN] the proxy forwarded exactly that invoice to the reactions
        Assert.AreEqual(1, LibraryVariableStorage.Length(), 'one forwarded call');
        Assert.AreEqual(SalesInvoiceHeader."No.", LibraryVariableStorage.DequeueText(), 'the inserted invoice was forwarded');
        TestLibrary.Initialize();
    end;

    [Test]
    procedure SalesInvoiceInsert_UserWithoutModule_NotForwarded()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FakeReactions: Codeunit "CONS Test Retention Reactions";
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        // [GIVEN] fake retention reactions and an access policy that denies the module
        Initialize();
        ServiceLocator.ImplementRetentionReactions(FakeReactions);
        TestLibrary.SetAccessAllowed(false);

        // [WHEN] a posted sales invoice header is inserted
        InsertSalesInvoiceHeader(SalesInvoiceHeader, '', 0, false);

        // [THEN] the proxy returned early — standard posting runs untouched for users who do not own the product
        Assert.AreEqual(0, LibraryVariableStorage.Length(), 'nothing forwarded for an unentitled user');
        TestLibrary.Initialize();
    end;

    [Test]
    procedure PurchInvoiceInsert_UserOwnsModule_ForwardsToReactions()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        FakeReactions: Codeunit "CONS Test Retention Reactions";
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        // [GIVEN] fake retention reactions and an access policy that grants the module
        Initialize();
        ServiceLocator.ImplementRetentionReactions(FakeReactions);

        // [WHEN] a posted purchase invoice header is inserted
        InsertPurchInvHeader(PurchInvHeader, '', 0, false);

        // [THEN] the proxy forwarded exactly that invoice to the reactions
        Assert.AreEqual(1, LibraryVariableStorage.Length(), 'one forwarded call');
        Assert.AreEqual(PurchInvHeader."No.", LibraryVariableStorage.DequeueText(), 'the inserted invoice was forwarded');
        TestLibrary.Initialize();
    end;

    [Test]
    procedure PurchInvoiceInsert_UserWithoutModule_NotForwarded()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        FakeReactions: Codeunit "CONS Test Retention Reactions";
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        // [GIVEN] fake retention reactions and an access policy that denies the module
        Initialize();
        ServiceLocator.ImplementRetentionReactions(FakeReactions);
        TestLibrary.SetAccessAllowed(false);

        // [WHEN] a posted purchase invoice header is inserted
        InsertPurchInvHeader(PurchInvHeader, '', 0, false);

        // [THEN] nothing is forwarded
        Assert.AreEqual(0, LibraryVariableStorage.Length(), 'nothing forwarded for an unentitled user');
        TestLibrary.Initialize();
    end;

    [Test]
    procedure SalesInvoiceInsert_DefaultReactions_RecordWithheldRetention()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetentionEntry: Record "CONS Retention Entry";
        ProjectNo: Code[20];
    begin
        // [GIVEN] Progress Billing enabled and the default reactions
        Initialize();
        TestLibrary.SetFeature(Enum::"CONS Feature"::ProgressBilling, true);
        ProjectNo := TestLibrary.NewCode();

        // [WHEN] a posted sales invoice stamped with a project and 150 retention is inserted
        InsertSalesInvoiceHeader(SalesInvoiceHeader, ProjectNo, 150, false);

        // [THEN] the whole subscriber chain writes one open Withheld receivable entry of 150
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        Assert.RecordCount(RetentionEntry, 1);
        RetentionEntry.FindFirst();
        Assert.AreEqual(150, RetentionEntry.Amount, 'withheld amount');
        Assert.AreEqual(RetentionEntry."Entry Type"::Withheld, RetentionEntry."Entry Type", 'entry type');
        Assert.AreEqual(RetentionEntry.Direction::Receivable, RetentionEntry.Direction, 'direction');
        Assert.AreEqual(ProjectNo, RetentionEntry."Project No.", 'project');
    end;

    [Test]
    procedure PurchInvoiceInsert_DefaultReactions_RecordReleasedRetention()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        RetentionEntry: Record "CONS Retention Entry";
    begin
        // [GIVEN] Subcontracts enabled and the default reactions
        Initialize();
        TestLibrary.SetFeature(Enum::"CONS Feature"::Subcontracts, true);

        // [WHEN] a posted purchase invoice flagged as a retention release of 80 is inserted
        InsertPurchInvHeader(PurchInvHeader, TestLibrary.NewCode(), 80, true);

        // [THEN] a closed Released payable entry of -80 is written
        RetentionEntry.SetRange("Document No.", PurchInvHeader."No.");
        Assert.RecordCount(RetentionEntry, 1);
        RetentionEntry.FindFirst();
        Assert.AreEqual(-80, RetentionEntry.Amount, 'released amount is negative');
        Assert.AreEqual(RetentionEntry."Entry Type"::Released, RetentionEntry."Entry Type", 'entry type');
        Assert.AreEqual(RetentionEntry.Direction::Payable, RetentionEntry.Direction, 'direction');
        Assert.IsFalse(RetentionEntry.Open, 'a release entry is closed');
    end;

    local procedure Initialize()
    begin
        TestLibrary.Initialize();
        LibraryVariableStorage.Clear();
    end;

    local procedure InsertSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header"; ProjectNo: Code[20]; RetentionAmount: Decimal; IsRelease: Boolean)
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := TestLibrary.NewCode();
        SalesInvoiceHeader."Posting Date" := WorkDate();
        SalesInvoiceHeader."CONS Project No." := ProjectNo;
        SalesInvoiceHeader."CONS Retention Amount" := RetentionAmount;
        SalesInvoiceHeader."CONS Retention Is Release" := IsRelease;
        SalesInvoiceHeader.Insert();
    end;

    local procedure InsertPurchInvHeader(var PurchInvHeader: Record "Purch. Inv. Header"; ProjectNo: Code[20]; RetentionAmount: Decimal; IsRelease: Boolean)
    begin
        PurchInvHeader.Init();
        PurchInvHeader."No." := TestLibrary.NewCode();
        PurchInvHeader."Posting Date" := WorkDate();
        PurchInvHeader."CONS Project No." := ProjectNo;
        PurchInvHeader."CONS Retention Amount" := RetentionAmount;
        PurchInvHeader."CONS Retention Is Release" := IsRelease;
        PurchInvHeader.Insert();
    end;
}
