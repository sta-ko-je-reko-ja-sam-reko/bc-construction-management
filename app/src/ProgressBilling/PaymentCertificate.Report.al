namespace Construction.ProgressBilling;

report 50160 "CONS Payment Certificate"
{
    Caption = 'Payment Certificate';
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/ProgressBilling/PaymentCertificate.rdl';

    dataset
    {
        dataitem(Header; "CONS Progress Billing Header")
        {
            column(No_Header; "No.") { }
            column(ProjectNo_Header; "Project No.") { }
            column(ApplicationNo_Header; "Application No.") { }
            column(BillToCustomer_Header; "Bill-to Customer No.") { }
            column(PeriodStart_Header; "Period Start") { }
            column(PeriodEnd_Header; "Period End") { }
            column(RetentionPct_Header; "Retention %") { }
            column(ScheduledValue_Header; "Scheduled Value") { }
            column(ThisPeriodAmount_Header; "This Period Amount") { }
            column(RetentionThisPeriod_Header; "Retention This Period") { }
            column(NetDueThisPeriod_Header; "Net Due This Period") { }

            dataitem(Line; "CONS Progress Billing Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(JobTaskNo_Line; "Job Task No.") { }
                column(Description_Line; Description) { }
                column(ScheduledValue_Line; "Scheduled Value") { }
                column(PreviousAmount_Line; "Previous Amount") { }
                column(ThisPeriodAmount_Line; "This Period Amount") { }
                column(StoredMaterials_Line; "Stored Materials") { }
                column(CompletedToDate_Line; "Completed To Date") { }
                column(PctComplete_Line; "% Complete") { }
                column(RetentionThisPeriod_Line; "Retention This Period") { }
                column(NetDueThisPeriod_Line; "Net Due This Period") { }
            }

            trigger OnAfterGetRecord()
            begin
                Header.CalcFields("Scheduled Value", "This Period Amount", "Retention This Period", "Net Due This Period");
            end;
        }
    }
}
