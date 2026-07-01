namespace Construction.Scheduling;

using Construction.Core;
using Microsoft.Projects.Project.Job;

codeunit 50472 "CONS Schedule Rollup"
{
    Access = Public;

    /// <summary>
    /// Recomputes the schedule rollup for a single project. Aggregates the planned dates and a
    /// duration-weighted progress percentage up the Job Task outline (summary tasks) and onto the
    /// Job header. Calc-only: child Posting tasks are never modified and no auto-rescheduling occurs.
    /// </summary>
    /// <param name="JobNo">The project (Job) to roll up.</param>
    procedure RollupProject(JobNo: Code[20])
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        RollupSummaryTasks(JobNo);
        RollupJobHeader(JobNo);
    end;

    /// <summary>
    /// Walks the job's tasks in outline order and, for each summary task (a task followed by at
    /// least one task of greater indentation), aggregates the Posting descendants contained in its
    /// contiguous outline block and writes the result back to the summary task.
    /// </summary>
    /// <param name="JobNo">The project whose summary tasks are recomputed.</param>
    local procedure RollupSummaryTasks(JobNo: Code[20])
    var
        SummaryTask: Record "Job Task";
    begin
        SummaryTask.SetRange("Job No.", JobNo);
        SummaryTask.SetCurrentKey("Job No.", "Job Task No.");
        if not SummaryTask.FindSet() then
            exit;
        repeat
            if IsSummaryTask(SummaryTask) then
                RollupOneSummaryTask(SummaryTask);
        until SummaryTask.Next() = 0;
    end;

    /// <summary>
    /// Aggregates the Posting descendants of a single summary task and writes the result back to it.
    /// Descendants are the contiguous block of following tasks whose Indentation stays greater than
    /// the summary task's, ending at the first task with Indentation less than or equal to it.
    /// </summary>
    /// <param name="SummaryTask">The summary task to recompute and modify.</param>
    local procedure RollupOneSummaryTask(var SummaryTask: Record "Job Task")
    var
        ChildTask: Record "Job Task";
        StartDate: Date;
        EndDate: Date;
        WeightedPct: Decimal;
        TotalDuration: Decimal;
        SimplePctSum: Decimal;
        PostingCount: Integer;
    begin
        StartDate := 0D;
        EndDate := 0D;
        WeightedPct := 0;
        TotalDuration := 0;
        SimplePctSum := 0;
        PostingCount := 0;

        ChildTask.SetRange("Job No.", SummaryTask."Job No.");
        ChildTask.SetCurrentKey("Job No.", "Job Task No.");
        ChildTask.SetLoadFields("Job Task Type", Indentation, "CONS Planned Start Date", "CONS Planned End Date", "CONS Duration (Days)", "CONS % Complete");
        ChildTask.SetFilter("Job Task No.", '>%1', SummaryTask."Job Task No.");
        if ChildTask.FindSet() then
            repeat
                if ChildTask.Indentation <= SummaryTask.Indentation then begin
                    WriteSummaryTask(SummaryTask, StartDate, EndDate, WeightedPct, TotalDuration, SimplePctSum, PostingCount);
                    exit;
                end;
                if ChildTask."Job Task Type" = ChildTask."Job Task Type"::Posting then
                    AccumulateTask(ChildTask, StartDate, EndDate, WeightedPct, TotalDuration, SimplePctSum, PostingCount);
            until ChildTask.Next() = 0;

        WriteSummaryTask(SummaryTask, StartDate, EndDate, WeightedPct, TotalDuration, SimplePctSum, PostingCount);
    end;

    /// <summary>Writes the aggregated values onto the summary task and persists it.</summary>
    /// <param name="SummaryTask">The summary task to update and modify.</param>
    /// <param name="StartDate">Rolled-up minimum start date.</param>
    /// <param name="EndDate">Rolled-up maximum end date.</param>
    /// <param name="WeightedPct">Sum of (% complete * duration) across descendants.</param>
    /// <param name="TotalDuration">Sum of duration across descendants.</param>
    /// <param name="SimplePctSum">Sum of % complete across descendants (zero-duration fallback).</param>
    /// <param name="PostingCount">Count of descendant Posting tasks.</param>
    local procedure WriteSummaryTask(var SummaryTask: Record "Job Task"; StartDate: Date; EndDate: Date; WeightedPct: Decimal; TotalDuration: Decimal; SimplePctSum: Decimal; PostingCount: Integer)
    begin
        SummaryTask."CONS Planned Start Date" := StartDate;
        SummaryTask."CONS Planned End Date" := EndDate;
        SummaryTask."CONS % Complete" := AveragePct(WeightedPct, TotalDuration, SimplePctSum, PostingCount);
        SummaryTask.Modify(true);
    end;

    /// <summary>Aggregates every Posting task of the job onto the Job header.</summary>
    /// <param name="JobNo">The project whose header is recomputed.</param>
    local procedure RollupJobHeader(JobNo: Code[20])
    var
        Job: Record Job;
        PostingTask: Record "Job Task";
        StartDate: Date;
        EndDate: Date;
        WeightedPct: Decimal;
        TotalDuration: Decimal;
        SimplePctSum: Decimal;
        PostingCount: Integer;
    begin
        if not Job.Get(JobNo) then
            exit;

        StartDate := 0D;
        EndDate := 0D;
        WeightedPct := 0;
        TotalDuration := 0;
        SimplePctSum := 0;
        PostingCount := 0;

        PostingTask.SetRange("Job No.", JobNo);
        PostingTask.SetRange("Job Task Type", PostingTask."Job Task Type"::Posting);
        PostingTask.SetLoadFields("CONS Planned Start Date", "CONS Planned End Date", "CONS Duration (Days)", "CONS % Complete");
        if PostingTask.FindSet() then
            repeat
                AccumulateTask(PostingTask, StartDate, EndDate, WeightedPct, TotalDuration, SimplePctSum, PostingCount);
            until PostingTask.Next() = 0;

        Job."CONS Planned Start Date" := StartDate;
        Job."CONS Planned End Date" := EndDate;
        Job."CONS Schedule % Complete" := AveragePct(WeightedPct, TotalDuration, SimplePctSum, PostingCount);
        Job.Modify(true);
    end;

    /// <summary>
    /// Returns whether the task is a summary (parent) task — true when the immediately following
    /// task in outline order has a greater indentation.
    /// </summary>
    /// <param name="SummaryTask">The candidate task.</param>
    /// <returns>True if the task heads an outline block.</returns>
    local procedure IsSummaryTask(SummaryTask: Record "Job Task"): Boolean
    var
        NextTask: Record "Job Task";
    begin
        NextTask.SetRange("Job No.", SummaryTask."Job No.");
        NextTask.SetCurrentKey("Job No.", "Job Task No.");
        NextTask.SetLoadFields(Indentation);
        NextTask.SetFilter("Job Task No.", '>%1', SummaryTask."Job Task No.");
        if NextTask.FindFirst() then
            exit(NextTask.Indentation > SummaryTask.Indentation);
        exit(false);
    end;

    /// <summary>Folds one task's planned dates and progress into the running aggregates.</summary>
    /// <param name="Task">The Posting task to fold in.</param>
    /// <param name="StartDate">Running minimum start date (ignoring 0D).</param>
    /// <param name="EndDate">Running maximum end date.</param>
    /// <param name="WeightedPct">Running sum of (% complete * duration).</param>
    /// <param name="TotalDuration">Running sum of duration.</param>
    /// <param name="SimplePctSum">Running sum of % complete (for the zero-duration fallback).</param>
    /// <param name="PostingCount">Running count of folded tasks.</param>
    local procedure AccumulateTask(Task: Record "Job Task"; var StartDate: Date; var EndDate: Date; var WeightedPct: Decimal; var TotalDuration: Decimal; var SimplePctSum: Decimal; var PostingCount: Integer)
    begin
        if Task."CONS Planned Start Date" <> 0D then
            if (StartDate = 0D) or (Task."CONS Planned Start Date" < StartDate) then
                StartDate := Task."CONS Planned Start Date";
        if Task."CONS Planned End Date" <> 0D then
            if (EndDate = 0D) or (Task."CONS Planned End Date" > EndDate) then
                EndDate := Task."CONS Planned End Date";

        WeightedPct += Task."CONS % Complete" * Task."CONS Duration (Days)";
        TotalDuration += Task."CONS Duration (Days)";
        SimplePctSum += Task."CONS % Complete";
        PostingCount += 1;
    end;

    /// <summary>
    /// Returns the duration-weighted average progress, falling back to a simple average when the
    /// total duration is zero.
    /// </summary>
    /// <param name="WeightedPct">Sum of (% complete * duration).</param>
    /// <param name="TotalDuration">Sum of duration.</param>
    /// <param name="SimplePctSum">Sum of % complete (zero-duration fallback numerator).</param>
    /// <param name="PostingCount">Count of folded tasks.</param>
    /// <returns>The rolled-up percentage, rounded to two decimals.</returns>
    local procedure AveragePct(WeightedPct: Decimal; TotalDuration: Decimal; SimplePctSum: Decimal; PostingCount: Integer): Decimal
    begin
        if TotalDuration <> 0 then
            exit(Round(WeightedPct / TotalDuration, 0.01));
        if PostingCount <> 0 then
            exit(Round(SimplePctSum / PostingCount, 0.01));
        exit(0);
    end;
}
