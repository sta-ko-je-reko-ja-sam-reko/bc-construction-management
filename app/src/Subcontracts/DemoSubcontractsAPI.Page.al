namespace Construction.Subcontracts;

using Construction.Setup;

/// <summary>
/// Demo-import API for Subcontracts. Its value is the bound [ServiceEnabled] importDemoData action (the MCP
/// tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated
/// 'demoSubcontracts' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50044 "CONS Demo Subcontracts API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoSubcontracts';
    APIVersion = 'v1.0';
    EntityName = 'demoSubcontracts';
    EntitySetName = 'demoSubcontractsSet';
    Caption = 'Demo Subcontracts';
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

    /// <summary>MCP/OData bound action: seed a demo subcontract with retention on the CONS-DEMO project.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Subcontracts";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
