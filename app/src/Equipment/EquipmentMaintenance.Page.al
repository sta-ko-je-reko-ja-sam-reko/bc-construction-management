namespace Construction.Equipment;

page 50424 "CONS Equipment Maintenance"
{
    PageType = List;
    ApplicationArea = CONSEquipment;
    UsageCategory = None;
    SourceTable = "CONS Equipment Maintenance";
    Editable = true;
    Caption = 'Equipment Maintenance';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Equipment No."; Rec."Equipment No.") { }
                field("Maintenance Date"; Rec."Maintenance Date") { }
                field("Maintenance Type"; Rec."Maintenance Type") { }
                field(Description; Rec.Description) { }
                field("Meter Reading"; Rec."Meter Reading") { }
                field(Cost; Rec.Cost) { }
                field("Vendor No."; Rec."Vendor No.") { }
                field("Next Service Date"; Rec."Next Service Date") { }
                field("Next Service Meter"; Rec."Next Service Meter") { }
            }
        }
    }
}
