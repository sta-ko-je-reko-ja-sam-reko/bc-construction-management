namespace Construction.Scheduling;

using Construction.Setup;

/// <summary>
/// Demo-import API for Scheduling &amp; Resource Planning. Its value is the bound [ServiceEnabled] importDemoData
/// action (the MCP tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own
/// dedicated 'demoScheduling' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50046 "CONS Demo Scheduling API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoScheduling';
    APIVersion = 'v1.0';
    EntityName = 'demoScheduling';
    EntitySetName = 'demoSchedulingSet';
    Caption = 'Demo Scheduling';
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

    /// <summary>MCP/OData bound action: seed the CONS-DEMO project schedule (task dates and a dependency).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Scheduling";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
