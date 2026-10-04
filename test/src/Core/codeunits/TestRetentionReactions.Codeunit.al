namespace Construction.Test;

using Construction.Retention;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

/// <summary>Fake retention reactions: records each call in Library - Variable Storage instead of writing retention entries, so a test can see whether the subscriber proxy forwarded the event.</summary>
codeunit 64018 "CONS Test Retention Reactions" implements "CONS IRetentionReactions"
{
    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure OnAfterPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        LibraryVariableStorage.Enqueue(SalesInvoiceHeader."No.");
    end;

    procedure OnAfterPostedPurchInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        LibraryVariableStorage.Enqueue(PurchInvHeader."No.");
    end;
}
