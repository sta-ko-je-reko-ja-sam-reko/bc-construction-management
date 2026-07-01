# FEAT-SET-002 - Assisted Setup (guided onboarding)

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Foundation (Core/Setup) — see [MODULES.md](../../../MODULES.md).
> **Affected objects:** a feature-list hub registered on Microsoft's Assisted Setup list, a parameterized per-feature wizard, the Guided Setup orchestrator, a Demo Data builder, and the split of the feature-management facade for a single deferred restart.
> **Namespaces:** `Construction.Setup` (objects), `Construction.Core` (facade changes).
> **ID block:** 50015–50020.
> **Depends on:** the feature setup/toggle architecture (per-feature `Enabled` + application areas + `CONS Feature Mgt.`).

## Business Process

1. From **Tell Me → Assisted Setup** (or the role center) the user runs **Set up Construction Management**. It opens the **Setup Hub** — the features listed in setup order (Foundation → Estimating → Cost Control → Progress Billing → Subcontracts → Equipment → Scheduling) with a derived status (Completed when enabled / its number series exist).
2. The user clicks a feature → the **Feature Setup Wizard** opens (parameterized for that feature): an intro (with the "the session may restart at the end" note), then choices — **enable the feature**, **create & assign its number series**, **import demo data** — then Finish. Control returns to the hub.
3. Enabling a feature writes its setup `Enabled` and recomputes application areas **without restarting** (the wizard never restarts).
4. When the user **closes the hub**, if any feature's enabled-state changed during the visit, the session restarts **once** (5-second countdown), after which the enabled features' UI is live. The hub marks the assisted setup complete.

## Data Model

| Table | Key | Notes |
|---|---|---|
| CONS Setup Step | Step No. (Integer) | **`TableType = Temporary`** buffer — order, Module, Feature, Has Toggle, Name, Description, Setup Page ID, Enabled, Status. Populated per open; never persisted (no API page, no `tabledata` permission). |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| enum | 50015 | CONS Setup Step Status | Not Started / In Progress / Completed. |
| table | 50016 | CONS Setup Step | Temporary step buffer for the hub. |
| page | 50017 | CONS Setup Hub | `List` over the buffer; the **registered Assisted Setup object**; runs the wizard per row; fires the single deferred restart in `OnQueryClosePage`. |
| page | 50018 | CONS Feature Setup Wizard | `NavigatePage`, parameterized per feature (intro / options / done). |
| codeunit | 50019 | CONS Guided Setup | Registers the assisted setup; populates steps; runs the wizard; applies choices (enable, number series, demo data); marks complete. |
| codeunit | 50020 | CONS Demo Data | Idempotent demo dataset per module (demo customer/vendor/project + per-feature artifacts + MCP config). |

## Patterns used

- **Assisted-setup orchestration** — one assisted setup, feature-list hub, parameterized wizard, single deferred restart on hub close. The `CONS Feature Mgt.` facade is split into `RefreshExperienceAreas` (no restart) / `RestartSession` / `ApplyExperienceChange`; the hub compares an **enabled fingerprint** open-vs-close to decide the one restart. See `bc-customer-project-template/al-object-types/_patterns/assisted-setup-orchestration.md`.
- **Registration** from the install codeunit via `Guided Experience.InsertAssistedSetup` (group `DoMoreWithBC`), guarded by `Exists`.

## Tests

`test/CONS Feature Mgt Tests` — `SetEnabled`↔`IsEnabled` round-trip, `CheckEnabled` blocks API writes when off, and the enabled-fingerprint changes on toggle (the restart trigger).
