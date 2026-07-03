namespace Construction.CostBreakdown;

using Construction.Setup;

/// <summary>
/// Demo-import API for Cost Control. Its value is the bound [ServiceEnabled] importDemoData action (the MCP
/// tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated
/// 'demoCostControl' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50042 "CONS Demo Cost Control API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoCostControl';
    APIVersion = 'v1.0';
    EntityName = 'demoCostControl';
    EntitySetName = 'demoCostControlSet';
    Caption = 'Demo Cost Control';
    SourceTable = "CONS Demo Data";
    Extensible = false;
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(code; Rec.Code) { Caption = 'Code'; }
            }
        }
    }

    /// <summary>MCP/OData bound action: ensure the CONS-DEMO project context exists for Cost Control analysis.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Cost Control";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
