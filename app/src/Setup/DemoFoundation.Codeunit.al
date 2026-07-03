namespace Construction.Setup;

using Construction.MCP;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

/// <summary>
/// Foundation demo seeder. Owns the CRONUS-style shared context every other construction feature's demo hangs
/// off — one demo customer, one demo vendor, the CONS-DEMO project and its task structure — and exposes that
/// context (plus the fixed keys) to the per-feature demo codeunits via public getters, so each feature seeder
/// stays focused on its own records but can reference the same project. Idempotent: fixed keys + Get-guards, so
/// re-running (wizard or the demoFoundation MCP tool) is a no-op. Message-free — the same Import() is called from
/// the assisted-setup wizard AND from the [ServiceEnabled] API action, where UI messages are not allowed.
/// </summary>
codeunit 50031 "CONS Demo Foundation"
{
    Access = Public;

    /// <summary>Seed the shared demo context and, on the first run, create the MCP server configurations. Idempotent.</summary>
    procedure Import()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        MCPConfigDemo: Codeunit "CONS MCP Config Demo";
        MCPDemoConfig: Codeunit "CONS MCP Demo Config";
        RecRef: RecordRef;
        ProjectExisted: Boolean;
    begin
        ProjectExisted := Job.Get(DemoProjectCodeTok);
        EnsureProjectContext();
        if not ProjectExisted then begin
            MCPConfigDemo.CreateConstructionMCPConfig();
            MCPDemoConfig.CreateDemoMCPConfigs();
        end;
        if ConfigPackageBuilder.EnsurePackage(FoundationPkgCodeTok, FoundationPkgNameLbl) then begin
            ConfigPackageBuilder.AddExtendedTable(FoundationPkgCodeTok, Database::Job);
            ConfigPackageBuilder.AddExtendedTable(FoundationPkgCodeTok, Database::"Job Task");
            Job.SetRange("No.", DemoProjectCodeTok);
            RecRef.GetTable(Job);
            ConfigPackageBuilder.SnapshotTable(FoundationPkgCodeTok, RecRef);
            JobTask.SetRange("Job No.", DemoProjectCodeTok);
            RecRef.GetTable(JobTask);
            ConfigPackageBuilder.SnapshotTable(FoundationPkgCodeTok, RecRef);
        end;
    end;

    /// <summary>Idempotently ensures the demo customer, vendor, CONS-DEMO project and its tasks exist. Returns the demo project code. Called by every feature seeder that needs a project to hang records off.</summary>
    procedure EnsureProjectContext(): Code[20]
    begin
        EnsureDemoCustomer();
        EnsureDemoVendor();
        EnsureDemoProject();
        exit(DemoProjectCodeTok);
    end;

    /// <summary>The fixed demo project (Job) number.</summary>
    procedure DemoProjectCode(): Code[20]
    begin
        exit(DemoProjectCodeTok);
    end;

    /// <summary>The fixed demo customer/vendor number (both parties share the code).</summary>
    procedure DemoPartyCode(): Code[20]
    begin
        exit(DemoPartyCodeTok);
    end;

    /// <summary>The fixed "Groundworks &amp; Foundations" posting task number on the demo project.</summary>
    procedure DemoTaskGroundCode(): Code[20]
    begin
        exit(Task2CodeTok);
    end;

    /// <summary>The fixed "Superstructure" posting task number on the demo project.</summary>
    procedure DemoTaskStructureCode(): Code[20]
    begin
        exit(Task3CodeTok);
    end;

    local procedure EnsureDemoCustomer()
    var
        Customer: Record Customer;
    begin
        if Customer.Get(DemoPartyCodeTok) then
            exit;
        Customer.Init();
        Customer."No." := DemoPartyCodeTok;
        Customer.Insert(true);
        Customer.Validate(Name, DemoCustomerNameTxt);
        Customer.Modify(true);
    end;

    local procedure EnsureDemoVendor()
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(DemoPartyCodeTok) then
            exit;
        Vendor.Init();
        Vendor."No." := DemoPartyCodeTok;
        Vendor.Insert(true);
        Vendor.Validate(Name, DemoVendorNameTxt);
        Vendor.Modify(true);
    end;

    local procedure EnsureDemoProject()
    var
        Job: Record Job;
    begin
        if not Job.Get(DemoProjectCodeTok) then begin
            Job.Init();
            Job."No." := DemoProjectCodeTok;
            Job.Insert(true);
            Job.Validate(Description, DemoProjectNameTxt);
            Job.Validate("Bill-to Customer No.", DemoPartyCodeTok);
            Job.Status := Job.Status::Open;
            Job.Modify(true);
        end;
        EnsureDemoTask(Task1CodeTok, DemoTaskHeadingTxt, "Job Task Type"::Heading);
        EnsureDemoTask(Task2CodeTok, DemoTaskGroundTxt, "Job Task Type"::Posting);
        EnsureDemoTask(Task3CodeTok, DemoTaskStructureTxt, "Job Task Type"::Posting);
    end;

    local procedure EnsureDemoTask(TaskNo: Code[20]; TaskDescription: Text[100]; TaskType: Enum "Job Task Type")
    var
        JobTask: Record "Job Task";
    begin
        if JobTask.Get(DemoProjectCodeTok, TaskNo) then
            exit;
        JobTask.Init();
        JobTask."Job No." := DemoProjectCodeTok;
        JobTask."Job Task No." := TaskNo;
        JobTask.Validate(Description, TaskDescription);
        JobTask.Validate("Job Task Type", TaskType);
        JobTask.Insert(true);
    end;

    var
        DemoProjectCodeTok: Label 'CONS-DEMO', Locked = true, MaxLength = 20;
        DemoPartyCodeTok: Label 'CONS-DEMO', Locked = true, MaxLength = 20;
        FoundationPkgCodeTok: Label 'CONS-FOUNDATION', Locked = true, MaxLength = 20;
        FoundationPkgNameLbl: Label 'Construction Demo - Foundation', MaxLength = 50;
        Task1CodeTok: Label '1000', Locked = true, MaxLength = 20;
        Task2CodeTok: Label '1100', Locked = true, MaxLength = 20;
        Task3CodeTok: Label '1200', Locked = true, MaxLength = 20;
        DemoCustomerNameTxt: Label 'Construction Demo Client';
        DemoVendorNameTxt: Label 'Construction Demo Subcontractor';
        DemoProjectNameTxt: Label 'Demo Construction Project';
        DemoTaskHeadingTxt: Label 'Site Works';
        DemoTaskGroundTxt: Label 'Groundworks & Foundations';
        DemoTaskStructureTxt: Label 'Superstructure';
}
