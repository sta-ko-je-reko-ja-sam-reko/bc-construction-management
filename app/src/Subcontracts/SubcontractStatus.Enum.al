namespace Construction.Subcontracts;

enum 50250 "CONS Subcontract Status"
{
    Extensible = true;
    Caption = 'Subcontract Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}
