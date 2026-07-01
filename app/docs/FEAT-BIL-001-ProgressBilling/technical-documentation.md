# FEAT-BIL-001 — Progress Billing (Schedule of Values / Application for Payment)

> Module: **Progress Billing** (add-on, license-gated). Phase 2. Builds on standard BC Projects
> billable planning lines + standard sales posting. Retention mechanics are designed in the sibling
> spike [../FEAT-RET-001-Retention/retention-posting-spike.md](../FEAT-RET-001-Retention/retention-posting-spike.md).

## 1. Problem

Standard BC bills a project either as a fixed sales document or by transferring billable planning lines
1:1. Construction owners require an **AIA-style Application for Payment**: a **Schedule of Values (SoV)**
(the contract sum broken into line items), and each period you certify **% complete / measured quantity
per line**, from which the period's billing, **retention**, and **net amount due** are computed and
presented on a certificate before invoicing.

## 2. Concept → BC mapping

| Construction concept | BC foundation | Construction layer (this feature) |
|---|---|---|
| Schedule of Values | Job Planning Lines (Billable) / BoQ positions / WBS tasks | `CONS Progress Billing Line` mirrors the SoV; seeded from billable planning lines or BoQ |
| Application for Payment (period) | — (gap) | `CONS Progress Billing Header` (Application No., period, status, retention %) |
| Work completed this period | `Qty. to Transfer to Invoice` on planning line | per-line this-period % / qty → drives `Qty. to Transfer to Invoice` |
| Certificate (G702/G703) | — (gap) | report over header + lines |
| Invoice + retention split | `Job Create-Invoice` → Sales Invoice → `Sales-Post` | standard invoice **plus** the retention G/L line (per RET spike Option D) |

## 3. Data model (sketch — IDs in the BIL block 50150–50199)

- **`CONS Progress Billing Header`** — `Project No.`, `Application No.` (sequential per project),
  `Period Start/End`, `Status` (Open / Certified / Invoiced), `Retention %` (defaults from setup),
  totals (FlowFields): Scheduled Value, Completed To Date, This Period, Retention This Period,
  Net Due This Period.
- **`CONS Progress Billing Line`** — `Project No.`, `Application No.`, `Line No.`, link to
  `Job Task No.` / `Job Planning Line No.` (or BoQ position), `Scheduled Value`, `Previous % / Amount`,
  `This Period % / Amount`, `Completed To Date % / Amount`, `Retention This Period`, `Stored Materials`.
- All amount/percent **calculation logic lives in a `CONS Progress Billing Line Logic` codeunit behind
  an interface** (polymorphic pattern); table triggers/field-OnValidate delegate one line each. The
  pure roll-up math (this-period = completed-to-date − previous, retention = this-period × %, net =
  this-period − retention) is **DB-free unit-testable** like the BoQ/forecast logic already shipped.

## 4. Flow

1. **Create application** for a project + period → seed SoV lines from billable Job Planning Lines
   (or carry forward the previous application's lines with their completed-to-date).
2. **Enter progress** per line (% complete or measured qty). Logic computes this-period, retention,
   net due. Idempotent recalculation; nothing posted yet.
3. **Certify** → status Certified; print the **certificate report**. Optional approval/Feature-Management
   gate.
4. **Invoice** → set each planning line's `Qty./Amount to Transfer to Invoice` for the period, run
   standard **`Job Create-Invoice`** to build the Sales Invoice, then **append the retention G/L line**
   (RET Option D) and post via standard `Sales-Post`. A `Sales-Post` subscriber writes the
   `CONS Retention Entry` ledger.
5. **Release retention** (RET feature) → generate a release application/invoice that reverses the held
   retention G/L line per the release schedule.

## 5. Permission set / entitlement (per MODULES.md)

- `CONS Bill - Edit` / `CONS Bill - Read` (caption *Construction Progress Billing*), entitlement
  `CONS Bill Ent`. Module entry points call `CONS License Mgt.CheckModuleLicensed(Module::"Progress Billing")`
  (add the enum value to `CONS Module`). Objects added only to this module's sets + composite `CONS Admin`.

## 6. Build order (after the retention-model decision)

1. RET posting setup fields + `CONS Retention Entry` table + `Sales-Post` subscriber (thin/delegating).
2. BIL header/line tables + line logic codeunit + interface (+ DB-free unit tests for the math).
3. Application pages + seed-from-planning-lines codeunit.
4. Invoice generation (`Job Create-Invoice` + retention line) + certificate report.
5. Retention release flow.
6. Permission sets + entitlement + license-gate + telemetry signals (certificate issued, retention released).

## 7. Dependencies & risks

- Depends only on **Foundation** (license gate, setup) + standard Projects — **not** on Estimating or
  Cost Control (à-la-carte rule). If a SoV line references a BoQ position, that linkage is optional and
  guarded so the module works without the Estimating module installed.
- Risk: tax treatment of the retention line across localisations — keep it a non-taxable balance
  reclassification (RET spike §3 Option D); verify VAT base stays on full revenue.
