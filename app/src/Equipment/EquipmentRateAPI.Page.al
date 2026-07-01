namespace Construction.Equipment;

using Construction.Core;

page 50441 "CONS Equipment Rate API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipmentRate';
    EntitySetName = 'equipmentRates';
    EntityCaption = 'Equipment Rate';
    EntitySetCaption = 'Equipment Rates';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment Rate";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(equipmentNo; Rec."Equipment No.") { Caption = 'Equipment No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(hireRate; Rec."Hire Rate") { Caption = 'Hire Rate'; }
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
