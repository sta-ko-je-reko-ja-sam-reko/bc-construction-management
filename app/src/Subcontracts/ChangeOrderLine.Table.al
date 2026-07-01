namespace Construction.Subcontracts;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

table 50274 "CONS Change Order Line"
{
    Caption = 'Change Order Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Change Order Header"."No.";
            ToolTip = 'Specifies the change order the line belongs to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the line number.';
        }
        field(5; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("CONS Change Order Header"."Project No." where("No." = field("Document No.")));
            ToolTip = 'Specifies the project the change order varies.';
        }
        field(6; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
            ToolTip = 'Specifies the project task affected by the variation.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the variation line.';
        }
        field(15; "Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the construction cost type of the variation.';
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the value of the variation line (negative for an omission).';
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Totals; "Document No.")
        {
            SumIndexFields = Amount;
        }
    }
}
