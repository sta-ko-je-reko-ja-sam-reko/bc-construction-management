# FEAT-SUB-001 - Subcontracts

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Subcontracts (add-on, license-gated) — see [MODULES.md](../../../../MODULES.md).
> **Affected objects:** Subcontract document (header + lines), Subcontract Claim document (header + lines), Change Order document (header + lines), claim-to-invoice and retention-release codeunits, change-order approval workflow, Purchase Header/line table extensions, Subcontracts permission sets + entitlement.
> **Namespaces:** `Construction.Subcontracts`.
> **ID block:** 50250–50299 (objects), tests 50506–50507 and 50514–50515.
> **Depends on:** Foundation module (Construction Setup, Cost Type, Cost Type Setup, License Mgt., Feature Mgt., Project gate), Retention module (`CONS Retention Mgt`, `CONS Retention Entry`), standard BC Projects (Jobs) and Purchasing.

## Business Process

1. **Subcontract** — the project manager creates a **Subcontract** against a construction **Project** for a **subcontractor (vendor)**. The No. comes from `Construction Setup."Subcontract Nos."`. When the vendor is chosen, the **Retention %** defaults from `Construction Setup."Default Retention %"` (unless already entered). Scope is captured as **Subcontract Lines** (cost type, quantity, unit cost) — each line computes **Line Amount = Quantity × Unit Cost**, and the header rolls these up into the **Subcontract Value** FlowField.
2. **Subcontractor Claim** — for each period the subcontractor submits a progress claim. The PM creates a **Subcontract Claim** against the subcontract; the No. comes from `Construction Setup."Subcontract Claim Nos."` and a sequential **Claim No.** is assigned per subcontract. Choosing the subcontract copies **Project No.**, **Subcontractor No.**, and the **Retention %**. Each **Claim Line** records **Scheduled Value**, **Previous Amount**, and **This Period Amount**, and computes **Completed To Date**, **% Complete**, **Retention This Period** (= This Period × Retention %), and **Net Payable This Period** (= This Period − Retention). The header rolls these up.
3. **Certify and invoice** — once certified, **Create Purchase Invoice** (`CONS Subc Claim Invoice`) generates a draft purchase invoice: one cost line per claim line with a period amount (to the `Subcontract Cost Account`) plus a single negative **retention** line (to the `Retention Payable Acc.`). The header is stamped (`CONS Subc Claim No.`, `CONS Project No.`, `CONS Retention Amount`) so the purchase-post subscriber records the withheld payable retention entry on posting. The claim moves to **Invoiced**. The invoice is left unposted for the vendor invoice number to be entered.
4. **Change Order (variation)** — variations are captured as a **Change Order** (No. from `Construction Setup."Change Order Nos."`) of type **Owner** or **Subcontract**, with **Change Order Lines** (cost type, job task, amount; negative = omission). The header's **Total Amount** is the sum of the lines. The change order can be routed through the standard **approval workflow** (Pending Approval → Approved). On **Apply**: an *Owner* change adds the total to the project's `CONS Contract Value`; a *Subcontract* change appends variation lines to the named subcontract. Either way, line amounts with a job task and a cost-type default G/L account are pushed to the project budget as **Job Planning Lines (Budget)**, and the change order is set to **Approved**.
5. **Subcontractor Retention release** — when retention becomes due, **Release Retention** (`CONS Subc Retention Release`) creates a draft purchase invoice with a single positive retention G/L line (debit Retention Payable, credit AP) for the released amount. The release amount is validated against the **outstanding** payable retention for the project/subcontractor (`CONS Retention Mgt.OutstandingForAccount`); `ReleaseFullOutstanding` releases the entire held balance. The invoice is left unposted for review.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS Subcontract Header | No. (Code[20], PK) | Buy-from Vendor No. (defaults Retention % on validate); Project No. (Job, Open); Description; Status (enum); Retention %; Starting/Ending Date; Subcontract Value (FlowField = sum of line amounts); No. Series. Triggers/validate delegate to `Logic()`. |
| CONS Subcontract Line | Document No. (Code[20]), Line No. (Integer) | Job Task No.; Description; Cost Type (enum); Quantity; Unit Cost; **Line Amount** (= round(Qty × Unit Cost)). |
| CONS Subc Claim Header | No. (Code[20], PK) | Subcontract No. (copies project/vendor/retention on validate); Claim No. (sequential per subcontract); Project No.; Buy-from Vendor No.; Period Start/End; Posting Date; Status (enum); Retention %; This Period Amount / Retention This Period / Net Payable This Period (FlowFields); No. Series. |
| CONS Subc Claim Line | Document No. (Code[20]), Line No. (Integer) | Subcontract Line No.; Job Task No.; Description; Scheduled Value; Previous Amount; This Period Amount; **Completed To Date**; **% Complete**; Retention %; **Retention This Period**; **Net Payable This Period**. Amount fields recalc on validate. |
| CONS Change Order Header | No. (Code[20], PK) | Project No. (Job, Open); Change Type (Owner/Subcontract); Subcontract No.; Description; Reason; Document Date; Status (enum); **Total Amount** (FlowField = sum of line amounts); No. Series. `Apply()` delegates to `Logic()`. |
| CONS Change Order Line | Document No. (Code[20]), Line No. (Integer) | Project No. (FlowField lookup); Job Task No.; Description; Cost Type (enum); Amount (negative = omission). |
| CONS Subcontracts Setup | (singleton) | Module-specific setup (see `SubcontractsSetup.Table.al`). |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Purchase Header | CONS Subc Claim No. | Code[20] | Links a generated invoice back to its claim. |
| Purchase Header | CONS Project No. | Code[20] | Project the invoice/retention belongs to. |
| Purchase Header | CONS Retention Amount | Decimal | Retention withheld (claim invoice) or released (release invoice). |
| Purchase Header | CONS Retention Is Release | Boolean | Marks a retention-release invoice for the post subscriber. |
| Purch. Inv. Header / Purch. Inv. Entry Aggregate / Purch. Order Entry Buffer | (mirror of the above) | various | Carry the CONS retention fields through posting/aggregation (see `*.TableExt.al`). |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50250 | CONS Subcontract Status | Open / Released / Closed. |
| enum | 50251 | CONS Subc Claim Status | Open / Certified / Invoiced. |
| table | 50252 | CONS Subcontract Header | Subcontract document header. |
| table | 50254 | CONS Subc Claim Header | Subcontractor claim header. |
| table | 50255 | CONS Subc Claim Line | Subcontractor claim lines (period amounts, retention). |
| table | 50253 | CONS Subcontract Line | Subcontract scope lines. |
| codeunit | 50256 | CONS Subcontract Header Logic | Default impl of `CONS ISubcontractHeader` — no-series, cascade delete, **Validate_VendorNo** (retention default). |
| codeunit | 50257 | CONS Subcontract Line Logic | Default impl of `CONS ISubcontractLine` — **Validate_Amounts** (Line Amount). |
| codeunit | 50258 | CONS Subc Claim Hdr Logic | Default impl of `CONS ISubcClaimHdr` — no-series, sequential claim no., cascade delete, **Validate_SubcontractNo** (copy project/vendor/retention). |
| codeunit | 50259 | CONS Subc Claim Line Logic | Default impl of `CONS ISubcClaimLine` — **Trigger_OnInsert** (retention default) and **Validate_Amounts** (completed-to-date, % complete, retention, net payable). |
| codeunit | 50269 | CONS Subc Claim Invoice | Generates a draft purchase invoice from a certified claim (cost lines + retention line). |
| codeunit | 50270 | CONS Subc Retention Release | Creates a draft retention-release purchase invoice; validates against outstanding payable retention. |
| table | 50273 | CONS Change Order Header | Change order (variation) header; `Apply()` releases the variation. |
| table | 50274 | CONS Change Order Line | Change order lines (amount per job task / cost type). |
| codeunit | 50275 | CONS Change Order Hdr Logic | Default impl of `CONS IChangeOrderHeader` — no-series, cascade delete, **Apply** (contract value / subcontract variation + budget push). |
| codeunit | 50281 | CONS Change Order Approval | Send for approval / cancel / workflow-enabled checks + approval-entry subscribers. |
| codeunit | (workflow) | CONS Change Order Workflow / CONS Change Order Wf Demo | Workflow event registration and demo setup. |
| enum | 50271 | CONS Change Order Status | Open / Approved / Pending Approval / Rejected / Cancelled. |
| enum | 50272 | CONS Change Order Type | Owner / Subcontract. |
| interface | — | CONS ISubcontractHeader / ISubcontractLine / ISubcClaimHdr / ISubcClaimLine / IChangeOrderHeader | Polymorphic trigger/validate contracts (no object ID). |
| page | — | Subcontract / Subcontract List / Subform, Subc Claim / List / Subform, Change Order / List / Subform, Subcontracts Setup, plus API pages | UI and API surface. |
| table | — | CONS Subcontracts Setup | Module setup singleton. |
| permissionset | — | CONS Subc - Edit / CONS Subc - Read / CONS Subc License | Module permission sets (RW / R / license). |
| entitlement | — | CONS Subc Ent | Maps Subcontracts permission set to license plan. |

## Tests

| Test codeunit | ID | Covers |
|---|---|---|
| CONS Subcontract Line Tests | 50506 | `CONS Subcontract Line Logic.Validate_Amounts` — Line Amount = Quantity × Unit Cost. |
| CONS Subc Claim Line Tests | 50507 | `CONS Subc Claim Line Logic.Validate_Amounts` — completed-to-date, % complete, retention, net payable (5% retention happy path). |
| CONS Change Order Tests | 50514 | `CONS Change Order Hdr Logic.Apply` guard paths — blank Project No. (TestField) and already-Approved (`AlreadyAppliedErr`), both before any database access. |
| CONS Subcontract Header Tests | 50515 | `CONS Subcontract Header Logic.Validate_VendorNo` (vendor-unchanged and retention-already-set early-exit paths); `CONS Subc Claim Hdr Logic.Validate_SubcontractNo` (subcontract-unchanged and blank early-exit paths); `CONS Subc Claim Line Logic.Trigger_OnInsert` (retention-already-set early-exit); `CONS Subc Claim Line Logic.Validate_Amounts` edge cases (zero scheduled value → % complete = 0; 0% retention → net = period). |

> All tests are pure / DB-free: they call the public `Logic` codeunit methods directly with in-memory records, matching the existing `Assert`-based convention (no AL Test Toolkit dependency).

### Deliberately not unit-tested (require heavy database/posting setup)

- **`CONS Change Order Hdr Logic.Apply`** happy paths (Owner → `Job."CONS Contract Value"`; Subcontract → variation lines; budget push to **Job Planning Lines**) — depend on Jobs, Job Tasks, Cost Type Setup G/L accounts, the **Total Amount** FlowField (`CalcFields`), and DB writes.
- **`CONS Subc Claim Invoice.CreateInvoice`** and **`CONS Subc Retention Release.CreateReleaseInvoice` / `ReleaseFullOutstanding`** — require Construction Setup G/L accounts, a licensed module (`CONS License Mgt.CheckModuleLicensed`), `CONS Retention Mgt.OutstandingForAccount` (retention ledger), vendor/Purchase Header/line creation, and `Message` UI — integration-test territory.
- **No-series triggers** (`Trigger_OnInsert` on subcontract/claim/change-order headers) — require `Construction Setup` and `No. Series` records.
- **`Validate_VendorNo` / `Validate_SubcontractNo` default (copy) paths** — call `ConstructionSetup.Get()` / `SubcontractHeader.Get()`; only the early-exit branches are unit-tested.
- **`CONS Change Order Approval`** send/cancel and the approval-entry subscribers — depend on the standard Workflow/Approvals engine and Feature Management.

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Construction Setup (no-series, retention default, G/L accounts), Cost Type / Cost Type Setup, License Mgt., Feature Mgt., Project gate. |
| Retention (this app) | internal | `CONS Retention Mgt.CalcRetention` / `OutstandingForAccount`, `CONS Retention Entry`, `CONS Retention Direction`. |
| Base Application | Microsoft | Job (Contract Value), Job Task, **Job Planning Line** (Budget), Purchase Header/Line, Vendor, No. Series, Workflow / Approvals Mgmt. |

## Known Limitations

- Subcontract and claim line amounts are unit-rate; no schedule-of-rates remeasurement engine.
- Generated purchase invoices are left **unposted** by design (vendor invoice no. + review before posting) — the retention ledger entry is recorded by the purchase-post subscriber, not at invoice creation.
- Change-order budget push targets existing **Job Planning Lines / tasks** and a cost-type default G/L account; lines without a job task or without a cost-type G/L default are skipped.
