namespace Construction.Estimating;

enum 50050 "CONS BoQ Status"
{
    Extensible = true;
    Caption = 'Bill of Quantities Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; Awarded)
    {
        Caption = 'Awarded';
    }
    value(3; Closed)
    {
        Caption = 'Closed';
    }
}
