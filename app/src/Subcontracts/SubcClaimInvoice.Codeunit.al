namespace Construction.Subcontracts;

using Construction.Core;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Document;

codeunit 50269 "CONS Subc Claim Invoice"
{
    Access = Public;

    /// <summary>
    /// Generates a draft purchase invoice from a subcontract claim: one cost line per claim line
    /// with a period amount, plus a single negative retention G/L line (Option D, AP side) that
    /// moves the withheld amount into the Retention Payable account. The header is stamped so the
    /// purchase-post subscriber records the payable retention entry when the invoice is posted.
    /// The invoice is left unposted for review (the vendor invoice number is entered before posting).
    /// </summary>
    /// <param name="SubcClaimHeader">The certified claim to invoice.</param>
    /// <returns>The number of the created draft purchase invoice.</returns>
    internal procedure CreateInvoice(var SubcClaimHeader: Record "CONS Subc Claim Header"): Code[20]
    var
        ConstructionSetup: Record "CONS Construction Setup";
        SubcClaimLine: Record "CONS Subc Claim Line";
        PurchaseHeader: Record "Purchase Header";
        LicenseMgt: Codeunit "CONS License Mgt.";
        TotalRetention: Decimal;
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
        SubcClaimHeader.TestField("Subcontract No.");
        SubcClaimHeader.TestField("Buy-from Vendor No.");
        if SubcClaimHeader.Status = SubcClaimHeader.Status::Invoiced then
            Error(AlreadyInvoicedErr);
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Subcontract Cost Account");
        ConstructionSetup.TestField("Retention Payable Acc.");

        CreateHeader(SubcClaimHeader, PurchaseHeader);

        SubcClaimLine.SetRange("Document No.", SubcClaimHeader."No.");
        if SubcClaimLine.FindSet() then
            repeat
                if SubcClaimLine."This Period Amount" <> 0 then begin
                    CreateCostLine(PurchaseHeader, ConstructionSetup."Subcontract Cost Account", SubcClaimLine);
                    TotalRetention += SubcClaimLine."Retention This Period";
                    Created += 1;
                end;
            until SubcClaimLine.Next() = 0;

        if Created = 0 then begin
            PurchaseHeader.Delete(true);
            Error(NothingToInvoiceErr);
        end;

        if TotalRetention <> 0 then
            CreateRetentionLine(PurchaseHeader, ConstructionSetup."Retention Payable Acc.", TotalRetention);

        PurchaseHeader."CONS Retention Amount" := TotalRetention;
        PurchaseHeader.Modify(true);

        SubcClaimHeader.Status := SubcClaimHeader.Status::Invoiced;
        SubcClaimHeader.Modify(true);

        Message(InvoiceCreatedMsg, PurchaseHeader."No.");
        exit(PurchaseHeader."No.");
    end;

    local procedure CreateHeader(SubcClaimHeader: Record "CONS Subc Claim Header"; var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", SubcClaimHeader."Buy-from Vendor No.");
        if SubcClaimHeader."Posting Date" <> 0D then
            PurchaseHeader.Validate("Posting Date", SubcClaimHeader."Posting Date");
        PurchaseHeader."CONS Subc Claim No." := SubcClaimHeader."No.";
        PurchaseHeader."CONS Project No." := SubcClaimHeader."Project No.";
        PurchaseHeader.Modify(true);
    end;

    local procedure CreateCostLine(PurchaseHeader: Record "Purchase Header"; CostAccount: Code[20]; SubcClaimLine: Record "CONS Subc Claim Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine."Line No." := NextPurchaseLineNo(PurchaseHeader);
        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Validate("No.", CostAccount);
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", SubcClaimLine."This Period Amount");
        if SubcClaimLine.Description <> '' then
            PurchaseLine.Description := SubcClaimLine.Description;
        PurchaseLine.Insert(true);
    end;

    local procedure CreateRetentionLine(PurchaseHeader: Record "Purchase Header"; RetentionAccount: Code[20]; RetentionAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine."Line No." := NextPurchaseLineNo(PurchaseHeader);
        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Validate("No.", RetentionAccount);
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", -RetentionAmount);
        PurchaseLine.Description := RetentionLineLbl;
        PurchaseLine.Insert(true);
    end;

    local procedure NextPurchaseLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No." + 10000);
        exit(10000);
    end;

    var
        AlreadyInvoicedErr: Label 'This claim has already been invoiced.';
        NothingToInvoiceErr: Label 'There is nothing to invoice on this claim (no period amounts).';
        InvoiceCreatedMsg: Label 'Purchase invoice %1 was created. Enter the vendor invoice number, review and post it to record the retention.', Comment = '%1 = invoice no.';
        RetentionLineLbl: Label 'Retention withheld';
}
