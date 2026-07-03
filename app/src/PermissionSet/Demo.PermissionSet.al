namespace Construction.PermissionSet;

using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.MCP;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Setup;
using Construction.Subcontracts;
using System.IO;

/// <summary>
/// Shared demo-data permission set — execute on every per-feature demo seeder and its [ServiceEnabled] import
/// API page, the demo-MCP-config builder, the RapidStart config-package builder, and the dummy source table.
/// Demo seeding is an admin/onboarding action that writes into the feature tables the seeders touch (and, on
/// opt-in, into the Microsoft RapidStart Config. Package tables), so this set is included in the composite
/// "CONS Admin" (which already grants those feature tabledata); it is not part of the per-seat module sets.
/// Kept as one shared set per the demo-data pattern (routing to agents is by API group / MCP configuration,
/// independent of the permission split), rather than scattering demo objects across the module sets.
/// </summary>
permissionset 50027 "CONS Demo"
{
    Assignable = true;
    Caption = 'Construction Demo Data', Locked = true;

    Permissions =
        tabledata "CONS Demo Data" = RIMD,
        table "CONS Demo Data" = X,
        codeunit "CONS Demo Foundation" = X,
        codeunit "CONS Demo Estimating" = X,
        codeunit "CONS Demo Cost Control" = X,
        codeunit "CONS Demo Progress Billing" = X,
        codeunit "CONS Demo Subcontracts" = X,
        codeunit "CONS Demo Equipment" = X,
        codeunit "CONS Demo Scheduling" = X,
        codeunit "CONS MCP Demo Config" = X,
        codeunit "CONS Config Package Builder" = X,
        tabledata "Config. Package" = RIMD,
        tabledata "Config. Package Table" = RIMD,
        tabledata "Config. Package Field" = RIMD,
        tabledata "Config. Package Filter" = RIMD,
        tabledata "Config. Package Data" = RIMD,
        page "CONS Demo Foundation API" = X,
        page "CONS Demo Estimating API" = X,
        page "CONS Demo Cost Control API" = X,
        page "CONS Demo Prog. Billing API" = X,
        page "CONS Demo Subcontracts API" = X,
        page "CONS Demo Equipment API" = X,
        page "CONS Demo Scheduling API" = X;
}
