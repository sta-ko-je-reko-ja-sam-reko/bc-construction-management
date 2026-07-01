namespace Construction.Equipment;

using Microsoft.Projects.Project.Job;

table 50415 "CONS Equipment Assignment"
{
    Caption = 'Equipment Assignment';
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
        field(5; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Equipment";
            ToolTip = 'Specifies the equipment that is assigned.';
        }
        field(10; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the equipment is assigned to.';
        }
        field(11; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
            ToolTip = 'Specifies the project task the equipment is assigned to.';
        }
        field(15; "From Date"; Date)
        {
            Caption = 'From Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment assignment starts.';
        }
        field(16; "To Date"; Date)
        {
            Caption = 'To Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment assignment ends.';
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the equipment assignment.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Equipment; "Equipment No.")
        {
        }
    }
}
