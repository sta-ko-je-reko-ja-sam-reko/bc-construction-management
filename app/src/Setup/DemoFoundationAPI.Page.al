namespace Construction.Setup;

/// <summary>
/// Demo-import API for the Foundation context. Its value is the bound [ServiceEnabled] importDemoData action
/// (the MCP tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated
/// 'demoFoundation' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50040 "CONS Demo Foundation API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoFoundation';
    APIVersion = 'v1.0';
    EntityName = 'demoFoundation';
    EntitySetName = 'demoFoundationSet';
    Caption = 'Demo Foundation';
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

    /// <summary>MCP/OData bound action: seed the Foundation demo context (CONS-DEMO project, customer, vendor, tasks).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Foundation";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
