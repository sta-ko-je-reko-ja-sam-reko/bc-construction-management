namespace Construction.Equipment;

enum 50401 "CONS Equipment Ownership"
{
    Extensible = true;
    Caption = 'Equipment ownership';

    value(0; Owned)
    {
        Caption = 'Owned';
    }
    value(1; Hired)
    {
        Caption = 'Hired';
    }
}
