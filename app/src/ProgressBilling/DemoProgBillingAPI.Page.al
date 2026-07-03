namespace Construction.ProgressBilling;

using Construction.Setup;

/// <summary>
/// Demo-import API for Progress Billing. Its value is the bound [ServiceEnabled] importDemoData action (the MCP
/// tool), not its rows — hence the shared empty "CONS Demo Data" source. Lives in its own dedicated
/// 'demoProgressBilling' API group so it can be routed to a dedicated MCP configuration / agent.
/// </summary>
page 50043 "CONS Demo Prog. Billing API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'demoProgressBilling';
    APIVersion = 'v1.0';
    EntityName = 'demoProgressBilling';
    EntitySetName = 'demoProgressBillingSet';
    Caption = 'Demo Progress Billing';
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

    /// <summary>MCP/OData bound action: ensure the CONS-DEMO project context exists for Progress Billing.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "CONS Demo Progress Billing";
    begin
        Demo.Import();
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
