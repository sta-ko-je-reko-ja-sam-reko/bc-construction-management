namespace Construction.CostControl;

using Construction.Core;
using Microsoft.Projects.Project.Job;

page 50124 "CONS Project Cost Control"
{
    PageType = List;
    ApplicationArea = CONSCostControl;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Job Task";
    Caption = 'Project Cost Control';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Tasks)
            {
                field("Job No."; Rec."Job No.")
                {
                    ToolTip = 'Specifies the project the task belongs to.';
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ToolTip = 'Specifies the task number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the task.';
                }
                field(Budget; BudgetAmt)
                {
                    Caption = 'Budget';
                    ToolTip = 'Specifies the budgeted cost (schedule total cost).';
                }
                field(Committed; CommittedAmt)
                {
                    Caption = 'Committed';
                    ToolTip = 'Specifies the committed cost — outstanding amounts on open purchase documents linked to the task.';
                }
                field(Actual; ActualAmt)
                {
                    Caption = 'Actual';
                    ToolTip = 'Specifies the actual cost posted to the task (usage total cost).';
                }
                field(ETC; ETCAmt)
                {
                    Caption = 'Cost to Complete (ETC)';
                    ToolTip = 'Specifies the estimated remaining cost to complete the task.';
                }
                field(EAC; EACAmt)
                {
                    Caption = 'Estimate at Completion (EAC)';
                    ToolTip = 'Specifies the forecast final cost (actual + committed + cost to complete).';
                }
                field(Variance; VarianceAmt)
                {
                    Caption = 'Variance';
                    ToolTip = 'Specifies budget minus forecast (EAC). Negative means a forecast overrun.';
                    StyleExpr = VarianceStyle;
                }
                field("% Complete"; PctCompleteAmt)
                {
                    Caption = '% Complete';
                    ToolTip = 'Specifies the progress of the task, in percent (manual override, or cost-based default).';
                }
            }
        }
    }

    var
        BudgetAmt, CommittedAmt, ActualAmt, ETCAmt, EACAmt, VarianceAmt, PctCompleteAmt : Decimal;
        VarianceStyle: Text;

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Cost Control");
    end;

    trigger OnAfterGetRecord()
    var
        Forecast: Codeunit "CONS Cost Forecast";
    begin
        Forecast.CalcForecast(Rec, BudgetAmt, CommittedAmt, ActualAmt, ETCAmt, EACAmt, VarianceAmt, PctCompleteAmt);
        if VarianceAmt < 0 then
            VarianceStyle := 'Unfavorable'
        else
            VarianceStyle := 'Favorable';
    end;
}
