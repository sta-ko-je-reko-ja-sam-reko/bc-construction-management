namespace Construction.Setup;

page 50004 "CONS Cost Type Setup"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "CONS Cost Type Setup";
    Caption = 'Cost Type Defaults';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Cost Type"; Rec."Cost Type")
                {
                    ToolTip = 'Specifies the construction cost type.';
                }
                field("Default G/L Account No."; Rec."Default G/L Account No.")
                {
                    ToolTip = 'Specifies the G/L account used when an estimate line of this cost type has no specific item, resource, or account and is pushed to the project budget.';
                }
                field("Default Work Type Code"; Rec."Default Work Type Code")
                {
                    ToolTip = 'Specifies the default work type for resource lines of this cost type.';
                }
            }
        }
    }
}
