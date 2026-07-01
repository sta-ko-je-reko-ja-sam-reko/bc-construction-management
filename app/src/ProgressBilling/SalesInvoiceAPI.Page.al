namespace Construction.ProgressBilling;

using Microsoft.Integration.Entity;

page 50341 "CONS Sales Invoice API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'salesInvoice';
    EntitySetName = 'salesInvoices';
    EntityCaption = 'Sales Invoice';
    EntitySetCaption = 'Sales Invoices';
    ODataKeyFields = Id;
    SourceTable = "Sales Invoice Entity Aggregate";
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
                field(invoiceDate; Rec."Document Date") { Caption = 'Invoice Date'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(dueDate; Rec."Due Date") { Caption = 'Due Date'; }
                field(customerPurchaseOrderReference; Rec."Your Reference") { Caption = 'Customer Purchase Order Reference'; }
                field(customerId; Rec."Customer Id") { Caption = 'Customer Id'; }
                field(customerNumber; Rec."Sell-to Customer No.") { Caption = 'Customer Number'; }
                field(customerName; Rec."Sell-to Customer Name") { Caption = 'Customer Name'; Editable = false; }
                field(billToName; Rec."Bill-to Name") { Caption = 'Bill-To Name'; Editable = false; }
                field(billToCustomerId; Rec."Bill-to Customer Id") { Caption = 'Bill-To Customer Id'; }
                field(billToCustomerNumber; Rec."Bill-to Customer No.") { Caption = 'Bill-To Customer Number'; }
                field(shipToName; Rec."Ship-to Name") { Caption = 'Ship-To Name'; }
                field(shipToContact; Rec."Ship-to Contact") { Caption = 'Ship-To Contact'; }
                field(sellToAddressLine1; Rec."Sell-to Address") { Caption = 'Sell-To Address Line 1'; }
                field(sellToAddressLine2; Rec."Sell-to Address 2") { Caption = 'Sell-To Address Line 2'; }
                field(sellToCity; Rec."Sell-to City") { Caption = 'Sell-To City'; }
                field(sellToCountry; Rec."Sell-to Country/Region Code") { Caption = 'Sell-To Country/Region Code'; }
                field(sellToState; Rec."Sell-to County") { Caption = 'Sell-To State'; }
                field(sellToPostCode; Rec."Sell-to Post Code") { Caption = 'Sell-To Post Code'; }
                field(billToAddressLine1; Rec."Bill-To Address") { Caption = 'Bill-To Address Line 1'; Editable = false; }
                field(billToAddressLine2; Rec."Bill-To Address 2") { Caption = 'Bill-To Address Line 2'; Editable = false; }
                field(billToCity; Rec."Bill-To City") { Caption = 'Bill-To City'; Editable = false; }
                field(billToCountry; Rec."Bill-To Country/Region Code") { Caption = 'Bill-To Country/Region Code'; Editable = false; }
                field(billToState; Rec."Bill-To County") { Caption = 'Bill-To State'; Editable = false; }
                field(billToPostCode; Rec."Bill-To Post Code") { Caption = 'Bill-To Post Code'; Editable = false; }
                field(shipToAddressLine1; Rec."Ship-to Address") { Caption = 'Ship-To Address Line 1'; }
                field(shipToAddressLine2; Rec."Ship-to Address 2") { Caption = 'Ship-To Address Line 2'; }
                field(shipToCity; Rec."Ship-to City") { Caption = 'Ship-To City'; }
                field(shipToCountry; Rec."Ship-to Country/Region Code") { Caption = 'Ship-To Country/Region Code'; }
                field(shipToState; Rec."Ship-to County") { Caption = 'Ship-To State'; }
                field(shipToPostCode; Rec."Ship-to Post Code") { Caption = 'Ship-To Post Code'; }
                field(currencyId; Rec."Currency Id") { Caption = 'Currency Id'; }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code") { Caption = 'Shortcut Dimension 1 Code'; }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code") { Caption = 'Shortcut Dimension 2 Code'; }
                field(orderId; Rec."Order Id") { Caption = 'Order Id'; Editable = false; }
                field(orderNumber; Rec."Order No.") { Caption = 'Order Number'; Editable = false; }
                field(paymentTermsId; Rec."Payment Terms Id") { Caption = 'Payment Terms Id'; }
                field(shipmentMethodId; Rec."Shipment Method Id") { Caption = 'Shipment Method Id'; }
                field(salesperson; Rec."Salesperson Code") { Caption = 'Salesperson'; }
                field(pricesIncludeTax; Rec."Prices Including VAT") { Caption = 'Prices Include Tax'; Editable = false; }
                field(discountAmount; Rec."Invoice Discount Amount") { Caption = 'Discount Amount'; }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax") { Caption = 'Discount Applied Before Tax'; Editable = false; }
                field(totalAmountExcludingTax; Rec.Amount) { Caption = 'Total Amount Excluding Tax'; Editable = false; }
                field(totalTaxAmount; Rec."Total Tax Amount") { Caption = 'Total Tax Amount'; Editable = false; }
                field(totalAmountIncludingTax; Rec."Amount Including VAT") { Caption = 'Total Amount Including Tax'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(phoneNumber; Rec."Sell-to Phone No.") { Caption = 'Phone Number'; }
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
