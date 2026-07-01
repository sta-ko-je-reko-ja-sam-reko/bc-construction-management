namespace Construction.Subcontracts;

page 50264 "CONS Subc Claim Subform"
{
    PageType = ListPart;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Subc Claim Line";
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
                field("Scheduled Value"; Rec."Scheduled Value") { }
                field("Previous Amount"; Rec."Previous Amount") { }
                field("This Period Amount"; Rec."This Period Amount") { }
                field("Completed To Date"; Rec."Completed To Date") { }
                field("% Complete"; Rec."% Complete") { }
                field("Retention %"; Rec."Retention %") { }
                field("Retention This Period"; Rec."Retention This Period") { }
                field("Net Payable This Period"; Rec."Net Payable This Period") { }
            }
        }
    }
}
