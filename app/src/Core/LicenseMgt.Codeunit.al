namespace Construction.Core;

codeunit 50008 "CONS License Mgt."
{
    Access = Public;

    /// <summary>
    /// Returns whether the given Construction Management module is licensed for the current tenant.
    /// Premium module entry points must call this before showing UI or running logic. Public: this
    /// is the product's deliberate licensing API. Dual-target: in an AppSource build (APPSOURCE
    /// symbol) licensing is enforced by the entitlement/offer plans, so this defers to true; in a
    /// PTE build it is the gate (MVP stub — wire the per-tenant check in the #else branch).
    /// </summary>
    /// <param name="Module">The construction module to check.</param>
    /// <returns>True if the module is licensed.</returns>
    procedure IsModuleLicensed(Module: Enum "CONS Module"): Boolean
    begin
#if APPSOURCE
        exit(true);
#else
        exit(true);
#endif
    end;

    /// <summary>Errors if the given module is not licensed. Call from module entry points.</summary>
    /// <param name="Module">The construction module to check.</param>
    procedure CheckModuleLicensed(Module: Enum "CONS Module")
    begin
        if not IsModuleLicensed(Module) then
            Error(ModuleNotLicensedErr, Module);
    end;

    var
        ModuleNotLicensedErr: Label 'The %1 module is not licensed for this environment.', Comment = '%1 = module name';
}
