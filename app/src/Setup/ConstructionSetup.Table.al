namespace Construction.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;

table 50001 "CONS Construction Setup"
{
    Caption = 'Construction Setup';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Default Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Default Cost Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the default cost type applied to new estimate and budget lines.';
        }
        field(30; "BoQ Nos."; Code[20])
        {
            Caption = 'Bill of Quantities Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for Bill of Quantities documents.';
        }
        field(31; "Progress Cert. Nos."; Code[20])
        {
            Caption = 'Progress Certificate Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for progress certificates.';
        }
        field(32; "Subcontract Nos."; Code[20])
        {
            Caption = 'Subcontract Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for subcontracts.';
        }
        field(33; "Progress Billing Nos."; Code[20])
        {
            Caption = 'Progress Billing Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for progress billing applications.';
        }
        field(34; "Subcontract Claim Nos."; Code[20])
        {
            Caption = 'Subcontract Claim Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for subcontractor progress claims.';
        }
        field(35; "Change Order Nos."; Code[20])
        {
            Caption = 'Change Order Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series for change orders / variations.';
        }
        field(40; "Default Retention %"; Decimal)
        {
            Caption = 'Default Retention %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the retention percentage defaulted onto new progress billing applications.';
        }
        field(41; "Retention Receivable Acc."; Code[20])
        {
            Caption = 'Retention Receivable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true));
            ToolTip = 'Specifies the G/L account that holds retention withheld from customer progress invoices.';
        }
        field(42; "Retention Payable Acc."; Code[20])
        {
            Caption = 'Retention Payable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true));
            ToolTip = 'Specifies the G/L account that holds retention withheld from subcontractor claims.';
        }
        field(43; "Revenue Account"; Code[20])
        {
            Caption = 'Revenue Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true));
            ToolTip = 'Specifies the G/L account progress billing revenue lines post to.';
        }
        field(44; "Subcontract Cost Account"; Code[20])
        {
            Caption = 'Subcontract Cost Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true));
            ToolTip = 'Specifies the G/L account subcontractor claim cost lines post to.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>Ensures the singleton setup record exists and returns it.</summary>
    internal procedure InitSetup()
    begin
        if Rec.Get() then
            exit;
        Rec.Init();
        Rec.Insert();
    end;
}
