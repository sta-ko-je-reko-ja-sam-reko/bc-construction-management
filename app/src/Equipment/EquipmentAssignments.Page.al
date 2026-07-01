namespace Construction.Equipment;

page 50426 "CONS Equipment Assignments"
{
    PageType = List;
    ApplicationArea = CONSEquipment;
    UsageCategory = None;
    SourceTable = "CONS Equipment Assignment";
    Editable = true;
    Caption = 'Equipment Assignments';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Equipment No."; Rec."Equipment No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Job Task No."; Rec."Job Task No.") { }
                field("From Date"; Rec."From Date") { }
                field("To Date"; Rec."To Date") { }
                field(Description; Rec.Description) { }
            }
        }
    }
}
