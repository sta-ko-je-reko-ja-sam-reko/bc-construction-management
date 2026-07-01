namespace Construction.Subcontracts;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

table 50253 "CONS Subcontract Line"
{
    Caption = 'Subcontract Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Subcontract Header"."No.";
            ToolTip = 'Specifies the subcontract the line belongs to.';
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
            CalcFormula = lookup("CONS Subcontract Header"."Project No." where("No." = field("Document No.")));
            ToolTip = 'Specifies the project the subcontract belongs to.';
        }
        field(6; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
            ToolTip = 'Specifies the project task the subcontracted scope maps to.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the subcontracted scope line.';
        }
        field(15; "Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the construction cost type of the subcontracted scope.';
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the quantity of the subcontracted scope line.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(25; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            ToolTip = 'Specifies the agreed unit cost of the subcontracted scope line.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(30; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the agreed amount for the line (quantity times unit cost).';
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
            SumIndexFields = "Line Amount";
        }
    }

    trigger OnInsert()
    begin
        Logic().Validate_Amounts(Rec);
    end;

    var
        ILogic: Interface "CONS ISubcontractLine";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS ISubcontractLine"
    var
        Default: Codeunit "CONS Subcontract Line Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative line-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS ISubcontractLine")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
