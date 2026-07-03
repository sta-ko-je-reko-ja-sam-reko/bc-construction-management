namespace Construction.Retention;

using Construction.Core;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;

/// <summary>
/// Base-app subscriber proxy — hooks the posted Sales/Purch invoice inserts published by MS BaseApp, so it
/// fires for EVERY user in the tenant. Entitled Unlicensed (via permission set "CONS Base Subs" → entitlement
/// "CONS Base Ent") so the subscription itself never errors for anyone. Pure proxy: each body is a guard plus a
/// one-line delegation. The guard asks the swappable access policy (resolved through the Unlicensed-entitled
/// Service Locator) whether the user has effective EXECUTE on the reaction implementation "CONS Retention Logic"
/// — a module-gated object — so only users who own the product forward to the reaction; everyone else's standard
/// invoice posting runs untouched. The per-feature (Enabled) tier check lives in the reaction, not here.
/// </summary>
codeunit 50211 "CONS Retention Subscribers"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", OnAfterInsertEvent, '', true, true)]
    local procedure OnAfterSalesInvoiceHeaderInsert(var Rec: Record "Sales Invoice Header")
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Retention Logic") then
            exit;
        ServiceLocator.RetentionReactions().OnAfterPostedSalesInvoice(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", OnAfterInsertEvent, '', true, true)]
    local procedure OnAfterPurchInvHeaderInsert(var Rec: Record "Purch. Inv. Header")
    var
        ServiceLocator: Codeunit "CONS Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"CONS Retention Logic") then
            exit;
        ServiceLocator.RetentionReactions().OnAfterPostedPurchInvoice(Rec);
    end;
}
