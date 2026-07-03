namespace Construction.Setup;

using System.IO;

/// <summary>
/// Builds a per-feature RapidStart Configuration Package for the demo data — called from each feature seeder's
/// Import(), so a package exists ONLY when the user opted to import that feature's demo data (never eager, never
/// on install). Idempotent on the package code. Own tables are added with all fields; a standard table extended
/// by CONS fields is added narrowed to its primary key + our affix fields (never Microsoft's base columns, and
/// never another extension's). The feature Setup tables are intentionally never added — those are prepopulated by
/// the Assisted Setup wizard / MCP path, not by RapidStart. Structure (tables + included fields) is built by
/// EnsurePackage/AddOwnTable/AddExtendedTable; SnapshotTable then captures the seeded row values into
/// Config. Package Data, so the package carries the demo data (not just the shape) when exported to another company.
/// </summary>
codeunit 50029 "CONS Config Package Builder"
{
    Access = Public;

    /// <summary>Creates the configuration package if it does not exist. Returns true when it was just created — the caller adds its tables only then, so re-running is a no-op. RapidStart config tables are excluded.</summary>
    procedure EnsurePackage(PackageCode: Code[20]; PackageName: Text[50]): Boolean
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        if ConfigPackage.Get(PackageCode) then
            exit(false);
        ConfigPackageMgt.InsertPackage(ConfigPackage, PackageCode, PackageName, true);
        exit(true);
    end;

    /// <summary>Adds one of our own tables to the package with all its fields.</summary>
    procedure AddOwnTable(PackageCode: Code[20]; TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);
    end;

    /// <summary>Adds a standard table extended by CONS fields, then narrows the included fields to the primary key + our affix (CONS) fields, so the package carries only our projection onto the standard record — not Microsoft's (or another extension's) columns.</summary>
    procedure AddExtendedTable(PackageCode: Code[20]; TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", TableId);
        if ConfigPackageField.FindSet() then
            repeat
                ConfigPackageField."Include Field" :=
                    ConfigPackageField."Primary Key" or ConfigPackageField."Field Name".StartsWith('CONS ');
                ConfigPackageField.Modify(true);
            until ConfigPackageField.Next() = 0;
    end;

    /// <summary>Captures the (filtered) records behind RecRef into the package's data — one Config. Package Data row per included Normal field — so the package carries the demo VALUES, not just the structure, into another company. Values are stored in the culture-invariant XML format (Format code 9) that RapidStart round-trips when the package is applied. Call after the records are seeded, with RecRef filtered to just the demo rows.</summary>
    procedure SnapshotTable(PackageCode: Code[20]; var RecRef: RecordRef)
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldRef: FieldRef;
        TableId: Integer;
        RecNo: Integer;
    begin
        TableId := RecRef.Number;
        if not RecRef.FindSet() then
            exit;
        repeat
            RecNo += 1;
            ConfigPackageField.SetRange("Package Code", PackageCode);
            ConfigPackageField.SetRange("Table ID", TableId);
            ConfigPackageField.SetRange("Include Field", true);
            if ConfigPackageField.FindSet() then
                repeat
                    FieldRef := RecRef.Field(ConfigPackageField."Field ID");
                    if FieldRef.Class = FieldClass::Normal then
                        ConfigPackageMgt.InsertPackageData(ConfigPackageData, PackageCode, TableId, RecNo,
                            ConfigPackageField."Field ID", CopyStr(Format(FieldRef.Value, 0, 9), 1, MaxStrLen(ConfigPackageData.Value)), false);
                until ConfigPackageField.Next() = 0;
        until RecRef.Next() = 0;
    end;
}
