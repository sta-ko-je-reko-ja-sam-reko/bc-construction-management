namespace Construction.PermissionSet;

using Construction.Core;
using Construction.CostBreakdown;
using Construction.Setup;

permissionset 50011 "CONS Found - Read"
{
    Assignable = true;
    Caption = 'Construction Foundation - Read', Locked = true;

    Permissions =
        tabledata "CONS Construction Setup" = R,
        tabledata "CONS Cost Type Setup" = R,
        table "CONS Construction Setup" = X,
        table "CONS Cost Type Setup" = X,
        table "CONS Setup Step" = X,
        table "CONS Activities Cue" = X,
        page "CONS Construction Setup" = X,
        page "CONS Cost Type Setup" = X,
        page "CONS Cost Type Setup API" = X,
        page "CONS Project API" = X,
        page "CONS Project Task API" = X,
        page "CONS Setup Hub" = X,
        page "CONS Feature Setup Wizard" = X,
        page "CONS Construction Activities" = X,
        page "CONS Construction Manager RC" = X,
        codeunit "CONS License Mgt." = X,
        codeunit "CONS Service Locator" = X,
        codeunit "CONS Feature Mgt." = X,
        codeunit "CONS App Area Subscriber" = X,
        codeunit "CONS Guided Setup" = X,
        codeunit "CONS Activities Cue Calc" = X;
}
