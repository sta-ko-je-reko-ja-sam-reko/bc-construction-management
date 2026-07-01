namespace Construction.Retention;

using Microsoft.Purchases.History;
using Microsoft.Sales.History;

interface "CONS IRetentionReactions"
{
    Access = Public;

    /// <summary>Reacts to a posted sales invoice: records the receivable retention withheld or released.</summary>
    procedure OnAfterPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header");

    /// <summary>Reacts to a posted purchase invoice: records the payable retention withheld or released.</summary>
    procedure OnAfterPostedPurchInvoice(var PurchInvHeader: Record "Purch. Inv. Header");
}
