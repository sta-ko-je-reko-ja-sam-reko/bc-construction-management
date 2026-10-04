namespace Construction.Test;

using Construction.Core;
using Construction.Retention;
using System.TestLibraries.Utilities;

codeunit 64020 "CONS Licensing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure IsModuleLicensed_EveryModuleInPTEBuild()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
        Ordinal: Integer;
    begin
        // [GIVEN] the PTE build (no APPSOURCE symbol), where the license gate is still a stub
        // [WHEN] each module is checked
        // [THEN] every module is licensed, so no entry point is blocked
        foreach Ordinal in Enum::"CONS Module".Ordinals() do
            Assert.IsTrue(LicenseMgt.IsModuleLicensed(Enum::"CONS Module".FromInteger(Ordinal)), StrSubstNo(ModuleTxt, Ordinal));
    end;

    [Test]
    procedure CheckModuleLicensed_DoesNotError()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        // [GIVEN] a licensed module
        // [WHEN] an entry point checks the license
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Progress Billing");
        // [THEN] it passes silently
        Assert.IsTrue(LicenseMgt.IsModuleLicensed(Enum::"CONS Module"::"Progress Billing"), 'Progress Billing is licensed');
    end;

    [Test]
    procedure ServiceLocator_UsesInjectedAccessPolicy()
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        // [GIVEN] a test access policy injected through the Service Locator
        TestLibrary.Initialize();

        // [WHEN] the policy is switched to deny
        TestLibrary.SetAccessAllowed(false);

        // [THEN] the locator hands out the injected policy (not the built-in effective-permission check)
        Assert.IsFalse(ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Retention Logic"), 'injected policy denies execute');
        Assert.IsFalse(ServiceLocator.AccessPolicy().HasEffectiveRead(Database::"CONS Retention Entry"), 'injected policy denies read');
        TestLibrary.SetAccessAllowed(true);
        Assert.IsTrue(ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Retention Logic"), 'injected policy grants execute');
    end;

    [Test]
    procedure AccessPolicy_SameAnswerOnRepeatedCalls()
    var
        AccessPolicy: Codeunit "CONS Access Policy";
        First: Boolean;
    begin
        // [GIVEN] the built-in effective-permission policy
        // [WHEN] the same object is asked about twice (the second answer comes from the session cache)
        First := AccessPolicy.HasEffectiveRead(Database::"CONS Retention Entry");
        // [THEN] both answers agree
        Assert.AreEqual(First, AccessPolicy.HasEffectiveRead(Database::"CONS Retention Entry"), 'cached read answer is stable');
        Assert.AreEqual(
            AccessPolicy.HasEffectiveExecute(Codeunit::"CONS Retention Logic"),
            AccessPolicy.HasEffectiveExecute(Codeunit::"CONS Retention Logic"), 'cached execute answer is stable');
    end;

    var
        ModuleTxt: Label 'module ordinal %1 should be licensed', Locked = true;
}
