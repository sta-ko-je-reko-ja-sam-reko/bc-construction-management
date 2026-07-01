namespace Construction.Retention;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Projects.Project.Job;

table 50200 "CONS Retention Entry"
{
    Caption = 'Retention Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "CONS Retention Entries";
    LookupPageId = "CONS Retention Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            ToolTip = 'Specifies the unique entry number.';
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the retention relates to.';
        }
        field(3; Direction; Enum "CONS Retention Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the retention is receivable (billed to a customer) or payable (withheld from a vendor).';
        }
        field(4; "Entry Type"; Enum "CONS Retention Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the entry withholds or releases retention.';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posted document that created the entry.';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posting date of the entry.';
        }
        field(7; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the customer (Receivable) or vendor (Payable) the retention relates to.';
        }
        field(10; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the retention amount. Positive when withheld, negative when released, so the per-project sum is the outstanding retention.';
        }
        field(11; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
            ToolTip = 'Specifies the retention G/L account the amount was posted to.';
        }
        field(15; "Application No."; Integer)
        {
            Caption = 'Application No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the progress billing application the retention originated from.';
        }
        field(20; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the withheld retention is scheduled for release.';
        }
        field(21; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the withheld retention is still outstanding (not yet fully released).';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Project; "Project No.", Direction, Open)
        {
            SumIndexFields = Amount;
        }
        key(Document; "Document No.")
        {
        }
    }
}
