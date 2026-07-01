# Construction Management — Build Plan

Product: a **general/international construction** vertical for BC, built **on standard Projects (Jobs)**, to **AppSource standards** in the **PTE ID range (50000–99999)**. Selected concepts adapted from **Dynamics 365 Project Operations** — capability map researched in [docs/research/project-operations-vs-bc-projects.md](docs/research/project-operations-vs-bc-projects.md).

Shipped as **independently sellable modules**, each with its own permission set + entitlement + license gate — see [MODULES.md](MODULES.md). The feature areas below are grouped into those modules.

## 1. Architecture: build *on* Projects

Reuse and extend standard BC; the construction layer sits on top.

| BC Projects gives | Construction layers on top |
|---|---|
| Project (Job), Project Tasks (WBS), Planning Lines (Budget/Billable) | Hierarchical Cost Breakdown Structure + Bill of Quantities that *generate* planning lines |
| Resources + resource costs | Crews / labor rates / equipment & plant costing |
| Job Journals, Job Ledger Entries, WIP & recognition | Committed cost (open POs) + EAC/cost-to-complete on the same ledger |
| Project Quotes/Invoices, dimensions, posting | Progress billing / Application for Payment + retention as document layers |

**Gaps standard BC has even internationally (our differentiation):** estimating/BoQ, schedule-of-values progress billing, retention/retainage (AR *and* AP), subcontract progress claims with back-charges, change orders against contract value, committed-cost + cost-to-complete visibility.

## 2. Feature decomposition (→ FEAT-<AREA>-<NNN> folders), grouped by sellable module

| AREA | Module (tier) | Core scope |
|---|---|---|
| SET | **Foundation** (base) | Construction Setup, number series, posting/cost-type setup, Project (Job) extension, permission sets, dimensions wiring, license gate + telemetry plumbing |
| EST | **Estimating** (add-on) | Hierarchical BoQ, unit rates by cost type (labor/material/equipment/subcontract), markup, → push to Project budget |
| WBS | **Cost Control** (add-on) | Multi-level cost breakdown over Project Tasks; roll-up of budget/actual/committed |
| CST | **Cost Control** (add-on) | Committed cost (open POs), actual vs budget, EAC/ETC, % complete, earned value |
| BIL | **Progress Billing** (add-on) | Schedule of values, Application for Payment (measured qty or % complete), AIA-style certificate |
| RET | **Progress Billing** (add-on) | Withhold % on AR billing and AP subcontract claims; release schedule |
| SUB | **Subcontracts** (add-on) | Subcontract orders, subcontractor progress claims, back-charges, AP retention |
| CHG | **Subcontracts** (add-on) | Change orders / variations against contract value and budget with approval/status |
| EQP | **Equipment & Plant** (add-on) | Internal equipment usage, machine-hour rates, charge-out to projects |
| SCH | **Scheduling & Resource Planning** (premium) | Native lightweight task dates/durations/% complete, simple predecessors, read-only timeline |
| RES | **Scheduling & Resource Planning** (premium) | Crew & equipment **assignment list** on tasks — NOT a Gantt engine or Dataverse resource board (see research §4 / MODULES.md) |
| TEL | cross-cutting | App Insights signals, Feature Management toggles (lives in Foundation) |

## 3. Release roadmap (vertical slices)

- **Phase 0 — Product bootstrap.** Repo + config + **AL-Go for GitHub** pipeline (`.github/` + `.AL-Go/`) + test app + telemetry plumbing. *(this scaffold)*
- **Phase 1 — MVP / the differentiator.** `SET` + `EST` (BoQ) + `WBS` + `CST` (committed cost & EAC). Estimate → budget → real-time cost control. First listing.
- **Phase 2 — Get paid.** `BIL` (progress billing / schedule of values) + `RET` (retention).
- **Phase 3 — Supply side.** `SUB` (subcontract claims, back-charges, AP retention) + `CHG` (change orders).
- **Phase 4 — Depth.** `EQP` (Equipment & Plant module) + the **Scheduling & Resource Planning** premium module (`SCH` + `RES`) + dashboards/Power BI, refined earned-value reporting.

MVP critical path: **EST → WBS → CST**. MVP ships the **Foundation + Estimating + Cost Control** modules.

## 4. Per-feature loop

Each feature runs the greenfield loop: `intake → design → document → implement AL → test → deliver`. Design always starts by reading standard Projects via `.alpackages` symbols to extend the real tables (Job, Job Task, Job Planning Line, Job Ledger Entry).

## 5. Open decisions & risks

- **Project Operations parity** — ✅ RESOLVED (see [docs/research/project-operations-vs-bc-projects.md](docs/research/project-operations-vs-bc-projects.md)). MVP shape (`SET→EST→WBS→CST`) confirmed; PO informs *details inside* those features (cost-vs-sales estimating, transaction categories, budget-from-estimate, forecast/variance). The Project-for-the-web scheduling **engine** and the Dataverse universal resource board are NOT replicated; instead a **native lightweight** `SCH`+`RES` ships as the **Scheduling & Resource Planning premium module** (Phase 4) — an upsell, not dead scope. See [MODULES.md](MODULES.md).
- **Module packaging** — one app with per-module permission sets + entitlements + license gate (current); folders kept module-clean so any module can later split into its own extension/AppSource listing. See [MODULES.md](MODULES.md).
- **Estimating depth** — full norm/assembly engine vs simple unit-rate BoQ. Start with unit-rate BoQ (broad appeal); leave a norms engine as a later localization add-on.
- **Retention posting model** — trickiest AL: how withheld amounts post and release (deferred GL vs separate ledger). Design spike before Phase 2.
- **WBS vs Project Tasks** — extend Job Task hierarchy or add a parallel CBS table. Design spike in Phase 1.

## 6. Status

Phase 0 scaffolded. MVP feature docs being drafted under `app/docs/` (`FEAT-SET-001` first). No AL written yet — symbols must be downloaded and the build confirmed green first.
