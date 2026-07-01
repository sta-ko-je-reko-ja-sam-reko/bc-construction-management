namespace Construction.ProgressBilling;

using Construction.Core;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Document;

codeunit 50159 "CONS Prog. Billing Invoice"
{
    Access = Public;

    /// <summary>
    /// Generates a draft Sales Invoice from a progress billing application: one revenue line per
    /// schedule-of-values line with a period amount, plus a single negative retention G/L line
    /// (Option D) that moves the withheld amount into the Retention Receivable account. The header
    /// is stamped with the application/project/retention so the Sales-Post subscriber records the
    /// retention entry when the invoice is posted. The invoice is left unposted for review.
    /// </summary>
    /// <param name="ProgBillingHeader">The certified application to invoice.</param>
    /// <returns>The number of the created draft sales invoice.</returns>
    internal procedure CreateInvoice(var ProgBillingHeader: Record "CONS Progress Billing Header"): Code[20]
    var
        ConstructionSetup: Record "CONS Construction Setup";
        ProgBillingLine: Record "CONS Progress Billing Line";
        SalesHeader: Record "Sales Header";
        LicenseMgt: Codeunit "CONS License Mgt.";
        TotalRetention: Decimal;
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
        ProgBillingHeader.TestField("Project No.");
        ProgBillingHeader.TestField("Bill-to Customer No.");
        if ProgBillingHeader.Status = ProgBillingHeader.Status::Invoiced then
            Error(AlreadyInvoicedErr);
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Revenue Account");
        ConstructionSetup.TestField("Retention Receivable Acc.");

        CreateHeader(ProgBillingHeader, SalesHeader);

        ProgBillingLine.SetRange("Document No.", ProgBillingHeader."No.");
        if ProgBillingLine.FindSet() then
            repeat
                if (ProgBillingLine."This Period Amount" + ProgBillingLine."Stored Materials") <> 0 then begin
                    CreateRevenueLine(SalesHeader, ConstructionSetup."Revenue Account", ProgBillingLine);
                    TotalRetention += ProgBillingLine."Retention This Period";
                    Created += 1;
                end;
            until ProgBillingLine.Next() = 0;

        if Created = 0 then begin
            SalesHeader.Delete(true);
            Error(NothingToInvoiceErr);
        end;

        if TotalRetention <> 0 then
            CreateRetentionLine(SalesHeader, ConstructionSetup."Retention Receivable Acc.", TotalRetention);

        SalesHeader."CONS Retention Amount" := TotalRetention;
        SalesHeader.Modify(true);

        ProgBillingHeader.Status := ProgBillingHeader.Status::Invoiced;
        ProgBillingHeader.Modify(true);

        Message(InvoiceCreatedMsg, SalesHeader."No.");
        exit(SalesHeader."No.");
    end;

    local procedure CreateHeader(ProgBillingHeader: Record "CONS Progress Billing Header"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", ProgBillingHeader."Bill-to Customer No.");
        if ProgBillingHeader."Posting Date" <> 0D then
            SalesHeader.Validate("Posting Date", ProgBillingHeader."Posting Date");
        SalesHeader."CONS Progress Billing No." := ProgBillingHeader."No.";
        SalesHeader."CONS Project No." := ProgBillingHeader."Project No.";
        SalesHeader.Modify(true);
    end;

    local procedure CreateRevenueLine(SalesHeader: Record "Sales Header"; RevenueAccount: Code[20]; ProgBillingLine: Record "CONS Progress Billing Line")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine."Line No." := NextSalesLineNo(SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", RevenueAccount);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", ProgBillingLine."This Period Amount" + ProgBillingLine."Stored Materials");
        if ProgBillingLine.Description <> '' then
            SalesLine.Description := ProgBillingLine.Description;
        SalesLine.Insert(true);
    end;

    local procedure CreateRetentionLine(SalesHeader: Record "Sales Header"; RetentionAccount: Code[20]; RetentionAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine."Line No." := NextSalesLineNo(SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", RetentionAccount);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", -RetentionAmount);
        SalesLine.Description := RetentionLineLbl;
        SalesLine.Insert(true);
    end;

    local procedure NextSalesLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000);
        exit(10000);
    end;

    var
        AlreadyInvoicedErr: Label 'This application has already been invoiced.';
        NothingToInvoiceErr: Label 'There is nothing to invoice on this application (no period amounts).';
        InvoiceCreatedMsg: Label 'Sales invoice %1 was created. Review and post it to record the retention.', Comment = '%1 = invoice no.';
        RetentionLineLbl: Label 'Retention withheld';
}
