namespace Construction.Subcontracts;

enum 50271 "CONS Change Order Status"
{
    Extensible = true;
    Caption = 'Change Order Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Approved)
    {
        Caption = 'Approved';
    }
    value(4; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
    value(2; Rejected)
    {
        Caption = 'Rejected';
    }
    value(3; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
