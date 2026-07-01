namespace Construction.Subcontracts;

using Microsoft.Integration.Entity;

page 50345 "CONS Purchase Invoice API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    EntityCaption = 'Purchase Invoice';
    EntitySetCaption = 'Purchase Invoices';
    ODataKeyFields = Id;
    SourceTable = "Purch. Inv. Entity Aggregate";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(invoiceDate; Rec."Document Date") { Caption = 'Invoice Date'; }
                field(dueDate; Rec."Due Date") { Caption = 'Due Date'; }
                field(vendorInvoiceNumber; Rec."Vendor Invoice No.") { Caption = 'Vendor Invoice No.'; }
                field(vendorId; Rec."Vendor Id") { Caption = 'Vendor Id'; }
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'Vendor No.'; }
                field(vendorName; Rec."Buy-from Vendor Name") { Caption = 'Vendor Name'; Editable = false; }
                field(payToName; Rec."Pay-to Name") { Caption = 'Pay-To Name'; Editable = false; }
                field(payToContact; Rec."Pay-to Contact") { Caption = 'Pay-To Contact'; Editable = false; }
                field(payToVendorId; Rec."Pay-to Vendor Id") { Caption = 'Pay-To Vendor Id'; }
                field(payToVendorNumber; Rec."Pay-to Vendor No.") { Caption = 'Pay-To Vendor No.'; }
                field(shipToName; Rec."Ship-to Name") { Caption = 'Ship-To Name'; }
                field(shipToContact; Rec."Ship-to Contact") { Caption = 'Ship-To Contact'; }
                field(buyFromAddressLine1; Rec."Buy-from Address") { Caption = 'Buy-from Address Line 1'; }
                field(buyFromAddressLine2; Rec."Buy-from Address 2") { Caption = 'Buy-from Address Line 2'; }
                field(buyFromCity; Rec."Buy-from City") { Caption = 'Buy-from City'; }
                field(buyFromCountry; Rec."Buy-from Country/Region Code") { Caption = 'Buy-from Country/Region Code'; }
                field(buyFromState; Rec."Buy-from County") { Caption = 'Buy-from State'; }
                field(buyFromPostCode; Rec."Buy-from Post Code") { Caption = 'Buy-from Post Code'; }
                field(shipToAddressLine1; Rec."Ship-to Address") { Caption = 'Ship-to Address Line 1'; }
                field(shipToAddressLine2; Rec."Ship-to Address 2") { Caption = 'Ship-to Address Line 2'; }
                field(shipToCity; Rec."Ship-to City") { Caption = 'Ship-to City'; }
                field(shipToCountry; Rec."Ship-to Country/Region Code") { Caption = 'Ship-to Country/Region Code'; }
                field(shipToState; Rec."Ship-to County") { Caption = 'Ship-to State'; }
                field(shipToPostCode; Rec."Ship-to Post Code") { Caption = 'Ship-to Post Code'; }
                field(payToAddressLine1; Rec."Pay-to Address") { Caption = 'Pay To Address Line 1'; Editable = false; }
                field(payToAddressLine2; Rec."Pay-to Address 2") { Caption = 'Pay To Address Line 2'; Editable = false; }
                field(payToCity; Rec."Pay-to City") { Caption = 'Pay To City'; Editable = false; }
                field(payToCountry; Rec."Pay-to Country/Region Code") { Caption = 'Pay To Country/Region Code'; Editable = false; }
                field(payToState; Rec."Pay-to County") { Caption = 'Pay To State'; Editable = false; }
                field(payToPostCode; Rec."Pay-to Post Code") { Caption = 'Pay To Post Code'; Editable = false; }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code") { Caption = 'Shortcut Dimension 1 Code'; }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code") { Caption = 'Shortcut Dimension 2 Code'; }
                field(currencyId; Rec."Currency Id") { Caption = 'Currency Id'; }
                field(orderId; Rec."Order Id") { Caption = 'Order Id'; Editable = false; }
                field(orderNumber; Rec."Order No.") { Caption = 'Order No.'; Editable = false; }
                field(purchaser; Rec."Purchaser Code") { Caption = 'Purchaser'; }
                field(pricesIncludeTax; Rec."Prices Including VAT") { Caption = 'Prices Include Tax'; }
                field(discountAmount; Rec."Invoice Discount Amount") { Caption = 'Discount Amount'; }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax") { Caption = 'Discount Applied Before Tax'; Editable = false; }
                field(totalAmountExcludingTax; Rec.Amount) { Caption = 'Total Amount Excluding Tax'; Editable = false; }
                field(totalTaxAmount; Rec."Total Tax Amount") { Caption = 'Total Tax Amount'; Editable = false; }
                field(totalAmountIncludingTax; Rec."Amount Including VAT") { Caption = 'Total Amount Including Tax'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(subcontractClaimNo; Rec."CONS Subc Claim No.") { Caption = 'Subcontract Claim No.'; Editable = false; }
                field(constructionProjectNo; Rec."CONS Project No.") { Caption = 'Construction Project No.'; Editable = false; }
                field(retentionAmount; Rec."CONS Retention Amount") { Caption = 'Retention Amount'; Editable = false; }
                field(retentionIsRelease; Rec."CONS Retention Is Release") { Caption = 'Retention Is Release'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
