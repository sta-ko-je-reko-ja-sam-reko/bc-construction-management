namespace Construction.PermissionSet;

#if APPSOURCE
/// <summary>
/// Unlicensed entitlement — grants the base-subscriber codeunits to EVERY user regardless of plan, so the
/// subscriptions on Microsoft BaseApp publishers (which fire for all users) never raise a licensing error. The
/// subscriber bodies themselves check effective permission (Service Locator execute / setup-table read) before
/// doing any product work. Compiled only in the AppSource build (APPSOURCE); a PTE extension cannot contain an
/// entitlement (PTE0013) — in a PTE build the admin assigns "CONS Base Subs" to all users instead.
/// </summary>
entitlement "CONS Base Ent"
{
    Type = Unlicensed;
    ObjectEntitlements = "CONS Base Subs";
}
#endif
