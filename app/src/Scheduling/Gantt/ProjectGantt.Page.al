namespace Construction.Scheduling;

using Construction.Core;
using Microsoft.Projects.Project.Job;

page 50474 "CONS Project Gantt"
{
    PageType = Card;
    ApplicationArea = CONSScheduling;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = Job;
    Caption = 'Project Gantt';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of the project.';
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies the description of the project.';
                }
            }
            group(Chart)
            {
                Caption = 'Schedule';
                ShowCaption = false;

                usercontrol(GanttControl; "CONS Gantt Chart")
                {
                    ApplicationArea = CONSScheduling;

                    trigger ControlAddInReady()
                    begin
                        Ready := true;
                        DrawForCurrentJob();
                    end;

                    trigger TaskClicked(JobTaskNo: Text)
                    var
                        JobTask: Record "Job Task";
                    begin
                        if JobTask.Get(Rec."No.", CopyStr(JobTaskNo, 1, MaxStrLen(JobTask."Job Task No."))) then
                            Page.Run(Page::"Job Task Card", JobTask);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                Caption = 'Recalculate';
                ToolTip = 'Rolls up the planned dates and progress onto the summary tasks and the project, then redraws the chart.';
                Image = Calculate;

                trigger OnAction()
                begin
                    ScheduleRollup.RollupProject(Rec."No.");
                    DrawForCurrentJob();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Recalculate_Promoted; Recalculate) { }
            }
        }
    }

    var
        ScheduleRollup: Codeunit "CONS Schedule Rollup";
        GanttData: Codeunit "CONS Gantt Data";
        Ready: Boolean;

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Scheduling & Resource Planning");
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DrawForCurrentJob();
    end;

    /// <summary>Builds the schedule JSON for the current project and pushes it to the control, once ready.</summary>
    local procedure DrawForCurrentJob()
    begin
        if not Ready then
            exit;
        if Rec."No." = '' then
            exit;
        CurrPage.GanttControl.DrawGantt(GanttData.BuildScheduleJson(Rec."No."));
    end;
}
