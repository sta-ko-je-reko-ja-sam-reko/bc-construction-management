# FEAT-RC-001 - Construction Manager Role Center

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Foundation (Core) — aggregates every feature module.
> **Affected objects:** one Role Center page + profile, one activities cue part, a Temporary cue table, a Page Background Task that computes the counts, and the shared Gantt JSON builder.
> **Namespaces:** `Construction.Core` (role center, activities, cue), `Construction.Scheduling` (Gantt builder).
> **ID block:** 50021–50025.
> **Depends on:** all feature modules (it links to their lists/cards and counts their documents); the Scheduling Gantt control add-in.

## Business Process

1. A user assigned the **Construction Manager** role lands on the role center. It shows **one Activities part** with cue tiles **grouped per feature** (Projects, Estimating, Progress Billing, Subcontracts, Equipment & Plant, Scheduling), plus the **project Gantt** for a representative scheduled project.
2. Each cue group and each navigation/creation action carries its **feature's Application Area**, so a user only sees the tiles and actions for the features that are enabled/licensed for them.
3. The cue counts are computed by a **Page Background Task** — the role center opens immediately and the numbers fill in a moment later; counts are never calculated synchronously on the page thread.
4. Choosing a cue drills to that feature's list; the **Sections / Create / Process** actions open the feature lists, new documents, and the guided setup.

## Data Model

| Table | Key | Notes |
|---|---|---|
| CONS Activities Cue | Primary Key (Code[10]) | **`TableType = Temporary`** buffer; plain `Integer` cue fields (not FlowFields) filled by the background task. No API page, no `tabledata` permission. |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| table | 50021 | CONS Activities Cue | Temporary cue buffer (count per cue). |
| page | 50022 | CONS Construction Activities | `CardPart` — per-feature `cuegroup`s (each with its feature `ApplicationArea` on the cue fields) + a Scheduling group hosting the Gantt; enqueues the cue task on open and applies the result in `OnPageBackgroundTaskCompleted`. |
| page | 50023 | CONS Construction Manager RC | `RoleCenter`; one Activities part; actions grouped per feature (areas on the actions). |
| codeunit | 50024 | CONS Gantt Data | Builds the schedule JSON for the Gantt; shared with the Project Gantt page; finds the default scheduled project. |
| codeunit | 50025 | CONS Activities Cue Calc | Page Background Task — counts per feature (keyed by `FieldNo`) returned via `SetBackgroundTaskResult`. |
| profile | — | CONS Construction Manager | Sets this Role Center; `Enabled = true`. |

## Patterns used

- **Role-center cues via Page Background Task** — Temporary cue table + Integer fields + PBT, so the home page opens instantly; `OnPageBackgroundTaskError` handled so a failed calc never blocks the page. See `bc-customer-project-template/al-object-types/_patterns/role-center-cues.md`.
- **Per-feature Application Area on leaf controls** — areas live on cue **fields** and **actions**, never on `cuegroup`/action `group` (AL0124).

## Tests

`test/CONS Gantt Data Tests` — the schedule JSON has the expected shape, and the default-project resolver returns blank when there's no scheduled construction project (so the Gantt group hides).
