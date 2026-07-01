namespace Construction.Equipment;

enum 50400 "CONS Equipment Status"
{
    Extensible = true;
    Caption = 'Equipment status';

    value(0; Available)
    {
        Caption = 'Available';
    }
    value(1; "In Use")
    {
        Caption = 'In use';
    }
    value(2; "In Maintenance")
    {
        Caption = 'In maintenance';
    }
    value(3; "Off Hire")
    {
        Caption = 'Off hire';
    }
    value(4; Blocked)
    {
        Caption = 'Blocked';
    }
}
