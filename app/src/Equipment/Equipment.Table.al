namespace Construction.Equipment;

using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;

table 50410 "CONS Equipment"
{
    Caption = 'Equipment';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    LookupPageId = "CONS Equipment List";
    DrillDownPageId = "CONS Equipment List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique number identifying the equipment.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the equipment.';
        }
        field(3; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional description of the equipment.';
        }
        field(5; "Equipment Type"; Enum "CONS Equipment Type")
        {
            Caption = 'Equipment Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the kind of equipment, such as machine, vehicle, or tool.';
        }
        field(6; Status; Enum "CONS Equipment Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the current status of the equipment. The status is maintained automatically.';
        }
        field(7; Ownership; Enum "CONS Equipment Ownership")
        {
            Caption = 'Ownership';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the equipment is owned or hired.';
        }
        field(10; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            DataClassification = CustomerContent;
            TableRelation = Resource;
            ToolTip = 'Specifies the standard resource this equipment posts cost and usage through.';
        }
        field(11; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ToolTip = 'Specifies the location where the equipment is currently held.';
        }
        field(12; "Serial No."; Text[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the manufacturer serial number of the equipment.';
        }
        field(13; Manufacturer; Text[50])
        {
            Caption = 'Manufacturer';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the manufacturer of the equipment.';
        }
        field(14; Model; Text[50])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the model of the equipment.';
        }
        field(20; "Cost Rate"; Decimal)
        {
            Caption = 'Cost Rate';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the default unit cost of using the equipment, per usage unit of measure.';
        }
        field(21; "Hire Rate"; Decimal)
        {
            Caption = 'Hire Rate';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the default charge or hire rate for the equipment, per usage unit of measure.';
        }
        field(22; "Rate Unit of Measure"; Code[10])
        {
            Caption = 'Rate Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ToolTip = 'Specifies the unit of measure the cost and hire rates apply to.';
        }
        field(30; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ToolTip = 'Specifies the vendor the equipment is hired from.';
        }
        field(31; "On-Hire Date"; Date)
        {
            Caption = 'On-Hire Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment was taken on hire.';
        }
        field(32; "Off-Hire Date"; Date)
        {
            Caption = 'Off-Hire Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment was returned off hire.';
        }
        field(40; "Meter Reading"; Decimal)
        {
            Caption = 'Meter Reading';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the current operating hours or meter reading of the equipment.';
        }
        field(41; "Meter Unit"; Code[10])
        {
            Caption = 'Meter Unit';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unit the meter reading is recorded in, such as HOURS or KM.';
        }
        field(42; "Last Service Date"; Date)
        {
            Caption = 'Last Service Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment was last serviced.';
        }
        field(43; "Next Service Date"; Date)
        {
            Caption = 'Next Service Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment is next due for service.';
        }
        field(44; "Next Service Meter"; Decimal)
        {
            Caption = 'Next Service Meter';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the meter reading at which the equipment is next due for service.';
        }
        field(45; "In Maintenance"; Boolean)
        {
            Caption = 'In Maintenance';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the equipment is currently in maintenance, which blocks its usage.';
        }
        field(50; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the equipment is blocked from being used.';
        }
        field(60; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used to assign the number to the equipment.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        EquipmentSetup: Record "CONS Equipment Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if Rec."No." <> '' then
            exit;
        EquipmentSetup.Get();
        EquipmentSetup.TestField("Equipment Nos.");
        Rec."No. Series" := EquipmentSetup."Equipment Nos.";
        Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
    end;
}
