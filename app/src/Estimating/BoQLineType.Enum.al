namespace Construction.Estimating;

enum 50051 "CONS BoQ Line Type"
{
    Extensible = true;
    Caption = 'BoQ Line Type';

    value(0; Position)
    {
        Caption = 'Position';
    }
    value(1; Heading)
    {
        Caption = 'Heading';
    }
    value(2; Comment)
    {
        Caption = 'Comment';
    }
}
