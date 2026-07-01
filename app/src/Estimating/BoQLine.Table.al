namespace Construction.Estimating;

using Construction.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;

table 50053 "CONS BoQ Line"
{
    Caption = 'BoQ Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS BoQ Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line Type"; Enum "CONS BoQ Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Logic().Validate_LineType(Rec);
            end;
        }
        field(4; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Resource,Item,"G/L Account";
            OptionCaption = ' ,Resource,Item,G/L Account';

            trigger OnValidate()
            begin
                Logic().Validate_Type(Rec, xRec);
            end;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Resource)) Resource."No."
            else if (Type = const(Item)) Item."No."
            else if (Type = const("G/L Account")) "G/L Account"."No.";

            trigger OnValidate()
            begin
                Logic().Validate_No(Rec);
            end;
        }
        field(7; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("CONS BoQ Header"."Project No." where("No." = field("Document No.")));
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
        }
        field(20; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(25; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(30; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = GetCurrencyCode();

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(31; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = GetCurrencyCode();
        }
        field(35; "Markup %"; Decimal)
        {
            Caption = 'Markup %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(40; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = GetCurrencyCode();
        }
        field(41; "Total Price"; Decimal)
        {
            Caption = 'Total Price';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = GetCurrencyCode();
        }
        field(50; "Project Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
        }
        field(55; "Linked Job Planning Line No."; Integer)
        {
            Caption = 'Linked Project Planning Line No.';
            Editable = false;
            DataClassification = CustomerContent;
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
            SumIndexFields = "Total Cost", "Total Price";
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS IBoQLine";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IBoQLine"
    var
        Default: Codeunit "CONS BoQ Line Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative line-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS IBoQLine")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;

    /// <summary>Presentation helper for AutoFormatExpression — stays on the table (not business logic).</summary>
    local procedure GetCurrencyCode(): Code[10]
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        if BoQHeader.Get("Document No.") then
            exit(BoQHeader."Currency Code");
        exit('');
    end;
}
