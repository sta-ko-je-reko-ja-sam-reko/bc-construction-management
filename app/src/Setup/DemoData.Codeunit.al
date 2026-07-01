namespace Construction.Setup;

using Construction.Core;
using Construction.Equipment;
using Construction.Estimating;
using Construction.MCP;
using Construction.Scheduling;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 50020 "CONS Demo Data"
{
    Access = Internal;

    /// <summary>
    /// Creates a coherent, idempotent demo dataset for a construction module, so a trial user can
    /// start working immediately. Everything hangs off one demo project (CONS-DEMO). Called from the
    /// assisted setup wizard when the user opts to import demo data; the wizard ensures the module's
    /// number series exist first. Re-running is safe — existing records are detected and skipped.
    /// </summary>
    /// <param name="Module">The module to create demo data for.</param>
    procedure CreateDemoData(Module: Enum "CONS Module")
    begin
        case Module of
            Module::Foundation:
                CreateFoundationDemo();
            Module::Estimating:
                CreateEstimatingDemo();
            Module::"Cost Control":
                Message(CostControlInfoMsg);
            Module::"Progress Billing":
                Message(ProgressBillingInfoMsg);
            Module::Subcontracts:
                CreateSubcontractDemo();
            Module::"Equipment & Plant":
                CreateEquipmentDemo();
            Module::"Scheduling & Resource Planning":
                CreateSchedulingDemo();
        end;
    end;

    local procedure CreateFoundationDemo()
    var
        Job: Record Job;
        MCPConfigDemo: Codeunit "CONS MCP Config Demo";
        ProjectExisted: Boolean;
    begin
        ProjectExisted := Job.Get(DemoProjectCodeTok);
        EnsureDemoCustomer();
        EnsureDemoVendor();
        EnsureDemoProject();
        if not ProjectExisted then
            MCPConfigDemo.CreateConstructionMCPConfig();
        Message(DemoCreatedMsg, FoundationNameTxt);
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

    local procedure EnsureDemoProject(): Code[20]
    var
        Job: Record Job;
    begin
        EnsureDemoCustomer();
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
        exit(DemoProjectCodeTok);
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

    local procedure CreateEstimatingDemo()
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        EnsureDemoProject();
        BoQHeader.SetRange("Project No.", DemoProjectCodeTok);
        if not BoQHeader.IsEmpty() then begin
            Message(DemoExistsMsg, EstimatingNameTxt);
            exit;
        end;
        BoQHeader.Init();
        BoQHeader.Insert(true);
        BoQHeader.Validate(Description, DemoBoQDescTxt);
        BoQHeader.Validate("Project No.", DemoProjectCodeTok);
        BoQHeader.Validate("Bill-to Customer No.", DemoPartyCodeTok);
        BoQHeader.Modify(true);

        InsertBoQLine(BoQHeader."No.", 10000, DemoBoQLine1Txt, 250, 35);
        InsertBoQLine(BoQHeader."No.", 20000, DemoBoQLine2Txt, 120, 90);
        Message(DemoCreatedMsg, EstimatingNameTxt);
    end;

    local procedure InsertBoQLine(DocumentNo: Code[20]; LineNo: Integer; LineDescription: Text[100]; Qty: Decimal; UnitCostValue: Decimal)
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.Init();
        BoQLine."Document No." := DocumentNo;
        BoQLine."Line No." := LineNo;
        BoQLine.Validate(Description, LineDescription);
        BoQLine.Validate(Quantity, Qty);
        BoQLine.Validate("Unit Cost", UnitCostValue);
        BoQLine.Insert(true);
    end;

    local procedure CreateSubcontractDemo()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
    begin
        EnsureDemoProject();
        EnsureDemoVendor();
        SubcontractHeader.SetRange("Project No.", DemoProjectCodeTok);
        if not SubcontractHeader.IsEmpty() then begin
            Message(DemoExistsMsg, SubcontractsNameTxt);
            exit;
        end;
        SubcontractHeader.Init();
        SubcontractHeader.Insert(true);
        SubcontractHeader.Validate("Project No.", DemoProjectCodeTok);
        SubcontractHeader.Validate("Buy-from Vendor No.", DemoPartyCodeTok);
        SubcontractHeader.Validate(Description, DemoSubcontractDescTxt);
        SubcontractHeader.Validate("Retention %", 5);
        SubcontractHeader.Modify(true);
        Message(DemoCreatedMsg, SubcontractsNameTxt);
    end;

    local procedure CreateEquipmentDemo()
    var
        Equipment: Record "CONS Equipment";
    begin
        Equipment.SetRange(Description, DemoEquip1Txt);
        if not Equipment.IsEmpty() then begin
            Message(DemoExistsMsg, EquipmentNameTxt);
            exit;
        end;
        InsertEquipment(DemoEquip1Txt, 45, 70);
        InsertEquipment(DemoEquip2Txt, 30, 55);
        Message(DemoCreatedMsg, EquipmentNameTxt);
    end;

    local procedure InsertEquipment(EquipDescription: Text[100]; CostRate: Decimal; HireRate: Decimal)
    var
        Equipment: Record "CONS Equipment";
    begin
        Equipment.Init();
        Equipment.Validate(Description, EquipDescription);
        Equipment."Cost Rate" := CostRate;
        Equipment."Hire Rate" := HireRate;
        Equipment.Insert(true);
    end;

    local procedure CreateSchedulingDemo()
    var
        TaskDependency: Record "CONS Task Dependency";
        TwoWeeks: DateFormula;
    begin
        EnsureDemoProject();
        Evaluate(TwoWeeks, TwoWeeksTok);
        ScheduleTask(Task2CodeTok, WorkDate(), 14);
        ScheduleTask(Task3CodeTok, CalcDate(TwoWeeks, WorkDate()), 21);
        if not TaskDependency.Get(DemoProjectCodeTok, Task3CodeTok, Task2CodeTok) then begin
            TaskDependency.Init();
            TaskDependency."Job No." := DemoProjectCodeTok;
            TaskDependency."Job Task No." := Task3CodeTok;
            TaskDependency."Predecessor Task No." := Task2CodeTok;
            TaskDependency.Insert(true);
        end;
        Message(DemoCreatedMsg, SchedulingNameTxt);
    end;

    local procedure ScheduleTask(TaskNo: Code[20]; StartDate: Date; DurationDays: Integer)
    var
        JobTask: Record "Job Task";
        DurationFormula: DateFormula;
    begin
        if not JobTask.Get(DemoProjectCodeTok, TaskNo) then
            exit;
        Evaluate(DurationFormula, StrSubstNo(DurationFormulaTok, DurationDays));
        JobTask."CONS Planned Start Date" := StartDate;
        JobTask."CONS Planned End Date" := CalcDate(DurationFormula, StartDate);
        JobTask."CONS Duration (Days)" := DurationDays;
        JobTask."CONS Scheduled" := true;
        JobTask.Modify(true);
    end;

    var
        DemoProjectCodeTok: Label 'CONS-DEMO', Locked = true, MaxLength = 20;
        DemoPartyCodeTok: Label 'CONS-DEMO', Locked = true, MaxLength = 20;
        Task1CodeTok: Label '1000', Locked = true, MaxLength = 20;
        Task2CodeTok: Label '1100', Locked = true, MaxLength = 20;
        Task3CodeTok: Label '1200', Locked = true, MaxLength = 20;
        TwoWeeksTok: Label '<2W>', Locked = true;
        DurationFormulaTok: Label '<%1D>', Locked = true, Comment = '%1 = number of days';
        FoundationNameTxt: Label 'Foundation';
        EstimatingNameTxt: Label 'Estimating';
        SubcontractsNameTxt: Label 'Subcontracts';
        EquipmentNameTxt: Label 'Equipment & Plant';
        SchedulingNameTxt: Label 'Scheduling & Resource Planning';
        DemoCustomerNameTxt: Label 'Construction Demo Client';
        DemoVendorNameTxt: Label 'Construction Demo Subcontractor';
        DemoProjectNameTxt: Label 'Demo Construction Project';
        DemoTaskHeadingTxt: Label 'Site Works';
        DemoTaskGroundTxt: Label 'Groundworks & Foundations';
        DemoTaskStructureTxt: Label 'Superstructure';
        DemoBoQDescTxt: Label 'Demo Bill of Quantities';
        DemoBoQLine1Txt: Label 'Concrete to foundations (m3)';
        DemoBoQLine2Txt: Label 'Structural steel erection (t)';
        DemoSubcontractDescTxt: Label 'Demo groundworks subcontract';
        DemoEquip1Txt: Label 'Demo Excavator 20t';
        DemoEquip2Txt: Label 'Demo Tower Crane';
        DemoCreatedMsg: Label 'Demo data for %1 was created on the CONS-DEMO project.', Comment = '%1 = feature name';
        DemoExistsMsg: Label 'Demo data for %1 already exists on the CONS-DEMO project.', Comment = '%1 = feature name';
        CostControlInfoMsg: Label 'Cost Control analyzes the demo project''s budget and actuals — it needs no separate demo data. Enable Estimating and create a budget, then open Project Cost Control on CONS-DEMO.';
        ProgressBillingInfoMsg: Label 'To try Progress Billing, create a Progress Billing application on the CONS-DEMO project and use Seed from Project to generate its lines.';
}
