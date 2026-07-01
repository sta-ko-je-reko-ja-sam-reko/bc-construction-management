namespace Construction.Estimating;

using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Customer;

table 50052 "CONS BoQ Header"
{
    Caption = 'Bill of Quantities';
    DataClassification = CustomerContent;
    LookupPageId = "CONS Bill of Quantities List";
    DrillDownPageId = "CONS Bill of Quantities List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
        }
        field(6; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(10; Status; Enum "CONS BoQ Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(11; "Estimator Code"; Code[20])
        {
            Caption = 'Estimator';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency.Code;
        }
        field(20; "Default Markup %"; Decimal)
        {
            Caption = 'Default Markup %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(25; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(26; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(30; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS BoQ Line"."Total Cost" where("Document No." = field("No.")));
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(31; "Total Price"; Decimal)
        {
            Caption = 'Total Price';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS BoQ Line"."Total Price" where("Document No." = field("No.")));
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    trigger OnDelete()
    begin
        Logic().Trigger_OnDelete(Rec);
    end;

    var
        ILogic: Interface "CONS IBoQHeader";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IBoQHeader"
    var
        Default: Codeunit "CONS BoQ Header Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative header-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS IBoQHeader")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
