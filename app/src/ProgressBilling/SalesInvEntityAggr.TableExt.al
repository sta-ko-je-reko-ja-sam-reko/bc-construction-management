namespace Construction.ProgressBilling;

using Microsoft.Integration.Entity;

tableextension 60340 "CONS Sales Inv. Entity Aggr." extends "Sales Invoice Entity Aggregate"
{
    fields
    {
        field(60150; "CONS Progress Billing No."; Code[20])
        {
            Caption = 'Progress Billing No.';
            DataClassification = CustomerContent;
        }
        field(60151; "CONS Project No."; Code[20])
        {
            Caption = 'Construction Project No.';
            DataClassification = CustomerContent;
        }
        field(60152; "CONS Retention Amount"; Decimal)
        {
            Caption = 'Retention Amount';
            DataClassification = CustomerContent;
        }
        field(60153; "CONS Retention Is Release"; Boolean)
        {
            Caption = 'Retention Is Release';
            DataClassification = CustomerContent;
        }
    }
}
