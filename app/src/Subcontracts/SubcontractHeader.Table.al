namespace Construction.Subcontracts;

using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;

table 50252 "CONS Subcontract Header"
{
    Caption = 'Subcontract';
    DataClassification = CustomerContent;
    LookupPageId = "CONS Subcontract List";
    DrillDownPageId = "CONS Subcontract List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the subcontract.';
        }
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Subcontractor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";
            ToolTip = 'Specifies the subcontractor (vendor) the work is contracted to.';

            trigger OnValidate()
            begin
                Logic().Validate_VendorNo(Rec, xRec);
            end;
        }
        field(5; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No." where(Status = const(Open));
            ToolTip = 'Specifies the project the subcontract belongs to.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the subcontracted scope.';
        }
        field(15; Status; Enum "CONS Subcontract Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the subcontract is open, released for claims, or closed.';
        }
        field(20; "Retention %"; Decimal)
        {
            Caption = 'Retention %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the percentage withheld as retention from subcontractor claims.';
        }
        field(25; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the subcontracted work starts.';
        }
        field(26; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the subcontracted work is due to complete.';
        }
        field(30; "Subcontract Value"; Decimal)
        {
            Caption = 'Subcontract Value';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Subcontract Line"."Line Amount" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total agreed value of the subcontract.';
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series the subcontract number was assigned from.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Project; "Project No.")
        {
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
        ILogic: Interface "CONS ISubcontractHeader";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS ISubcontractHeader"
    var
        Default: Codeunit "CONS Subcontract Header Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative header-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS ISubcontractHeader")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
