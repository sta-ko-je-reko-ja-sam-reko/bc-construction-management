namespace Construction.Scheduling;

using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;

table 50466 "CONS Resource Assignment"
{
    Caption = 'Resource Assignment';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique entry number of the assignment.';
        }
        field(5; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            DataClassification = CustomerContent;
            TableRelation = Resource;
            ToolTip = 'Specifies the resource that is assigned.';
        }
        field(10; "Job No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the resource is assigned to.';
        }
        field(11; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Job No."));
            ToolTip = 'Specifies the project task the resource is assigned to.';
        }
        field(15; "From Date"; Date)
        {
            Caption = 'From Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the resource assignment starts.';
        }
        field(16; "To Date"; Date)
        {
            Caption = 'To Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the resource assignment ends.';
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the planned hours or units of the resource assignment.';
        }
        field(25; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the resource assignment.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Task; "Job No.", "Job Task No.")
        {
        }
    }
}
