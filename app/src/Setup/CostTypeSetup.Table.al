namespace Construction.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Utilities;

table 50002 "CONS Cost Type Setup"
{
    Caption = 'Construction Cost Type Setup';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
        }
        field(10; "Default G/L Account No."; Code[20])
        {
            Caption = 'Default G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true));
        }
        field(20; "Default Work Type Code"; Code[10])
        {
            Caption = 'Default Work Type Code';
            DataClassification = CustomerContent;
            TableRelation = "Work Type";
        }
    }

    keys
    {
        key(PK; "Cost Type")
        {
            Clustered = true;
        }
    }
}
