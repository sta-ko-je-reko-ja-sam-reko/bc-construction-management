namespace Construction.PermissionSet;

using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Subcontracts;

permissionset 50012 "CONS Admin"
{
    Assignable = true;
    Caption = 'Construction Management - Admin', Locked = true;

    IncludedPermissionSets = "CONS Found - Edit", "CONS Est - Edit", "CONS Cost - Edit", "CONS Bill - Edit", "CONS Subc - Edit", "CONS Equip - Edit", "CONS Sched - Edit";
}
