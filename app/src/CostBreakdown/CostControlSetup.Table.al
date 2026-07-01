namespace Construction.CostBreakdown;

table 50325 "CONS Cost Control Setup"
{
    Caption = 'Cost Control Setup';
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
            ToolTip = 'Specifies whether the Cost Control feature is enabled. Turning it on shows the cost-breakdown and forecasting pages and actions; the session restarts so the change takes effect.';
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
