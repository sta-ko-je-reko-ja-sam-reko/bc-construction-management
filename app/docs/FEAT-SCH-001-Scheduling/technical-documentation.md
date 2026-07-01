# FEAT-SCH-001 - Scheduling & Resource Planning

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Scheduling & Resource Planning (add-on, license-gated + Feature-Management-gated) — see [MODULES.md](../../../../MODULES.md).
> **Affected objects:** Job Task schedule fields, Job header roll-up fields, Task Dependency table, Resource Assignment table, schedule roll-up codeunit, Gantt data + control add-in + Project Gantt page, Scheduling setup, API pages, Scheduling permission sets + entitlement.
> **Namespaces:** `Construction.Scheduling`.
> **Proposed ID block:** 50460–50474 (tables/enum/pages/setup), codeunits 50024 + 50472, table extensions 50463/50471.
> **Depends on:** Foundation module (Feature Mgt., License Mgt., Construction Project gate) and standard BC Projects (Job, Job Task, Resource).

## Business Process

1. A planner opens a construction **Project** and lays out its **Project Tasks** (Job Tasks) as an outline: summary tasks (`Begin-Total`) over posting tasks (`Posting`), using **Indentation** for the hierarchy — the same outline standard BC Projects already use.
2. On each **posting** task the planner sets a **Planned Start Date**, **Planned End Date**, **Duration (Days)**, and marks it **Scheduled**. Progress is tracked as **% Complete** per posting task.
3. The planner links tasks with **Task Dependencies** (predecessor → successor) typed Finish-to-Start, Start-to-Start, Finish-to-Finish, or Start-to-Finish, with an optional **Lag (Days)**. Dependencies are descriptive links drawn on the chart; the roll-up does not auto-reschedule from them.
4. The planner assigns **resources/crews** to tasks via **Resource Assignments** (resource, task, from/to dates, quantity).
5. The planner runs **Calculate Schedule** / **Recalculate**, which invokes the **Schedule Roll-up**. It walks the outline and writes, onto each **summary task** and onto the **Job header**, the earliest planned start, the latest planned end, and a **duration-weighted average % complete** of the contained posting tasks. The roll-up is calc-only — posting tasks are never modified and no dates are shifted.
6. The planner reviews the schedule on the **Project Gantt** page, a read-only chart (custom control add-in) rendered from a JSON payload of the project's tasks, progress, and predecessor links. The same chart is surfaced on the role center's scheduling activity.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS Scheduling Setup | Primary Key (Code[10], PK) | Singleton. Enabled (feature toggle); Default Dependency Type (enum); Include Nonworking Days. `InitSetup()` creates the singleton. |
| CONS Task Dependency | Job No. (Code[20]), Job Task No. (Code[20]), Predecessor Task No. (Code[20]) — composite PK | Job Task No. = successor. Dependency Type (enum); Lag (Days) (Decimal). Pure data — no triggers. |
| CONS Resource Assignment | Entry No. (Integer, AutoIncrement, PK) | Secondary key Task = (Job No., Job Task No.). Resource No.; From/To Date; Quantity; Description. Pure data — no triggers. |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Job Task | CONS Planned Start Date (50010) | Date | Planned start; set on posting tasks, rolled up onto summary tasks. |
| Job Task | CONS Planned End Date (50011) | Date | Planned end; set on posting tasks, rolled up onto summary tasks. |
| Job Task | CONS Duration (Days) (50012) | Decimal | Planned duration; weights the roll-up % complete. |
| Job Task | CONS Scheduled (50013) | Boolean | Marks a task as placed on the schedule. |
| Job Task | CONS % Complete (50001) | Decimal | Task progress (defined in the Cost Breakdown extension; consumed by the roll-up). |
| Job | CONS Planned Start Date (50010) | Date | Roll-up: earliest planned start (read-only). |
| Job | CONS Planned End Date (50011) | Date | Roll-up: latest planned end (read-only). |
| Job | CONS Schedule % Complete (50012) | Decimal | Roll-up: duration-weighted average progress (read-only). |

## Roll-up Logic

`CONS Schedule Rollup.RollupProject(JobNo)`:

1. **Feature gate** — `CONS Feature Mgt.CheckEnabled(Scheduling)`; errors if the feature is off.
2. **Summary tasks** — walks tasks in `(Job No., Job Task No.)` order. A task is a *summary* when the immediately following task has greater Indentation. For each summary, aggregates the contiguous following block whose Indentation stays greater (stopping at the first task of equal-or-lower Indentation), folding in only `Posting` tasks: min start (ignoring 0D), max end (ignoring 0D), Σ(% × duration), Σduration, Σ% and count.
3. **Job header** — aggregates every `Posting` task of the project the same way.
4. **% complete** — duration-weighted: `Round(Σ(% × duration) / Σduration, 0.01)`; if total duration is 0 it falls back to the simple average `Round(Σ% / count, 0.01)`; 0 when there are no tasks.

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50460 | CONS Dependency Type | Finish-to-Start / Start-to-Start / Finish-to-Finish / Start-to-Finish. |
| table | 50461 | CONS Scheduling Setup | Singleton setup (feature toggle, defaults). |
| table | 50464 | CONS Task Dependency | Predecessor → successor links. |
| table | 50466 | CONS Resource Assignment | Resource/crew assignments to tasks. |
| tableextension | 50463 | CONS Sched Job Task (extends Job Task) | Planned dates, duration, scheduled flag. |
| tableextension | 50471 | CONS Sched Job (extends Job) | Rolled-up planned dates + schedule % complete (read-only). |
| codeunit | 50024 | CONS Gantt Data | Serializes a project's schedule to the Gantt JSON payload; finds the role center's default scheduled project. |
| codeunit | 50472 | CONS Schedule Rollup | Rolls planned dates + duration-weighted % complete onto summary tasks and the Job header. |
| page | 50473 | CONS Project Schedule | Editable task list with planned dates/duration/% and Calculate Schedule + Gantt actions. |
| page | 50474 | CONS Project Gantt | Read-only Gantt card hosting the control add-in, with a Recalculate action. |
| controladdin | — | CONS Gantt Chart | JS/CSS control add-in; `DrawGantt(DataJson)`, events `ControlAddInReady`, `TaskClicked`. |
| page | 50462 | CONS Scheduling Setup | Setup card for the feature toggle and defaults. |
| page | 50465 | CONS Task Dependencies | Task dependency list. |
| page | 50467 | CONS Resource Assignments | Resource assignment list. |
| page (API) | 50475 | CONS Task Schedule API | API page for the Job Task schedule fields (write path gated by `CONS Feature Mgt.CheckEnabled`). |
| page (API) | 50476 | CONS Task Dependency API | API page for task dependencies. |
| page (API) | 50477 | CONS Resource Assignment API | API page for resource assignments. |
| permissionset | 50468 | CONS Sched - Edit | Scheduling objects, RW. |
| permissionset | 50469 | CONS Sched - Read | Scheduling objects, R. |
| permissionset | 50470 | CONS Sched License | License permission set referenced by the entitlement. |
| entitlement | — | CONS Sched Ent | Maps `CONS Sched License` to a per-user offer plan (AppSource-only, `#if APPSOURCE`). |

> All object IDs above are taken from the `app/src/Scheduling/` files. The control add-in and entitlement are named-only (no numeric ID).

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Roll-up | `CONS Schedule Rollup.RollupProject(JobNo)` | Run from the Project Schedule (Calculate Schedule) and Project Gantt (Recalculate) actions. |
| Gantt payload | `CONS Gantt Data.BuildScheduleJson(JobNo)` | Builds the range + tasks + predecessors JSON consumed by `CONS Gantt Chart.DrawGantt`. |
| Role center default | `CONS Gantt Data.FindDefaultScheduledProject()` | First open construction project with a scheduled task, else ''. |
| Feature gate | `CONS Feature Mgt.CheckEnabled(Scheduling)` / `IsEnabled` | Roll-up + API write guards; application-area visibility. |
| License gate | `CONS License Mgt.CheckModuleLicensed("Scheduling & Resource Planning")` | Project Schedule / Project Gantt `OnOpenPage`. |

## Tests

`test/src/ScheduleRollupTests.Codeunit.al` — codeunit 50512 `CONS Schedule Rollup Tests`. Covers summary-task and Job-header roll-up (planned date min/max, duration-weighted % complete, zero-duration simple-average fallback, outline-block boundary, 0D-date handling), the disabled-feature gate, the dependency→Gantt-JSON path, and the Resource Assignment task-key scoping. The Gantt JSON shape and default-project resolution are covered separately by `test/src/GanttDataTests.Codeunit.al` (codeunit 50509).

## Known Limitations

- **No critical-path / auto-scheduling.** Dependencies and lag are descriptive links drawn on the chart; the roll-up does not shift dates from them. A scheduling engine (forward/backward pass, constraint solving) is a later enhancement.
- **Duration is a stored field**, not derived from start/end or a working calendar. The `Include Nonworking Days` setup flag is reserved for a future duration calculation.
- **Gantt is read-only** — editing happens on the Project Schedule list / Job Task card; the chart navigates on row click.
- Resource Assignment has no overallocation or capacity check yet.
