# FEAT-EST-001 - Bill of Quantities

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Estimating (add-on, license-gated) — see [MODULES.md](../../../../MODULES.md).
> **Affected objects:** BoQ document (header + lines), BoQ pages, budget-push codeunit, Estimating permission sets + entitlement.
> **Namespaces:** default.
> **Proposed ID block:** 50050–50069 (confirm at implementation).
> **Depends on:** Foundation module (Cost Type, Cost Type Setup, Construction Setup, Project gate).

## Business Process

1. The estimator creates a **Bill of Quantities** (BoQ) — linked to a construction **Project**, or standalone for a tender. The No. comes from `Construction Setup.BoQ Nos.`
2. The estimator builds **hierarchical BoQ lines**: headings (Begin-Total), positions/items (Posting), and totals (End-Total), with **indentation**, mirroring the Project Task pattern.
3. Each position line carries a **Cost Type** (Labor/Material/Equipment/Subcontract/Other), **quantity**, **unit of measure**, **unit cost**, and **markup %** → the line computes **total cost**, **unit price**, **total price**. Headings roll up their positions.
4. The BoQ totals cost and price (with markup) per heading and overall, giving the tender/estimate value.
5. On award, the estimator sets status **Awarded** and runs **Create Project Budget** — the budget-push codeunit generates **Job Planning Lines (Budget)** on the linked project's tasks from the BoQ lines, and stamps each BoQ line with its linked planning line for traceability.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS BoQ Header | No. (Code[20], PK) | Description; Project No. (TableRelation Job, blank=tender); Bill-to Customer No.; Status (enum); Estimator; Currency Code; Default Markup %; Starting/Ending Date; Total Cost / Total Price (FlowField); No. Series. |
| CONS BoQ Line | Document No. (Code[20]), Line No. (Integer) | Line Type (enum: Heading/Position/Total/Comment); Indentation; Type (option: " "/Resource/Item/G-L Account/Text); No.; Description; Unit of Measure Code; Quantity; Cost Type (enum); Unit Cost; Total Cost; Markup %; Unit Price; Total Price; Project Task No. (target); Linked Job Planning Line No. (set on push). |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| (none required) | | | BoQ links to Job/Job Task by reference; no new fields on standard tables in this feature. |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50050 | CONS BoQ Status | Open / Released / Awarded / Closed. |
| enum | 50051 | CONS BoQ Line Type | Position / Heading / Comment (per-section Begin/End-Total subtotaling deferred). |
| table | 50052 | CONS BoQ Header | Estimate header. |
| table | 50053 | CONS BoQ Line | Estimate lines (hierarchical). |
| page | 50054 | CONS Bill of Quantities | Document page (header + lines subform). |
| page | 50055 | CONS BoQ Subform | Lines list part. |
| page | 50056 | CONS Bill of Quantities List | List of BoQ documents. |
| codeunit | 50057 | CONS BoQ Create Budget | Generates Job Planning Lines (Budget) from BoQ Position lines onto project tasks; idempotent; sets BoQ to Awarded. |
| interface | — | CONS IBoQHeader / CONS IBoQLine | Polymorphic trigger/validate logic contracts (no object ID). |
| codeunit | 50063 | CONS BoQ Line Logic | Default impl of `CONS IBoQLine` — line trigger/validate logic (amounts, type, lookups). |
| codeunit | 50064 | CONS BoQ Header Logic | Default impl of `CONS IBoQHeader` — header no-series + cascade delete. |
| ~~codeunit~~ | 50058 | ~~CONS BoQ Mgt.~~ | **Deferred** — line totals/markup live in the BoQ Line table; license gate via Foundation `CONS License Mgt.CheckModuleLicensed` (added there). |
| ~~report~~ | 50059 | ~~CONS Bill of Quantities~~ | **Deferred** — printable BoQ, post-MVP. |
| permissionset | 50060 | CONS Est - Edit | Estimating objects, RW (caption 'Construction Estimating - Edit'). Name ≤20 chars. |
| permissionset | 50061 | CONS Est - Read | Estimating objects, R (caption 'Construction Estimating - Read'). |
| entitlement | 50062 | CONS Est Ent | Maps Estimating permission set to license plan (deferred — needs service-plan GUID). |

> `CONS Admin` (Foundation) is extended to include `CONS Est - Edit`.

## Files

```
app/src/Estimating/
├── BoQStatus.Enum.al
├── BoQLineType.Enum.al
├── BoQHeader.Table.al          (triggers delegate to Logic())
├── BoQLine.Table.al            (triggers/validates delegate to Logic())
├── IBoQHeader.Interface.al
├── IBoQLine.Interface.al
├── BoQHeaderLogic.Codeunit.al  (default impl)
├── BoQLineLogic.Codeunit.al    (default impl)
├── BillOfQuantities.Page.al
├── BoQSubform.Page.al
├── BillOfQuantitiesList.Page.al
├── BoQCreateBudget.Codeunit.al
└── PermissionSet/
    ├── EstEdit.PermissionSet.al
    └── EstRead.PermissionSet.al
    (BoQ Mgt codeunit, print report, and entitlement deferred — see Objects table)
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Budget push | `CONS BoQ-Create Budget.Run(BoQHeader)` | Inserts Job Planning Lines (Line Type = Budget) per BoQ position; resolves Type/No or Cost-Type default G/L from `CONS Cost Type Setup`. |
| Cost-type defaults | `CONS Cost Type Setup` | Maps Cost Type → G/L account/work type for positions without a concrete BC No. |
| Number series | `Construction Setup.BoQ Nos.` | BoQ numbering. |
| License gate | `CONS License Mgt.IsModuleLicensed(Estimating)` | Page/codeunit entry checks. |

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Cost Type, Cost Type Setup, Setup, Project gate, license gate. |
| Base Application | Microsoft | Job, Job Task, **Job Planning Line** (Budget), Unit of Measure, No. Series, Resource/Item/G-L Account. |

## Known Limitations

- **Unit-rate** estimating only. A norm/assembly build-up engine (normativi) is a later add-on (PLAN §5).
- Budget push targets existing Project Tasks; auto-creating tasks from BoQ headings is a candidate enhancement.
- Confirm **Job Planning Line** required fields (Type, No., Line Type, Work Type, dimensions) against symbols before writing the push logic.
