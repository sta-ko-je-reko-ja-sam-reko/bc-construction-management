namespace Construction.ProgressBilling;

table 50326 "CONS Progress Billing Setup"
{
    Caption = 'Progress Billing Setup';
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
            ToolTip = 'Specifies whether the Progress Billing feature is enabled. Turning it on shows the progress-billing and retention pages and actions; the session restarts so the change takes effect.';
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
