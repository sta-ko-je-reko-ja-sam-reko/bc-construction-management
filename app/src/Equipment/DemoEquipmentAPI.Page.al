namespace Construction.Equipment;

using Construction.Setup;

/// <summary>
/// Demo-import API for Equipment &amp; Plant. Its value is the bound [ServiceEnabled] importDemoData action (the
/// MCP tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated
/// 'demoEquipment' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50045 "CONS Demo Equipment API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoEquipment';
    APIVersion = 'v1.0';
    EntityName = 'demoEquipment';
    EntitySetName = 'demoEquipmentSet';
    Caption = 'Demo Equipment';
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

    /// <summary>MCP/OData bound action: seed two demo equipment cards with cost and hire rates.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Equipment";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
