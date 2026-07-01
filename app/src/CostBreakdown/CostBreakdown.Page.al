namespace Construction.CostBreakdown;

using Construction.Core;
using Microsoft.Projects.Project.Job;

page 50101 "CONS Cost Breakdown"
{
    PageType = List;
    ApplicationArea = CONSCostControl;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Job Task";
    Caption = 'Construction Cost Breakdown';
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Tasks)
            {
                field("Job No."; Rec."Job No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the project the task belongs to.';
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the task number within the project''s cost breakdown.';
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies the description of the task.';
                }
                field("Job Task Type"; Rec."Job Task Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the task is a posting line or a totaling/heading line in the breakdown.';
                }
                field("CONS Cost Type"; Rec."CONS Cost Type")
                {
                    ToolTip = 'Specifies the construction cost type classification of the task.';
                }
                field(Budget; Rec."Schedule (Total Cost)")
                {
                    Caption = 'Budget (Total Cost)';
                    Editable = false;
                    ToolTip = 'Specifies the budgeted cost (sum of the task''s budget planning lines).';
                }
                field(Actual; Rec."Usage (Total Cost)")
                {
                    Caption = 'Actual (Total Cost)';
                    Editable = false;
                    ToolTip = 'Specifies the actual cost posted to the task (project ledger usage).';
                }
                field(Variance; VarianceAmount)
                {
                    Caption = 'Variance';
                    Editable = false;
                    ToolTip = 'Specifies the budget minus actual cost. Negative means over budget.';
                }
                field("CONS % Complete"; Rec."CONS % Complete")
                {
                    ToolTip = 'Specifies the manually entered progress of the task, in percent.';
                }
            }
        }
    }

    var
        VarianceAmount: Decimal;

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Cost Control");
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Schedule (Total Cost)", "Usage (Total Cost)");
        VarianceAmount := Rec."Schedule (Total Cost)" - Rec."Usage (Total Cost)";
    end;
}
