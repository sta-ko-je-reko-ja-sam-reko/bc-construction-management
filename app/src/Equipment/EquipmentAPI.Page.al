namespace Construction.Equipment;

using Construction.Core;

page 50440 "CONS Equipment API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipment';
    EntitySetName = 'equipmentItems';
    EntityCaption = 'Equipment';
    EntitySetCaption = 'Equipment';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment";
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
                field(description2; Rec."Description 2") { Caption = 'Description 2'; }
                field(equipmentType; Rec."Equipment Type") { Caption = 'Equipment Type'; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(ownership; Rec.Ownership) { Caption = 'Ownership'; }
                field(resourceNo; Rec."Resource No.") { Caption = 'Resource No.'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(serialNo; Rec."Serial No.") { Caption = 'Serial No.'; }
                field(manufacturer; Rec.Manufacturer) { Caption = 'Manufacturer'; }
                field(model; Rec.Model) { Caption = 'Model'; }
                field(costRate; Rec."Cost Rate") { Caption = 'Cost Rate'; }
                field(hireRate; Rec."Hire Rate") { Caption = 'Hire Rate'; }
                field(rateUnitOfMeasure; Rec."Rate Unit of Measure") { Caption = 'Rate Unit of Measure'; }
                field(vendorNo; Rec."Vendor No.") { Caption = 'Vendor No.'; }
                field(onHireDate; Rec."On-Hire Date") { Caption = 'On-Hire Date'; }
                field(offHireDate; Rec."Off-Hire Date") { Caption = 'Off-Hire Date'; }
                field(meterReading; Rec."Meter Reading") { Caption = 'Meter Reading'; }
                field(meterUnit; Rec."Meter Unit") { Caption = 'Meter Unit'; }
                field(lastServiceDate; Rec."Last Service Date") { Caption = 'Last Service Date'; }
                field(nextServiceDate; Rec."Next Service Date") { Caption = 'Next Service Date'; }
                field(nextServiceMeter; Rec."Next Service Meter") { Caption = 'Next Service Meter'; }
                field(inMaintenance; Rec."In Maintenance") { Caption = 'In Maintenance'; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
                field(noSeries; Rec."No. Series") { Caption = 'No. Series'; Editable = false; }
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
