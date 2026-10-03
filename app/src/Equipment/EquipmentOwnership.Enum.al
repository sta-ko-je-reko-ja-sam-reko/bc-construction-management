namespace Construction.Equipment;

enum 60401 "CONS Equipment Ownership"
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
