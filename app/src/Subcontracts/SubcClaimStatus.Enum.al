namespace Construction.Subcontracts;

enum 50251 "CONS Subc Claim Status"
{
    Extensible = true;
    Caption = 'Subcontract Claim Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Certified)
    {
        Caption = 'Certified';
    }
    value(2; Invoiced)
    {
        Caption = 'Invoiced';
    }
}
