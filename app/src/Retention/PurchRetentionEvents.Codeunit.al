namespace Construction.Retention;

using Construction.Core;
using Microsoft.Purchases.History;

codeunit 50210 "CONS Purch Retention Events"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", OnAfterInsertEvent, '', true, true)]
    local procedure OnAfterPurchInvHeaderInsert(var Rec: Record "Purch. Inv. Header")
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        ServiceLocator.RetentionReactions().OnAfterPostedPurchInvoice(Rec);
    end;
}
