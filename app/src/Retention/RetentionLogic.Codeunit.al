namespace Construction.Retention;

using Construction.Core;
using Construction.ProgressBilling;
using Construction.Setup;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;

codeunit 50207 "CONS Retention Logic" implements "CONS IRetentionReactions"
{
    Access = Public;

    procedure OnAfterPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        ProgBillingHeader: Record "CONS Progress Billing Header";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        ApplicationNo: Integer;
        GLAccountNo: Code[20];
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::ProgressBilling) then
            exit;
        if SalesInvoiceHeader.IsTemporary() then
            exit;
        if SalesInvoiceHeader."CONS Project No." = '' then
            exit;
        if SalesInvoiceHeader."CONS Retention Amount" = 0 then
            exit;

        if ConstructionSetup.Get() then
            GLAccountNo := ConstructionSetup."Retention Receivable Acc.";
        if ProgBillingHeader.Get(SalesInvoiceHeader."CONS Progress Billing No.") then
            ApplicationNo := ProgBillingHeader."Application No.";

        if SalesInvoiceHeader."CONS Retention Is Release" then
            RetentionMgt.InsertReleased(
                SalesInvoiceHeader."CONS Project No.", "CONS Retention Direction"::Receivable,
                SalesInvoiceHeader."No.", SalesInvoiceHeader."Posting Date",
                SalesInvoiceHeader."Bill-to Customer No.", GLAccountNo, ApplicationNo,
                SalesInvoiceHeader."CONS Retention Amount")
        else
            RetentionMgt.InsertWithheld(
                SalesInvoiceHeader."CONS Project No.", "CONS Retention Direction"::Receivable,
                SalesInvoiceHeader."No.", SalesInvoiceHeader."Posting Date",
                SalesInvoiceHeader."Bill-to Customer No.", GLAccountNo, ApplicationNo,
                SalesInvoiceHeader."CONS Retention Amount", 0D);
    end;

    procedure OnAfterPostedPurchInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        GLAccountNo: Code[20];
    begin
        if not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Subcontracts) then
            exit;
        if PurchInvHeader.IsTemporary() then
            exit;
        if PurchInvHeader."CONS Project No." = '' then
            exit;
        if PurchInvHeader."CONS Retention Amount" = 0 then
            exit;

        if ConstructionSetup.Get() then
            GLAccountNo := ConstructionSetup."Retention Payable Acc.";

        if PurchInvHeader."CONS Retention Is Release" then
            RetentionMgt.InsertReleased(
                PurchInvHeader."CONS Project No.", "CONS Retention Direction"::Payable,
                PurchInvHeader."No.", PurchInvHeader."Posting Date",
                PurchInvHeader."Buy-from Vendor No.", GLAccountNo, 0,
                PurchInvHeader."CONS Retention Amount")
        else
            RetentionMgt.InsertWithheld(
                PurchInvHeader."CONS Project No.", "CONS Retention Direction"::Payable,
                PurchInvHeader."No.", PurchInvHeader."Posting Date",
                PurchInvHeader."Buy-from Vendor No.", GLAccountNo, 0,
                PurchInvHeader."CONS Retention Amount", 0D);
    end;
}
