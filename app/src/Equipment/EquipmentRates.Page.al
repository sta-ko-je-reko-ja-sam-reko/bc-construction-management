namespace Construction.Equipment;

page 50422 "CONS Equipment Rates"
{
    PageType = List;
    ApplicationArea = CONSEquipment;
    UsageCategory = None;
    SourceTable = "CONS Equipment Rate";
    Caption = 'Equipment Rates';

    layout
    {
        area(content)
        {
            repeater(Rates)
            {
                field("Equipment No."; Rec."Equipment No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Starting Date"; Rec."Starting Date") { }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { }
                field("Unit Cost"; Rec."Unit Cost") { }
                field("Hire Rate"; Rec."Hire Rate") { }
            }
        }
    }
}
