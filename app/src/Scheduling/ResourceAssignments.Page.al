namespace Construction.Scheduling;

using Construction.Core;

page 50467 "CONS Resource Assignments"
{
    PageType = List;
    ApplicationArea = CONSScheduling;
    UsageCategory = None;
    SourceTable = "CONS Resource Assignment";
    Editable = true;
    Caption = 'Resource Assignments';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Resource No."; Rec."Resource No.") { }
                field("Job No."; Rec."Job No.") { }
                field("Job Task No."; Rec."Job Task No.") { }
                field("From Date"; Rec."From Date") { }
                field("To Date"; Rec."To Date") { }
                field(Quantity; Rec.Quantity) { }
                field(Description; Rec.Description) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Scheduling & Resource Planning");
    end;
}
