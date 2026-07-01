namespace Construction.Subcontracts;

using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;

table 50254 "CONS Subc Claim Header"
{
    Caption = 'Subcontract Claim';
    DataClassification = CustomerContent;
    LookupPageId = "CONS Subc Claim List";
    DrillDownPageId = "CONS Subc Claim List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the subcontract claim.';
        }
        field(2; "Subcontract No."; Code[20])
        {
            Caption = 'Subcontract No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Subcontract Header"."No.";
            ToolTip = 'Specifies the subcontract the claim is made against.';

            trigger OnValidate()
            begin
                Logic().Validate_SubcontractNo(Rec, xRec);
            end;
        }
        field(3; "Claim No."; Integer)
        {
            Caption = 'Claim No.';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential claim number within the subcontract.';
        }
        field(5; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the subcontract belongs to.';
        }
        field(6; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Subcontractor No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";
            ToolTip = 'Specifies the subcontractor the claim is paid to.';
        }
        field(10; "Period Start"; Date)
        {
            Caption = 'Period Start';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the first day of the period this claim covers.';
        }
        field(11; "Period End"; Date)
        {
            Caption = 'Period End';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the last day of the period this claim covers.';
        }
        field(12; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the resulting purchase invoice is posted on.';
        }
        field(15; Status; Enum "CONS Subc Claim Status")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the claim is open, certified, or invoiced.';
        }
        field(20; "Retention %"; Decimal)
        {
            Caption = 'Retention %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the percentage withheld as retention from this claim.';
        }
        field(30; "This Period Amount"; Decimal)
        {
            Caption = 'This Period Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Subc Claim Line"."This Period Amount" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total value claimed this period.';
        }
        field(31; "Retention This Period"; Decimal)
        {
            Caption = 'Retention This Period';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Subc Claim Line"."Retention This Period" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total retention withheld this period.';
        }
        field(32; "Net Payable This Period"; Decimal)
        {
            Caption = 'Net Payable This Period';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Subc Claim Line"."Net Payable This Period" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the net amount payable this period after retention.';
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series the claim number was assigned from.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Subcontract; "Subcontract No.", "Claim No.")
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
        ILogic: Interface "CONS ISubcClaimHdr";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS ISubcClaimHdr"
    var
        Default: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative header-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS ISubcClaimHdr")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
