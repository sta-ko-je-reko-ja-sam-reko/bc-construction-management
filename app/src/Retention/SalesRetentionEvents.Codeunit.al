namespace Construction.Retention;

using Construction.Core;
using Microsoft.Sales.History;

codeunit 50206 "CONS Sales Retention Events"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", OnAfterInsertEvent, '', true, true)]
    local procedure OnAfterSalesInvoiceHeaderInsert(var Rec: Record "Sales Invoice Header")
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        ServiceLocator.RetentionReactions().OnAfterPostedSalesInvoice(Rec);
    end;
}
