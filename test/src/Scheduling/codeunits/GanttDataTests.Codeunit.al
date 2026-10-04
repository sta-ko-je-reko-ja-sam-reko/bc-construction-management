namespace Construction.Test;

using Construction.Scheduling;
using Microsoft.Projects.Project.Job;
using System.TestLibraries.Utilities;

codeunit 64009 "CONS Gantt Data Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "CONS Test Library";

    [Test]
    procedure BuildScheduleJson_NoTasks_EmptyShape()
    var
        GanttData: Codeunit "CONS Gantt Data";
        Root: JsonObject;
        Token: JsonToken;
    begin
        // [GIVEN] a project with no tasks
        // [WHEN] the schedule JSON for the Gantt is built
        Root.ReadFrom(GanttData.BuildScheduleJson('NONEXISTENT'));

        // [THEN] it is a well-formed payload with an empty range and an empty tasks array
        Root.Get('rangeStart', Token);
        Assert.AreEqual('', Token.AsValue().AsText(), 'empty range start');
        Root.Get('tasks', Token);
        Assert.AreEqual(0, Token.AsArray().Count(), 'no tasks');
    end;

    [Test]
    procedure BuildScheduleJson_SerializesTasksInOutlineOrderWithRange()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        GanttData: Codeunit "CONS Gantt Data";
        Root: JsonObject;
        Token: JsonToken;
        Tasks: JsonArray;
        TaskObject: JsonObject;
    begin
        // [GIVEN] a project with tasks 2000 (1-10 Mar, 50%) and 1000 (5 Feb - 1 Mar, 100%)
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        JobTask.Delete();
        CreateTask(Job."No.", '2000', 20260301D, 20260310D, 50);
        CreateTask(Job."No.", '1000', 20260205D, 20260301D, 100);

        // [WHEN] the schedule JSON is built
        Root.ReadFrom(GanttData.BuildScheduleJson(Job."No."));

        // [THEN] the range spans the earliest start and the latest end in ISO format
        Root.Get('rangeStart', Token);
        Assert.AreEqual('2026-02-05', Token.AsValue().AsText(), 'range start');
        Root.Get('rangeEnd', Token);
        Assert.AreEqual('2026-03-10', Token.AsValue().AsText(), 'range end');

        // [THEN] tasks are listed in task-number order with their dates and progress
        Root.Get('tasks', Token);
        Tasks := Token.AsArray();
        Assert.AreEqual(2, Tasks.Count(), 'two tasks');
        Tasks.Get(0, Token);
        TaskObject := Token.AsObject();
        TaskObject.Get('no', Token);
        Assert.AreEqual('1000', Token.AsValue().AsText(), 'outline order');
        TaskObject.Get('start', Token);
        Assert.AreEqual('2026-02-05', Token.AsValue().AsText(), 'task start');
        TaskObject.Get('pct', Token);
        Assert.AreEqual(100, Token.AsValue().AsDecimal(), 'task progress');
        TaskObject.Get('predecessors', Token);
        Assert.AreEqual(0, Token.AsArray().Count(), 'no predecessors');
    end;

    [Test]
    procedure BuildScheduleJson_UnscheduledTask_HasBlankDates()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        GanttData: Codeunit "CONS Gantt Data";
        Root: JsonObject;
        Token: JsonToken;
        TaskObject: JsonObject;
    begin
        // [GIVEN] a project task without planned dates
        TestLibrary.Initialize();
        TestLibrary.CreateProjectWithTask(Job, JobTask);

        // [WHEN] the schedule JSON is built
        Root.ReadFrom(GanttData.BuildScheduleJson(Job."No."));

        // [THEN] the task is still listed, with blank dates the add-in can skip
        Root.Get('tasks', Token);
        Token.AsArray().Get(0, Token);
        TaskObject := Token.AsObject();
        TaskObject.Get('start', Token);
        Assert.AreEqual('', Token.AsValue().AsText(), 'blank start');
        TaskObject.Get('end', Token);
        Assert.AreEqual('', Token.AsValue().AsText(), 'blank end');
    end;

    [Test]
    procedure FindDefaultScheduledProject_ReturnsOpenConstructionProjectWithScheduledTasks()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        GanttData: Codeunit "CONS Gantt Data";
    begin
        // [GIVEN] the only construction project is open and has a scheduled task
        TestLibrary.Initialize();
        Job.ModifyAll("CONS Construction Project", false);
        TestLibrary.CreateProjectWithTask(Job, JobTask);
        JobTask."CONS Scheduled" := true;
        JobTask.Modify();

        // [WHEN]/[THEN] the role center charts that project
        Assert.AreEqual(Job."No.", GanttData.FindDefaultScheduledProject(), 'scheduled construction project found');
    end;

    [Test]
    procedure FindDefaultScheduledProject_IgnoresUnscheduledAndNonConstructionProjects()
    var
        ConstructionJob: Record Job;
        OtherJob: Record Job;
        JobTask: Record "Job Task";
        GanttData: Codeunit "CONS Gantt Data";
    begin
        // [GIVEN] a construction project without scheduled tasks and a scheduled project that is not a construction project
        TestLibrary.Initialize();
        ConstructionJob.ModifyAll("CONS Construction Project", false);
        TestLibrary.CreateProjectWithTask(ConstructionJob, JobTask);
        TestLibrary.CreateProjectWithTask(OtherJob, JobTask);
        OtherJob."CONS Construction Project" := false;
        OtherJob.Modify();
        JobTask."CONS Scheduled" := true;
        JobTask.Modify();

        // [WHEN]/[THEN] no project qualifies, so the role center hides the Gantt
        Assert.AreEqual('', GanttData.FindDefaultScheduledProject(), 'no default scheduled project');
    end;

    local procedure CreateTask(JobNo: Code[20]; JobTaskNo: Code[20]; StartDate: Date; EndDate: Date; PctComplete: Decimal)
    var
        JobTask: Record "Job Task";
    begin
        JobTask.Init();
        JobTask."Job No." := JobNo;
        JobTask."Job Task No." := JobTaskNo;
        JobTask."Job Task Type" := JobTask."Job Task Type"::Posting;
        JobTask."CONS Planned Start Date" := StartDate;
        JobTask."CONS Planned End Date" := EndDate;
        JobTask."CONS % Complete" := PctComplete;
        JobTask."CONS Scheduled" := true;
        JobTask.Insert(true);
    end;
}
