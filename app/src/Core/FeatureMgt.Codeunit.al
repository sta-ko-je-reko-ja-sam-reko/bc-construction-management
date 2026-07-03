namespace Construction.Core;

using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Subcontracts;
using System.Environment.Configuration;

codeunit 50322 "CONS Feature Mgt."
{
    Access = Public;
    SingleInstance = true;

    /// <summary>
    /// Returns whether a construction feature is enabled (reads the feature's setup record). Used as the first
    /// guard clause in the feature's event-subscriber reactions and to drive its application area. Each setup
    /// read is gated by the user's EFFECTIVE read permission on that setup table — checked by object id via the
    /// shared access policy (CONS Access Policy, over the Microsoft Effective Permissions Mgt.), never by
    /// instantiating our own (possibly unlicensed) table — so a user who owns only some modules gets "false" for
    /// the rest instead of a permission error. This is what
    /// makes the codeunit safe to call from an always-on base-app subscriber that runs for every tenant user.
    /// </summary>
    procedure IsEnabled(Feature: Enum "CONS Feature"): Boolean
    var
        EstimatingSetup: Record "CONS Estimating Setup";
        CostControlSetup: Record "CONS Cost Control Setup";
        ProgressBillingSetup: Record "CONS Progress Billing Setup";
        SubcontractsSetup: Record "CONS Subcontracts Setup";
        EquipmentSetup: Record "CONS Equipment Setup";
        SchedulingSetup: Record "CONS Scheduling Setup";
    begin
        case Feature of
            Feature::Estimating:
                if HasEffectiveRead(Database::"CONS Estimating Setup") and EstimatingSetup.Get() then
                    exit(EstimatingSetup.Enabled);
            Feature::CostControl:
                if HasEffectiveRead(Database::"CONS Cost Control Setup") and CostControlSetup.Get() then
                    exit(CostControlSetup.Enabled);
            Feature::ProgressBilling:
                if HasEffectiveRead(Database::"CONS Progress Billing Setup") and ProgressBillingSetup.Get() then
                    exit(ProgressBillingSetup.Enabled);
            Feature::Subcontracts:
                if HasEffectiveRead(Database::"CONS Subcontracts Setup") and SubcontractsSetup.Get() then
                    exit(SubcontractsSetup.Enabled);
            Feature::Equipment:
                if HasEffectiveRead(Database::"CONS Equipment Setup") and EquipmentSetup.Get() then
                    exit(EquipmentSetup.Enabled);
            Feature::Scheduling:
                if HasEffectiveRead(Database::"CONS Scheduling Setup") and SchedulingSetup.Get() then
                    exit(SchedulingSetup.Enabled);
        end;
        exit(false);
    end;

    /// <summary>The current user's effective read permission on a table — delegated to the shared access policy (checked by id, never touching a product object), so the effective-permission logic lives in one place.</summary>
    local procedure HasEffectiveRead(TableId: Integer): Boolean
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        exit(ServiceLocator.AccessPolicy().HasEffectiveRead(TableId));
    end;

    /// <summary>Sets each construction application-area flag from its feature's Enabled state. Called from the Essential-experience subscriber so a disabled feature's pages stay hidden.</summary>
    procedure SetEssentialAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."CONS Estimating" := IsEnabled(Enum::"CONS Feature"::Estimating);
        TempApplicationAreaSetup."CONS Cost Control" := IsEnabled(Enum::"CONS Feature"::CostControl);
        TempApplicationAreaSetup."CONS Progress Billing" := IsEnabled(Enum::"CONS Feature"::ProgressBilling);
        TempApplicationAreaSetup."CONS Subcontracts" := IsEnabled(Enum::"CONS Feature"::Subcontracts);
        TempApplicationAreaSetup."CONS Equipment" := IsEnabled(Enum::"CONS Feature"::Equipment);
        TempApplicationAreaSetup."CONS Scheduling" := IsEnabled(Enum::"CONS Feature"::Scheduling);
    end;

    /// <summary>Errors if the feature is not enabled. Use as a write-guard in the OnInsertRecord/OnModifyRecord/OnDeleteRecord triggers of a feature's writable API pages, so a disabled feature cannot be written to through the API/MCP path (which bypasses application areas).</summary>
    procedure CheckEnabled(Feature: Enum "CONS Feature")
    begin
        if not IsEnabled(Feature) then
            Error(FeatureDisabledErr, Format(Feature));
    end;

    /// <summary>Writes a feature's Enabled flag to its setup record (creating the singleton if needed). Does NOT refresh areas or restart — the caller decides when (the setup page restarts immediately; the assisted setup defers the restart to the hub).</summary>
    /// <param name="Feature">The feature to toggle.</param>
    /// <param name="NewEnabled">The new Enabled value.</param>
    procedure SetEnabled(Feature: Enum "CONS Feature"; NewEnabled: Boolean)
    var
        EstimatingSetup: Record "CONS Estimating Setup";
        CostControlSetup: Record "CONS Cost Control Setup";
        ProgressBillingSetup: Record "CONS Progress Billing Setup";
        SubcontractsSetup: Record "CONS Subcontracts Setup";
        EquipmentSetup: Record "CONS Equipment Setup";
        SchedulingSetup: Record "CONS Scheduling Setup";
    begin
        case Feature of
            Feature::Estimating:
                begin
                    if not EstimatingSetup.Get() then begin
                        EstimatingSetup.Init();
                        EstimatingSetup.Insert();
                    end;
                    EstimatingSetup.Enabled := NewEnabled;
                    EstimatingSetup.Modify(true);
                end;
            Feature::CostControl:
                begin
                    if not CostControlSetup.Get() then begin
                        CostControlSetup.Init();
                        CostControlSetup.Insert();
                    end;
                    CostControlSetup.Enabled := NewEnabled;
                    CostControlSetup.Modify(true);
                end;
            Feature::ProgressBilling:
                begin
                    if not ProgressBillingSetup.Get() then begin
                        ProgressBillingSetup.Init();
                        ProgressBillingSetup.Insert();
                    end;
                    ProgressBillingSetup.Enabled := NewEnabled;
                    ProgressBillingSetup.Modify(true);
                end;
            Feature::Subcontracts:
                begin
                    if not SubcontractsSetup.Get() then begin
                        SubcontractsSetup.Init();
                        SubcontractsSetup.Insert();
                    end;
                    SubcontractsSetup.Enabled := NewEnabled;
                    SubcontractsSetup.Modify(true);
                end;
            Feature::Equipment:
                begin
                    if not EquipmentSetup.Get() then begin
                        EquipmentSetup.Init();
                        EquipmentSetup.Insert();
                    end;
                    EquipmentSetup.Enabled := NewEnabled;
                    EquipmentSetup.Modify(true);
                end;
            Feature::Scheduling:
                begin
                    if not SchedulingSetup.Get() then begin
                        SchedulingSetup.Init();
                        SchedulingSetup.Insert();
                    end;
                    SchedulingSetup.Enabled := NewEnabled;
                    SchedulingSetup.Modify(true);
                end;
        end;
    end;

    /// <summary>Recomputes the company's application areas from the feature setups. Safe to call repeatedly; performs NO session restart. Use when several features are toggled before a single deferred restart (assisted setup).</summary>
    procedure RefreshExperienceAreas()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    /// <summary>Shows the countdown dialog, then abandons the session and starts a new one so application-area changes take effect. MUST be the last client-facing call (no UI after RequestSessionUpdate).</summary>
    procedure RestartSession()
    var
        SessionSetting: SessionSettings;
        RestartDialog: Dialog;
        Countdown: Integer;
    begin
        RestartDialog.Open(RestartMsg);
        for Countdown := 5 downto 1 do begin
            RestartDialog.Update(1, Countdown);
            Sleep(1000);
        end;
        RestartDialog.Close();
        SessionSetting.Init();
        SessionSetting.RequestSessionUpdate(true);
    end;

    /// <summary>Recomputes the company's application areas from the feature setups and restarts the session so the change takes effect. Single-page path (the feature setup card): refresh + restart in one call. The assisted setup splits these (RefreshExperienceAreas per feature, RestartSession once on close).</summary>
    procedure ApplyExperienceChange()
    begin
        RefreshExperienceAreas();
        RestartSession();
    end;

    /// <summary>Returns a fingerprint of every feature's Enabled state. The assisted setup hub captures this on open and compares on close to decide whether a single deferred session restart is owed.</summary>
    procedure GetEnabledFingerprint(): Text
    var
        Ordinal: Integer;
        FingerPrint: TextBuilder;
    begin
        foreach Ordinal in Enum::"CONS Feature".Ordinals() do
            FingerPrint.Append(Format(IsEnabled(Enum::"CONS Feature".FromInteger(Ordinal))));
        exit(FingerPrint.ToText());
    end;

    var
        RestartMsg: Label 'The session will restart in #1 second(s) so the construction experience changes take effect.', Comment = '#1 = seconds remaining';
        FeatureDisabledErr: Label 'The %1 feature is not enabled. Enable it in its setup before creating or changing records through the API.', Comment = '%1 = feature name';
}
