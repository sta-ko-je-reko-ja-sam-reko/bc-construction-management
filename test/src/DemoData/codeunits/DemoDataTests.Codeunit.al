namespace Construction.Test;

using Construction.CostBreakdown;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Scheduling;
using Construction.Setup;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 64016 "CONS Demo Data Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";
        DemoProjectTok: Label 'CONS-DEMO', Locked = true;
        DemoBoQTok: Label 'CONS-DEMO-BOQ', Locked = true;
        DemoSubcontractTok: Label 'CONS-DEMO-SUB', Locked = true;

    [Test]
    procedure Foundation_SeedsProjectContext_Idempotent()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Customer: Record Customer;
        Vendor: Record Vendor;
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        // [WHEN] the foundation demo context is ensured twice
        TestLibrary.Initialize();
        DemoFoundation.EnsureProjectContext();
        DemoFoundation.EnsureProjectContext();

        // [THEN] the fixed-key demo project, customer and vendor all exist (re-run is a no-op)
        Assert.IsTrue(Job.Get(DemoProjectTok), 'demo project created');
        Assert.AreEqual(DemoProjectTok, Job."Bill-to Customer No.", 'demo project bills the demo customer');
        Assert.IsTrue(Customer.Get(DemoProjectTok), 'demo customer created');
        Assert.IsTrue(Vendor.Get(DemoProjectTok), 'demo vendor created');
        // [THEN] the project has a heading and two posting tasks
        JobTask.SetRange("Job No.", DemoProjectTok);
        Assert.RecordCount(JobTask, 3);
        JobTask.Get(DemoProjectTok, DemoFoundation.DemoTaskGroundCode());
        Assert.AreEqual(JobTask."Job Task Type"::Posting, JobTask."Job Task Type", 'groundworks is a posting task');
    end;

    [Test]
    procedure Foundation_Import_BuildsConfigPackageWithData()
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageData: Record "Config. Package Data";
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        // [GIVEN] no foundation demo package
        TestLibrary.Initialize();
        if ConfigPackage.Get('CONS-FOUNDATION') then
            ConfigPackage.Delete(true);

        // [WHEN] the foundation demo is imported
        DemoFoundation.Import();

        // [THEN] the RapidStart package exists and carries the demo project's row values
        Assert.IsTrue(ConfigPackage.Get('CONS-FOUNDATION'), 'foundation package created');
        ConfigPackageData.SetRange("Package Code", 'CONS-FOUNDATION');
        ConfigPackageData.SetRange("Table ID", Database::Job);
        ConfigPackageData.SetRange(Value, DemoProjectTok);
        Assert.RecordIsNotEmpty(ConfigPackageData);
    end;

    [Test]
    procedure Estimating_SeedsBoQ_Idempotent()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        ConfigPackage: Record "Config. Package";
        DemoEstimating: Codeunit "CONS Demo Estimating";
    begin
        // [WHEN] the estimating demo runs twice (no number series set up — proves the fixed-key/API-safe path)
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        DemoEstimating.Import();
        DemoEstimating.Import();

        // [THEN] exactly one demo BoQ with its two costed lines exists on the demo project (fixed No. → no duplicate)
        Assert.IsTrue(BoQHeader.Get(DemoBoQTok), 'demo BoQ created with fixed No.');
        Assert.AreEqual(DemoProjectTok, BoQHeader."Project No.", 'demo BoQ on the demo project');
        BoQLine.SetRange("Document No.", DemoBoQTok);
        Assert.RecordCount(BoQLine, 2);
        BoQHeader.CalcFields("Total Cost");
        Assert.AreEqual(250 * 35 + 120 * 90, BoQHeader."Total Cost", 'demo BoQ total cost');
        Assert.IsTrue(ConfigPackage.Get('CONS-ESTIMATING'), 'estimating package created');
    end;

    [Test]
    procedure Subcontracts_SeedsSubcontract_Idempotent()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        DemoSubcontracts: Codeunit "CONS Demo Subcontracts";
    begin
        // [WHEN] the subcontracts demo runs twice
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();
        DemoSubcontracts.Import();
        DemoSubcontracts.Import();

        // [THEN] one demo subcontract with the demo subcontractor and 5% retention exists
        Assert.IsTrue(SubcontractHeader.Get(DemoSubcontractTok), 'demo subcontract created');
        Assert.AreEqual(DemoProjectTok, SubcontractHeader."Project No.", 'on the demo project');
        Assert.AreEqual(DemoProjectTok, SubcontractHeader."Buy-from Vendor No.", 'demo subcontractor');
        Assert.AreEqual(5, SubcontractHeader."Retention %", 'demo retention');
        SubcontractHeader.SetRange("Project No.", DemoProjectTok);
        Assert.RecordCount(SubcontractHeader, 1);
    end;

    [Test]
    procedure Equipment_SeedsTwoCards_Idempotent()
    var
        Equipment: Record "CONS Equipment";
        DemoEquipment: Codeunit "CONS Demo Equipment";
        CountAfterFirst: Integer;
    begin
        // [GIVEN] the equipment demo has run once
        TestLibrary.Initialize();
        DemoEquipment.Import();
        CountAfterFirst := Equipment.Count();

        // [WHEN] it runs again
        DemoEquipment.Import();

        // [THEN] no new equipment is added and both fixed-key cards exist with their rates
        Assert.AreEqual(CountAfterFirst, Equipment.Count(), 're-run adds no equipment');
        Assert.IsTrue(Equipment.Get('CONS-DEMO-EQ1'), 'demo equipment 1 exists');
        Assert.AreEqual(45, Equipment."Cost Rate", 'demo cost rate');
        Assert.AreEqual(70, Equipment."Hire Rate", 'demo hire rate');
        Assert.IsTrue(Equipment.Get('CONS-DEMO-EQ2'), 'demo equipment 2 exists');
    end;

    [Test]
    procedure Scheduling_SeedsDependency_Idempotent()
    var
        TaskDependency: Record "CONS Task Dependency";
        JobTask: Record "Job Task";
        DemoScheduling: Codeunit "CONS Demo Scheduling";
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        // [WHEN] the scheduling demo runs twice (ensures project + schedules tasks + links them)
        TestLibrary.Initialize();
        DemoScheduling.Import();
        DemoScheduling.Import();

        // [THEN] exactly one finish-to-start dependency between the two demo tasks exists
        TaskDependency.SetRange("Job No.", DemoProjectTok);
        Assert.RecordCount(TaskDependency, 1);
        // [THEN] the groundworks task is scheduled for 14 days from the work date
        JobTask.Get(DemoProjectTok, DemoFoundation.DemoTaskGroundCode());
        Assert.IsTrue(JobTask."CONS Scheduled", 'task scheduled');
        Assert.AreEqual(WorkDate(), JobTask."CONS Planned Start Date", 'starts on the work date');
        Assert.AreEqual(14, JobTask."CONS Duration (Days)", 'duration');
    end;

    [Test]
    procedure CostControlAndProgressBilling_EnsureProjectContext()
    var
        Job: Record Job;
        DemoCostControl: Codeunit "CONS Demo Cost Control";
        DemoProgressBilling: Codeunit "CONS Demo Progress Billing";
    begin
        // [WHEN] the context-only importers run
        TestLibrary.Initialize();
        DemoCostControl.Import();
        DemoProgressBilling.Import();
        // [THEN] they give their pages the demo project to work with
        Assert.IsTrue(Job.Get(DemoProjectTok), 'demo project available');
    end;

    [Test]
    procedure DemoAPIActions_RunTheSameSeeders()
    var
        BoQHeader: Record "CONS BoQ Header";
        SubcontractHeader: Record "CONS Subcontract Header";
        Equipment: Record "CONS Equipment";
        TaskDependency: Record "CONS Task Dependency";
        DemoEstimatingAPI: Page "CONS Demo Estimating API";
        DemoSubcontractsAPI: Page "CONS Demo Subcontracts API";
        DemoEquipmentAPI: Page "CONS Demo Equipment API";
        DemoSchedulingAPI: Page "CONS Demo Scheduling API";
        DemoCostControlAPI: Page "CONS Demo Cost Control API";
        DemoProgBillingAPI: Page "CONS Demo Prog. Billing API";
        ActionContext: WebServiceActionContext;
    begin
        // [GIVEN] the MCP/OData importDemoData bound actions of the demo API pages
        TestLibrary.Initialize();
        TestLibrary.ClearNumberSeries();

        // [WHEN] each action is invoked
        DemoEstimatingAPI.ImportDemoData(ActionContext);
        DemoSubcontractsAPI.ImportDemoData(ActionContext);
        DemoEquipmentAPI.ImportDemoData(ActionContext);
        DemoSchedulingAPI.ImportDemoData(ActionContext);
        DemoCostControlAPI.ImportDemoData(ActionContext);
        DemoProgBillingAPI.ImportDemoData(ActionContext);

        // [THEN] they seed the same fixed-key records as the assisted-setup wizard, without any UI
        Assert.IsTrue(BoQHeader.Get(DemoBoQTok), 'estimating seeded through the API');
        Assert.IsTrue(SubcontractHeader.Get(DemoSubcontractTok), 'subcontracts seeded through the API');
        Assert.IsTrue(Equipment.Get('CONS-DEMO-EQ1'), 'equipment seeded through the API');
        TaskDependency.SetRange("Job No.", DemoProjectTok);
        Assert.RecordIsNotEmpty(TaskDependency);
    end;
}
