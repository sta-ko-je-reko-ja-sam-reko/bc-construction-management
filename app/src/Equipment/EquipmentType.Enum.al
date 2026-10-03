namespace Construction.Equipment;

enum 60402 "CONS Equipment Type"
{
    Extensible = true;
    Caption = 'Equipment type';

    value(0; Machine)
    {
        Caption = 'Machine';
    }
    value(1; Vehicle)
    {
        Caption = 'Vehicle';
    }
    value(2; Tool)
    {
        Caption = 'Tool';
    }
    value(3; Other)
    {
        Caption = 'Other';
    }
}
