namespace Construction.Estimating;

using Construction.Core;

page 50056 "CONS Bill of Quantities List"
{
    PageType = List;
    ApplicationArea = CONSEstimating;
    UsageCategory = Documents;
    SourceTable = "CONS BoQ Header";
    CardPageId = "CONS Bill of Quantities";
    Caption = 'Bills of Quantities';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
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
                    ToolTip = 'Specifies the construction project this estimate belongs to.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the Bill of Quantities.';
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ToolTip = 'Specifies the total estimated cost.';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ToolTip = 'Specifies the total estimated price (with markup).';
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
