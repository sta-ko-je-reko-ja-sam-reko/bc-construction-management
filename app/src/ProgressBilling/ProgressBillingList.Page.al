namespace Construction.ProgressBilling;

using Construction.Core;

page 50157 "CONS Progress Billing List"
{
    PageType = List;
    ApplicationArea = CONSProgressBilling;
    UsageCategory = Documents;
    SourceTable = "CONS Progress Billing Header";
    CardPageId = "CONS Progress Billing";
    Caption = 'Progress Billing';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Application No."; Rec."Application No.") { }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { }
                field("Period End"; Rec."Period End") { }
                field("Retention %"; Rec."Retention %") { }
                field(Status; Rec.Status) { }
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
