namespace Construction.Retention;

enum 60202 "CONS Retention Direction"
{
    Extensible = true;
    Caption = 'Retention Direction';

    value(0; Receivable)
    {
        Caption = 'Receivable';
    }
    value(1; Payable)
    {
        Caption = 'Payable';
    }
}
