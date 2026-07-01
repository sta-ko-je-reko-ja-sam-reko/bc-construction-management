namespace Construction.Estimating;

using Construction.Core;

page 50054 "CONS Bill of Quantities"
{
    PageType = Document;
    ApplicationArea = CONSEstimating;
    UsageCategory = None;
    SourceTable = "CONS BoQ Header";
    Caption = 'Bill of Quantities';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the Bill of Quantities.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Bill of Quantities.';
                }
                field("Project No."; Rec."Project No.")
                {
                    ToolTip = 'Specifies the construction project this estimate belongs to. Leave blank for a standalone tender.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the customer the estimate is addressed to.';
                }
                field("Estimator Code"; Rec."Estimator Code")
                {
                    ToolTip = 'Specifies the salesperson/purchaser responsible for the estimate.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the Bill of Quantities.';
                }
            }
            part(Lines; "CONS BoQ Subform")
            {
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Pricing)
            {
                Caption = 'Pricing';

                field("Default Markup %"; Rec."Default Markup %")
                {
                    ToolTip = 'Specifies the default markup percentage applied to new position lines.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of the estimate.';
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ToolTip = 'Specifies the total estimated cost of all position lines.';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ToolTip = 'Specifies the total estimated price (with markup) of all position lines.';
                }
            }
            group(Schedule)
            {
                Caption = 'Schedule';

                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the planned start date; used as the planning date when pushing to the budget.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the planned end date.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateBudget)
            {
                Caption = 'Create Project Budget';
                ToolTip = 'Generates project planning lines of type Budget from the costed position lines onto the linked project''s tasks.';
                Image = CreateLinesFromJob;

                trigger OnAction()
                var
                    BoQCreateBudget: Codeunit "CONS BoQ Create Budget";
                begin
                    BoQCreateBudget.CreateBudget(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateBudget_Promoted; CreateBudget)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Estimating);
    end;
}
