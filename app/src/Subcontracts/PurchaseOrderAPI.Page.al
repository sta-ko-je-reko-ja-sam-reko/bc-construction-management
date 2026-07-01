namespace Construction.Subcontracts;

using Microsoft.Integration.Entity;

page 50347 "CONS Purchase Order API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'purchaseOrder';
    EntitySetName = 'purchaseOrders';
    EntityCaption = 'Purchase Order';
    EntitySetCaption = 'Purchase Orders';
    ODataKeyFields = Id;
    SourceTable = "Purchase Order Entity Buffer";
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
                field(orderDate; Rec."Document Date") { Caption = 'Order Date'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(vendorId; Rec."Vendor Id") { Caption = 'Vendor Id'; }
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'Vendor No.'; }
                field(vendorName; Rec."Buy-from Vendor Name") { Caption = 'Vendor Name'; Editable = false; }
                field(payToName; Rec."Pay-to Name") { Caption = 'Pay-to Name'; Editable = false; }
                field(payToVendorId; Rec."Pay-to Vendor Id") { Caption = 'Pay-to Vendor Id'; }
                field(payToVendorNumber; Rec."Pay-to Vendor No.") { Caption = 'Pay-to Vendor No.'; }
                field(shipToName; Rec."Ship-to Name") { Caption = 'Ship-to Name'; }
                field(shipToContact; Rec."Ship-to Contact") { Caption = 'Ship-to Contact'; }
                field(buyFromAddressLine1; Rec."Buy-from Address") { Caption = 'Buy-from Address Line 1'; }
                field(buyFromAddressLine2; Rec."Buy-from Address 2") { Caption = 'Buy-from Address Line 2'; }
                field(buyFromCity; Rec."Buy-from City") { Caption = 'Buy-from City'; }
                field(buyFromCountry; Rec."Buy-from Country/Region Code") { Caption = 'Buy-from Country/Region Code'; }
                field(buyFromState; Rec."Buy-from County") { Caption = 'Buy-from State'; }
                field(buyFromPostCode; Rec."Buy-from Post Code") { Caption = 'Buy-from Post Code'; }
                field(payToAddressLine1; Rec."Pay-to Address") { Caption = 'Pay-to Address Line 1'; Editable = false; }
                field(payToAddressLine2; Rec."Pay-to Address 2") { Caption = 'Pay-to Address Line 2'; Editable = false; }
                field(payToCity; Rec."Pay-to City") { Caption = 'Pay-to City'; Editable = false; }
                field(payToCountry; Rec."Pay-to Country/Region Code") { Caption = 'Pay-to Country/Region Code'; Editable = false; }
                field(payToState; Rec."Pay-to County") { Caption = 'Pay-to State'; Editable = false; }
                field(payToPostCode; Rec."Pay-to Post Code") { Caption = 'Pay-to Post Code'; Editable = false; }
                field(shipToAddressLine1; Rec."Ship-to Address") { Caption = 'Ship-to Address Line 1'; }
                field(shipToAddressLine2; Rec."Ship-to Address 2") { Caption = 'Ship-to Address Line 2'; }
                field(shipToCity; Rec."Ship-to City") { Caption = 'Ship-to City'; }
                field(shipToCountry; Rec."Ship-to Country/Region Code") { Caption = 'Ship-to Country/Region Code'; }
                field(shipToState; Rec."Ship-to County") { Caption = 'Ship-to State'; }
                field(shipToPostCode; Rec."Ship-to Post Code") { Caption = 'Ship-to Post Code'; }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code") { Caption = 'Shortcut Dimension 1 Code'; }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code") { Caption = 'Shortcut Dimension 2 Code'; }
                field(currencyId; Rec."Currency Id") { Caption = 'Currency Id'; }
                field(pricesIncludeTax; Rec."Prices Including VAT") { Caption = 'Prices Include Tax'; }
                field(paymentTermsId; Rec."Payment Terms Id") { Caption = 'Payment Terms Id'; }
                field(shipmentMethodId; Rec."Shipment Method Id") { Caption = 'Shipment Method Id'; }
                field(purchaser; Rec."Purchaser Code") { Caption = 'Purchaser'; }
                field(requestedReceiptDate; Rec."Requested Receipt Date") { Caption = 'Requested Receipt Date'; }
                field(discountAmount; Rec."Invoice Discount Amount") { Caption = 'Discount Amount'; }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax") { Caption = 'Discount Applied Before Tax'; Editable = false; }
                field(totalAmountExcludingTax; Rec.Amount) { Caption = 'Total Amount Excluding Tax'; Editable = false; }
                field(totalTaxAmount; Rec."Total Tax Amount") { Caption = 'Total Tax Amount'; Editable = false; }
                field(totalAmountIncludingTax; Rec."Amount Including VAT") { Caption = 'Total Amount Including Tax'; Editable = false; }
                field(fullyReceived; Rec."Completely Received") { Caption = 'Fully Received'; }
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
