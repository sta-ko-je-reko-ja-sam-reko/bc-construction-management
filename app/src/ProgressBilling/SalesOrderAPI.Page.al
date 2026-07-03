namespace Construction.ProgressBilling;

using Microsoft.Integration.Entity;

page 50343 "CONS Sales Order API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'salesOrder';
    EntitySetName = 'salesOrders';
    EntityCaption = 'Sales Order';
    EntitySetCaption = 'Sales Orders';
    ODataKeyFields = Id;
    SourceTable = "Sales Order Entity Buffer";
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
                field(externalDocumentNumber; Rec."External Document No.") { Caption = 'External Document No.'; }
                field(orderDate; Rec."Document Date") { Caption = 'Order Date'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(customerId; Rec."Customer Id") { Caption = 'Customer Id'; }
                field(customerNumber; Rec."Sell-to Customer No.") { Caption = 'Customer No.'; }
                field(customerName; Rec."Sell-to Customer Name") { Caption = 'Customer Name'; Editable = false; }
                field(billToName; Rec."Bill-to Name") { Caption = 'Bill-to Name'; Editable = false; }
                field(billToCustomerId; Rec."Bill-to Customer Id") { Caption = 'Bill-to Customer Id'; }
                field(billToCustomerNumber; Rec."Bill-to Customer No.") { Caption = 'Bill-to Customer No.'; }
                field(shipToName; Rec."Ship-to Name") { Caption = 'Ship-to Name'; }
                field(shipToContact; Rec."Ship-to Contact") { Caption = 'Ship-to Contact'; }
                field(sellToAddressLine1; Rec."Sell-to Address") { Caption = 'Sell-to Address Line 1'; }
                field(sellToAddressLine2; Rec."Sell-to Address 2") { Caption = 'Sell-to Address Line 2'; }
                field(sellToCity; Rec."Sell-to City") { Caption = 'Sell-to City'; }
                field(sellToCountry; Rec."Sell-to Country/Region Code") { Caption = 'Sell-to Country/Region Code'; }
                field(sellToState; Rec."Sell-to County") { Caption = 'Sell-to State'; }
                field(sellToPostCode; Rec."Sell-to Post Code") { Caption = 'Sell-to Post Code'; }
                field(billToAddressLine1; Rec."Bill-to Address") { Caption = 'Bill-to Address Line 1'; Editable = false; }
                field(billToAddressLine2; Rec."Bill-to Address 2") { Caption = 'Bill-to Address Line 2'; Editable = false; }
                field(billToCity; Rec."Bill-to City") { Caption = 'Bill-to City'; Editable = false; }
                field(billToCountry; Rec."Bill-to Country/Region Code") { Caption = 'Bill-to Country/Region Code'; Editable = false; }
                field(billToState; Rec."Bill-to County") { Caption = 'BillTo State'; Editable = false; }
                field(billToPostCode; Rec."Bill-to Post Code") { Caption = 'Bill-to Post Code'; Editable = false; }
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
                field(salesperson; Rec."Salesperson Code") { Caption = 'Salesperson'; }
                field(requestedDeliveryDate; Rec."Requested Delivery Date") { Caption = 'Requested Delivery Date'; }
                field(discountAmount; Rec."Invoice Discount Amount") { Caption = 'Discount Amount'; }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax") { Caption = 'Discount Applied Before Tax'; Editable = false; }
                field(totalAmountExcludingTax; Rec.Amount) { Caption = 'Total Amount Excluding Tax'; Editable = false; }
                field(totalTaxAmount; Rec."Total Tax Amount") { Caption = 'Total Tax Amount'; Editable = false; }
                field(totalAmountIncludingTax; Rec."Amount Including VAT") { Caption = 'Total Amount Including Tax'; Editable = false; }
                field(fullyShipped; Rec."Completely Shipped") { Caption = 'Fully Shipped'; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(phoneNumber; Rec."Sell-to Phone No.") { Caption = 'Phone No.'; }
                field(email; Rec."Sell-to E-Mail") { Caption = 'Email'; }
                field(constructionProjectNo; Rec."CONS Project No.") { Caption = 'Construction Project No.'; Editable = false; }
                field(progressBillingNo; Rec."CONS Progress Billing No.") { Caption = 'Progress Billing No.'; Editable = false; }
                field(retentionAmount; Rec."CONS Retention Amount") { Caption = 'Retention Amount'; Editable = false; }
                field(retentionIsRelease; Rec."CONS Retention Is Release") { Caption = 'Retention Is Release'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
