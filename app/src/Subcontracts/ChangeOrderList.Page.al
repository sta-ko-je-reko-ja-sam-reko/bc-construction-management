namespace Construction.Subcontracts;

using Construction.Core;

page 50279 "CONS Change Order List"
{
    PageType = List;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = Documents;
    SourceTable = "CONS Change Order Header";
    CardPageId = "CONS Change Order";
    Caption = 'Change Orders';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Change Type"; Rec."Change Type") { }
                field("Subcontract No."; Rec."Subcontract No.") { }
                field(Description; Rec.Description) { }
                field("Total Amount"; Rec."Total Amount") { }
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
