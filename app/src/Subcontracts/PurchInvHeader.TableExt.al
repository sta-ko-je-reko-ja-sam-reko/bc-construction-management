namespace Construction.Subcontracts;

using Microsoft.Purchases.History;

tableextension 60268 "CONS Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(60150; "CONS Subc Claim No."; Code[20])
        {
            Caption = 'Subcontract Claim No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the subcontract claim this purchase invoice was generated from.';
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
