namespace Construction.Estimating;

page 50055 "CONS BoQ Subform"
{
    PageType = ListPart;
    ApplicationArea = CONSEstimating;
    SourceTable = "CONS BoQ Line";
    Caption = 'Lines';
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;

                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies whether the line is a costed position, a heading, or a comment.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies whether the position references a resource, item, or G/L account. Leave blank to cost by cost type only.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the resource, item, or G/L account number for the position.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the line.';
                }
                field("Cost Type"; Rec."Cost Type")
                {
                    ToolTip = 'Specifies the construction cost type the position belongs to.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure for the quantity.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of the position.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the cost per unit.';
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ToolTip = 'Specifies the total cost of the line (quantity times unit cost).';
                }
                field("Markup %"; Rec."Markup %")
                {
                    ToolTip = 'Specifies the markup percentage applied to the unit cost to derive the unit price.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the price per unit (unit cost plus markup).';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ToolTip = 'Specifies the total price of the line.';
                }
                field("Project Task No."; Rec."Project Task No.")
                {
                    ToolTip = 'Specifies the project task this position is budgeted against when the BoQ is pushed to the project budget.';
                }
                field("Linked Job Planning Line No."; Rec."Linked Job Planning Line No.")
                {
                    ToolTip = 'Specifies the project planning line created from this position. Non-zero means the line was already pushed to the budget.';
                    Visible = false;
                }
            }
        }
    }
}
