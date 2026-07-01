namespace Construction.Estimating;

table 50324 "CONS Estimating Setup"
{
    Caption = 'Estimating Setup';
    DataClassification = CustomerContent;

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
            ToolTip = 'Specifies whether the Estimating feature is enabled. Turning it on shows the Estimating pages and actions; the session restarts so the change takes effect.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
