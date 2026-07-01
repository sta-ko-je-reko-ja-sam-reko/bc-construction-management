# FEAT-SET-001 - Construction Setup & Foundation

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Foundation (base, required) — see [MODULES.md](../../../../MODULES.md). Ships the license gate, the composite admin permission set, and the shared cost-type model every other module reuses.
> **Affected objects:** Construction Setup (singleton) + Cost Type model, Project (Job) extension, license-gate + install codeunits, Foundation permission sets + entitlement.
> **Namespaces:** default.
> **Proposed ID block:** 50000–50019 (confirm free at implementation; `implement-bc-object` allocates real IDs).

## Business Process

1. After install, the **install codeunit** seeds an empty **Construction Setup** record and default **Cost Types**, and emits a telemetry "installed" signal.
2. The administrator opens **Construction Setup** and assigns **number series** for the documents later modules introduce (Bill of Quantities, Progress Certificate, Subcontract).
3. The administrator reviews the **Cost Type** classification (Labor / Material / Equipment / Subcontract / Other) and, per cost type, an optional **default G/L account** and **work type** used when the Estimating module pushes a Bill of Quantities to the project budget.
4. On a **Project** (Job) card, the user turns on **Construction Project** to enable construction features for that project; construction UI is hidden on non-construction projects.
5. Access is granted via the module permission sets; premium modules additionally check the **license gate**.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS Construction Setup | Primary Key (Code[10], singleton) | BoQ Nos., Progress Cert. Nos., Subcontract Nos. (Code[20] number series); Default Cost Type (enum). Standard BC setup-table pattern (GetRecordOnce). |
| CONS Cost Type Setup | Cost Type (enum, PK) | Default G/L Account No., Default Work Type Code per cost type — consumed by Estimating's budget push. |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Job (Project) | CONS Construction Project | Boolean | Gates construction UI/logic for the project. |
| Job (Project) | CONS Default Cost Type | Enum CONS Cost Type | Default classification for the project's estimate/budget lines. |
| Job (Project) | CONS Contract Value | Decimal | Informational in MVP; maintained by Change Orders (CHG) later. |

> Read the standard **Job** table from `.alpackages` symbols before adding fields — confirm field names (the "Jobs → Projects" rename is largely caption-level; the table is still `Job`). Do not assume.

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50000 | CONS Cost Type | Labor / Material / Equipment / Subcontract / Other (Extensible). |
| table | 50001 | CONS Construction Setup | Singleton setup. |
| table | 50002 | CONS Cost Type Setup | Per-cost-type default G/L account + work type. |
| page | 50003 | CONS Construction Setup | Setup card. |
| page | 50004 | CONS Cost Type Setup | List (from setup). |
| tableextension | 50005 | CONS Job | Construction fields on Job. |
| pageextension | 50006 | CONS Project Card | Surface construction fields/actions; visibility tied to Construction Project. |
| pageextension | 50007 | CONS Project List | Construction Project column/filter. |
| codeunit | 50008 | CONS License Mgt. | License gate — `IsModuleLicensed(Module: Enum "CONS Module")`; MVP returns true. Premium modules call this. |
| codeunit | 50009 | CONS Install | Install: seed setup + cost type rows. |
| enum | 50014 | CONS Module | Module identifier for the license gate (Foundation/Estimating/Cost Control/…). |
| permissionset | 50010 | CONS Found - Edit | Foundation objects, RIMD (caption 'Construction Foundation - Edit'). Name ≤20 chars. |
| permissionset | 50011 | CONS Found - Read | Foundation objects, R (caption 'Construction Foundation - Read'). |
| permissionset | 50012 | CONS Admin | Composite (caption 'Construction Management - Admin'); `IncludedPermissionSets` grows as modules are added. |
| ~~entitlement~~ | 50013 | ~~CONS Construction Found.~~ | **Deferred** — a real AppSource service-plan GUID is required; not fabricated. Added with the commercial model. |

## Files

```
app/src/
├── Setup/
│   ├── CostType.Enum.al
│   ├── ConstructionSetup.Table.al
│   ├── ConstructionSetup.Page.al
│   ├── CostTypeSetup.Table.al
│   └── CostTypeSetup.Page.al
├── Core/
│   ├── Module.Enum.al
│   ├── Job.TableExt.al
│   ├── ProjectCard.PageExt.al
│   ├── ProjectList.PageExt.al
│   ├── LicenseMgt.Codeunit.al
│   └── Install.Codeunit.al
└── PermissionSet/
    ├── FoundEdit.PermissionSet.al
    ├── FoundRead.PermissionSet.al
    └── Admin.PermissionSet.al
    (entitlement deferred — see Objects table)
```
> File names follow the convention: object name minus affix, spaces/special chars stripped (LinterCop LC0015). E.g. `permissionset "CONS Admin"` → `Admin.PermissionSet.al`, `tableextension "CONS Job"` → `Job.TableExt.al`.

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Setup access | `CONS Construction Setup`.GetRecordOnce | Other modules read number series + defaults. |
| Project gate | `Job.CONS Construction Project` | Modules check this before showing construction UI. |
| Cost-type defaults | `CONS Cost Type Setup` | Estimating budget push resolves a G/L account/work type per cost type. |
| License gate | `CONS License Mgt.IsModuleLicensed()` | Premium modules gate entry points. |
| Install/upgrade | `OnInstallAppPerCompany` / `OnUpgradePerCompany` | Seed setup + cost types; data-upgrade safety. |

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Job/Project, No. Series, setup patterns, Feature Management. |
| System Application | Microsoft | Telemetry (`Session.LogMessage`), Feature Management. |

## Known Limitations

- License gate is a stub in MVP (returns licensed); real entitlement/subscription check added when the commercial model is finalized.
- Number-series targets for Progress Certificate/Subcontract are placeholders until those modules are built.
- No data seeded beyond setup defaults; the demo Configuration Package ships separately.
