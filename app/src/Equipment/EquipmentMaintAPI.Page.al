namespace Construction.Equipment;

using Construction.Core;

page 50443 "CONS Equipment Maint. API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipmentMaintenance';
    EntitySetName = 'equipmentMaintenanceEntries';
    EntityCaption = 'Equipment Maintenance';
    EntitySetCaption = 'Equipment Maintenance Entries';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment Maintenance";
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
                field(maintenanceDate; Rec."Maintenance Date") { Caption = 'Maintenance Date'; }
                field(maintenanceType; Rec."Maintenance Type") { Caption = 'Maintenance Type'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(meterReading; Rec."Meter Reading") { Caption = 'Meter Reading'; }
                field(cost; Rec.Cost) { Caption = 'Cost'; }
                field(vendorNo; Rec."Vendor No.") { Caption = 'Vendor No.'; }
                field(nextServiceDate; Rec."Next Service Date") { Caption = 'Next Service Date'; }
                field(nextServiceMeter; Rec."Next Service Meter") { Caption = 'Next Service Meter'; }
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
