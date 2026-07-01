namespace Construction.Equipment;

using Construction.Core;

page 50442 "CONS Equipment Usage API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipmentUsage';
    EntitySetName = 'equipmentUsageEntries';
    EntityCaption = 'Equipment Usage';
    EntitySetCaption = 'Equipment Usage Entries';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment Usage";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(equipmentNo; Rec."Equipment No.") { Caption = 'Equipment No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(totalCost; Rec."Total Cost") { Caption = 'Total Cost'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
