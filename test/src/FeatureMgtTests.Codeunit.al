codeunit 50508 "CONS Feature Mgt Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure SetEnabled_TogglesIsEnabled()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN]/[WHEN] a feature is enabled via the facade
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Estimating, true);
        // [THEN] IsEnabled reports it on
        Assert.IsTrue(FeatureMgt.IsEnabled(Enum::"CONS Feature"::Estimating), 'feature enabled after SetEnabled(true)');

        // [WHEN] the feature is disabled
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Estimating, false);
        // [THEN] IsEnabled reports it off
        Assert.IsTrue(not FeatureMgt.IsEnabled(Enum::"CONS Feature"::Estimating), 'feature disabled after SetEnabled(false)');
    end;

    [Test]
    procedure CheckEnabled_ErrorsWhenDisabled()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        // [GIVEN] a disabled feature
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Subcontracts, false);
        // [WHEN] the API write-guard is checked
        asserterror FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Subcontracts);
        // [THEN] it errors (so API/MCP writes are blocked while the feature is off)
        Assert.ExpectedError('not enabled');
    end;

    [Test]
    procedure EnabledFingerprint_ChangesWithToggle()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        Before: Text;
    begin
        // [GIVEN] the enabled fingerprint with Equipment off
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, false);
        Before := FeatureMgt.GetEnabledFingerprint();

        // [WHEN] a feature is toggled on
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Equipment, true);

        // [THEN] the fingerprint changes — this is what drives the setup hub's single deferred session restart
        Assert.IsTrue(Before <> FeatureMgt.GetEnabledFingerprint(), 'fingerprint changes when a feature toggles');
    end;
}
