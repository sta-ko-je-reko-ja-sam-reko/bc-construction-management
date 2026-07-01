namespace Construction.Subcontracts;

page 50278 "CONS Change Order Subform"
{
    PageType = ListPart;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Change Order Line";
    Caption = 'Lines';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Job Task No."; Rec."Job Task No.") { }
                field(Description; Rec.Description) { }
                field("Cost Type"; Rec."Cost Type") { }
                field(Amount; Rec.Amount) { }
            }
        }
    }
}
