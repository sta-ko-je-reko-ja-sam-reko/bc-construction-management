namespace Construction.Estimating;

using Construction.Core;

page 50283 "CONS BoQ API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'billOfQuantities';
    EntitySetName = 'billsOfQuantities';
    EntityCaption = 'Bill of Quantities';
    EntitySetCaption = 'Bills of Quantities';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS BoQ Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(billToCustomerNo; Rec."Bill-to Customer No.") { Caption = 'Bill-to Customer No.'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(estimatorCode; Rec."Estimator Code") { Caption = 'Estimator'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
                field(defaultMarkupPct; Rec."Default Markup %") { Caption = 'Default Markup %'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(endingDate; Rec."Ending Date") { Caption = 'Ending Date'; }
                field(totalCost; Rec."Total Cost") { Caption = 'Total Cost'; Editable = false; }
                field(totalPrice; Rec."Total Price") { Caption = 'Total Price'; Editable = false; }
                field(noSeries; Rec."No. Series") { Caption = 'No. Series'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Estimating);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Estimating);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Estimating);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
