namespace Construction.ProgressBilling;

using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Customer;

table 50150 "CONS Progress Billing Header"
{
    Caption = 'Progress Billing';
    DataClassification = CustomerContent;
    LookupPageId = "CONS Progress Billing List";
    DrillDownPageId = "CONS Progress Billing List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the progress billing application.';
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No." where(Status = const(Open));
            ToolTip = 'Specifies the project (job) being billed.';

            trigger OnValidate()
            begin
                Logic().Validate_ProjectNo(Rec, xRec);
            end;
        }
        field(3; "Application No."; Integer)
        {
            Caption = 'Application No.';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential application number within the project.';
        }
        field(5; "Period Start"; Date)
        {
            Caption = 'Period Start';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the first day of the billing period this application covers.';
        }
        field(6; "Period End"; Date)
        {
            Caption = 'Period End';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the last day of the billing period this application covers.';
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the resulting invoice is posted on.';
        }
        field(10; Status; Enum "CONS Progress Billing Status")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the application is open, certified, or invoiced.';
        }
        field(11; "Retention %"; Decimal)
        {
            Caption = 'Retention %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the percentage withheld as retention from this application.';
        }
        field(15; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            ToolTip = 'Specifies the customer the application is billed to.';
        }
        field(30; "Scheduled Value"; Decimal)
        {
            Caption = 'Scheduled Value';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Progress Billing Line"."Scheduled Value" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total contract value scheduled across the application lines.';
        }
        field(31; "This Period Amount"; Decimal)
        {
            Caption = 'This Period Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Progress Billing Line"."This Period Amount" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total value of work completed this period.';
        }
        field(32; "Retention This Period"; Decimal)
        {
            Caption = 'Retention This Period';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Progress Billing Line"."Retention This Period" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the total retention withheld this period.';
        }
        field(33; "Net Due This Period"; Decimal)
        {
            Caption = 'Net Due This Period';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CONS Progress Billing Line"."Net Due This Period" where("Document No." = field("No.")));
            AutoFormatType = 1;
            ToolTip = 'Specifies the net amount due this period after retention.';
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series the application number was assigned from.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Project; "Project No.", "Application No.")
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
        ILogic: Interface "CONS IProgBillingHeader";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IProgBillingHeader"
    var
        Default: Codeunit "CONS Prog. Bill Header Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative header-logic implementation (tests / downstream overrides).</summary>
    procedure Define(Implementation: Interface "CONS IProgBillingHeader")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
