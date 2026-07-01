namespace Construction.Equipment;

using Construction.Core;

page 50444 "CONS Equipment Meter API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipmentMeterEntry';
    EntitySetName = 'equipmentMeterEntries';
    EntityCaption = 'Equipment Meter Entry';
    EntitySetCaption = 'Equipment Meter Entries';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment Meter Entry";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(equipmentNo; Rec."Equipment No.") { Caption = 'Equipment No.'; }
                field(readingDate; Rec."Reading Date") { Caption = 'Reading Date'; }
                field(meterReading; Rec."Meter Reading") { Caption = 'Meter Reading'; }
                field(description; Rec.Description) { Caption = 'Description'; }
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
