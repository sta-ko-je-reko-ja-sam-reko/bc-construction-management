namespace Construction.MCP;

using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Setup;
using Construction.Subcontracts;
using System.MCP;

/// <summary>
/// Builds one Model Context Protocol (MCP) server configuration per feature's demo importer, each exposing ONLY
/// that feature's "CONS Demo &lt;Feature&gt; API" page (its importDemoData bound action). Kept separate from the
/// functional configuration in "CONS MCP Config Demo" so a Copilot/agent bound to, say, the "Construction Demo
/// Estimating" configuration can seed only estimating demo data and reach none of the functional write tools.
/// Run once per environment (called from the Foundation demo seeder on first run).
/// </summary>
codeunit 50038 "CONS MCP Demo Config"
{
    Access = Public;

    /// <summary>Create and activate the per-feature demo-import MCP configurations. Each exposes a single importer tool.</summary>
    procedure CreateDemoMCPConfigs()
    begin
        CreateDemoConfig(FoundationCfgTok, FoundationDescTxt, Page::"CONS Demo Foundation API");
        CreateDemoConfig(EstimatingCfgTok, EstimatingDescTxt, Page::"CONS Demo Estimating API");
        CreateDemoConfig(CostControlCfgTok, CostControlDescTxt, Page::"CONS Demo Cost Control API");
        CreateDemoConfig(ProgressBillingCfgTok, ProgressBillingDescTxt, Page::"CONS Demo Prog. Billing API");
        CreateDemoConfig(SubcontractsCfgTok, SubcontractsDescTxt, Page::"CONS Demo Subcontracts API");
        CreateDemoConfig(EquipmentCfgTok, EquipmentDescTxt, Page::"CONS Demo Equipment API");
        CreateDemoConfig(SchedulingCfgTok, SchedulingDescTxt, Page::"CONS Demo Scheduling API");
    end;

    /// <summary>Create one MCP configuration exposing exactly one demo-import API page (its bound importDemoData action).</summary>
    local procedure CreateDemoConfig(ConfigName: Text[100]; ConfigDescription: Text[250]; APIPageId: Integer)
    var
        MCPConfig: Codeunit "MCP Config";
        ConfigId: Guid;
        ToolId: Guid;
    begin
        ConfigId := MCPConfig.CreateConfiguration(ConfigName, ConfigDescription);
        MCPConfig.AllowCreateUpdateDeleteTools(ConfigId, true);
        ToolId := MCPConfig.CreateAPITool(ConfigId, APIPageId);
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.AllowCreate(ToolId, true);
        MCPConfig.AllowModify(ToolId, true);
        MCPConfig.ActivateConfiguration(ConfigId, true);
    end;

    var
        FoundationCfgTok: Label 'Construction Demo Foundation', Locked = true, MaxLength = 100;
        EstimatingCfgTok: Label 'Construction Demo Estimating', Locked = true, MaxLength = 100;
        CostControlCfgTok: Label 'Construction Demo Cost Control', Locked = true, MaxLength = 100;
        ProgressBillingCfgTok: Label 'Construction Demo Progress Billing', Locked = true, MaxLength = 100;
        SubcontractsCfgTok: Label 'Construction Demo Subcontracts', Locked = true, MaxLength = 100;
        EquipmentCfgTok: Label 'Construction Demo Equipment', Locked = true, MaxLength = 100;
        SchedulingCfgTok: Label 'Construction Demo Scheduling', Locked = true, MaxLength = 100;
        FoundationDescTxt: Label 'Seed the shared demo project, customer and vendor (CONS-DEMO).', MaxLength = 250;
        EstimatingDescTxt: Label 'Seed a demo Bill of Quantities on the CONS-DEMO project.', MaxLength = 250;
        CostControlDescTxt: Label 'Seed the demo project context for Cost Control analysis.', MaxLength = 250;
        ProgressBillingDescTxt: Label 'Seed the demo project context for Progress Billing.', MaxLength = 250;
        SubcontractsDescTxt: Label 'Seed a demo subcontract with retention on CONS-DEMO.', MaxLength = 250;
        EquipmentDescTxt: Label 'Seed demo equipment with cost and hire rates.', MaxLength = 250;
        SchedulingDescTxt: Label 'Seed the demo project schedule (task dates and a dependency).', MaxLength = 250;
}
