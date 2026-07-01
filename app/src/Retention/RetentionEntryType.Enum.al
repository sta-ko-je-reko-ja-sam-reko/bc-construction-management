namespace Construction.Retention;

enum 50203 "CONS Retention Entry Type"
{
    Extensible = true;
    Caption = 'Retention Entry Type';

    value(0; Withheld)
    {
        Caption = 'Withheld';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
}
