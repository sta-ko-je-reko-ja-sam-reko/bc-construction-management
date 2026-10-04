namespace Construction.Test;

using Construction.Setup;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using System.TestLibraries.Utilities;

/// <summary>Integration tests for applying an approved change order: contract value, subcontract variation lines and the project budget.</summary>
codeunit 64030 "CONS Change Order Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        LibraryPurchase: Codeunit "Library - Purchase";

    [Test]
    procedure ApplyOwnerChange_RaisesContractValueAndPushesBudget()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
        JobPlanningLine: Record "Job Planning Line";
        GLAccountNo: Code[20];
    begin
        // [GIVEN] a project with contract value 100000 and an owner change order of 2500 + 500 on a task
        Initialize(Job, JobTask);
        Job."CONS Contract Value" := 100000;
        Job.Modify();
        GLAccountNo := TestLibrary.SetCostTypeGLAccount(Enum::"CONS Cost Type"::Labor);
        CreateChangeOrder(ChangeOrderHeader, Job."No.", ChangeOrderHeader."Change Type"::Owner, '');
        InsertLine(ChangeOrderHeader."No.", 10000, JobTask."Job Task No.", Enum::"CONS Cost Type"::Labor, 2500);
        InsertLine(ChangeOrderHeader."No.", 20000, JobTask."Job Task No.", Enum::"CONS Cost Type"::Labor, 500);

        // [WHEN] the change order is applied
        ChangeOrderHeader.Apply();

        // [THEN] the contract value grows by the change order total
        Job.Get(Job."No.");
        Assert.AreEqual(103000, Job."CONS Contract Value", 'contract value + change order total');

        // [THEN] each line became a budget planning line on the task, on the cost type's G/L account
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange("Job Task No.", JobTask."Job Task No.");
        JobPlanningLine.SetRange("Line Type", JobPlanningLine."Line Type"::Budget);
        Assert.RecordCount(JobPlanningLine, 2);
        JobPlanningLine.CalcSums("Total Cost");
        Assert.AreEqual(3000, JobPlanningLine."Total Cost", 'budget increased by the change order');
        JobPlanningLine.FindFirst();
        Assert.AreEqual(GLAccountNo, JobPlanningLine."No.", 'cost type G/L account');

        // [THEN] the change order is Approved
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::Approved, ChangeOrderHeader.Status, 'approved');
    end;

    [Test]
    procedure ApplyOwnerOmission_LowersContractValue()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
    begin
        // [GIVEN] a contract value of 50000 and an omission of -1200 without a task
        Initialize(Job, JobTask);
        Job."CONS Contract Value" := 50000;
        Job.Modify();
        CreateChangeOrder(ChangeOrderHeader, Job."No.", ChangeOrderHeader."Change Type"::Owner, '');
        InsertLine(ChangeOrderHeader."No.", 10000, '', Enum::"CONS Cost Type"::Other, -1200);

        // [WHEN] it is applied
        ChangeOrderHeader.Apply();

        // [THEN] the contract value drops
        Job.Get(Job."No.");
        Assert.AreEqual(48800, Job."CONS Contract Value", 'omission lowers the contract value');
    end;

    [Test]
    procedure ApplySubcontractChange_AddsVariationLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
        SubcontractHeader: Record "CONS Subcontract Header";
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        // [GIVEN] a subcontract with one scope line of 10000 and a subcontract variation of 750
        Initialize(Job, JobTask);
        TestLibrary.ClearCostTypeGLAccount(Enum::"CONS Cost Type"::Subcontract);
        CreateSubcontract(SubcontractHeader, Job."No.");
        SubcontractLine.Init();
        SubcontractLine."Document No." := SubcontractHeader."No.";
        SubcontractLine."Line No." := 10000;
        SubcontractLine.Quantity := 1;
        SubcontractLine."Unit Cost" := 10000;
        SubcontractLine.Insert(true);
        CreateChangeOrder(ChangeOrderHeader, Job."No.", ChangeOrderHeader."Change Type"::Subcontract, SubcontractHeader."No.");
        InsertLine(ChangeOrderHeader."No.", 10000, JobTask."Job Task No.", Enum::"CONS Cost Type"::Subcontract, 750);

        // [WHEN] it is applied
        ChangeOrderHeader.Apply();

        // [THEN] the subcontract gets a variation line and its value grows to 10750
        SubcontractLine.SetRange("Document No.", SubcontractHeader."No.");
        Assert.RecordCount(SubcontractLine, 2);
        SubcontractLine.FindLast();
        Assert.AreEqual(20000, SubcontractLine."Line No.", 'variation appended after the scope');
        Assert.AreEqual(750, SubcontractLine."Line Amount", 'variation amount');
        Assert.AreEqual(JobTask."Job Task No.", SubcontractLine."Job Task No.", 'variation task');
        SubcontractHeader.CalcFields("Subcontract Value");
        Assert.AreEqual(10750, SubcontractHeader."Subcontract Value", 'subcontract value includes the variation');
    end;

    [Test]
    procedure Apply_CostTypeWithoutAccount_SkipsBudget()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
        JobPlanningLine: Record "Job Planning Line";
    begin
        // [GIVEN] an owner change order whose cost type has no default G/L account
        Initialize(Job, JobTask);
        TestLibrary.ClearCostTypeGLAccount(Enum::"CONS Cost Type"::Equipment);
        CreateChangeOrder(ChangeOrderHeader, Job."No.", ChangeOrderHeader."Change Type"::Owner, '');
        InsertLine(ChangeOrderHeader."No.", 10000, JobTask."Job Task No.", Enum::"CONS Cost Type"::Equipment, 900);

        // [WHEN] it is applied
        ChangeOrderHeader.Apply();

        // [THEN] it is approved but no budget line is created
        JobPlanningLine.SetRange("Job No.", Job."No.");
        Assert.RecordIsEmpty(JobPlanningLine);
        ChangeOrderHeader.Get(ChangeOrderHeader."No.");
        Assert.AreEqual(ChangeOrderHeader.Status::Approved, ChangeOrderHeader.Status, 'approved');
    end;

    [Test]
    procedure Apply_Twice_SecondIsRefused()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ChangeOrderHeader: Record "CONS Change Order Header";
    begin
        // [GIVEN] an applied owner change order of 1000
        Initialize(Job, JobTask);
        CreateChangeOrder(ChangeOrderHeader, Job."No.", ChangeOrderHeader."Change Type"::Owner, '');
        InsertLine(ChangeOrderHeader."No.", 10000, '', Enum::"CONS Cost Type"::Other, 1000);
        ChangeOrderHeader.Apply();

        // [WHEN] it is applied again
        asserterror ChangeOrderHeader.Apply();

        // [THEN] it is refused, so the contract value is never raised twice
        Assert.ExpectedError('already been applied');
    end;

    local procedure Initialize(var Job: Record Job; var JobTask: Record "Job Task")
    begin
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
    end;

    local procedure CreateChangeOrder(var ChangeOrderHeader: Record "CONS Change Order Header"; ProjectNo: Code[20]; ChangeType: Enum "CONS Change Order Type"; SubcontractNo: Code[20])
    begin
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := TestLibrary.NewCode();
        ChangeOrderHeader."Project No." := ProjectNo;
        ChangeOrderHeader."Change Type" := ChangeType;
        ChangeOrderHeader."Subcontract No." := SubcontractNo;
        ChangeOrderHeader.Insert(true);
    end;

    local procedure InsertLine(DocumentNo: Code[20]; LineNo: Integer; JobTaskNo: Code[20]; CostType: Enum "CONS Cost Type"; Amount: Decimal)
    var
        ChangeOrderLine: Record "CONS Change Order Line";
    begin
        ChangeOrderLine.Init();
        ChangeOrderLine."Document No." := DocumentNo;
        ChangeOrderLine."Line No." := LineNo;
        ChangeOrderLine."Job Task No." := JobTaskNo;
        ChangeOrderLine."Cost Type" := CostType;
        ChangeOrderLine.Description := 'Variation';
        ChangeOrderLine.Amount := Amount;
        ChangeOrderLine.Insert(true);
    end;

    local procedure CreateSubcontract(var SubcontractHeader: Record "CONS Subcontract Header"; ProjectNo: Code[20])
    begin
        SubcontractHeader.Init();
        SubcontractHeader."No." := TestLibrary.NewCode();
        SubcontractHeader."Project No." := ProjectNo;
        SubcontractHeader."Buy-from Vendor No." := LibraryPurchase.CreateVendorNo();
        SubcontractHeader.Insert(true);
    end;
}
