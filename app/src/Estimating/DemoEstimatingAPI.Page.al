namespace Construction.Estimating;

using Construction.Setup;

/// <summary>
/// Demo-import API for Estimating. Its value is the bound [ServiceEnabled] importDemoData action (the MCP tool),
/// not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated 'demoEstimating'
/// API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50041 "CONS Demo Estimating API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoEstimating';
    APIVersion = 'v1.0';
    EntityName = 'demoEstimating';
    EntitySetName = 'demoEstimatingSet';
    Caption = 'Demo Estimating';
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

    /// <summary>MCP/OData bound action: seed a demo Bill of Quantities on the CONS-DEMO project.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Estimating";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
