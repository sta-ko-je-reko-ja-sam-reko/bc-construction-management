namespace Construction.Subcontracts;

page 50261 "CONS Subcontract Subform"
{
    PageType = ListPart;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Subcontract Line";
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
                field(Quantity; Rec.Quantity) { }
                field("Unit Cost"; Rec."Unit Cost") { }
                field("Line Amount"; Rec."Line Amount") { }
            }
        }
    }
}
