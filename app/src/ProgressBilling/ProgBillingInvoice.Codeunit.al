namespace Construction.ProgressBilling;

using Construction.Core;
using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sales.Document;

codeunit 60159 "CONS Prog. Billing Invoice"
{
    Access = Public;

    /// <summary>
    /// Generates a draft Sales Invoice from a certified progress billing application through the standard project
    /// invoicing. For each schedule-of-values line with an amount this period, a Billable Project Planning Line for that
    /// amount is created on the line's task (stamped with the application no., so it is never seeded as a
    /// schedule-of-values line). The standard Job Create-Invoice then turns those planning lines into job-linked sales
    /// lines, so posting the invoice writes project Sale ledger entries and the invoiced revenue shows on the project.
    /// A single negative retention G/L line (Option D) moves the withheld amount into the Retention Receivable
    /// account, and the header is stamped with application/project/retention so the Sales-Post subscriber records the
    /// retention entry. The invoice is left unposted for review.
    /// </summary>
    /// <param name="ProgBillingHeader">The certified application to invoice.</param>
    /// <returns>The number of the created draft sales invoice.</returns>
    internal procedure CreateInvoice(var ProgBillingHeader: Record "CONS Progress Billing Header"): Code[20]
    var
        ConstructionSetup: Record "CONS Construction Setup";
        Job: Record Job;
        ProgBillingLine: Record "CONS Progress Billing Line";
        JobPlanningLine: Record "Job Planning Line";
        SalesHeader: Record "Sales Header";
        LicenseMgt: Codeunit "CONS License Mgt.";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
        PostingDate: Date;
        TotalRetention: Decimal;
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
        ProgBillingHeader.TestField("Project No.");
        ProgBillingHeader.TestField("Bill-to Customer No.");
        if ProgBillingHeader.Status = ProgBillingHeader.Status::Invoiced then
            Error(AlreadyInvoicedErr);
        if ProgBillingHeader.Status <> ProgBillingHeader.Status::Certified then
            Error(NotCertifiedErr, ProgBillingHeader."No.");
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Revenue Account");
        ConstructionSetup.TestField("Retention Receivable Acc.");
        Job.Get(ProgBillingHeader."Project No.");
        if Job."Bill-to Customer No." <> ProgBillingHeader."Bill-to Customer No." then
            Error(BillToMismatchErr, ProgBillingHeader."Bill-to Customer No.", Job."No.", Job."Bill-to Customer No.");

        PostingDate := ProgBillingHeader."Posting Date";
        if PostingDate = 0D then
            PostingDate := WorkDate();

        ProgBillingLine.SetRange("Document No.", ProgBillingHeader."No.");
        if ProgBillingLine.FindSet() then
            repeat
                if BilledThisPeriod(ProgBillingLine) <> 0 then begin
                    CreateBillingPlanningLine(ProgBillingHeader, ProgBillingLine, ConstructionSetup."Revenue Account", PostingDate);
                    TotalRetention += ProgBillingLine."Retention This Period";
                    Created += 1;
                end;
            until ProgBillingLine.Next() = 0;

        if Created = 0 then
            Error(NothingToInvoiceErr);

        JobPlanningLine.SetRange("Job No.", ProgBillingHeader."Project No.");
        JobPlanningLine.SetRange("CONS Progress Billing No.", ProgBillingHeader."No.");
        JobPlanningLine.FindFirst();
        JobCreateInvoice.CreateSalesInvoiceLines(ProgBillingHeader."Project No.", JobPlanningLine, '', true, PostingDate, PostingDate, false);
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, FindInvoiceNo(JobPlanningLine));

        if TotalRetention <> 0 then
            CreateRetentionLine(SalesHeader, ConstructionSetup."Retention Receivable Acc.", TotalRetention);

        SalesHeader."CONS Progress Billing No." := ProgBillingHeader."No.";
        SalesHeader."CONS Project No." := ProgBillingHeader."Project No.";
        SalesHeader."CONS Retention Amount" := TotalRetention;
        SalesHeader.Modify(true);

        ProgBillingHeader.Status := ProgBillingHeader.Status::Invoiced;
        ProgBillingHeader.Modify(true);

        Message(InvoiceCreatedMsg, SalesHeader."No.");
        exit(SalesHeader."No.");
    end;

    local procedure BilledThisPeriod(ProgBillingLine: Record "CONS Progress Billing Line"): Decimal
    begin
        exit(ProgBillingLine."This Period Amount" + ProgBillingLine."Stored Materials");
    end;

    /// <summary>Creates the Billable planning line that carries one schedule-of-values line's period amount to the invoice.</summary>
    local procedure CreateBillingPlanningLine(ProgBillingHeader: Record "CONS Progress Billing Header"; ProgBillingLine: Record "CONS Progress Billing Line"; RevenueAccount: Code[20]; PostingDate: Date)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        ProgBillingLine.TestField("Job Task No.");
        JobPlanningLine.Init();
        JobPlanningLine.Validate("Job No.", ProgBillingHeader."Project No.");
        JobPlanningLine.Validate("Job Task No.", ProgBillingLine."Job Task No.");
        JobPlanningLine."Line No." := NextPlanningLineNo(ProgBillingHeader."Project No.", ProgBillingLine."Job Task No.");
        JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::Billable);
        JobPlanningLine.Validate("Planning Date", PostingDate);
        JobPlanningLine.Validate(Type, JobPlanningLine.Type::"G/L Account");
        JobPlanningLine.Validate("No.", RevenueAccount);
        JobPlanningLine.Validate(Quantity, 1);
        JobPlanningLine.Validate("Unit Price", BilledThisPeriod(ProgBillingLine));
        if ProgBillingLine.Description <> '' then
            JobPlanningLine.Description := ProgBillingLine.Description;
        JobPlanningLine."CONS Progress Billing No." := ProgBillingHeader."No.";
        JobPlanningLine.Insert(true);
        JobPlanningLine.Validate("Qty. to Transfer to Invoice", JobPlanningLine.Quantity);
        JobPlanningLine.Modify(true);
    end;

    local procedure NextPlanningLineNo(JobNo: Code[20]; JobTaskNo: Code[20]): Integer
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        if JobPlanningLine.FindLast() then
            exit(JobPlanningLine."Line No." + 10000);
        exit(10000);
    end;

    /// <summary>The sales invoice the standard project invoicing created for the application's planning lines.</summary>
    local procedure FindInvoiceNo(JobPlanningLine: Record "Job Planning Line"): Code[20]
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLineInvoice.SetRange("Job No.", JobPlanningLine."Job No.");
        JobPlanningLineInvoice.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        JobPlanningLineInvoice.SetRange("Job Planning Line No.", JobPlanningLine."Line No.");
        JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::Invoice);
        JobPlanningLineInvoice.FindLast();
        exit(JobPlanningLineInvoice."Document No.");
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
        NotCertifiedErr: Label 'Progress billing application %1 must be certified before it can be invoiced.', Comment = '%1 = application no.';
        NothingToInvoiceErr: Label 'There is nothing to invoice on this application (no period amounts).';
        BillToMismatchErr: Label 'The application is billed to customer %1, but project %2 is billed to customer %3. Project invoices always go to the project''s bill-to customer.', Comment = '%1 = application customer, %2 = project no., %3 = project customer';
        InvoiceCreatedMsg: Label 'Sales invoice %1 was created. Review and post it to record the retention.', Comment = '%1 = invoice no.';
        RetentionLineLbl: Label 'Retention withheld';
}
