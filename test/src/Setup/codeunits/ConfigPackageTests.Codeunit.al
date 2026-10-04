namespace Construction.Test;

using Construction.Estimating;
using Construction.Setup;
using Microsoft.Projects.Project.Job;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 64024 "CONS Config Package Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure EnsurePackage_CreatesOnceThenReportsExisting()
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        PackageCode: Code[20];
    begin
        // [GIVEN] a package code that does not exist
        PackageCode := TestLibrary.NewCode();
        // [WHEN]/[THEN] the first call creates it and returns true; the second is a no-op returning false
        Assert.IsTrue(ConfigPackageBuilder.EnsurePackage(PackageCode, 'Test package'), 'package created');
        Assert.IsFalse(ConfigPackageBuilder.EnsurePackage(PackageCode, 'Test package'), 'second call does not recreate');
        Assert.IsTrue(ConfigPackage.Get(PackageCode), 'package exists');
    end;

    [Test]
    procedure AddOwnTable_IncludesAllFields()
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        PackageCode: Code[20];
    begin
        // [GIVEN] a new package
        PackageCode := TestLibrary.NewCode();
        ConfigPackageBuilder.EnsurePackage(PackageCode, 'Test package');
        // [WHEN] one of our own tables is added
        ConfigPackageBuilder.AddOwnTable(PackageCode, Database::"CONS BoQ Header");
        // [THEN] the table is in the package and its fields are not narrowed (key and business fields both included)
        Assert.IsTrue(ConfigPackageTable.Get(PackageCode, Database::"CONS BoQ Header"), 'own table added');
        ConfigPackageField.Get(PackageCode, Database::"CONS BoQ Header", 1);
        Assert.IsTrue(ConfigPackageField."Include Field", 'No. included');
        ConfigPackageField.Get(PackageCode, Database::"CONS BoQ Header", 2);
        Assert.IsTrue(ConfigPackageField."Include Field", 'Description included');
        ConfigPackageField.Get(PackageCode, Database::"CONS BoQ Header", 5);
        Assert.IsTrue(ConfigPackageField."Include Field", 'Project No. included');
    end;

    [Test]
    procedure AddExtendedTable_KeepsOnlyKeyAndAffixFields()
    var
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        PackageCode: Code[20];
    begin
        // [GIVEN] a new package
        PackageCode := TestLibrary.NewCode();
        ConfigPackageBuilder.EnsurePackage(PackageCode, 'Test package');
        // [WHEN] the standard Job table (extended with CONS fields) is added
        ConfigPackageBuilder.AddExtendedTable(PackageCode, Database::Job);
        // [THEN] the primary key and our CONS fields are included
        ConfigPackageField.Get(PackageCode, Database::Job, 1);
        Assert.IsTrue(ConfigPackageField."Include Field", 'primary key included');
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", Database::Job);
        ConfigPackageField.SetFilter("Field Name", 'CONS *');
        ConfigPackageField.SetRange("Include Field", false);
        Assert.RecordIsEmpty(ConfigPackageField);
        // [THEN] Microsoft's own non-key columns are excluded
        ConfigPackageField.Get(PackageCode, Database::Job, 2);
        Assert.IsFalse(ConfigPackageField."Include Field", 'standard Search Description excluded');
    end;

    [Test]
    procedure SnapshotTable_CapturesRowValues()
    var
        BoQHeader: Record "CONS BoQ Header";
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        RecRef: RecordRef;
        PackageCode: Code[20];
    begin
        // [GIVEN] a package with the BoQ header table and one BoQ
        PackageCode := TestLibrary.NewCode();
        ConfigPackageBuilder.EnsurePackage(PackageCode, 'Test package');
        ConfigPackageBuilder.AddOwnTable(PackageCode, Database::"CONS BoQ Header");
        BoQHeader.Init();
        BoQHeader."No." := TestLibrary.NewCode();
        BoQHeader.Description := 'Snapshot me';
        BoQHeader.Insert();

        // [WHEN] the BoQ is snapshotted into the package
        BoQHeader.SetRecFilter();
        RecRef.GetTable(BoQHeader);
        ConfigPackageBuilder.SnapshotTable(PackageCode, RecRef);

        // [THEN] the package data carries the row's values (not just the table shape)
        ConfigPackageData.SetRange("Package Code", PackageCode);
        ConfigPackageData.SetRange("Table ID", Database::"CONS BoQ Header");
        ConfigPackageData.SetRange("Field ID", BoQHeader.FieldNo(Description));
        ConfigPackageData.FindFirst();
        Assert.AreEqual('Snapshot me', ConfigPackageData.Value, 'description value captured');
        // [THEN] FlowFields are never snapshotted
        ConfigPackageData.SetRange("Field ID", BoQHeader.FieldNo("Total Cost"));
        Assert.RecordIsEmpty(ConfigPackageData);
    end;
}
