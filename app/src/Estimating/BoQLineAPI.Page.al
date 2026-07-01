namespace Construction.Estimating;

using Construction.Core;

page 50284 "CONS BoQ Line API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'billOfQuantitiesLine';
    EntitySetName = 'billOfQuantitiesLines';
    EntityCaption = 'BoQ Line';
    EntitySetCaption = 'BoQ Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS BoQ Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(documentNo; Rec."Document No.") { Caption = 'Document No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(lineType; Rec."Line Type") { Caption = 'Line Type'; }
                field(indentation; Rec.Indentation) { Caption = 'Indentation'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(costType; Rec."Cost Type") { Caption = 'Cost Type'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(totalCost; Rec."Total Cost") { Caption = 'Total Cost'; Editable = false; }
                field(markupPct; Rec."Markup %") { Caption = 'Markup %'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; Editable = false; }
                field(totalPrice; Rec."Total Price") { Caption = 'Total Price'; Editable = false; }
                field(projectTaskNo; Rec."Project Task No.") { Caption = 'Project Task No.'; }
                field(linkedJobPlanningLineNo; Rec."Linked Job Planning Line No.") { Caption = 'Linked Project Planning Line No.'; Editable = false; }
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
