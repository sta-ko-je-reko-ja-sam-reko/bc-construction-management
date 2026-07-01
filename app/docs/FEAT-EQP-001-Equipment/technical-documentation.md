# FEAT-EQP-001 - Equipment & Plant

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Equipment & Plant (add-on, license-gated) — see [MODULES.md](../../../../MODULES.md).
> **Affected objects:** Equipment register (master + rates), usage worksheet + posting codeunit, meter & maintenance logs, Equipment setup, pages/APIs, Equipment permission sets + entitlement.
> **Namespaces:** `Construction.Equipment`.
> **ID block:** tables 50410–50414, codeunits 50430–50433, enums 50400–50403, interfaces (no ID), pages/APIs and permission sets in the Equipment range.
> **Depends on:** Foundation module (`CONS Feature Mgt.`, `CONS License Mgt.`), standard BC Projects (Job / Job Task), Resource, Job Journal posting.

## Business Process

1. The plant manager **registers equipment** (machines, vehicles, tools) in the Equipment register. The No. comes from `Equipment Setup.Equipment Nos.` Each equipment is linked to a standard **Resource** (`Resource No.`), which is how cost and usage post into the project ledger.
2. Each equipment carries a default **Cost Rate** and **Hire Rate** per its **Rate Unit of Measure**, plus ownership (Owned/Hired), location, meter reading and service schedule.
3. Optionally, **Equipment Rates** override the default cost/hire rate per project and per starting date. Rate selection prefers an exact project match (latest starting date on or before the usage date), then falls back to a blank-project rate, then to zero (caller uses the equipment default cost rate).
4. Usage is recorded on the **Equipment Usage** worksheet. Selecting an equipment defaults its unit of measure and resolves the unit cost (project rate → equipment default). Quantity × unit cost gives the line **Total Cost** (rounded).
5. **Posting** an equipment usage line builds a standard **Job Journal Line** (Type Resource, the equipment's linked resource) and posts it to the project via `Job Jnl.-Post Line`. Posting is blocked while the equipment is in maintenance. The usage line is deleted after a successful post. Posting checks the Feature key and module license.
6. **Meter entries** record operating hours/kilometres; inserting an entry updates the equipment's current meter reading.
7. **Maintenance records** log service/repair/inspection events; inserting one stamps the equipment's last service date and (when provided) next service date, next service meter and meter reading.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS Equipment | No. (Code[20], PK) | Description / Description 2; Equipment Type, Status, Ownership (enums); Resource No.; Location Code; Serial No.; Manufacturer; Model; Cost Rate; Hire Rate; Rate Unit of Measure; Vendor No.; On-Hire / Off-Hire Date; Meter Reading; Meter Unit; Last/Next Service Date; Next Service Meter; In Maintenance; Blocked; No. Series. |
| CONS Equipment Rate | Equipment No., Project No., Starting Date (PK) | Unit of Measure Code; Unit Cost; Hire Rate. Blank Project No. = applies to all projects. Provides `FindUnitCost` / `FindHireRate`. |
| CONS Equipment Usage | Line No. (Integer, PK) | Equipment No.; Project No. (open Jobs); Job Task No.; Posting Date; Description; Quantity; Unit of Measure Code; Unit Cost; Total Cost (qty × unit cost). |
| CONS Equipment Maintenance | Entry No. (Integer, AutoIncrement, PK) | Equipment No. (secondary key); Maintenance Date; Maintenance Type (enum); Description; Meter Reading; Cost; Vendor No.; Next Service Date; Next Service Meter. |
| CONS Equipment Meter Entry | Entry No. (Integer, AutoIncrement, PK) | Equipment No. (secondary key); Reading Date; Meter Reading; Description. |
| CONS Equipment Setup | (setup, singleton) | Equipment Nos. (number series). |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| (none) | | | Equipment links to standard Resource / Job / Job Task by reference; no new fields on standard tables. |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50400 | CONS Equipment Status | Available / In Use / In Maintenance / Off Hire / Blocked. |
| enum | 50401 | CONS Equipment Ownership | Owned / Hired. |
| enum | 50402 | CONS Equipment Type | Machine / Vehicle / Tool / Other. |
| enum | 50403 | CONS Maintenance Type | Service / Repair / Inspection / Other. |
| table | 50410 | CONS Equipment | Equipment register (master). |
| table | 50411 | CONS Equipment Rate | Project/date-dependent cost & hire rates; `FindUnitCost` / `FindHireRate`. |
| table | 50412 | CONS Equipment Usage | Usage worksheet line; delegates triggers/validates to logic. |
| table | 50413 | CONS Equipment Maintenance | Maintenance log; delegates insert to logic. |
| table | 50414 | CONS Equipment Meter Entry | Meter reading log; delegates insert to logic. |
| codeunit | 50430 | CONS Equipment Usage-Post | `PostUsage` / `PostBatch` — posts usage to the project as a Job Journal resource line. |
| codeunit | 50431 | CONS Equipment Usage Logic | Default impl of `CONS IEquipmentUsage` — line-no. assignment, equipment/quantity/unit-cost validation, total-cost recalculation. |
| codeunit | 50432 | CONS Equipment Maint. Logic | Default impl of `CONS IEquipmentMaintenance` — stamps equipment service/meter fields on maintenance insert. |
| codeunit | 50433 | CONS Equipment Meter Logic | Default impl of `CONS IEquipmentMeter` — updates equipment meter reading on meter entry insert. |
| interface | — | CONS IEquipmentUsage | Usage trigger/validate logic contract (no object ID). |
| interface | — | CONS IEquipmentMaintenance | Maintenance trigger logic contract (no object ID). |
| interface | — | CONS IEquipmentMeter | Meter trigger logic contract (no object ID). |
| table | — | CONS Equipment Setup | Equipment number series setup. |
| page | — | CONS Equipment Card / List / Setup | Equipment master UI. |
| page | — | CONS Equipment Rates / Usage / Maintenance / Meter Entries / Assignments | Subsidiary list pages. |
| page (API) | — | CONS Equipment / Rate / Usage / Maint / Meter / Assign APIs | API pages for integration. |
| permissionset | — | CONS Equip - Edit / CONS Equip - Read | Equipment objects RW / R. |
| entitlement | — | CONS Equip Ent | Maps Equipment permission set to license plan. |

> `CONS Admin` (Foundation) is extended to include the Equipment edit permission set.

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Usage posting | `CONS Equipment Usage-Post.PostUsage(EquipmentUsage)` / `.PostBatch()` | Builds and posts a standard Job Journal Line (Type Resource) via `Job Jnl.-Post Line`; deletes the usage line on success. |
| Rate resolution | `CONS Equipment Rate.FindUnitCost(EquipmentNo, ProjectNo, OnDate)` / `.FindHireRate(...)` | Resolves project/date-applicable rates with blank-project fallback; called from usage logic. |
| Feature gate | `CONS Feature Mgt.CheckEnabled(Enum::"CONS Feature"::Equipment)` | Posting entry check. |
| License gate | `CONS License Mgt.CheckModuleLicensed(Enum::"CONS Module"::"Equipment & Plant")` | Posting entry check. |
| Number series | `Equipment Setup.Equipment Nos.` | Equipment numbering on insert. |

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Feature Mgt., License Mgt. gates, `CONS Feature` / `CONS Module` enums. |
| Base Application | Microsoft | Job, Job Task, **Job Journal Line**, `Job Jnl.-Post Line`, Resource, Unit of Measure, No. Series, Location, Vendor. |

## Tests

Automated tests live in **`test/src/EquipmentTests.Codeunit.al`** — `codeunit 50510 "CONS Equipment Tests"`. Coverage: usage total-cost calculation and rounding, blank-equipment clearing, usage line-no. assignment, equipment-rate selection (`FindUnitCost` / `FindHireRate`: project-vs-blank precedence, latest-starting-date, future-date exclusion, no-rate-returns-zero), meter-reading update on meter-entry insert, and equipment service/meter stamping on maintenance insert.

## Known Limitations

- **Posting** (`PostUsage` / `PostBatch`) is exercised end-to-end only manually; it is not covered by automated tests because it requires a posted project, a linked resource, dimensions, and feature/license setup — out of scope for unit-level assertions.
- `Validate_EquipmentNo` is tested only on its blank-equipment branch; the populated branch performs `Equipment.Get` + rate lookup and belongs to an integration test with a seeded equipment master.
- Equipment **Status** is maintained externally (not auto-computed by the logic codeunits read for this feature); status transitions are not part of the calculable logic tested here.
