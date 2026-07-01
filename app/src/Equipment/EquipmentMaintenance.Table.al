namespace Construction.Equipment;

using Microsoft.Purchases.Vendor;

table 50413 "CONS Equipment Maintenance"
{
    Caption = 'Equipment Maintenance';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique entry number of the maintenance record.';
        }
        field(5; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Equipment";
            ToolTip = 'Specifies the equipment the maintenance record relates to.';
        }
        field(10; "Maintenance Date"; Date)
        {
            Caption = 'Maintenance Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the maintenance was carried out.';
        }
        field(11; "Maintenance Type"; Enum "CONS Maintenance Type")
        {
            Caption = 'Maintenance Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of maintenance that was carried out.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the maintenance that was carried out.';
        }
        field(20; "Meter Reading"; Decimal)
        {
            Caption = 'Meter Reading';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the equipment meter reading recorded at the time of maintenance.';
        }
        field(25; Cost; Decimal)
        {
            Caption = 'Cost';
            AutoFormatType = 1;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the cost of the maintenance.';
        }
        field(30; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ToolTip = 'Specifies the vendor that carried out the maintenance.';
        }
        field(35; "Next Service Date"; Date)
        {
            Caption = 'Next Service Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the equipment is next due for service.';
        }
        field(36; "Next Service Meter"; Decimal)
        {
            Caption = 'Next Service Meter';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the meter reading at which the equipment is next due for service.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Equipment; "Equipment No.")
        {
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS IEquipmentMaintenance";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IEquipmentMaintenance"
    var
        Default: Codeunit "CONS Equipment Maint. Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative maintenance-logic implementation (tests / downstream overrides).</summary>
    /// <param name="Implementation">The logic implementation to use.</param>
    procedure Define(Implementation: Interface "CONS IEquipmentMaintenance")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
