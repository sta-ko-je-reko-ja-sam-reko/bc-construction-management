namespace Construction.Setup;

page 50003 "CONS Construction Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CONS Construction Setup";
    Caption = 'Construction Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AboutTitle = 'About Construction Setup';
    AboutText = 'Configure number series, default cost type, and per-cost-type defaults for the Construction Management modules.';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Default Cost Type"; Rec."Default Cost Type") { }
            }
            group(Numbering)
            {
                Caption = 'Numbering';

                field("BoQ Nos."; Rec."BoQ Nos.") { }
                field("Progress Cert. Nos."; Rec."Progress Cert. Nos.") { }
                field("Progress Billing Nos."; Rec."Progress Billing Nos.") { }
                field("Subcontract Nos."; Rec."Subcontract Nos.") { }
                field("Subcontract Claim Nos."; Rec."Subcontract Claim Nos.") { }
                field("Change Order Nos."; Rec."Change Order Nos.") { }
            }
            group(Billing)
            {
                Caption = 'Progress Billing & Retention';

                field("Default Retention %"; Rec."Default Retention %") { }
                field("Revenue Account"; Rec."Revenue Account") { }
                field("Subcontract Cost Account"; Rec."Subcontract Cost Account") { }
                field("Retention Receivable Acc."; Rec."Retention Receivable Acc.") { }
                field("Retention Payable Acc."; Rec."Retention Payable Acc.") { }
            }
            part(CostTypes; "CONS Cost Type Setup")
            {
                Caption = 'Cost Type Defaults';
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitSetup();
    end;
}
