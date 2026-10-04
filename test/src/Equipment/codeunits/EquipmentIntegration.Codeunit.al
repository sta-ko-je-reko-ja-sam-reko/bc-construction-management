namespace Construction.Test;

using Construction.Core;
using Construction.Equipment;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Resources.Resource;
using System.TestLibraries.Utilities;

/// <summary>Integration tests for posting equipment usage to the project ledger through the standard Job Jnl.-Post Line.</summary>
codeunit 64033 "CONS Equipment Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryResource: Codeunit "Library - Resource";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    procedure PostUsage_PostsResourceUsageToProjectAndDeletesLine()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        JobLedgerEntry: Record "Job Ledger Entry";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] equipment linked to a resource, costing 55 per unit, and a usage line of 3 units on a project task
        Initialize(Job, JobTask);
        CreateEquipment(Equipment, 55);
        CreateUsage(Usage, Equipment, JobTask, 3);

        // [WHEN] the usage line is posted
        EquipmentUsagePost.PostUsage(Usage);

        // [THEN] the project ledger shows the equipment's resource used on the task at the equipment rate
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        JobLedgerEntry.SetRange("Job Task No.", JobTask."Job Task No.");
        Assert.RecordCount(JobLedgerEntry, 1);
        JobLedgerEntry.FindFirst();
        Assert.AreEqual(JobLedgerEntry.Type::Resource, JobLedgerEntry.Type, 'posted as a resource');
        Assert.AreEqual(Equipment."Resource No.", JobLedgerEntry."No.", 'the equipment''s resource');
        Assert.AreEqual(3, JobLedgerEntry.Quantity, 'quantity');
        Assert.AreEqual(165, JobLedgerEntry."Total Cost (LCY)", 'cost = 3 x 55');
        Assert.AreEqual(StrSubstNo(DefaultDescriptionTxt, Equipment."No.", Equipment.Description), JobLedgerEntry.Description, 'default description');

        // [THEN] the usage line is removed from the worksheet
        Assert.IsFalse(Usage.Get(Usage."Line No."), 'usage line deleted after posting');
    end;

    [Test]
    procedure PostUsage_EquipmentInMaintenance_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] a usage line for equipment that is in maintenance
        Initialize(Job, JobTask);
        CreateEquipment(Equipment, 55);
        Equipment."In Maintenance" := true;
        Equipment.Modify();
        CreateUsage(Usage, Equipment, JobTask, 1);
        // [WHEN] it is posted
        asserterror EquipmentUsagePost.PostUsage(Usage);
        // [THEN] posting is refused
        Assert.ExpectedError('is in maintenance');
    end;

    [Test]
    procedure PostUsage_FeatureDisabled_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] a usage line and the Equipment feature switched off
        Initialize(Job, JobTask);
        CreateEquipment(Equipment, 55);
        CreateUsage(Usage, Equipment, JobTask, 1);
        TestLibrary.SetFeature(Enum::"CONS Feature"::Equipment, false);
        // [WHEN] it is posted
        asserterror EquipmentUsagePost.PostUsage(Usage);
        // [THEN] the feature gate refuses it
        Assert.ExpectedError('not enabled');
    end;

    [Test]
    procedure PostUsage_EquipmentWithoutResource_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] equipment that is not linked to a resource
        Initialize(Job, JobTask);
        CreateEquipment(Equipment, 55);
        CreateUsage(Usage, Equipment, JobTask, 1);
        Equipment."Resource No." := '';
        Equipment.Modify();
        // [WHEN] its usage is posted
        asserterror EquipmentUsagePost.PostUsage(Usage);
        // [THEN] the missing resource is reported
        Assert.ExpectedError('Resource No.');
    end;

    [Test]
    procedure PostUsage_ZeroQuantity_Errors()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] a usage line without a quantity
        Initialize(Job, JobTask);
        CreateEquipment(Equipment, 55);
        CreateUsage(Usage, Equipment, JobTask, 0);
        // [WHEN] it is posted
        asserterror EquipmentUsagePost.PostUsage(Usage);
        // [THEN] the missing quantity is reported
        Assert.ExpectedError('Quantity');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostBatch_PostsEveryLine()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Equipment: Record "CONS Equipment";
        Usage: Record "CONS Equipment Usage";
        JobLedgerEntry: Record "Job Ledger Entry";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] an empty worksheet with two usage lines added
        Initialize(Job, JobTask);
        Usage.DeleteAll();
        CreateEquipment(Equipment, 20);
        CreateUsage(Usage, Equipment, JobTask, 1);
        CreateUsage(Usage, Equipment, JobTask, 2);

        // [WHEN] the whole worksheet is posted
        EquipmentUsagePost.PostBatch();

        // [THEN] both lines are posted to the project and the worksheet is empty
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        Assert.RecordCount(JobLedgerEntry, 2);
        Usage.Reset();
        Assert.RecordIsEmpty(Usage);
        Assert.ExpectedMessage('2 equipment usage line(s)', LibraryVariableStorage.DequeueText());
    end;

    [Test]
    procedure PostBatch_NothingToPost_Errors()
    var
        Usage: Record "CONS Equipment Usage";
        EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
    begin
        // [GIVEN] an empty worksheet
        TestLibrary.Initialize();
        Usage.DeleteAll();
        // [WHEN] it is posted
        asserterror EquipmentUsagePost.PostBatch();
        // [THEN] the user is told there is nothing to post
        Assert.ExpectedError('no equipment usage lines');
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        LibraryVariableStorage.Clear();
        TestLibrary.SetFeature(Enum::"CONS Feature"::Equipment, true);
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreateEquipment(var Equipment: Record "CONS Equipment"; CostRate: Decimal)
    var
        Resource: Record Resource;
    begin
        LibraryResource.CreateResourceNew(Resource);
        Equipment.Init();
        Equipment."No." := TestLibrary.NewCode();
        Equipment.Description := 'Test excavator';
        Equipment."Resource No." := Resource."No.";
        Equipment."Rate Unit of Measure" := Resource."Base Unit of Measure";
        Equipment."Cost Rate" := CostRate;
        Equipment.Insert(true);
    end;

    local procedure CreateUsage(var Usage: Record "CONS Equipment Usage"; Equipment: Record "CONS Equipment"; JobTask: Record "Job Task"; Qty: Decimal)
    begin
        Usage.Init();
        Usage."Line No." := 0;
        Usage."Project No." := JobTask."Job No.";
        Usage."Job Task No." := JobTask."Job Task No.";
        Usage."Posting Date" := WorkDate();
        Usage.Validate("Equipment No.", Equipment."No.");
        Usage.Validate(Quantity, Qty);
        Usage.Insert(true);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    var
        DefaultDescriptionTxt: Label 'Equipment %1 %2', Locked = true;
}
