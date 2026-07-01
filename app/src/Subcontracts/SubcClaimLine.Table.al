namespace Construction.Subcontracts;

table 50255 "CONS Subc Claim Line"
{
    Caption = 'Subcontract Claim Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Subc Claim Header"."No.";
            ToolTip = 'Specifies the subcontract claim the line belongs to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the line number.';
        }
        field(5; "Subcontract Line No."; Integer)
        {
            Caption = 'Subcontract Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the subcontract scope line this claim line draws down.';
        }
        field(6; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the project task the claimed scope maps to.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the claimed scope line.';
        }
        field(15; "Scheduled Value"; Decimal)
        {
            Caption = 'Scheduled Value';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the agreed subcontract value for this scope line.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(20; "Previous Amount"; Decimal)
        {
            Caption = 'Previous Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the value claimed in prior claims.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(21; "This Period Amount"; Decimal)
        {
            Caption = 'This Period Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the value of work claimed this period.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(25; "Completed To Date"; Decimal)
        {
            Caption = 'Completed To Date';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the total value claimed to date (previous + this period).';
        }
        field(26; "% Complete"; Decimal)
        {
            Caption = '% Complete';
            Editable = false;
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the percentage of the scheduled value claimed to date.';
        }
        field(30; "Retention %"; Decimal)
        {
            Caption = 'Retention %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the percentage withheld as retention from this line.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(31; "Retention This Period"; Decimal)
        {
            Caption = 'Retention This Period';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the retention withheld from this line this period.';
        }
        field(32; "Net Payable This Period"; Decimal)
        {
            Caption = 'Net Payable This Period';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the net amount payable for this line this period after retention.';
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
            SumIndexFields = "This Period Amount", "Retention This Period", "Net Payable This Period";
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS ISubcClaimLine";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS ISubcClaimLine"
    var
        Default: Codeunit "CONS Subc Claim Line Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative line-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS ISubcClaimLine")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
