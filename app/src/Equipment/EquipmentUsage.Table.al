namespace Construction.Equipment;

using Microsoft.Foundation.UOM;
using Microsoft.Projects.Project.Job;

table 50412 "CONS Equipment Usage"
{
    Caption = 'Equipment Usage';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the line number of the equipment usage entry.';
        }
        field(5; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Equipment";
            ToolTip = 'Specifies the equipment whose usage is being recorded.';

            trigger OnValidate()
            begin
                Logic().Validate_EquipmentNo(Rec);
            end;
        }
        field(6; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No." where(Status = const(Open));
            ToolTip = 'Specifies the project the equipment usage is posted to.';
        }
        field(7; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
            ToolTip = 'Specifies the project task the equipment usage is posted to.';
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment usage is posted on.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the equipment usage.';
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the quantity of equipment usage, in the unit of measure.';

            trigger OnValidate()
            begin
                Logic().Validate_Quantity(Rec);
            end;
        }
        field(21; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ToolTip = 'Specifies the unit of measure of the equipment usage.';
        }
        field(22; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the unit cost applied to the equipment usage.';

            trigger OnValidate()
            begin
                Logic().Validate_UnitCost(Rec);
            end;
        }
        field(25; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the total cost of the equipment usage (quantity times unit cost).';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS IEquipmentUsage";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IEquipmentUsage"
    var
        Default: Codeunit "CONS Equipment Usage Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative usage-logic implementation (tests / downstream overrides).</summary>
    /// <param name="Implementation">The logic implementation to use.</param>
    procedure Define(Implementation: Interface "CONS IEquipmentUsage")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
