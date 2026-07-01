namespace Construction.MCP;

using Construction.Core;
using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Retention;
using Construction.Scheduling;
using Construction.Setup;
using Construction.Subcontracts;
using System.MCP;

codeunit 50300 "CONS MCP Config Demo"
{
    Access = Public;

    /// <summary>
    /// Builds a ready-to-use Model Context Protocol (MCP) server configuration that exposes the
    /// construction module API pages as tools for AI clients (GitHub Copilot, Copilot Studio).
    /// Document entities are read/create/modify; the retention sub-ledger and cost-type setup are
    /// read-only. Not called anywhere yet — the product's assisted setup offers to run this and the
    /// user attaches the resulting configuration to their MCP host. Run once per environment.
    /// </summary>
    /// <returns>The name of the created MCP server configuration.</returns>
    procedure CreateConstructionMCPConfig(): Text[100]
    var
        MCPConfig: Codeunit "MCP Config";
        ConfigId: Guid;
    begin
        ConfigId := MCPConfig.CreateConfiguration(ConfigNameTok, ConfigDescTxt);
        MCPConfig.AllowCreateUpdateDeleteTools(ConfigId, true);

        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Project API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Project Task API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS BoQ API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS BoQ Line API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Progress Billing API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Progress Billing Line API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Retention Entry API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Sales Invoice API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Sales Order API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Purchase Order API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Purchase Invoice API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Subcontract API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Subcontract Line API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Subc Claim API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Subc Claim Line API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Change Order API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Change Order Line API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment Rate API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment Usage API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment Maint. API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment Meter API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Equipment Assign. API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Task Schedule API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Task Dependency API");
        AddWritableTool(MCPConfig, ConfigId, Page::"CONS Resource Assignment API");
        AddReadOnlyTool(MCPConfig, ConfigId, Page::"CONS Cost Type Setup API");

        MCPConfig.ActivateConfiguration(ConfigId, true);
        exit(ConfigNameTok);
    end;

    local procedure AddWritableTool(MCPConfig: Codeunit "MCP Config"; ConfigId: Guid; APIPageId: Integer)
    var
        ToolId: Guid;
    begin
        ToolId := MCPConfig.CreateAPITool(ConfigId, APIPageId);
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.AllowCreate(ToolId, true);
        MCPConfig.AllowModify(ToolId, true);
    end;

    local procedure AddReadOnlyTool(MCPConfig: Codeunit "MCP Config"; ConfigId: Guid; APIPageId: Integer)
    var
        ToolId: Guid;
    begin
        ToolId := MCPConfig.CreateAPITool(ConfigId, APIPageId);
        MCPConfig.AllowRead(ToolId, true);
    end;

    var
        ConfigNameTok: Label 'Construction', Locked = true, MaxLength = 100;
        ConfigDescTxt: Label 'Construction Management tools for AI clients — estimating, cost control, progress billing, retention, subcontracts, change orders, equipment & plant, and scheduling & resource planning.', MaxLength = 250;
}
