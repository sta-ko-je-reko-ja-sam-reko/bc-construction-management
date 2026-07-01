namespace Construction.Equipment;

permissionset 50451 "CONS Equip - Read"
{
    Assignable = true;
    Caption = 'Construction Equipment & Plant - Read', Locked = true;

    Permissions =
        tabledata "CONS Equipment" = R,
        tabledata "CONS Equipment Setup" = R,
        tabledata "CONS Equipment Rate" = R,
        tabledata "CONS Equipment Usage" = R,
        tabledata "CONS Equipment Maintenance" = R,
        tabledata "CONS Equipment Meter Entry" = R,
        tabledata "CONS Equipment Assignment" = R,
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
