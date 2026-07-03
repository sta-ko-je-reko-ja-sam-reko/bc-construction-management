namespace Construction.Setup;

/// <summary>
/// Shared, tiny dummy source for the per-feature demo-import API pages. The demo importers exist for their
/// bound [ServiceEnabled] action (the MCP tool), not for their rows — so every "CONS Demo &lt;Feature&gt; API" page
/// binds to this one empty table. No records are ever written here; it only gives the API pages a SourceTable.
/// </summary>
table 50030 "CONS Demo Data"
{
    Caption = 'Demo Data';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20]) { Caption = 'Code'; }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
