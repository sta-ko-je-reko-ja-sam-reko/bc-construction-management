namespace Construction.Subcontracts;

using Microsoft.Integration.Entity;

tableextension 50346 "CONS Purch. Order Ent. Buffer" extends "Purchase Order Entity Buffer"
{
    fields
    {
        field(50150; "CONS Subc Claim No."; Code[20])
        {
            Caption = 'Subcontract Claim No.';
            DataClassification = CustomerContent;
        }
        field(50151; "CONS Project No."; Code[20])
        {
            Caption = 'Construction Project No.';
            DataClassification = CustomerContent;
        }
        field(50152; "CONS Retention Amount"; Decimal)
        {
            Caption = 'Retention Amount';
            DataClassification = CustomerContent;
        }
        field(50153; "CONS Retention Is Release"; Boolean)
        {
            Caption = 'Retention Is Release';
            DataClassification = CustomerContent;
        }
    }
}
