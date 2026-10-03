namespace Construction.Scheduling;

using Microsoft.Projects.Project.Job;

tableextension 60463 "CONS Sched Job Task" extends "Job Task"
{
    fields
    {
        field(60010; "CONS Planned Start Date"; Date)
        {
            Caption = 'Planned Start Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the planned start date of the task in the schedule.';
        }
        field(60011; "CONS Planned End Date"; Date)
        {
            Caption = 'Planned End Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the planned end date of the task in the schedule.';
        }
        field(60012; "CONS Duration (Days)"; Decimal)
        {
            Caption = 'Duration (Days)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the planned duration of the task in days.';
        }
        field(60013; "CONS Scheduled"; Boolean)
        {
            Caption = 'Scheduled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the task has been placed on the schedule.';
        }
    }
}
