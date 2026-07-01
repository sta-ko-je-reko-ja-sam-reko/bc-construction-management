namespace Construction.Equipment;

page 50425 "CONS Equipment Meter Entries"
{
    PageType = List;
    ApplicationArea = CONSEquipment;
    UsageCategory = None;
    SourceTable = "CONS Equipment Meter Entry";
    Editable = true;
    Caption = 'Equipment Meter Entries';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Equipment No."; Rec."Equipment No.") { }
                field("Reading Date"; Rec."Reading Date") { }
                field("Meter Reading"; Rec."Meter Reading") { }
                field(Description; Rec.Description) { }
            }
        }
    }
}
