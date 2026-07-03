namespace Construction.Scheduling;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

/// <summary>
/// Scheduling &amp; Resource Planning demo seeder — schedules the two posting tasks on CONS-DEMO (planned dates
/// and durations) and links them with a finish-to-start dependency, so the Gantt shows a realistic two-bar plan.
/// Idempotent (Get-guards on the dependency; task scheduling re-writes the same fixed values). Message-free;
/// reached from the assisted-setup wizard and the demoScheduling [ServiceEnabled] API action. Ensures the
/// Foundation demo context (project + tasks) via "CONS Demo Foundation" first.
/// </summary>
codeunit 50037 "CONS Demo Scheduling"
{
    Access = Public;

    /// <summary>Seed the demo schedule (task dates + dependency) on CONS-DEMO. Idempotent.</summary>
    procedure Import()
    var
        TaskDependency: Record "CONS Task Dependency";
        JobTask: Record "Job Task";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        DemoFoundation: Codeunit "CONS Demo Foundation";
        TwoWeeks: DateFormula;
        RecRef: RecordRef;
        ProjectNo: Code[20];
        GroundTaskNo: Code[20];
        StructureTaskNo: Code[20];
    begin
        ProjectNo := DemoFoundation.EnsureProjectContext();
        GroundTaskNo := DemoFoundation.DemoTaskGroundCode();
        StructureTaskNo := DemoFoundation.DemoTaskStructureCode();

        if ConfigPackageBuilder.EnsurePackage(SchedPkgCodeTok, SchedPkgNameLbl) then begin
            ConfigPackageBuilder.AddOwnTable(SchedPkgCodeTok, Database::"CONS Task Dependency");
            ConfigPackageBuilder.AddExtendedTable(SchedPkgCodeTok, Database::"Job Task");
        end;

        Evaluate(TwoWeeks, TwoWeeksTok);
        ScheduleTask(ProjectNo, GroundTaskNo, WorkDate(), 14);
        ScheduleTask(ProjectNo, StructureTaskNo, CalcDate(TwoWeeks, WorkDate()), 21);

        if not TaskDependency.Get(ProjectNo, StructureTaskNo, GroundTaskNo) then begin
            TaskDependency.Init();
            TaskDependency."Job No." := ProjectNo;
            TaskDependency."Job Task No." := StructureTaskNo;
            TaskDependency."Predecessor Task No." := GroundTaskNo;
            TaskDependency.Insert(true);
        end;

        JobTask.SetRange("Job No.", ProjectNo);
        RecRef.GetTable(JobTask);
        ConfigPackageBuilder.SnapshotTable(SchedPkgCodeTok, RecRef);
        TaskDependency.Reset();
        TaskDependency.SetRange("Job No.", ProjectNo);
        RecRef.GetTable(TaskDependency);
        ConfigPackageBuilder.SnapshotTable(SchedPkgCodeTok, RecRef);
    end;

    local procedure ScheduleTask(ProjectNo: Code[20]; TaskNo: Code[20]; StartDate: Date; DurationDays: Integer)
    var
        JobTask: Record "Job Task";
        DurationFormula: DateFormula;
    begin
        if not JobTask.Get(ProjectNo, TaskNo) then
            exit;
        Evaluate(DurationFormula, StrSubstNo(DurationFormulaTok, DurationDays));
        JobTask."CONS Planned Start Date" := StartDate;
        JobTask."CONS Planned End Date" := CalcDate(DurationFormula, StartDate);
        JobTask."CONS Duration (Days)" := DurationDays;
        JobTask."CONS Scheduled" := true;
        JobTask.Modify(true);
    end;

    var
        TwoWeeksTok: Label '<2W>', Locked = true;
        DurationFormulaTok: Label '<%1D>', Locked = true, Comment = '%1 = number of days';
        SchedPkgCodeTok: Label 'CONS-SCHEDULING', Locked = true, MaxLength = 20;
        SchedPkgNameLbl: Label 'Construction Demo - Scheduling', MaxLength = 50;
}
