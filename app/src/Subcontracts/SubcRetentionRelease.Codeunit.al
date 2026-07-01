namespace Construction.Subcontracts;

using Construction.Core;
using Construction.Retention;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Document;

codeunit 50270 "CONS Subc Retention Release"
{
    Access = Public;

    /// <summary>
    /// Creates a draft purchase invoice that releases withheld payable retention for a subcontractor:
    /// a single positive retention G/L line (debit Retention Payable, credit AP) that makes the held
    /// amount payable to the subcontractor. The header is stamped so the purchase-post subscriber
    /// records a released payable retention entry. The invoice is left unposted for review.
    /// </summary>
    /// <param name="ProjectNo">The project whose retention is released.</param>
    /// <param name="VendorNo">The subcontractor the retention is released to.</param>
    /// <param name="ReleaseAmount">The amount to release; must not exceed the outstanding retention.</param>
    /// <returns>The number of the created draft purchase invoice.</returns>
    internal procedure CreateReleaseInvoice(ProjectNo: Code[20]; VendorNo: Code[20]; ReleaseAmount: Decimal): Code[20]
    var
        ConstructionSetup: Record "CONS Construction Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        LicenseMgt: Codeunit "CONS License Mgt.";
        Outstanding: Decimal;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
        if ReleaseAmount <= 0 then
            Error(NothingToReleaseErr);
        Outstanding := RetentionMgt.OutstandingForAccount(ProjectNo, "CONS Retention Direction"::Payable, VendorNo);
        if ReleaseAmount > Outstanding then
            Error(ExceedsOutstandingErr, Outstanding);
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Retention Payable Acc.");

        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchaseHeader."CONS Project No." := ProjectNo;
        PurchaseHeader."CONS Retention Amount" := ReleaseAmount;
        PurchaseHeader."CONS Retention Is Release" := true;
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Validate("No.", ConstructionSetup."Retention Payable Acc.");
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", ReleaseAmount);
        PurchaseLine.Description := ReleaseLineLbl;
        PurchaseLine.Insert(true);

        Message(ReleaseInvoiceCreatedMsg, PurchaseHeader."No.", VendorNo);
        exit(PurchaseHeader."No.");
    end;

    /// <summary>Releases the full outstanding retention held for a subcontract's project and subcontractor.</summary>
    /// <param name="SubcontractNo">The subcontract whose outstanding retention is released.</param>
    /// <returns>The number of the created draft purchase invoice.</returns>
    internal procedure ReleaseFullOutstanding(SubcontractNo: Code[20]): Code[20]
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        Outstanding: Decimal;
    begin
        SubcontractHeader.Get(SubcontractNo);
        SubcontractHeader.TestField("Project No.");
        SubcontractHeader.TestField("Buy-from Vendor No.");
        Outstanding := RetentionMgt.OutstandingForAccount(
            SubcontractHeader."Project No.", "CONS Retention Direction"::Payable, SubcontractHeader."Buy-from Vendor No.");
        if Outstanding <= 0 then
            Error(NothingToReleaseErr);
        exit(CreateReleaseInvoice(SubcontractHeader."Project No.", SubcontractHeader."Buy-from Vendor No.", Outstanding));
    end;

    var
        NothingToReleaseErr: Label 'There is no outstanding retention to release for this subcontractor on this project.';
        ExceedsOutstandingErr: Label 'The release amount exceeds the outstanding retention of %1.', Comment = '%1 = outstanding amount';
        ReleaseInvoiceCreatedMsg: Label 'Retention release purchase invoice %1 was created for subcontractor %2. Review and post it.', Comment = '%1 = invoice no., %2 = vendor no.';
        ReleaseLineLbl: Label 'Retention release';
}
