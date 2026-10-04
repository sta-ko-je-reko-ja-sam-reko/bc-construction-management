namespace Construction.Test;

using Construction.Core;
using Construction.Estimating;
using System.Environment.Configuration;
using System.TestLibraries.Utilities;

codeunit 64008 "CONS Feature Mgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure SetEnabled_TogglesIsEnabled()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN]/[WHEN] a feature is enabled via the facade
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Estimating, true);
        // [THEN] IsEnabled reports it on
        Assert.IsTrue(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Estimating), 'feature enabled after SetEnabled(true)');

        // [WHEN] the feature is disabled
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Estimating, false);
        // [THEN] IsEnabled reports it off
        Assert.IsFalse(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Estimating), 'feature disabled after SetEnabled(false)');
    end;

    [Test]
    procedure SetEnabled_EveryFeatureRoundTrips()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        Feature: Enum "CONS Feature";
        Ordinal: Integer;
    begin
        // [GIVEN] every feature of the product
        TestLibrary.Initialize();
        foreach Ordinal in Enum::"CONS Feature".Ordinals() do begin
            Feature := Enum::"CONS Feature".FromInteger(Ordinal);
            // [WHEN] it is enabled and then disabled
            FeatureMgt.SetEnabled(Feature, true);
            // [THEN] each state is read back from that feature's own setup table
            Assert.IsTrue(FeatureMgt.IsEnabled(Feature), StrSubstNo(FeatureStateTxt, Feature, true));
            FeatureMgt.SetEnabled(Feature, false);
            Assert.IsFalse(FeatureMgt.IsEnabled(Feature), StrSubstNo(FeatureStateTxt, Feature, false));
        end;
    end;

    [Test]
    procedure IsEnabled_NoSetupRecord_IsFalse()
    var
        EstimatingSetup: Record "CONS Estimating Setup";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] the Estimating setup singleton does not exist
        TestLibrary.Initialize();
        EstimatingSetup.DeleteAll();
        // [WHEN]/[THEN] the feature counts as disabled instead of failing on a missing record
        Assert.IsFalse(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Estimating), 'a missing setup record means disabled');
    end;

    [Test]
    procedure IsEnabled_NoEffectiveRead_IsFalse()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] an enabled feature, but a user without effective read permission on its setup table
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, true);
        TestLibrary.SetAccessAllowed(false);
        // [WHEN]/[THEN] the feature reports disabled instead of raising a permission error
        Assert.IsFalse(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Equipment), 'a user without the module sees the feature as disabled');
        TestLibrary.SetAccessAllowed(true);
    end;

    [Test]
    procedure CheckEnabled_ErrorsWhenDisabled()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] a disabled feature
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Subcontracts, false);
        // [WHEN] the API write-guard is checked
        asserterror FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Subcontracts);
        // [THEN] it errors (so API/MCP writes are blocked while the feature is off)
        Assert.ExpectedError('not enabled');
    end;

    [Test]
    procedure CheckEnabled_PassesWhenEnabled()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] an enabled feature
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Scheduling, true);
        // [WHEN] the API write-guard is checked
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        // [THEN] no error is raised
        Assert.IsTrue(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Scheduling), 'write guard passes for an enabled feature');
    end;

    [Test]
    procedure SetEssentialAppAreas_FollowsFeatureState()
    var
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] Estimating and Scheduling on, every other feature off
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Estimating, true);
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::CostControl, false);
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::ProgressBilling, false);
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Subcontracts, false);
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, false);
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Scheduling, true);

        // [WHEN] the Essential experience asks for the construction application areas
        FeatureMgt.SetEssentialAppAreas(TempApplicationAreaSetup);

        // [THEN] each application area mirrors its feature's Enabled flag
        Assert.IsTrue(TempApplicationAreaSetup."CONS Estimating", 'Estimating area on');
        Assert.IsFalse(TempApplicationAreaSetup."CONS Cost Control", 'Cost Control area off');
        Assert.IsFalse(TempApplicationAreaSetup."CONS Progress Billing", 'Progress Billing area off');
        Assert.IsFalse(TempApplicationAreaSetup."CONS Subcontracts", 'Subcontracts area off');
        Assert.IsFalse(TempApplicationAreaSetup."CONS Equipment", 'Equipment area off');
        Assert.IsTrue(TempApplicationAreaSetup."CONS Scheduling", 'Scheduling area on');
    end;

    [Test]
    procedure EnabledFingerprint_ChangesWithToggle()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        Before: Text;
    begin
        // [GIVEN] the enabled fingerprint with Equipment off
        TestLibrary.Initialize();
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, false);
        Before := FeatureMgt.GetEnabledFingerprint();

        // [WHEN] a feature is toggled on
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, true);

        // [THEN] the fingerprint changes — this is what drives the setup hub's single deferred session restart
        Assert.AreNotEqual(Before, FeatureMgt.GetEnabledFingerprint(), 'fingerprint changes when a feature toggles');
    end;

    [Test]
    procedure EnabledFingerprint_StableWithoutChange()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] no feature changes between two reads
        TestLibrary.Initialize();
        TestLibrary.EnableAllFeatures();
        // [WHEN]/[THEN] the fingerprint is identical, so the hub owes no restart
        Assert.AreEqual(FeatureMgt.GetEnabledFingerprint(), FeatureMgt.GetEnabledFingerprint(), 'fingerprint is stable');
    end;

    var
        FeatureStateTxt: Label 'feature %1 should be enabled = %2', Locked = true;
}
