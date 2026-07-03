codeunit 50516 "CONS Demo Data Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";
        DemoProjectTok: Label 'CONS-DEMO', Locked = true;
        DemoBoQTok: Label 'CONS-DEMO-BOQ', Locked = true;

    [Test]
    procedure Foundation_SeedsProjectContext_Idempotent()
    var
        Job: Record Job;
        Customer: Record Customer;
        Vendor: Record Vendor;
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        // [WHEN] the foundation demo context is ensured twice
        DemoFoundation.EnsureProjectContext();
        DemoFoundation.EnsureProjectContext();

        // [THEN] the fixed-key demo project, customer and vendor all exist (re-run is a no-op)
        Assert.IsTrue(Job.Get(DemoProjectTok), 'demo project created');
        Assert.IsTrue(Customer.Get(DemoProjectTok), 'demo customer created');
        Assert.IsTrue(Vendor.Get(DemoProjectTok), 'demo vendor created');
    end;

    [Test]
    procedure Estimating_SeedsBoQ_Idempotent()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        DemoEstimating: Codeunit "CONS Demo Estimating";
    begin
        // [WHEN] the estimating demo runs twice (no number series set up — proves the fixed-key/API-safe path)
        DemoEstimating.Import();
        DemoEstimating.Import();

        // [THEN] exactly one demo BoQ with its two lines exists (fixed No. → no duplicate)
        Assert.IsTrue(BoQHeader.Get(DemoBoQTok), 'demo BoQ created with fixed No.');
        BoQLine.SetRange("Document No.", DemoBoQTok);
        Assert.AreEqual(2, BoQLine.Count(), 'demo BoQ has two lines');
    end;

    [Test]
    procedure Equipment_SeedsTwoCards_Idempotent()
    var
        Equipment: Record "CONS Equipment";
        DemoEquipment: Codeunit "CONS Demo Equipment";
        CountAfterFirst: Integer;
    begin
        // [GIVEN] the equipment demo has run once
        DemoEquipment.Import();
        CountAfterFirst := Equipment.Count();

        // [WHEN] it runs again
        DemoEquipment.Import();

        // [THEN] no new equipment is added and both fixed-key cards exist
        Assert.AreEqual(CountAfterFirst, Equipment.Count(), 're-run adds no equipment');
        Assert.IsTrue(Equipment.Get('CONS-DEMO-EQ1'), 'demo equipment 1 exists');
        Assert.IsTrue(Equipment.Get('CONS-DEMO-EQ2'), 'demo equipment 2 exists');
    end;

    [Test]
    procedure Scheduling_SeedsDependency_Idempotent()
    var
        TaskDependency: Record "CONS Task Dependency";
        DemoScheduling: Codeunit "CONS Demo Scheduling";
    begin
        // [WHEN] the scheduling demo runs twice (ensures project + schedules tasks + links them)
        DemoScheduling.Import();
        DemoScheduling.Import();

        // [THEN] exactly one finish-to-start dependency between the two demo tasks exists
        TaskDependency.SetRange("Job No.", DemoProjectTok);
        Assert.AreEqual(1, TaskDependency.Count(), 'one demo task dependency created (idempotent)');
    end;
}
