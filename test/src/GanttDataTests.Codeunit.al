codeunit 50509 "CONS Gantt Data Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure BuildScheduleJson_ReturnsScheduleShape()
    var
        GanttData: Codeunit "CONS Gantt Data";
        Json: Text;
    begin
        // [GIVEN] a project with no scheduled tasks
        // [WHEN] the schedule JSON for the Gantt is built
        Json := GanttData.BuildScheduleJson('NONEXISTENT');

        // [THEN] it is a well-formed schedule payload (range + tasks array) the add-in can draw
        Assert.IsTrue(StrPos(Json, '"rangeStart"') > 0, 'schedule JSON contains the planned range');
        Assert.IsTrue(StrPos(Json, '"tasks"') > 0, 'schedule JSON contains a tasks array');
    end;

    [Test]
    procedure FindDefaultScheduledProject_NoneIsBlank()
    var
        GanttData: Codeunit "CONS Gantt Data";
    begin
        // [GIVEN] no open construction project with scheduled tasks in the test isolation
        // [WHEN]/[THEN] the role center's default Gantt project is blank (so the Gantt group hides)
        Assert.AreEqualText('', GanttData.FindDefaultScheduledProject(), 'no default scheduled project resolves to blank');
    end;
}
