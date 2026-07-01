namespace Construction.ProgressBilling;

using Microsoft.Projects.Project.Job;

table 50151 "CONS Progress Billing Line"
{
    Caption = 'Progress Billing Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Progress Billing Header"."No.";
            ToolTip = 'Specifies the progress billing application the line belongs to.';
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
            CalcFormula = lookup("CONS Progress Billing Header"."Project No." where("No." = field("Document No.")));
            ToolTip = 'Specifies the project the application bills.';
        }
        field(6; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No."));
            ToolTip = 'Specifies the project task this schedule-of-values line bills against.';
        }
        field(7; "Job Planning Line No."; Integer)
        {
            Caption = 'Project Planning Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the billable project planning line this schedule-of-values line was seeded from.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the schedule-of-values line.';
        }
        field(15; "Scheduled Value"; Decimal)
        {
            Caption = 'Scheduled Value';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the contract value scheduled for this line.';

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
            ToolTip = 'Specifies the value completed in prior applications.';

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
            ToolTip = 'Specifies the value of work completed this period.';

            trigger OnValidate()
            begin
                Logic().Validate_Amounts(Rec);
            end;
        }
        field(22; "Stored Materials"; Decimal)
        {
            Caption = 'Stored Materials';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies materials presently stored but not yet incorporated into the work.';

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
            ToolTip = 'Specifies the total value completed and stored to date (previous + this period + stored).';
        }
        field(26; "% Complete"; Decimal)
        {
            Caption = '% Complete';
            Editable = false;
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the percentage of the scheduled value completed to date.';
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
        field(32; "Net Due This Period"; Decimal)
        {
            Caption = 'Net Due This Period';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the net amount due for this line this period after retention.';
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
            SumIndexFields = "Scheduled Value", "This Period Amount", "Retention This Period", "Net Due This Period";
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS IProgBillingLine";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IProgBillingLine"
    var
        Default: Codeunit "CONS Prog. Billing Line Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative line-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS IProgBillingLine")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
