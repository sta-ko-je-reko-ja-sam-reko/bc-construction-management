# FEAT-CST-001 - Cost Control & Forecasting

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Cost Control (add-on, license-gated) — see [MODULES.md](../../../../MODULES.md). Shares the Cost Control permission sets + entitlement defined in FEAT-WBS-001.
> **Affected objects:** Job Task / Job extensions (committed + forecast), committed-cost query, forecast codeunit, cost-control page.
> **Namespaces:** default.
> **Proposed ID block:** 50120–50139 (confirm at implementation).
> **Depends on:** Foundation + Cost Control/WBS (Job Task structure, Cost Control permission sets).

## Business Process

1. As **purchase orders/invoices** are raised against a construction project, the **open (outstanding, not-yet-invoiced) amounts** are surfaced as **committed cost** per task and project.
2. The **Project Cost Control** page shows, per cost-breakdown node: **Budget / Committed / Actual / Remaining / EAC / Variance / % Complete**.
3. The **forecast codeunit** computes **% complete** (cost-based default = Actual ÷ Budget, manual override from WBS), **Estimate to Complete (ETC)** and **Estimate at Completion (EAC)**.
4. The project manager reviews variance (Budget vs EAC) and acts; figures feed dashboards and progress billing.

## Forecasting method (MVP, configurable later)

- **Committed Cost** = Σ outstanding amount (LCY) of open Purchase Lines linked to the Job/Job Task.
- **% Complete** (default) = Actual Cost ÷ Budget Cost; overridable per task (`Job Task.CONS % Complete`).
- **ETC** = max(Budget Cost − Actual Cost − Committed Cost, 0) (unless flagged overrun, then 0).
- **EAC** = Actual Cost + Committed Cost + ETC.
- **Cost Variance** = Budget Cost − EAC (negative = forecast overrun).

## Data Model

### New Tables
_None in MVP. Optional `CONS Cost Snapshot` (per project/date) for trend reporting is a future enhancement (note below)._

### New Fields on Existing Tables
_None._ Budget/Committed/Actual/ETC/EAC/Variance/% are **computed per row on the page** by the forecast codeunit — not stored — so no new fields and no second Job/Job Task tableextension (which the one-extension-per-object rule would forbid anyway, since Foundation extends Job and WBS extends Job Task). Committed cost is summed from `Purchase Line."Outstanding Amount (LCY)"` (filtered by `Job No.`/`Job Task No.`) via `CalcSums` — no FlowField, so no SIFT index added to the standard Purchase Line and no LC0045.

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| codeunit | 50123 | CONS Cost Forecast | Computes Budget/Committed/Actual/% complete/ETC/EAC/Variance for a task (`CalcForecast`); committed via `CalcSums` on Purchase Line. |
| page | 50124 | CONS Project Cost Control | List over Job Task computing Budget/Committed/Actual/ETC/EAC/Variance/% per row; opened from the task subform; searchable. |
| ~~tableextension~~ | 50120/50121 | ~~Job Task / Job Cost Ctrl~~ | **Not needed** — figures are page-computed, not stored. |
| ~~query~~ | 50122 | ~~CONS Committed Cost~~ | **Deferred** — committed cost uses `CalcSums` in the codeunit instead. |
| ~~page~~ | 50125 | ~~CONS Cost Control FactBox~~ | **Deferred** — post-MVP. |

> Objects are added to the existing **Cost Control** permission sets (50117/50118) from FEAT-WBS-001 — no new permission set/entitlement here.

## Files

```
app/src/CostControl/
├── CostForecast.Codeunit.al
└── ProjectCostControl.Page.al
    (committed-cost via CalcSums; tableextensions/query/factbox not needed — see Objects table.
     "Cost Control" action added to app/src/CostBreakdown/JobTaskLines.PageExt.al;
     codeunit + page granted in the Cost Control permission sets.)
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Committed cost | `CONS Committed Cost` query / FlowField | Open PO outstanding per Job/Task. |
| Forecast | `CONS Cost Forecast.CalcProject(Job)` | Refresh ETC/EAC/% on demand and on page open. |
| Budget/actual | Job Planning Line (Budget) / Job Ledger Entry | Inputs to forecast. |
| License gate | `CONS License Mgt.IsModuleLicensed(CostControl)` | Page/codeunit entry. |

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Project gate, license gate. |
| Cost Control / WBS (this app) | internal | Job Task structure + permission sets. |
| Base Application | Microsoft | **Purchase Line** (Job fields/outstanding), Job Ledger Entry, Job Planning Line, Job Task. |

## Known Limitations

- Single forecasting method in MVP; alternative EAC methods (CPI-based, etc.) are configurable later.
- Committed cost covers open **purchase documents**; commitments from subcontracts arrive with the Subcontracts module.
- No persisted history in MVP (point-in-time calc); `CONS Cost Snapshot` trend table is a future enhancement.
