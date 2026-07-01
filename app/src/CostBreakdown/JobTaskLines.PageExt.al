namespace Construction.CostBreakdown;

using Construction.CostControl;
using Microsoft.Projects.Project.Job;

pageextension 50102 "CONS Job Task Lines" extends "Job Task Lines"
{
    layout
    {
        addafter(Description)
        {
            field("CONS Cost Type"; Rec."CONS Cost Type")
            {
                ApplicationArea = CONSCostControl;
                ToolTip = 'Specifies the construction cost type classification of the task.';
            }
            field("CONS % Complete"; Rec."CONS % Complete")
            {
                ApplicationArea = CONSCostControl;
                ToolTip = 'Specifies the manually entered progress of the task, in percent.';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("CONS Cost Breakdown")
            {
                ApplicationArea = CONSCostControl;
                Caption = 'Cost Breakdown';
                ToolTip = 'Opens the construction cost breakdown (budget, actual, variance) for this project.';
                Image = CostBudget;
                RunObject = page "CONS Cost Breakdown";
                RunPageLink = "Job No." = field("Job No.");
            }
            action("CONS Project Cost Control")
            {
                ApplicationArea = CONSCostControl;
                Caption = 'Cost Control';
                ToolTip = 'Opens budget vs committed vs actual cost control with EAC/ETC forecasting for this project.';
                Image = Costs;
                RunObject = page "CONS Project Cost Control";
                RunPageLink = "Job No." = field("Job No.");
            }
        }
    }
}
