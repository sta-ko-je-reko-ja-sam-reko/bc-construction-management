# Project Operations → BC Projects — capability map & what to port

> Research date: 2026-06-29. Purpose: decide which **Dynamics 365 Project Operations** functionalities are worth adapting into the Construction Management module (general/international, built on BC **Projects/Jobs**). Project Operations is Dataverse/Power-Platform based — we adapt **concepts and data models into AL**, we do not integrate. Sources at the bottom.

## 1. Project Operations capability set (2025/2026)

Project Operations ships in three deployment types — **Core/Lite** (Dataverse + Project for the web), **Integrated with Finance & Operations**, and **for Manufacturing/Stocked**. Capability areas:

- **Project planning / WBS & scheduling** — work breakdown structure with task hierarchy, **effort, start/end, duration**, **task dependencies (4 predecessor types)**, generic resource estimates, **Gantt**, project templates. Powered by **Microsoft Project for the web**.
- **Resource management** — bookable resources, resource requirements/requests, assignments, **universal resource scheduling** (shared with Field Service), team members.
- **Estimates** — per quote/contract line detail; transaction classes **Time / Expense / Fees** (no materials in PSA); dual cost-vs-sales records; bottom-up estimate from the project plan.
- **Project budgeting** (Integrated/F&O) — budget from estimates, **budget approval workflow**, actuals matched to budget, variance and **forecasts** (EAC-style).
- **Cost/transaction categories** — shared categories: Hours, Expense, Fees, Item, On-account; cost types/dimensions.
- **Time & expense entry** — timesheets, expense capture (OCR in Stocked), approvals.
- **Project contracts & billing** — quotes → contract; **fixed-price, time-&-material, milestone** billing; billing limits/terms; invoicing; **revenue recognition**.
- **Change / contract management** — note: classic PSA does **not** support change orders; richer contract management exists in the F&O-integrated flavor.
- **Analytics** — project profitability, actual-vs-estimate dashboards.

## 2. Comparison vs standard BC Projects (Jobs)

BC native (per the current *Managing projects* walkthrough, updated 2026-04): Project card; **Project Task Lines** (Begin-Total / Posting / End-Total + indentation); **Project Planning Lines** (Budget / Billable / Both); Resources / Items / G-L; per-project **Prices**; **Project Journals** + **Project Ledger Entries**; **WIP & recognition** (Cost Value etc.); **Project Statistics** (cost/price/profit, budget vs actual); Create Project Sales Invoice (per task or whole); payment by installments; copy project.

| Project Operations capability | BC Projects native? | Notes |
|---|---|---|
| Project hierarchy / task grouping | **partial** | BC has Begin/End-Total + indentation — an *accounting* roll-up, **not** a scheduling WBS. |
| Task scheduling: start/end, duration, **dependencies/predecessors, Gantt** | **gap** | BC tasks have **no** dates/durations/dependencies; project header has start/end only. |
| Generic-resource staffing on tasks, **bookable resources, scheduling board** | **gap** | BC has Resources + capacity, but no booking/assignment-to-task or scheduling board. |
| Estimating (structured estimate that becomes the budget) | **partial** | BC planning lines *are* the budget, entered manually; no separate estimate document, no markup model, no cost-vs-sales estimate pairing. |
| Project budget (budget vs actual, variance) | **already** | Planning lines (Budget) + Project Statistics give budget vs actual cost/price/profit. |
| Budget **approval workflow** | **gap** | No native budget-approval flow on projects. |
| Cost / transaction **categories** | **partial** | BC groups via posting groups + dimensions + line Type (Resource/Item/G-L); no first-class "cost type/category" on construction lines. |
| Time & expense entry + approval | **partial** | Project Journals + Time Sheets exist; lighter than PO timesheet/expense + approval. |
| Billing: T&M, fixed price, installments | **already** | Billable planning lines, fixed price, installment billing all supported. |
| Billing: **milestone / schedule of values / progress %** | **gap** | Installments are manual lines; no schedule-of-values or %-complete progress certificate. |
| **Retention / retainage** | **gap** | Not in standard BC at all. |
| **Committed cost** (open PO amounts vs budget) | **gap** | BC shows posted actuals (ledger); open-PO commitments are not surfaced on the project. |
| **Earned value / EAC / ETC / % complete forecast** | **gap** | Statistics shows budget vs actual, **not** forecast-at-completion. |
| Revenue recognition / WIP | **already** | BC WIP methods + recognition cover this. |
| Change orders / variations | **gap** | Not native (and not in PSA either — so this is our differentiator, not a port). |
| Dimensions / cost analysis | **already** | Full Dimension Set model. |

## 3. Construction-relevant gaps, ranked by value-to-effort (AL on BC)

| Rank | Gap | Value | Effort | Verdict |
|---|---|---|---|---|
| 1 | **Estimating / Bill of Quantities → budget** (markup, cost types, push to planning lines) | High | Med | **Build (MVP).** Core construction differentiator; PO's estimate→budget is the model to adapt. |
| 2 | **Committed cost** (open POs vs budget on the project) | High | Low-Med | **Build (MVP).** Cheap (query standard Purchase Line), high PM value. |
| 3 | **Cost control / EAC / ETC / % complete** | High | Med | **Build (MVP).** The forecasting layer BC lacks; pairs with #2. |
| 4 | **Cost breakdown structure** (deeper roll-up than Begin/End-Total) | High | Med | **Build (MVP).** Lean on Job Task indentation + roll-up fields rather than a parallel tree. |
| 5 | **Progress billing / schedule of values + retention** | High | High | **Build (Phase 2).** Highest construction-revenue value; retention posting is the hard part. |
| 6 | **Cost types / categories** on estimate & ledger | Med | Low | **Build (folds into #1/#4).** Enum + classification, cheap. |
| 7 | **Task scheduling: dates, durations, dependencies, Gantt** | Med | **High** | **Defer / partial.** Replicating Project-for-the-web scheduling in AL is expensive; do lightweight dates/% only. See §4. |
| 8 | **Resource scheduling / crew booking board** | Med | **High** | **Defer (Phase 4, thin).** Full universal-resource-scheduling is Dataverse-bound; ship a simple crew-assignment list, not a board. |
| 9 | Budget approval workflow | Low-Med | Low | **Build later** — reuse BC's native approval-workflow framework, don't invent. |

## 4. Dataverse / Project-for-the-web–bound features → do NOT replicate

- **Gantt + interactive task scheduling engine** (predecessors, auto-rescheduling) — this is Microsoft Project for the web. Re-implementing in AL is a huge build for low BC-fit. **Skip** the engine; offer optional task start/end/% complete fields and (later) a read-only timeline.
- **Universal Resource Scheduling / booking board** — shared Dataverse component (Field Service). **Skip** the board; a construction crew/equipment **assignment list** on the project covers 80% at a fraction of the cost.
- **PSA quote/contract-line-detail dual-entity estimating** — Dataverse data model; we take the *concept* (cost-vs-sales, transaction classes) but model it natively as BoQ lines on BC.
- **OCR expense capture** — out of scope; BC has its own document-capture story.

## 5. Recommendation — folded into the roadmap

- **Adopt as MVP concepts** (Phase 1): estimate→budget (BoQ), cost types/transaction categories, committed cost, EAC/ETC/% complete, CBS roll-up. These map directly to existing `EST` / `WBS` / `CST` features — **no new feature areas needed**; PO validates the design.
- **Phase 2**: progress billing (schedule of values) + retention — construction-specific, not a PO port but informed by PO billing models.
- **Phase 4 — Scheduling & Resource Planning *premium module***: light task dates/durations/% complete + simple predecessors + read-only timeline (`SCH`) and a crew/equipment **assignment list** (`RES`). Native, lightweight, **sold as a premium add-on** (own permission set + entitlement + license gate — see [../../MODULES.md](../../MODULES.md)).
- **Skip entirely (never replicate)**: the Microsoft **Project-for-the-web scheduling engine** (interactive Gantt/auto-reschedule), the Dataverse **universal resource-scheduling board**, **OCR expense capture**, and PSA's dual-entity estimate data model. The premium module above is a native subset, *not* a re-implementation of these.

**Net:** the MVP feature set (`SET → EST → WBS → CST`) is confirmed correct. Project Operations changes *details inside* those features (cost-vs-sales estimating, transaction categories, budget-from-estimate flow, forecast/variance), not the roadmap shape. `RES` is downgraded from "scheduling" to a thin assignment list and pushed to Phase 4.

## Sources

- [Determine your deployment type — Project Operations](https://learn.microsoft.com/en-us/dynamics365/project-operations/environment/determine-deployment-type)
- [Project Operations documentation hub](https://learn.microsoft.com/en-us/dynamics365/project-operations/)
- [Create a work breakdown structure — Project Operations](https://learn.microsoft.com/en-us/dynamics365/project-operations/project-management/create-wbs)
- [Schedule a project with a work breakdown structure](https://learn.microsoft.com/en-us/dynamics365/project-operations/psa/schedule-project-work-breakdown-structure)
- [Estimates — Project Operations](https://learn.microsoft.com/en-us/dynamics365/project-operations/psa/estimates)
- [Project budget management overview](https://learn.microsoft.com/en-us/dynamics365/project-operations/pro/budget/projectbudgetmanagement)
- [Create a project budget from estimates](https://learn.microsoft.com/en-us/dynamics365/project-operations/pro/budget/create-project-budget-from-estimates)
- [Configure project categories](https://learn.microsoft.com/en-us/dynamics365/project-operations/project-accounting/configure-project-categories)
- [Walkthrough - Managing projects — Business Central](https://learn.microsoft.com/en-us/dynamics365/business-central/walkthrough-managing-projects-with-jobs)
- [Table "Job Planning Line" — Business Central](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/table/microsoft.projects.project.planning.job-planning-line)
- [Set up projects, prices, and project posting groups — Business Central](https://learn.microsoft.com/en-us/dynamics365/business-central/projects-how-setup-jobs)
