namespace Construction.Scheduling;

using Microsoft.Projects.Project.Job;

table 50464 "CONS Task Dependency"
{
    Caption = 'Task Dependency';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Job No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the dependency belongs to.';
        }
        field(2; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Job No."));
            ToolTip = 'Specifies the successor task that depends on the predecessor task.';
        }
        field(3; "Predecessor Task No."; Code[20])
        {
            Caption = 'Predecessor Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Job No."));
            ToolTip = 'Specifies the predecessor task that must precede the successor task.';
        }
        field(10; "Dependency Type"; Enum "CONS Dependency Type")
        {
            Caption = 'Dependency Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the predecessor and successor tasks are linked in the schedule.';
        }
        field(15; "Lag (Days)"; Decimal)
        {
            Caption = 'Lag (Days)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the delay, in days, applied to the dependency.';
        }
    }

    keys
    {
        key(PK; "Job No.", "Job Task No.", "Predecessor Task No.")
        {
            Clustered = true;
        }
    }
}
