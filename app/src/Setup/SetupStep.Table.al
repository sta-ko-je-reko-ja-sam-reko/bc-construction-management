namespace Construction.Setup;

using Construction.Core;

table 50016 "CONS Setup Step"
{
    Caption = 'Construction Setup Step';
    DataClassification = SystemMetadata;
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; "Step No."; Integer)
        {
            Caption = 'Order';
            ToolTip = 'Specifies the order in which the feature should be set up.';
        }
        field(2; Module; Enum "CONS Module")
        {
            Caption = 'Module';
        }
        field(3; Feature; Enum "CONS Feature")
        {
            Caption = 'Feature';
        }
        field(4; "Has Toggle"; Boolean)
        {
            Caption = 'Has Toggle';
            ToolTip = 'Specifies whether the step represents a switchable feature. The Foundation step is always on and has no toggle.';
        }
        field(10; Name; Text[100])
        {
            Caption = 'Feature';
            ToolTip = 'Specifies the feature to set up.';
        }
        field(11; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies what the feature does and what the setup step prepares.';
        }
        field(12; "Setup Page ID"; Integer)
        {
            Caption = 'Detailed Setup Page';
            ToolTip = 'Specifies the feature''s full setup page, opened from the Detailed Setup action.';
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            ToolTip = 'Specifies whether the feature is currently enabled.';
        }
        field(30; Status; Enum "CONS Setup Step Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies how far the setup of this feature has progressed.';
        }
    }

    keys
    {
        key(PK; "Step No.")
        {
            Clustered = true;
        }
    }
}
