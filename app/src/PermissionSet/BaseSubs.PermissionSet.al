namespace Construction.PermissionSet;

using Construction.Core;
using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Retention;
using Construction.Scheduling;
using Construction.Subcontracts;

/// <summary>
/// Execute permission for the always-on codeunits that MUST run for EVERY user in the tenant — the base-app
/// subscriber proxies, the feature facade, and the Service Locator + Access Policy they resolve (the proxies call
/// the Service Locator's access-policy check BEFORE the entitlement gate, so both must be executable by everyone;
/// the reactions the locator also resolves stay module-gated and are only reached after the check passes).
/// Granted to all users by the Unlicensed
/// "CONS Base Ent" entitlement (AppSource) or assigned to all users by the admin (PTE). These codeunits never
/// touch a licensed object's DATA without first checking the user's effective permission, so granting them
/// broadly is safe. Object (X) grants on the setup + change-order tables let the codeunits reference those
/// Record types for every user while DATA access stays gated: IsEnabled reads only after an effective-read
/// check, and AccessByPermission on the surfaced controls keys off tabledata, granted only by the module sets.
/// </summary>
permissionset 50026 "CONS Base Subs"
{
    Caption = 'Construction Base Subscribers', Locked = true;
    Assignable = true;

    Permissions =
        codeunit "CONS Retention Subscribers" = X,
        codeunit "CONS Subc Base Subscribers" = X,
        codeunit "CONS App Area Subscriber" = X,
        codeunit "CONS Feature Mgt." = X,
        codeunit "CONS Service Locator" = X,
        codeunit "CONS Access Policy" = X,
        table "CONS Estimating Setup" = X,
        table "CONS Cost Control Setup" = X,
        table "CONS Progress Billing Setup" = X,
        table "CONS Subcontracts Setup" = X,
        table "CONS Equipment Setup" = X,
        table "CONS Scheduling Setup" = X,
        table "CONS Change Order Header" = X;
}
