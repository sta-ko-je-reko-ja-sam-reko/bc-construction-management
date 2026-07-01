namespace Construction.Scheduling;

controladdin "CONS Gantt Chart"
{
    RequestedHeight = 500;
    MinimumHeight = 200;
    HorizontalStretch = true;
    VerticalStretch = true;
    Scripts = 'src/Scheduling/Gantt/Gantt.js';
    StartupScript = 'src/Scheduling/Gantt/Startup.js';
    StyleSheets = 'src/Scheduling/Gantt/Gantt.css';

    /// <summary>Renders the read-only Gantt chart from a JSON payload describing the project schedule.</summary>
    /// <param name="DataJson">The serialized schedule: range and an ordered array of tasks.</param>
    procedure DrawGantt(DataJson: Text);

    /// <summary>Raised once the add-in has loaded and its root element is ready to receive draw calls.</summary>
    event ControlAddInReady();

    /// <summary>Raised when the user clicks a task row.</summary>
    /// <param name="JobTaskNo">The task number of the clicked row.</param>
    event TaskClicked(JobTaskNo: Text);
}
