namespace Construction.Subcontracts;

table 50327 "CONS Subcontracts Setup"
{
    Caption = 'Subcontracts Setup';
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
            ToolTip = 'Specifies whether the Subcontracts feature is enabled. Turning it on shows the subcontract, claim and change-order pages and actions; the session restarts so the change takes effect.';
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
