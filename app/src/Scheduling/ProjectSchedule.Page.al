namespace Construction.Scheduling;

using Construction.Core;
using Microsoft.Projects.Project.Job;

page 50473 "CONS Project Schedule"
{
    PageType = List;
    ApplicationArea = CONSScheduling;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Job Task";
    Caption = 'Project Schedule';
    Editable = true;

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
                field(Indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                    ToolTip = 'Specifies the outline level of the task. Higher values are nested deeper under summary tasks.';
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ToolTip = 'Specifies the task number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the task.';
                }
                field("Job Task Type"; Rec."Job Task Type")
                {
                    ToolTip = 'Specifies whether the task is a posting line, a heading, a total, or an outline boundary.';
                }
                field("CONS Planned Start Date"; Rec."CONS Planned Start Date")
                {
                    ToolTip = 'Specifies the planned start date of the task in the schedule.';
                }
                field("CONS Planned End Date"; Rec."CONS Planned End Date")
                {
                    ToolTip = 'Specifies the planned end date of the task in the schedule.';
                }
                field("CONS Duration (Days)"; Rec."CONS Duration (Days)")
                {
                    ToolTip = 'Specifies the planned duration of the task in days.';
                }
                field("CONS % Complete"; Rec."CONS % Complete")
                {
                    ToolTip = 'Specifies the progress of the task, in percent.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Gantt)
            {
                Caption = 'Gantt';
                ToolTip = 'Opens a read-only Gantt chart of the schedule for the current row''s project.';
                Image = Timeline;
                RunObject = page "CONS Project Gantt";
                RunPageLink = "No." = field("Job No.");
            }
        }
        area(Processing)
        {
            action(CalculateSchedule)
            {
                Caption = 'Calculate Schedule';
                ToolTip = 'Rolls up planned dates and progress onto the summary tasks and the project for the current row''s project.';
                Image = Calculate;

                trigger OnAction()
                var
                    ScheduleRollup: Codeunit "CONS Schedule Rollup";
                begin
                    ScheduleRollup.RollupProject(Rec."Job No.");
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CalculateSchedule_Promoted; CalculateSchedule) { }
                actionref(Gantt_Promoted; Gantt) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Scheduling & Resource Planning");
    end;
}
