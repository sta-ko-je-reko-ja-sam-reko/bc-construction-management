namespace Construction.ProgressBilling;

using Construction.Core;

page 50155 "CONS Progress Billing"
{
    PageType = Document;
    ApplicationArea = CONSProgressBilling;
    UsageCategory = None;
    SourceTable = "CONS Progress Billing Header";
    Caption = 'Progress Billing';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Application No."; Rec."Application No.") { }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { }
                field("Period Start"; Rec."Period Start") { }
                field("Period End"; Rec."Period End") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Retention %"; Rec."Retention %") { }
                field(Status; Rec.Status) { }
            }
            part(Lines; "CONS Prog. Billing Subform")
            {
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Totals)
            {
                field("Scheduled Value"; Rec."Scheduled Value") { }
                field("This Period Amount"; Rec."This Period Amount") { }
                field("Retention This Period"; Rec."Retention This Period") { }
                field("Net Due This Period"; Rec."Net Due This Period") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SeedScheduleOfValues)
            {
                Caption = 'Suggest Schedule of Values';
                Image = SuggestLines;
                ToolTip = 'Creates schedule-of-values lines from the project''s billable planning lines.';

                trigger OnAction()
                var
                    Seed: Codeunit "CONS Prog. Billing Seed";
                begin
                    Seed.SeedFromProject(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Certify)
            {
                Caption = 'Certify';
                Image = Approve;
                ToolTip = 'Certifies the application, locking it for invoicing.';

                trigger OnAction()
                begin
                    Rec.TestField("Project No.");
                    Rec.Status := Rec.Status::Certified;
                    Rec.Modify(true);
                end;
            }
            action(CreateSalesInvoice)
            {
                Caption = 'Create Sales Invoice';
                Image = Invoice;
                ToolTip = 'Creates a draft sales invoice for this application, with the retention withheld on a separate G/L line.';

                trigger OnAction()
                var
                    ProgBillingInvoice: Codeunit "CONS Prog. Billing Invoice";
                begin
                    ProgBillingInvoice.CreateInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(PrintCertificate)
            {
                Caption = 'Print Payment Certificate';
                Image = Print;
                ToolTip = 'Prints the payment certificate (schedule of values, completion, retention and net due) for this application.';

                trigger OnAction()
                var
                    ProgBillingHeader: Record "CONS Progress Billing Header";
                begin
                    ProgBillingHeader := Rec;
                    ProgBillingHeader.SetRecFilter();
                    Report.Run(Report::"CONS Payment Certificate", true, false, ProgBillingHeader);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SeedScheduleOfValues_Promoted; SeedScheduleOfValues) { }
                actionref(Certify_Promoted; Certify) { }
                actionref(CreateSalesInvoice_Promoted; CreateSalesInvoice) { }
                actionref(PrintCertificate_Promoted; PrintCertificate) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
    end;
}
