# FEAT-SCH-001 - Scheduling & Resource Planning

Plan a construction project as an outline of tasks with planned dates, link them with dependencies, assign crews/resources, roll the dates and progress up to the project, and view it all on a Gantt chart. Requires the **Scheduling & Resource Planning** module (license-gated) and the **Scheduling** feature switched on in **Scheduling Setup**.

## Steps

1. **Enable the feature.** Open **Scheduling Setup**, turn on **Enabled**, and (optionally) set the **Default Dependency Type** and **Include Nonworking Days**. The session restarts so the scheduling pages and Gantt appear.

2. **Open the project schedule.** From a construction **Project**, open **Project Schedule**. It lists the project's tasks with their **Indentation** (outline level), **Project Task Type**, planned dates, duration, and % complete.

3. **Set planned dates on posting tasks.** For each **Posting** task, fill in **Planned Start Date**, **Planned End Date**, and **Duration (Days)**, and mark it **Scheduled**. Leave summary (Begin-Total) tasks blank — they are filled by the roll-up. Update **% Complete** as work progresses.

4. **Link task dependencies.** Open **Task Dependencies** and add predecessor → successor links: pick the **Project Task No.** (successor) and its **Predecessor Task No.**, choose the **Dependency Type** (Finish-to-Start, Start-to-Start, Finish-to-Finish, or Start-to-Finish), and set a **Lag (Days)** if needed. Dependencies are drawn on the Gantt; they do not move dates automatically.

5. **Assign resources / crews.** Open **Resource Assignments** and add a line per assignment: the **Resource No.**, the **Project Task No.** it works on, the **From Date** / **To Date**, and the planned **Quantity** (hours or units).

6. **Recalculate the roll-up.** On **Project Schedule** choose **Calculate Schedule** (or **Recalculate** on the Project Gantt). This writes onto each summary task and onto the project header: the **earliest planned start**, the **latest planned end**, and a **duration-weighted average % complete** of the posting tasks below it. Posting tasks are never changed.

7. **View the Gantt.** From Project Schedule choose **Gantt** (or open **Project Gantt** directly) to see the read-only timeline: each task as a bar with progress, and the predecessor links between them. Click a task bar to open its **Project Task Card**. The same chart appears on the role center's scheduling activity for the default scheduled project.

> _Screenshots and a full field reference to be completed at implementation review._
