namespace Construction.Retention;

using Construction.Core;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Document;

codeunit 50209 "CONS Retention Release"
{
    Access = Public;

    /// <summary>
    /// Creates a draft sales invoice that releases withheld retention for a project: a single
    /// positive retention G/L line (debit AR, credit Retention Receivable) that bills the customer
    /// for the held amount. The header is stamped so the Sales-Post subscriber records a Released
    /// retention entry on posting. The invoice is left unposted for review.
    /// </summary>
    /// <param name="ProjectNo">The project whose retention is released.</param>
    /// <param name="ReleaseAmount">The amount to release; must not exceed the outstanding retention.</param>
    /// <returns>The number of the created draft sales invoice.</returns>
    internal procedure CreateReleaseInvoice(ProjectNo: Code[20]; ReleaseAmount: Decimal): Code[20]
    var
        ConstructionSetup: Record "CONS Construction Setup";
        Job: Record Job;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RetentionMgt: Codeunit "CONS Retention Mgt";
        LicenseMgt: Codeunit "CONS License Mgt.";
        Outstanding: Decimal;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
        if ReleaseAmount <= 0 then
            Error(NothingToReleaseErr);
        Outstanding := RetentionMgt.OutstandingRetention(ProjectNo, "CONS Retention Direction"::Receivable);
        if ReleaseAmount > Outstanding then
            Error(ExceedsOutstandingErr, Outstanding);

        Job.Get(ProjectNo);
        Job.TestField("Bill-to Customer No.");
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Retention Receivable Acc.");

        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Job."Bill-to Customer No.");
        SalesHeader."CONS Project No." := ProjectNo;
        SalesHeader."CONS Retention Amount" := ReleaseAmount;
        SalesHeader."CONS Retention Is Release" := true;
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine."Line No." := 10000;
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ConstructionSetup."Retention Receivable Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", ReleaseAmount);
        SalesLine.Description := ReleaseLineLbl;
        SalesLine.Insert(true);

        Message(ReleaseInvoiceCreatedMsg, SalesHeader."No.", ProjectNo);
        exit(SalesHeader."No.");
    end;

    /// <summary>Releases the full outstanding retention currently held for a project.</summary>
    /// <param name="ProjectNo">The project whose entire outstanding retention is released.</param>
    /// <returns>The number of the created draft sales invoice.</returns>
    internal procedure ReleaseFullOutstanding(ProjectNo: Code[20]): Code[20]
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
        Outstanding: Decimal;
    begin
        Outstanding := RetentionMgt.OutstandingRetention(ProjectNo, "CONS Retention Direction"::Receivable);
        if Outstanding <= 0 then
            Error(NothingToReleaseErr);
        exit(CreateReleaseInvoice(ProjectNo, Outstanding));
    end;

    var
        NothingToReleaseErr: Label 'There is no outstanding retention to release for this project.';
        ExceedsOutstandingErr: Label 'The release amount exceeds the outstanding retention of %1.', Comment = '%1 = outstanding amount';
        ReleaseInvoiceCreatedMsg: Label 'Retention release invoice %1 was created for project %2. Review and post it.', Comment = '%1 = invoice no., %2 = project no.';
        ReleaseLineLbl: Label 'Retention release';
}
