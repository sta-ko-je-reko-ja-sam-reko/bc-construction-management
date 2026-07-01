namespace Construction.Scheduling;

using Microsoft.Projects.Project.Job;

tableextension 50471 "CONS Sched Job" extends Job
{
    fields
    {
        field(50010; "CONS Planned Start Date"; Date)
        {
            Caption = 'Planned Start Date';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the earliest planned start date rolled up from the project''s scheduled tasks.';
        }
        field(50011; "CONS Planned End Date"; Date)
        {
            Caption = 'Planned End Date';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the latest planned end date rolled up from the project''s scheduled tasks.';
        }
        field(50012; "CONS Schedule % Complete"; Decimal)
        {
            Caption = 'Schedule % Complete';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
            ToolTip = 'Specifies the duration-weighted average progress rolled up from the project''s scheduled tasks, in percent.';
        }
    }
}
