namespace Construction.Subcontracts;

using Construction.Core;

page 50262 "CONS Subcontract List"
{
    PageType = List;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = Documents;
    SourceTable = "CONS Subcontract Header";
    CardPageId = "CONS Subcontract";
    Caption = 'Subcontracts';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.") { }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { }
                field("Project No."; Rec."Project No.") { }
                field(Description; Rec.Description) { }
                field("Retention %"; Rec."Retention %") { }
                field("Subcontract Value"; Rec."Subcontract Value") { }
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
