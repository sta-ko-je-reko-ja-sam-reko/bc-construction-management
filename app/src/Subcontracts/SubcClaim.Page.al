namespace Construction.Subcontracts;

using Construction.Core;

page 50263 "CONS Subc Claim"
{
    PageType = Document;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Subc Claim Header";
    Caption = 'Subcontract Claim';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field("Subcontract No."; Rec."Subcontract No.") { }
                field("Claim No."; Rec."Claim No.") { }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Period Start"; Rec."Period Start") { }
                field("Period End"; Rec."Period End") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Retention %"; Rec."Retention %") { }
                field(Status; Rec.Status) { }
            }
            part(Lines; "CONS Subc Claim Subform")
            {
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Totals)
            {
                field("This Period Amount"; Rec."This Period Amount") { }
                field("Retention This Period"; Rec."Retention This Period") { }
                field("Net Payable This Period"; Rec."Net Payable This Period") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SeedFromSubcontract)
            {
                Caption = 'Suggest Claim Lines';
                Image = SuggestLines;
                ToolTip = 'Creates claim lines from the subcontract''s scope lines.';

                trigger OnAction()
                var
                    Seed: Codeunit "CONS Subc Claim Seed";
                begin
                    Seed.SeedFromSubcontract(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Certify)
            {
                Caption = 'Certify';
                Image = Approve;
                ToolTip = 'Certifies the claim, locking it for invoicing.';

                trigger OnAction()
                begin
                    Rec.TestField("Subcontract No.");
                    Rec.Status := Rec.Status::Certified;
                    Rec.Modify(true);
                end;
            }
            action(CreatePurchaseInvoice)
            {
                Caption = 'Create Purchase Invoice';
                Image = Invoice;
                ToolTip = 'Creates a draft purchase invoice for this claim, with the retention withheld on a separate G/L line.';

                trigger OnAction()
                var
                    SubcClaimInvoice: Codeunit "CONS Subc Claim Invoice";
                begin
                    SubcClaimInvoice.CreateInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SeedFromSubcontract_Promoted; SeedFromSubcontract) { }
                actionref(Certify_Promoted; Certify) { }
                actionref(CreatePurchaseInvoice_Promoted; CreatePurchaseInvoice) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
    end;
}
