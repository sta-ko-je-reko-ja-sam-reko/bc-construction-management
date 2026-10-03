namespace Construction.Retention;

using Microsoft.Sales.History;

tableextension 60166 "CONS Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(60150; "CONS Progress Billing No."; Code[20])
        {
            Caption = 'Progress Billing No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the progress billing application this invoice was generated from.';
        }
        field(60151; "CONS Project No."; Code[20])
        {
            Caption = 'Construction Project No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the construction project the retention relates to.';
        }
        field(60152; "CONS Retention Amount"; Decimal)
        {
            Caption = 'Retention Amount';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the retention amount withheld (or released) on this invoice.';
        }
        field(60153; "CONS Retention Is Release"; Boolean)
        {
            Caption = 'Retention Is Release';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies whether the invoice releases previously withheld retention rather than withholding it.';
        }
    }
}
