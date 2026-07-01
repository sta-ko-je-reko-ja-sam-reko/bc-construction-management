namespace Construction.Subcontracts;

using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;

table 50273 "CONS Change Order Header"
{
    Caption = 'Change Order';
    DataClassification = CustomerContent;
    LookupPageId = "CONS Change Order List";
    DrillDownPageId = "CONS Change Order List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the change order.';
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No." where(Status = const(Open));
            ToolTip = 'Specifies the project the change order varies.';
        }
        field(5; "Change Type"; Enum "CONS Change Order Type")
        {
            Caption = 'Change Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the variation is to the owner contract value or to a subcontract.';
        }
        field(6; "Subcontract No."; Code[20])
        {
            Caption = 'Subcontract No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Subcontract Header"."No." where("Project No." = field("Project No."));
            ToolTip = 'Specifies the subcontract varied, for a subcontract change.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the change order.';
        }
        field(11; Reason; Text[250])
        {
            Caption = 'Reason';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the reason for the variation.';
        }
        field(15; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date of the change order.';
        }
        field(20; Status; Enum "CONS Change Order Status")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the change order is open, approved, rejected, or cancelled.';
        }
        field(30; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Change Order Line".Amount where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the net value of the variation (sum of the change order lines).';
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series the change order number was assigned from.';
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

    /// <summary>Applies (releases) the change order via the resolved logic implementation.</summary>
    procedure Apply()
    begin
        Logic().Apply(Rec);
    end;

    var
        ILogic: Interface "CONS IChangeOrderHeader";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IChangeOrderHeader"
    var
        Default: Codeunit "CONS Change Order Hdr Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative header-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS IChangeOrderHeader")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
