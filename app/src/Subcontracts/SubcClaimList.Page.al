namespace Construction.Subcontracts;

using Construction.Core;

page 50265 "CONS Subc Claim List"
{
    PageType = List;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = Documents;
    SourceTable = "CONS Subc Claim Header";
    CardPageId = "CONS Subc Claim";
    Caption = 'Subcontract Claims';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.") { }
                field("Subcontract No."; Rec."Subcontract No.") { }
                field("Claim No."; Rec."Claim No.") { }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Period End"; Rec."Period End") { }
                field("Net Payable This Period"; Rec."Net Payable This Period") { }
                field(Status; Rec.Status) { }
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
