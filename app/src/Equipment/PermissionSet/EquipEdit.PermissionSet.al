namespace Construction.Equipment;

permissionset 50450 "CONS Equip - Edit"
{
    Assignable = true;
    Caption = 'Construction Equipment & Plant - Edit', Locked = true;

    Permissions =
        tabledata "CONS Equipment" = RIMD,
        tabledata "CONS Equipment Setup" = RIMD,
        tabledata "CONS Equipment Rate" = RIMD,
        tabledata "CONS Equipment Usage" = RIMD,
        tabledata "CONS Equipment Maintenance" = RIMD,
        tabledata "CONS Equipment Meter Entry" = RIMD,
        tabledata "CONS Equipment Assignment" = RIMD,
        table "CONS Equipment" = X,
        table "CONS Equipment Setup" = X,
        table "CONS Equipment Rate" = X,
        table "CONS Equipment Usage" = X,
        table "CONS Equipment Maintenance" = X,
        table "CONS Equipment Meter Entry" = X,
        table "CONS Equipment Assignment" = X,
        page "CONS Equipment Card" = X,
        page "CONS Equipment List" = X,
        page "CONS Equipment Setup" = X,
        page "CONS Equipment Rates" = X,
        page "CONS Equipment Usage" = X,
        page "CONS Equipment Maintenance" = X,
        page "CONS Equipment Meter Entries" = X,
        page "CONS Equipment Assignments" = X,
        page "CONS Equipment API" = X,
        page "CONS Equipment Rate API" = X,
        page "CONS Equipment Usage API" = X,
        page "CONS Equipment Maint. API" = X,
        page "CONS Equipment Meter API" = X,
        page "CONS Equipment Assign. API" = X,
        codeunit "CONS Equipment Usage Logic" = X,
        codeunit "CONS Equipment Usage-Post" = X,
        codeunit "CONS Equipment Maint. Logic" = X,
        codeunit "CONS Equipment Meter Logic" = X;
}
