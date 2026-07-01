# FEAT-WBS-001 - Cost Breakdown Structure

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Cost Control (add-on, license-gated) — see [MODULES.md](../../../../MODULES.md). This is the first feature of the Cost Control module, so it defines the module's permission sets + entitlement (shared with FEAT-CST-001).
> **Affected objects:** Job Task extension (structural/% fields), Cost Breakdown page, Cost Control permission sets + entitlement.
> **Namespaces:** default.
> **Proposed ID block:** 50100–50119 (confirm at implementation).
> **Depends on:** Foundation module.

## Design decision (made; confirm against symbols)

**Extend the standard Job Task hierarchy** — do **not** build a parallel CBS table. Standard **Job Task** already provides multi-level structure (Begin-Total / End-Total + indentation) and totaling FlowFields (Schedule / Usage / Contract total cost). That *is* the cost breakdown backbone. This feature therefore:

- Adds a small number of **construction fields** to Job Task (Cost Type, % Complete).
- Adds a dedicated **Cost Breakdown** page that presents the hierarchy with budget/actual/variance/% in one construction-oriented view.

Rationale: least reinvention, automatic integration with planning lines, journals, WIP and invoicing. (Committed cost + forecast are added by FEAT-CST-001 on the same module.) Confirm the standard Job Task totaling field names in symbols before relying on them.

## Business Process

1. The project manager structures the construction project into a multi-level breakdown using **Project Tasks** (phases → work packages → cost items) with indentation.
2. Each posting-level task carries a **Cost Type** and a **% Complete** (manual override; cost-based default from CST).
3. **Budget** (from the BoQ push), **actual cost** (Job Ledger), and totals **roll up** the hierarchy via standard totaling.
4. The **Cost Breakdown** page shows, per node: Budget / Actual / Variance / % Complete — the reporting backbone for cost control and progress billing.

## Data Model

### New Tables
_None — this feature extends Job Task; the hierarchy is standard._

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Job Task | CONS Cost Type | Enum CONS Cost Type | Construction classification of the task. |
| Job Task | CONS % Complete | Decimal | Manual progress override; CST computes a cost-based default. |

> Budget/actual roll-ups use the **standard** Job Task FlowFields `Schedule (Total Cost)` (budget) and `Usage (Total Cost)` (actual) — **no `CONS` FlowFields added**. Variance is computed on the page (`Schedule − Usage`). Only Cost Type + % Complete are new fields.

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| tableextension | 50100 | CONS Job Task | Cost Type + % Complete. Budget/actual roll-ups use standard `Schedule (Total Cost)` / `Usage (Total Cost)` — not duplicated. |
| page | 50101 | CONS Cost Breakdown | List over Job Task: Cost Type, Budget (`Schedule (Total Cost)`), Actual (`Usage (Total Cost)`), Variance, % Complete. Searchable (ReportsAndAnalysis). |
| pageextension | 50102 | CONS Job Task Lines | Extends **Job Task Lines** (the project's task subform) — adds Cost Type + % Complete columns and a Cost Breakdown action. **Not** Job Card: an app allows only one pageextension per page and Foundation already extends Job Card. |
| permissionset | 50117 | CONS Cost - Edit | Cost Control module objects (WBS + CST), RW (caption 'Construction Cost Control - Edit'). Name ≤20 chars. |
| permissionset | 50118 | CONS Cost - Read | Cost Control module objects, R (caption 'Construction Cost Control - Read'). |
| entitlement | 50119 | CONS Cost Ent | Maps Cost Control permission set to license plan (deferred — needs service-plan GUID). |

> `CONS Admin` is extended to include `CONS Cost - Edit`.

## Files

```
app/src/CostBreakdown/
├── JobTask.TableExt.al
├── CostBreakdown.Page.al
├── JobTaskLines.PageExt.al
└── PermissionSet/
    ├── CostEdit.PermissionSet.al
    └── CostRead.PermissionSet.al
    (entitlement deferred — needs service-plan GUID)
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Roll-up | Standard Job Task totaling + CONS FlowFields | Budget/actual aggregation up the hierarchy. |
| Budget source | Job Planning Lines (Budget) from Estimating push | Budget figures per task. |
| Actual source | Job Ledger Entries | Actual cost per task. |
| License gate | `CONS License Mgt.IsModuleLicensed(CostControl)` | Page entry check. |

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Cost Type, Project gate, license gate. |
| Base Application | Microsoft | **Job Task** (hierarchy/totaling), Job Planning Line, Job Ledger Entry. |

## Known Limitations

- Roll-up correctness depends on standard Job Task totaling field names — confirm in symbols; add CONS FlowFields only where needed.
- Committed cost and EAC/ETC are **not** here — they are FEAT-CST-001 (same module).
