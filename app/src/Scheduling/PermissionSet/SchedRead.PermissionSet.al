namespace Construction.Scheduling;

permissionset 50469 "CONS Sched - Read"
{
    Assignable = true;
    Caption = 'Construction Scheduling & Resource Planning - Read', Locked = true;

    Permissions =
        tabledata "CONS Scheduling Setup" = R,
        tabledata "CONS Task Dependency" = R,
        tabledata "CONS Resource Assignment" = R,
        table "CONS Scheduling Setup" = X,
        table "CONS Task Dependency" = X,
        table "CONS Resource Assignment" = X,
        page "CONS Project Gantt" = X,
        page "CONS Project Schedule" = X,
        page "CONS Scheduling Setup" = X,
        page "CONS Task Dependencies" = X,
        page "CONS Resource Assignments" = X,
        page "CONS Task Schedule API" = X,
        page "CONS Task Dependency API" = X,
        page "CONS Resource Assignment API" = X,
        codeunit "CONS Schedule Rollup" = X,
        codeunit "CONS Gantt Data" = X;
}
