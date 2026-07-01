namespace Construction.Equipment;

using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;

table 50416 "CONS Equipment Setup"
{
    Caption = 'Equipment Setup';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the Equipment & Plant feature is enabled. Turning it on shows the equipment pages and actions; the session restarts so the change takes effect.';
        }
        field(20; "Equipment Nos."; Code[20])
        {
            Caption = 'Equipment Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used to assign numbers to equipment records.';
        }
        field(21; "Default Rate Unit of Measure"; Code[10])
        {
            Caption = 'Default Rate Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ToolTip = 'Specifies the unit of measure defaulted onto the cost and hire rates of new equipment.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>Ensures the singleton setup record exists and returns it.</summary>
    internal procedure InitSetup()
    begin
        if Rec.Get() then
            exit;
        Rec.Init();
        Rec.Insert();
    end;
}
