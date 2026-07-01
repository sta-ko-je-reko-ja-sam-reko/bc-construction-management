namespace Construction.Subcontracts;

enum 50272 "CONS Change Order Type"
{
    Extensible = true;
    Caption = 'Change Order Type';

    value(0; Owner)
    {
        Caption = 'Owner';
    }
    value(1; Subcontract)
    {
        Caption = 'Subcontract';
    }
}
