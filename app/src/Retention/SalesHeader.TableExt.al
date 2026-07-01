namespace Construction.Retention;

using Microsoft.Sales.Document;

tableextension 50165 "CONS Sales Header" extends "Sales Header"
{
    fields
    {
        field(50150; "CONS Progress Billing No."; Code[20])
        {
            Caption = 'Progress Billing No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the progress billing application this invoice was generated from.';
        }
        field(50151; "CONS Project No."; Code[20])
        {
            Caption = 'Construction Project No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the construction project the retention relates to.';
        }
        field(50152; "CONS Retention Amount"; Decimal)
        {
            Caption = 'Retention Amount';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the retention amount withheld (or released) on this invoice.';
        }
        field(50153; "CONS Retention Is Release"; Boolean)
        {
            Caption = 'Retention Is Release';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies whether the invoice releases previously withheld retention rather than withholding it.';
        }
    }
}
