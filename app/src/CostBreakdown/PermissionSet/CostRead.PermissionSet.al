namespace Construction.CostBreakdown;

using Construction.CostControl;

permissionset 50118 "CONS Cost - Read"
{
    Assignable = true;
    Caption = 'Construction Cost Control - Read', Locked = true;

    Permissions =
        page "CONS Cost Breakdown" = X,
        page "CONS Project Cost Control" = X,
        tabledata "CONS Cost Control Setup" = R,
        table "CONS Cost Control Setup" = X,
        page "CONS Cost Control Setup" = X,
        codeunit "CONS Cost Forecast" = X;
}
