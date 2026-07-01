namespace Construction.ProgressBilling;

enum 50152 "CONS Progress Billing Status"
{
    Extensible = true;
    Caption = 'Progress Billing Status';

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
