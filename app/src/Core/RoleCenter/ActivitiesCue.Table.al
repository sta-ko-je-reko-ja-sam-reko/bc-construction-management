namespace Construction.Core;

table 50021 "CONS Activities Cue"
{
    Caption = 'Construction Activities';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Construction Projects"; Integer)
        {
            Caption = 'Construction Projects';
            Editable = false;
            ToolTip = 'Specifies the number of projects flagged as construction projects.';
        }
        field(11; "Active Projects"; Integer)
        {
            Caption = 'Active Projects';
            Editable = false;
            ToolTip = 'Specifies the number of open construction projects.';
        }
        field(20; "Bills of Quantities"; Integer)
        {
            Caption = 'Bills of Quantities';
            Editable = false;
            ToolTip = 'Specifies the number of bills of quantities (estimates).';
        }
        field(30; "Progress Billing Applications"; Integer)
        {
            Caption = 'Progress Billing Applications';
            Editable = false;
            ToolTip = 'Specifies the number of progress billing applications.';
        }
        field(40; Subcontracts; Integer)
        {
            Caption = 'Subcontracts';
            Editable = false;
            ToolTip = 'Specifies the number of subcontracts.';
        }
        field(41; "Change Orders"; Integer)
        {
            Caption = 'Change Orders';
            Editable = false;
            ToolTip = 'Specifies the number of change orders / variations.';
        }
        field(42; "Subcontractor Claims"; Integer)
        {
            Caption = 'Subcontractor Claims';
            Editable = false;
            ToolTip = 'Specifies the number of subcontractor progress claims.';
        }
        field(50; "Equipment Items"; Integer)
        {
            Caption = 'Equipment Items';
            Editable = false;
            ToolTip = 'Specifies the number of equipment records.';
        }
        field(51; "Equipment In Maintenance"; Integer)
        {
            Caption = 'Equipment In Maintenance';
            Editable = false;
            ToolTip = 'Specifies the number of equipment items currently in maintenance.';
        }
        field(60; "Scheduled Tasks"; Integer)
        {
            Caption = 'Scheduled Tasks';
            Editable = false;
            ToolTip = 'Specifies the number of project tasks placed on the schedule.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>Ensures the single (temporary) cue record exists so the activity part can bind to it. Counts are filled asynchronously by the Page Background Task — see "CONS Activities Cue Calc".</summary>
    internal procedure InitCue()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
