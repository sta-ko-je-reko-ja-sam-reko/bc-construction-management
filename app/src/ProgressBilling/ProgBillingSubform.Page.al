namespace Construction.ProgressBilling;

page 50156 "CONS Prog. Billing Subform"
{
    PageType = ListPart;
    ApplicationArea = CONSProgressBilling;
    UsageCategory = None;
    SourceTable = "CONS Progress Billing Line";
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
                field("Stored Materials"; Rec."Stored Materials") { }
                field("Completed To Date"; Rec."Completed To Date") { }
                field("% Complete"; Rec."% Complete") { }
                field("Retention %"; Rec."Retention %") { }
                field("Retention This Period"; Rec."Retention This Period") { }
                field("Net Due This Period"; Rec."Net Due This Period") { }
            }
        }
    }
}
