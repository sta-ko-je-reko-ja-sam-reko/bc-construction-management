namespace Construction.Scheduling;

using Microsoft.Projects.Project.Job;

codeunit 50024 "CONS Gantt Data"
{
    Access = Public;

    /// <summary>
    /// Serializes a project's schedule into the JSON payload the Gantt add-in expects: the planned
    /// date range and an ordered array of tasks with progress and predecessors. Shared by the Project
    /// Gantt page and the role center's scheduling activity so the chart is built one way.
    /// </summary>
    /// <param name="JobNo">The project to serialize.</param>
    /// <returns>The schedule as a JSON text.</returns>
    procedure BuildScheduleJson(JobNo: Code[20]): Text
    var
        JobTask: Record "Job Task";
        Root: JsonObject;
        TasksArray: JsonArray;
        RangeStart: Date;
        RangeEnd: Date;
        ResultJson: Text;
    begin
        RangeStart := 0D;
        RangeEnd := 0D;

        JobTask.SetLoadFields("Job Task No.", Description, Indentation, "Job Task Type", "CONS Planned Start Date", "CONS Planned End Date", "CONS % Complete");
        JobTask.SetCurrentKey("Job No.", "Job Task No.");
        JobTask.SetRange("Job No.", JobNo);
        if JobTask.FindSet() then
            repeat
                if JobTask."CONS Planned Start Date" <> 0D then
                    if (RangeStart = 0D) or (JobTask."CONS Planned Start Date" < RangeStart) then
                        RangeStart := JobTask."CONS Planned Start Date";
                if JobTask."CONS Planned End Date" <> 0D then
                    if (RangeEnd = 0D) or (JobTask."CONS Planned End Date" > RangeEnd) then
                        RangeEnd := JobTask."CONS Planned End Date";

                TasksArray.Add(BuildTaskObject(JobTask));
            until JobTask.Next() = 0;

        Root.Add('rangeStart', FormatDate(RangeStart));
        Root.Add('rangeEnd', FormatDate(RangeEnd));
        Root.Add('tasks', TasksArray);

        Root.WriteTo(ResultJson);
        exit(ResultJson);
    end;

    local procedure BuildTaskObject(var JobTask: Record "Job Task"): JsonObject
    var
        TaskDependency: Record "CONS Task Dependency";
        TaskObject: JsonObject;
        Predecessors: JsonArray;
    begin
        TaskDependency.SetLoadFields("Predecessor Task No.");
        TaskDependency.SetRange("Job No.", JobTask."Job No.");
        TaskDependency.SetRange("Job Task No.", JobTask."Job Task No.");
        if TaskDependency.FindSet() then
            repeat
                Predecessors.Add(TaskDependency."Predecessor Task No.");
            until TaskDependency.Next() = 0;

        TaskObject.Add('no', JobTask."Job Task No.");
        TaskObject.Add('description', JobTask.Description);
        TaskObject.Add('indentation', JobTask.Indentation);
        TaskObject.Add('start', FormatDate(JobTask."CONS Planned Start Date"));
        TaskObject.Add('end', FormatDate(JobTask."CONS Planned End Date"));
        TaskObject.Add('pct', JobTask."CONS % Complete");
        TaskObject.Add('type', Format(JobTask."Job Task Type"));
        TaskObject.Add('predecessors', Predecessors);

        exit(TaskObject);
    end;

    local procedure FormatDate(TheDate: Date): Text
    begin
        if TheDate = 0D then
            exit('');
        exit(Format(TheDate, 0, 9));
    end;

    /// <summary>Returns a representative construction project to chart on the role center — the first open construction project that has scheduled tasks. Empty if none.</summary>
    /// <returns>The project number, or '' if no scheduled construction project exists.</returns>
    procedure FindDefaultScheduledProject(): Code[20]
    var
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        Job.SetLoadFields("No.");
        Job.SetRange("CONS Construction Project", true);
        Job.SetRange(Status, Job.Status::Open);
        if Job.FindSet() then
            repeat
                JobTask.SetRange("Job No.", Job."No.");
                JobTask.SetRange("CONS Scheduled", true);
                if not JobTask.IsEmpty() then
                    exit(Job."No.");
            until Job.Next() = 0;
        exit('');
    end;
}
