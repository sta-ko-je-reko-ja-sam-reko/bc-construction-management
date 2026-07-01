namespace Construction.Core;

using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;

page 50022 "CONS Construction Activities"
{
    PageType = CardPart;
    SourceTable = "CONS Activities Cue";
    Caption = 'Construction Activities';

    layout
    {
        area(Content)
        {
            cuegroup(ProjectsGrp)
            {
                Caption = 'Projects';

                field("Construction Projects"; Rec."Construction Projects")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Job List";
                    ToolTip = 'Specifies the number of projects flagged as construction projects. Choose the number to open the project list.';
                }
                field("Active Projects"; Rec."Active Projects")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Job List";
                    ToolTip = 'Specifies the number of open construction projects.';
                }
            }
            cuegroup(EstimatingGrp)
            {
                Caption = 'Estimating';

                field("Bills of Quantities"; Rec."Bills of Quantities")
                {
                    ApplicationArea = CONSEstimating;
                    DrillDownPageId = "CONS Bill of Quantities List";
                    ToolTip = 'Specifies the number of bills of quantities. Choose the number to open the list.';
                }
            }
            cuegroup(ProgressBillingGrp)
            {
                Caption = 'Progress Billing';

                field("Progress Billing Applications"; Rec."Progress Billing Applications")
                {
                    ApplicationArea = CONSProgressBilling;
                    DrillDownPageId = "CONS Progress Billing List";
                    ToolTip = 'Specifies the number of progress billing applications. Choose the number to open the list.';
                }
            }
            cuegroup(SubcontractsGrp)
            {
                Caption = 'Subcontracts';

                field(Subcontracts; Rec.Subcontracts)
                {
                    ApplicationArea = CONSSubcontracts;
                    DrillDownPageId = "CONS Subcontract List";
                    ToolTip = 'Specifies the number of subcontracts. Choose the number to open the list.';
                }
                field("Change Orders"; Rec."Change Orders")
                {
                    ApplicationArea = CONSSubcontracts;
                    DrillDownPageId = "CONS Change Order List";
                    ToolTip = 'Specifies the number of change orders. Choose the number to open the list.';
                }
                field("Subcontractor Claims"; Rec."Subcontractor Claims")
                {
                    ApplicationArea = CONSSubcontracts;
                    DrillDownPageId = "CONS Subc Claim List";
                    ToolTip = 'Specifies the number of subcontractor claims. Choose the number to open the list.';
                }
            }
            cuegroup(EquipmentGrp)
            {
                Caption = 'Equipment & Plant';

                field("Equipment Items"; Rec."Equipment Items")
                {
                    ApplicationArea = CONSEquipment;
                    DrillDownPageId = "CONS Equipment List";
                    ToolTip = 'Specifies the number of equipment records. Choose the number to open the list.';
                }
                field("Equipment In Maintenance"; Rec."Equipment In Maintenance")
                {
                    ApplicationArea = CONSEquipment;
                    DrillDownPageId = "CONS Equipment List";
                    ToolTip = 'Specifies the number of equipment items currently in maintenance.';
                }
            }
            cuegroup(SchedulingGrp)
            {
                Caption = 'Scheduling';

                field("Scheduled Tasks"; Rec."Scheduled Tasks")
                {
                    ApplicationArea = CONSScheduling;
                    DrillDownPageId = "CONS Project Schedule";
                    ToolTip = 'Specifies the number of project tasks placed on the schedule. Choose the number to open the schedule.';
                }
            }
            group(GanttGroup)
            {
                Caption = 'Project Schedule';
                Visible = HasGanttProject;

                usercontrol(Gantt; "CONS Gantt Chart")
                {
                    ApplicationArea = CONSScheduling;

                    trigger ControlAddInReady()
                    begin
                        GanttReady := true;
                        DrawGantt();
                    end;

                    trigger TaskClicked(JobTaskNo: Text)
                    var
                        JobTask: Record "Job Task";
                    begin
                        if JobTask.Get(GanttProjectNo, CopyStr(JobTaskNo, 1, MaxStrLen(JobTask."Job Task No."))) then
                            Page.Run(Page::"Job Task Card", JobTask);
                    end;
                }
            }
        }
    }

    var
        GanttData: Codeunit "CONS Gantt Data";
        GanttProjectNo: Code[20];
        GanttReady: Boolean;
        HasGanttProject: Boolean;
        CueTaskId: Integer;

    trigger OnOpenPage()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        Rec.InitCue();
        GanttProjectNo := GanttData.FindDefaultScheduledProject();
        HasGanttProject := GanttProjectNo <> '';
        CurrPage.EnqueueBackgroundTask(CueTaskId, Codeunit::"CONS Activities Cue Calc", TaskParameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> CueTaskId then
            exit;
        SetCue(Rec."Construction Projects", Results, Rec.FieldNo("Construction Projects"));
        SetCue(Rec."Active Projects", Results, Rec.FieldNo("Active Projects"));
        SetCue(Rec."Bills of Quantities", Results, Rec.FieldNo("Bills of Quantities"));
        SetCue(Rec."Progress Billing Applications", Results, Rec.FieldNo("Progress Billing Applications"));
        SetCue(Rec.Subcontracts, Results, Rec.FieldNo(Subcontracts));
        SetCue(Rec."Change Orders", Results, Rec.FieldNo("Change Orders"));
        SetCue(Rec."Subcontractor Claims", Results, Rec.FieldNo("Subcontractor Claims"));
        SetCue(Rec."Equipment Items", Results, Rec.FieldNo("Equipment Items"));
        SetCue(Rec."Equipment In Maintenance", Results, Rec.FieldNo("Equipment In Maintenance"));
        SetCue(Rec."Scheduled Tasks", Results, Rec.FieldNo("Scheduled Tasks"));
        CurrPage.Update(false);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        if TaskId = CueTaskId then
            IsHandled := true;
    end;

    local procedure SetCue(var Target: Integer; Results: Dictionary of [Text, Text]; CueFieldNo: Integer)
    var
        Value: Integer;
    begin
        if Results.ContainsKey(Format(CueFieldNo)) then
            if Evaluate(Value, Results.Get(Format(CueFieldNo))) then
                Target := Value;
    end;

    local procedure DrawGantt()
    begin
        if not GanttReady then
            exit;
        if GanttProjectNo = '' then
            exit;
        CurrPage.Gantt.DrawGantt(GanttData.BuildScheduleJson(GanttProjectNo));
    end;
}
