namespace Construction.Scheduling;

table 50461 "CONS Scheduling Setup"
{
    Caption = 'Scheduling Setup';
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
            ToolTip = 'Specifies whether the Scheduling & Resource Planning feature is enabled. Turning it on shows the scheduling pages and Gantt; the session restarts so the change takes effect.';
        }
        field(20; "Default Dependency Type"; Enum "CONS Dependency Type")
        {
            Caption = 'Default Dependency Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the dependency type defaulted onto new task dependencies.';
        }
        field(21; "Include Nonworking Days"; Boolean)
        {
            Caption = 'Include Nonworking Days';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether weekends and other nonworking days are counted when calculating task duration.';
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
