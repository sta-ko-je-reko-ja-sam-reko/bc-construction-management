codeunit 50512 "CONS Schedule Rollup Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure Rollup_SummaryTask_AggregatesPlannedDatesFromChildren()
    var
        SummaryTask: Record "Job Task";
        JobNo: Code[20];
    begin
        // [GIVEN] an enabled Scheduling feature and a project with a summary task over two posting children
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 20260101D, 20260110D, 10, 0);
        CreatePostingTask(JobNo, '1200', 1, 20260105D, 20260120D, 15, 0);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] the summary task spans the earliest child start and the latest child end
        SummaryTask.Get(JobNo, '1000');
        Assert.IsTrue(SummaryTask."CONS Planned Start Date" = 20260101D, 'summary start is the earliest child start');
        Assert.IsTrue(SummaryTask."CONS Planned End Date" = 20260120D, 'summary end is the latest child end');
    end;

    [Test]
    procedure Rollup_SummaryTask_DurationWeightedPercentComplete()
    var
        SummaryTask: Record "Job Task";
        JobNo: Code[20];
    begin
        // [GIVEN] two posting children with different durations and progress (100% over 10d, 0% over 30d)
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 20260101D, 20260110D, 10, 100);
        CreatePostingTask(JobNo, '1200', 1, 20260101D, 20260131D, 30, 0);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] the rolled-up % is duration-weighted: (100*10 + 0*30) / 40 = 25.00
        SummaryTask.Get(JobNo, '1000');
        Assert.AreEqual(25, SummaryTask."CONS % Complete", 'summary % is duration-weighted, not a simple average');
    end;

    [Test]
    procedure Rollup_SummaryTask_ZeroDurationFallsBackToSimpleAverage()
    var
        SummaryTask: Record "Job Task";
        JobNo: Code[20];
    begin
        // [GIVEN] two zero-duration posting children with 40% and 60% progress
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 20260101D, 20260101D, 0, 40);
        CreatePostingTask(JobNo, '1200', 1, 20260101D, 20260101D, 0, 60);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] with total duration zero it falls back to the simple average: (40 + 60) / 2 = 50.00
        SummaryTask.Get(JobNo, '1000');
        Assert.AreEqual(50, SummaryTask."CONS % Complete", 'zero-duration summary uses a simple average of % complete');
    end;

    [Test]
    procedure Rollup_SummaryTask_IgnoresDeeperBlockBoundary()
    var
        SummaryTask: Record "Job Task";
        JobNo: Code[20];
    begin
        // [GIVEN] a summary task whose contiguous block ends before a sibling summary's children
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 20260101D, 20260110D, 10, 100);
        CreateSummaryTask(JobNo, '2000', 0);
        CreatePostingTask(JobNo, '2100', 1, 20260201D, 20260210D, 10, 0);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] the first summary only aggregates its own block (ends at the next same-or-lower indentation)
        SummaryTask.Get(JobNo, '1000');
        Assert.IsTrue(SummaryTask."CONS Planned End Date" = 20260110D, 'first summary stops at the next outline boundary');
        Assert.AreEqual(100, SummaryTask."CONS % Complete", 'first summary excludes the second block''s tasks');
    end;

    [Test]
    procedure Rollup_JobHeader_AggregatesAllPostingTasks()
    var
        Job: Record Job;
        JobNo: Code[20];
    begin
        // [GIVEN] a project with posting tasks under two summaries
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 20260101D, 20260110D, 10, 100);
        CreateSummaryTask(JobNo, '2000', 0);
        CreatePostingTask(JobNo, '2100', 1, 20260201D, 20260228D, 20, 50);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] the job header spans every posting task and weights progress across them all
        Job.Get(JobNo);
        Assert.IsTrue(Job."CONS Planned Start Date" = 20260101D, 'header start is the earliest posting start');
        Assert.IsTrue(Job."CONS Planned End Date" = 20260228D, 'header end is the latest posting end');
        // (100*10 + 50*20) / 30 = 66.67
        Assert.AreEqual(66.67, Job."CONS Schedule % Complete", 'header % is duration-weighted across all posting tasks');
    end;

    [Test]
    procedure Rollup_IgnoresZeroPlannedDatesWhenAggregating()
    var
        SummaryTask: Record "Job Task";
        JobNo: Code[20];
    begin
        // [GIVEN] a child with no planned start (0D) alongside a dated child
        EnableScheduling();
        JobNo := CreateJob();
        CreateSummaryTask(JobNo, '1000', 0);
        CreatePostingTask(JobNo, '1100', 1, 0D, 0D, 5, 0);
        CreatePostingTask(JobNo, '1200', 1, 20260105D, 20260115D, 10, 0);

        // [WHEN] the project schedule is rolled up
        RollupProject(JobNo);

        // [THEN] blank (0D) dates are skipped, so the dated child drives the summary range
        SummaryTask.Get(JobNo, '1000');
        Assert.IsTrue(SummaryTask."CONS Planned Start Date" = 20260105D, 'a 0D child start does not override a dated child');
        Assert.IsTrue(SummaryTask."CONS Planned End Date" = 20260115D, 'a 0D child end does not override a dated child');
    end;

    [Test]
    procedure Rollup_Disabled_Errors()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        ScheduleRollup: Codeunit "CONS Schedule Rollup";
        JobNo: Code[20];
    begin
        // [GIVEN] the Scheduling feature turned off
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Scheduling, false);
        JobNo := CreateJob();

        // [WHEN] a roll-up is attempted
        asserterror ScheduleRollup.RollupProject(JobNo);

        // [THEN] the feature gate blocks it
        Assert.ExpectedError('not enabled');
    end;

    [Test]
    procedure Dependency_PredecessorSurfacesInScheduleJson()
    var
        TaskDependency: Record "CONS Task Dependency";
        GanttData: Codeunit "CONS Gantt Data";
        JobNo: Code[20];
        Json: Text;
    begin
        // [GIVEN] a project with two posting tasks and a Finish-to-Start dependency 1200 -> 1100
        EnableScheduling();
        JobNo := CreateJob();
        CreatePostingTask(JobNo, '1100', 0, 20260101D, 20260110D, 10, 0);
        CreatePostingTask(JobNo, '1200', 0, 20260111D, 20260120D, 10, 0);
        TaskDependency.Init();
        TaskDependency."Job No." := JobNo;
        TaskDependency."Job Task No." := '1200';
        TaskDependency."Predecessor Task No." := '1100';
        TaskDependency."Dependency Type" := TaskDependency."Dependency Type"::"Finish-to-Start";
        TaskDependency.Insert(true);

        // [WHEN] the schedule JSON is built for the project
        Json := GanttData.BuildScheduleJson(JobNo);

        // [THEN] the successor task carries the predecessor in its predecessors array
        Assert.IsTrue(StrPos(Json, '"predecessors":["1100"]') > 0, 'the dependency''s predecessor appears in the successor''s predecessors array');
    end;

    [Test]
    procedure ResourceAssignment_TaskKeyFiltersByJobAndTask()
    var
        ResourceAssignment: Record "CONS Resource Assignment";
        JobNo: Code[20];
        Count1100: Integer;
    begin
        // [GIVEN] two assignments on task 1100 and one on task 1200 of the same project
        JobNo := CreateJob();
        CreateAssignment(JobNo, '1100');
        CreateAssignment(JobNo, '1100');
        CreateAssignment(JobNo, '1200');

        // [WHEN] the Task secondary key is used to scope to one task
        ResourceAssignment.SetCurrentKey("Job No.", "Job Task No.");
        ResourceAssignment.SetRange("Job No.", JobNo);
        ResourceAssignment.SetRange("Job Task No.", '1100');
        Count1100 := ResourceAssignment.Count();

        // [THEN] only the two assignments on that task are returned
        Assert.AreEqual(2, Count1100, 'the Task key scopes resource assignments to one project task');
    end;

    local procedure CreateAssignment(JobNo: Code[20]; JobTaskNo: Code[20])
    var
        ResourceAssignment: Record "CONS Resource Assignment";
    begin
        ResourceAssignment.Init();
        ResourceAssignment."Job No." := JobNo;
        ResourceAssignment."Job Task No." := JobTaskNo;
        ResourceAssignment.Insert(true);
    end;

    local procedure EnableScheduling()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        FeatureMgt.SetEnabled(Enum::"CONS Feature"::Scheduling, true);
    end;

    local procedure RollupProject(JobNo: Code[20])
    var
        ScheduleRollup: Codeunit "CONS Schedule Rollup";
    begin
        ScheduleRollup.RollupProject(JobNo);
    end;

    local procedure CreateJob(): Code[20]
    var
        Job: Record Job;
        JobNo: Code[20];
    begin
        JobNo := CopyStr('SCHTEST' + Format(Random(999999)), 1, MaxStrLen(Job."No."));
        Job.Init();
        Job."No." := JobNo;
        Job.Insert(true);
        exit(JobNo);
    end;

    local procedure CreateSummaryTask(JobNo: Code[20]; JobTaskNo: Code[20]; TheIndentation: Integer)
    var
        JobTask: Record "Job Task";
    begin
        JobTask.Init();
        JobTask."Job No." := JobNo;
        JobTask."Job Task No." := JobTaskNo;
        JobTask."Job Task Type" := JobTask."Job Task Type"::"Begin-Total";
        JobTask.Indentation := TheIndentation;
        JobTask.Insert(true);
    end;

    local procedure CreatePostingTask(JobNo: Code[20]; JobTaskNo: Code[20]; TheIndentation: Integer; StartDate: Date; EndDate: Date; DurationDays: Decimal; PctComplete: Decimal)
    var
        JobTask: Record "Job Task";
    begin
        JobTask.Init();
        JobTask."Job No." := JobNo;
        JobTask."Job Task No." := JobTaskNo;
        JobTask."Job Task Type" := JobTask."Job Task Type"::Posting;
        JobTask.Indentation := TheIndentation;
        JobTask."CONS Planned Start Date" := StartDate;
        JobTask."CONS Planned End Date" := EndDate;
        JobTask."CONS Duration (Days)" := DurationDays;
        JobTask."CONS % Complete" := PctComplete;
        JobTask.Insert(true);
    end;
}
