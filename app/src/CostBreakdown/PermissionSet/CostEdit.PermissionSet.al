namespace Construction.CostBreakdown;

using Construction.CostControl;

permissionset 50117 "CONS Cost - Edit"
{
    Assignable = true;
    Caption = 'Construction Cost Control - Edit', Locked = true;

    Permissions =
        page "CONS Cost Breakdown" = X,
        page "CONS Project Cost Control" = X,
        tabledata "CONS Cost Control Setup" = RIMD,
        table "CONS Cost Control Setup" = X,
        page "CONS Cost Control Setup" = X,
        codeunit "CONS Cost Forecast" = X;
}
