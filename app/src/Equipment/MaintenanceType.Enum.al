namespace Construction.Equipment;

enum 50403 "CONS Maintenance Type"
{
    Extensible = true;
    Caption = 'Maintenance type';

    value(0; Service)
    {
        Caption = 'Service';
    }
    value(1; Repair)
    {
        Caption = 'Repair';
    }
    value(2; Inspection)
    {
        Caption = 'Inspection';
    }
    value(3; Other)
    {
        Caption = 'Other';
    }
}
