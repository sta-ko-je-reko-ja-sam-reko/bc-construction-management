namespace Construction.Retention;

enum 50202 "CONS Retention Direction"
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
