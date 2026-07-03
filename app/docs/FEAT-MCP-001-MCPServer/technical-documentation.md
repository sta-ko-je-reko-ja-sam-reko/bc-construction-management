# FEAT-MCP-001 - API Surface & MCP Server

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Cross-cutting (spans all modules) — see [MODULES.md](../../../../MODULES.md).
> **Affected objects:** the `*API.Page.al` pages across every module + `CONS MCP Config Demo` codeunit (50300).
> **Namespaces:** `Construction.MCP` (codeunit); each API page lives in its module namespace.
> **Proposed ID block:** API pages are interleaved with their owning feature blocks; MCP codeunit at 50300.
> **Depends on:** the tables/documents each API page projects; platform module `System.MCP` (`MCP Config` codeunit) shipped in BC 26+.

## Business Process

1. **Every new construction table gets an API page.** Each document/master/sub-ledger table added by the product is projected through a `PageType = API` page under one logical apiGroup, so the whole vertical is reachable as a coherent OData v4 / REST surface: `APIPublisher = 'dmom'`, `APIGroup = 'construction'`, `APIVersion = 'v1.0'`.
2. **Document and master entities are read/create/modify.** BoQ, Progress Billing, Subcontracts, Change Orders, Equipment and Scheduling entities are backed by product tables and are writable (create + modify).
3. **Sub-ledgers and standard-entity mirrors are read-only.** The Retention sub-ledger and the Cost Type Setup master are exposed read-only; the Sales/Purchase document APIs mirror standard BC document buffers/aggregates (`InsertAllowed = ModifyAllowed = DeleteAllowed = false`) so agents can read project-linked orders and invoices without mutating posted/standard documents.
4. **The MCP Config Demo codeunit builds a ready-to-attach MCP server configuration.** `CONS MCP Config Demo` (codeunit 50300) uses the platform `MCP Config` codeunit to create an MCP server configuration named **"Construction"** that exposes these API pages as **agent tools** — each page becomes one tool, with per-tool read / create / modify permissions matching the writable-vs-read-only intent above. The admin runs it once per environment (directly or via the assisted-setup demo-data option), activates it, and attaches it to an MCP host (GitHub Copilot, Copilot Studio, VS Code).

## API Pages

All pages: `PageType = API`, `APIPublisher = 'dmom'`, `APIGroup = 'construction'`, `APIVersion = 'v1.0'`. "Access" is the intent wired into the MCP configuration by codeunit 50300 (read-only = read tool only; writable = read + create + modify).

| Object ID | Page name | Entity set | Source table | Access |
|---|---|---|---|---|
| 50295 | CONS Project API | `projects` | Job | Writable |
| 50296 | CONS Project Task API | `projectTasks` | Job Task | Writable |
| 50283 | CONS BoQ API | `billsOfQuantities` | CONS BoQ Header | Writable |
| 50284 | CONS BoQ Line API | `billOfQuantitiesLines` | CONS BoQ Line | Writable |
| 50285 | CONS Progress Billing API | `progressBillings` | CONS Progress Billing Header | Writable |
| 50286 | CONS Progress Billing Line API | `progressBillingLines` | CONS Progress Billing Line | Writable |
| 50287 | CONS Retention Entry API | `retentionEntries` | CONS Retention Entry | Read-only |
| 50341 | CONS Sales Invoice API | `salesInvoices` | Sales Invoice Entity Aggregate | Read-only |
| 50343 | CONS Sales Order API | `salesOrders` | Sales Order Entity Buffer | Read-only |
| 50345 | CONS Purchase Invoice API | `purchaseInvoices` | Purch. Inv. Entity Aggregate | Read-only |
| 50347 | CONS Purchase Order API | `purchaseOrders` | Purchase Order Entity Buffer | Read-only |
| 50288 | CONS Subcontract API | `subcontracts` | CONS Subcontract Header | Writable |
| 50289 | CONS Subcontract Line API | `subcontractLines` | CONS Subcontract Line | Writable |
| 50290 | CONS Subc Claim API | `subcontractClaims` | CONS Subc Claim Header | Writable |
| 50291 | CONS Subc Claim Line API | `subcontractClaimLines` | CONS Subc Claim Line | Writable |
| 50292 | CONS Change Order API | `changeOrders` | CONS Change Order Header | Writable |
| 50293 | CONS Change Order Line API | `changeOrderLines` | CONS Change Order Line | Writable |
| 50440 | CONS Equipment API | `equipmentItems` | CONS Equipment | Writable |
| 50441 | CONS Equipment Rate API | `equipmentRates` | CONS Equipment Rate | Writable |
| 50442 | CONS Equipment Usage API | `equipmentUsageEntries` | CONS Equipment Usage | Writable |
| 50443 | CONS Equipment Maint. API | `equipmentMaintenanceEntries` | CONS Equipment Maintenance | Writable |
| 50444 | CONS Equipment Meter API | `equipmentMeterEntries` | CONS Equipment Meter Entry | Writable |
| 50445 | CONS Equipment Assign. API | `equipmentAssignments` | CONS Equipment Assignment | Writable |
| 50475 | CONS Task Schedule API | `taskSchedules` | Job Task | Writable |
| 50476 | CONS Task Dependency API | `taskDependencies` | CONS Task Dependency | Writable |
| 50477 | CONS Resource Assignment API | `resourceAssignments` | CONS Resource Assignment | Writable |
| 50294 | CONS Cost Type Setup API | `costTypeSetups` | CONS Cost Type Setup | Read-only |

> **Note — 27 pages, 27 tools:** codeunit 50300 wires **all 27** API pages as tools (21 writable, 6 read-only). `CONS Task Schedule API` (50475) and `CONS Project Task API` are both `Job Task` projections — the former exposes the scheduling fields (planned dates, % complete), the latter the WBS/cost view; both are registered as writable tools.

## The MCP Config Demo codeunit

`app/src/MCP/MCPConfigDemo.Codeunit.al` — codeunit **50300 "CONS MCP Config Demo"** (`Access = Public`).

- **`CreateConstructionMCPConfig(): Text[100]`** — the single public entry point. It:
  1. Calls `MCP Config.CreateConfiguration('Construction', <description>)` to create the server configuration and captures its `Guid`.
  2. Calls `MCP Config.AllowCreateUpdateDeleteTools(ConfigId, true)` to permit write-capable tools on the configuration.
  3. Adds one tool per API page via two local helpers:
     - `AddWritableTool` → `CreateAPITool` then `AllowRead` + `AllowCreate` + `AllowModify` (read/create/modify).
     - `AddReadOnlyTool` → `CreateAPITool` then `AllowRead` only.
  4. Calls `MCP Config.ActivateConfiguration(ConfigId, true)` and returns the configuration name `'Construction'`.
- **Not called anywhere yet** by design — the product's assisted setup offers to run it (demo-data option). It is meant to be run **once per environment**; re-running would create a second "Construction" configuration.
- **Description label** (shown in the MCP host): *"Construction Management tools for AI clients — estimating, cost control, progress billing, retention, subcontracts, change orders, equipment & plant, and scheduling & resource planning."*
- Read-only tools: `CONS Retention Entry API`, `CONS Sales Invoice API`, `CONS Sales Order API`, `CONS Purchase Order API`, `CONS Purchase Invoice API`, `CONS Cost Type Setup API`. All other wired pages are writable.

## Demo-data import APIs (per-feature, own groups)

Separate from the functional `construction` group above, each feature ships a **demo-import API page** whose bound `[ServiceEnabled] importDemoData` action seeds that feature's CRONUS-style sample data on the shared `CONS-DEMO` project. Each lives in its **own dedicated API group** (`demo<Feature>`, never `construction`) binding to the shared dummy source table **`CONS Demo Data` (50030)** — the action is the deliverable, the rows are incidental. All: `APIPublisher = 'dmom'`, `APIVersion = 'v1.0'`.

| Object ID | Page name | API group / entity set | Seeder codeunit |
|---|---|---|---|
| 50040 | CONS Demo Foundation API | `demoFoundation` | CONS Demo Foundation (50031) |
| 50041 | CONS Demo Estimating API | `demoEstimating` | CONS Demo Estimating (50032) |
| 50042 | CONS Demo Cost Control API | `demoCostControl` | CONS Demo Cost Control (50033) |
| 50043 | CONS Demo Prog. Billing API | `demoProgressBilling` | CONS Demo Progress Billing (50034) |
| 50044 | CONS Demo Subcontracts API | `demoSubcontracts` | CONS Demo Subcontracts (50035) |
| 50045 | CONS Demo Equipment API | `demoEquipment` | CONS Demo Equipment (50036) |
| 50046 | CONS Demo Scheduling API | `demoScheduling` | CONS Demo Scheduling (50037) |

- **`CONS MCP Demo Config` (50038)** — builds **one MCP configuration per importer** (exposing only that feature's demo page), kept separate from `CONS MCP Config Demo` so an agent can be scoped to seed a single feature. Called once (guarded) from `CONS Demo Foundation.Import()`.
- **Two reach paths, one idempotent seeder** — the assisted-setup wizard (`GuidedSetup` → each `Import()`) and the `importDemoData` API action both call the same `Import()`. Seeders are **message-free** and use **fixed keys** (no number series), so they run cleanly from the agent/API path.
- **Permissions** — all demo objects are in the shared **`CONS Demo` set (50027)**, included in `CONS Admin`.

## Tests

Documentation-verified, **not unit-tested**, by design:

- The API pages are declarative page projections and the MCP builder is a thin orchestration over the platform `MCP Config` codeunit (create configuration → create tools → set per-tool permissions → activate). There is no calculation, posting, or business logic to assert, and `MCP Config` is Microsoft platform code — so there is no meaningful in-process unit test to write.
- Correctness here is *structural*: the object IDs, names, entity sets, apiGroup/publisher/version, and the writable-vs-read-only mapping. These are verified against the source (this document is derived directly from the `*API.Page.al` headers and codeunit 50300) and are guarded by the compiler and CodeCop at build time.
- End-to-end behavior (a tool actually created and callable) is validated by running the assisted-setup option in a sandbox and attaching the "Construction" configuration to an MCP host, per [getting-started-english.md](getting-started-english.md).
