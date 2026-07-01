namespace Construction.Scheduling;

using Construction.Core;

page 50465 "CONS Task Dependencies"
{
    PageType = List;
    ApplicationArea = CONSScheduling;
    UsageCategory = None;
    SourceTable = "CONS Task Dependency";
    Editable = true;
    Caption = 'Task Dependencies';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Job No."; Rec."Job No.") { }
                field("Job Task No."; Rec."Job Task No.") { }
                field("Predecessor Task No."; Rec."Predecessor Task No.") { }
                field("Dependency Type"; Rec."Dependency Type") { }
                field("Lag (Days)"; Rec."Lag (Days)") { }
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
