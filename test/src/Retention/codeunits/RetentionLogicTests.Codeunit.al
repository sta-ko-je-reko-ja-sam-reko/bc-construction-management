namespace Construction.Test;

using Construction.Core;
using Construction.ProgressBilling;
using Construction.Retention;
using Construction.Setup;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

/// <summary>The default retention reactions (CONS Retention Logic) called directly with in-memory posted headers: guard clauses and what they record.</summary>
codeunit 64022 "CONS Retention Logic Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure PostedSalesInvoice_RecordsWithheldWithSetupAccountAndApplicationNo()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ProgBillingHeader: Record "CONS Progress Billing Header";
        ConstructionSetup: Record "CONS Construction Setup";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] Progress Billing on, a receivable retention account, and application no. 4 of a project
        Initialize(Enum::"CONS Feature"::ProgressBilling);
        ConstructionSetup.Get();
        ProgBillingHeader.Init();
        ProgBillingHeader."No." := TestLibrary.NewCode();
        ProgBillingHeader."Project No." := TestLibrary.NewCode();
        ProgBillingHeader."Application No." := 4;
        ProgBillingHeader.Insert();
        BuildSalesInvoice(SalesInvoiceHeader, ProgBillingHeader."Project No.", 275, false);
        SalesInvoiceHeader."CONS Progress Billing No." := ProgBillingHeader."No.";
        SalesInvoiceHeader."Bill-to Customer No." := 'CUST1';

        // [WHEN] the posted invoice reaction runs
        RetentionLogic.OnAfterPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] a withheld receivable entry links the invoice, customer, retention account and application
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        RetentionEntry.FindFirst();
        Assert.AreEqual(275, RetentionEntry.Amount, 'amount');
        Assert.AreEqual('CUST1', RetentionEntry."Account No.", 'customer');
        Assert.AreEqual(ConstructionSetup."Retention Receivable Acc.", RetentionEntry."G/L Account No.", 'retention receivable account');
        Assert.AreEqual(4, RetentionEntry."Application No.", 'application no.');
        Assert.AreEqual(WorkDate(), RetentionEntry."Posting Date", 'posting date');
    end;

    [Test]
    procedure PostedSalesInvoice_Release_RecordsReleased()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] a posted retention-release invoice
        Initialize(Enum::"CONS Feature"::ProgressBilling);
        BuildSalesInvoice(SalesInvoiceHeader, TestLibrary.NewCode(), 90, true);

        // [WHEN] the reaction runs
        RetentionLogic.OnAfterPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] a released (negative) entry is recorded
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        RetentionEntry.FindFirst();
        Assert.AreEqual(-90, RetentionEntry.Amount, 'released amount');
        Assert.AreEqual(RetentionEntry."Entry Type"::Released, RetentionEntry."Entry Type", 'entry type');
    end;

    [Test]
    procedure PostedSalesInvoice_FeatureDisabled_RecordsNothing()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] Progress Billing switched off
        Initialize(Enum::"CONS Feature"::ProgressBilling);
        TestLibrary.SetFeature(Enum::"CONS Feature"::ProgressBilling, false);
        BuildSalesInvoice(SalesInvoiceHeader, TestLibrary.NewCode(), 90, false);

        // [WHEN] the reaction runs
        RetentionLogic.OnAfterPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] no retention is recorded
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    [Test]
    procedure PostedSalesInvoice_NotAConstructionInvoice_RecordsNothing()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] an ordinary invoice: no construction project, and one with a project but no retention
        Initialize(Enum::"CONS Feature"::ProgressBilling);
        BuildSalesInvoice(SalesInvoiceHeader, '', 90, false);
        RetentionLogic.OnAfterPostedSalesInvoice(SalesInvoiceHeader);
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        // [THEN] nothing is recorded for either
        Assert.RecordIsEmpty(RetentionEntry);

        BuildSalesInvoice(SalesInvoiceHeader, TestLibrary.NewCode(), 0, false);
        RetentionLogic.OnAfterPostedSalesInvoice(SalesInvoiceHeader);
        RetentionEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    [Test]
    procedure PostedSalesInvoice_TemporaryRecord_RecordsNothing()
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] a temporary (preview/buffer) posted invoice that carries retention
        Initialize(Enum::"CONS Feature"::ProgressBilling);
        TempSalesInvoiceHeader."No." := TestLibrary.NewCode();
        TempSalesInvoiceHeader."CONS Project No." := TestLibrary.NewCode();
        TempSalesInvoiceHeader."CONS Retention Amount" := 10;

        // [WHEN] the reaction runs
        RetentionLogic.OnAfterPostedSalesInvoice(TempSalesInvoiceHeader);

        // [THEN] buffers never write to the retention sub-ledger
        RetentionEntry.SetRange("Document No.", TempSalesInvoiceHeader."No.");
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    [Test]
    procedure PostedPurchInvoice_RecordsPayableWithSetupAccount()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        ConstructionSetup: Record "CONS Construction Setup";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] Subcontracts on and a posted subcontractor invoice withholding 60
        Initialize(Enum::"CONS Feature"::Subcontracts);
        ConstructionSetup.Get();
        BuildPurchInvoice(PurchInvHeader, TestLibrary.NewCode(), 60, false);
        PurchInvHeader."Buy-from Vendor No." := 'VEND1';

        // [WHEN] the reaction runs
        RetentionLogic.OnAfterPostedPurchInvoice(PurchInvHeader);

        // [THEN] a withheld payable entry for the vendor on the retention payable account is recorded
        RetentionEntry.SetRange("Document No.", PurchInvHeader."No.");
        RetentionEntry.FindFirst();
        Assert.AreEqual(60, RetentionEntry.Amount, 'amount');
        Assert.AreEqual(RetentionEntry.Direction::Payable, RetentionEntry.Direction, 'direction');
        Assert.AreEqual('VEND1', RetentionEntry."Account No.", 'vendor');
        Assert.AreEqual(ConstructionSetup."Retention Payable Acc.", RetentionEntry."G/L Account No.", 'retention payable account');
    end;

    [Test]
    procedure PostedPurchInvoice_FeatureDisabled_RecordsNothing()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        RetentionEntry: Record "CONS Retention Entry";
        RetentionLogic: Codeunit "CONS Retention Logic";
    begin
        // [GIVEN] Subcontracts switched off
        Initialize(Enum::"CONS Feature"::Subcontracts);
        TestLibrary.SetFeature(Enum::"CONS Feature"::Subcontracts, false);
        BuildPurchInvoice(PurchInvHeader, TestLibrary.NewCode(), 60, false);

        // [WHEN] the reaction runs
        RetentionLogic.OnAfterPostedPurchInvoice(PurchInvHeader);

        // [THEN] nothing is recorded
        RetentionEntry.SetRange("Document No.", PurchInvHeader."No.");
        Assert.RecordIsEmpty(RetentionEntry);
    end;

    local procedure Initialize(Feature: Enum "CONS Feature")
    begin
        TestLibrary.Initialize();
        TestLibrary.SetupPostingAccounts();
        TestLibrary.SetFeature(Feature, true);
    end;

    local procedure BuildSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; ProjectNo: Code[20]; RetentionAmount: Decimal; IsRelease: Boolean)
    begin
        Clear(SalesInvoiceHeader);
        SalesInvoiceHeader."No." := TestLibrary.NewCode();
        SalesInvoiceHeader."Posting Date" := WorkDate();
        SalesInvoiceHeader."CONS Project No." := ProjectNo;
        SalesInvoiceHeader."CONS Retention Amount" := RetentionAmount;
        SalesInvoiceHeader."CONS Retention Is Release" := IsRelease;
    end;

    local procedure BuildPurchInvoice(var PurchInvHeader: Record "Purch. Inv. Header"; ProjectNo: Code[20]; RetentionAmount: Decimal; IsRelease: Boolean)
    begin
        Clear(PurchInvHeader);
        PurchInvHeader."No." := TestLibrary.NewCode();
        PurchInvHeader."Posting Date" := WorkDate();
        PurchInvHeader."CONS Project No." := ProjectNo;
        PurchInvHeader."CONS Retention Amount" := RetentionAmount;
        PurchInvHeader."CONS Retention Is Release" := IsRelease;
    end;
}
