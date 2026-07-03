# Construction Management — BC AL Extension (Greenfield ISV)

A from-scratch Microsoft Dynamics 365 Business Central AL extension: a **Construction Management** vertical built **on top of standard BC Projects (Jobs)**. This is an **ISV product** built to **AppSource standards** but shipped in the **PTE object ID range (50000–99999)**. Not a Navision/NAV port.

## Methodology this project follows

This project uses the **bc-greenfield-template** methodology (in `../bc-greenfield-template/`) plus the shared conventions and AL object-type guides in **bc-customer-project-template** (`../bc-customer-project-template/`):

- **Feature workflow** — `intake → design → document → implement AL → import data (optional) → test → deliver`. One `app/docs/FEAT-<MARK>-<Title>/` folder per feature. See `../bc-greenfield-template/instructions/02-feature-workflow.md`.
- **AL authoring** — the per-object-type guides + metamodel live in `../bc-customer-project-template/al-object-types/`. The single canonical AL reference.
- **Ruleset** — `app/ruleset.json` is copied from `../bc-customer-project-template/ruleset.json` (self-contained build). Re-sync if the base template changes. Escalated-to-Error: AA0008, AA0073, AA0137, AA0139, AA0217, AA0233, AL0606. Zero-error builds.
- **Definition of done** — `../bc-greenfield-template/checklists/feature-ready.md`.

## Project-specific values

| What | Value |
|---|---|
| Affix / prefix | `CONS` |
| Object ID range | `50000–99999` (PTE) |
| BC version target | `28.2.0.0` (platform `28.0.0.0`, runtime `17.0`) — confirmed: dev container `bcconstr28` builds BC 28.2 |
| Foundation | Standard BC **Projects (Jobs)** — extend, don't reinvent |
| Primary language | English (international); Serbian getting-started optional |
| Publisher | `dmom` — set in `app/app.json` + `test/app.json` (2026-07-03) |

## Cross-session context

Portable project context (decisions, gotchas, "why we did X") lives in **[app/docs/PROJECT-NOTES.md](app/docs/PROJECT-NOTES.md)** — a checked-in substitute for Claude's local memory, which is machine-specific and never synced via git. Read it at the start of work and append durable cross-session facts there.

## Working a feature

1. `plan-feature {MARK} {Title}` — scaffold `app/docs/{MARK}-{Suffix}/`, draft `technical-documentation.md`.
2. `implement-bc-object` — write AL per the shared object-type guides; **extend standard objects, never edit base**.
3. Tests (`test/`) + getting-started docs + version bump.
4. Gate: `feature-ready`.

## Hard rules

- **Extend, never edit base** — tableextension/pageextension/enumextension + event subscribers.
- **Build on BC Projects & its models** — Job/Job Task/Job Planning Line/Job Ledger Entry; dimensions via Dimension Set, posting via standard routines, prices via Price List. Read standard objects from `.alpackages` symbols — don't assume field/event names.
- **Mandatory affix `CONS`** on every new object and every new field on a standard table.
- **Object IDs** inside 50000–99999. **Zero CodeCop errors** on build.
- **No legacy port** — no NAV baselines, no `nav2bc-object-mapping.md`.
- **Test + document each segment as you build it** — every segment with behavior gets an automated `[Test]` in `test/` in the same pass, and the feature's `app/docs/FEAT-*/technical-documentation.md` + getting-started are updated to match. Don't batch tests or docs to the end. See `../bc-greenfield-template/instructions/02-feature-workflow.md`.

## Modular / sellable architecture

The product ships as **independently sellable modules** — see [MODULES.md](MODULES.md). When authoring:

- Place objects under `app/src/<Module>/…` so module boundaries stay clean (future extension split).
- Every module has its **own permission set(s)** — compact names **≤20 chars** (`CONS <ShortCode> - Edit`/`- Read`, full descriptive name in `Caption`) — and its **own `entitlement`**; add an object **only** to its module's set (+ the composite `CONS Admin`).
- **Premium** module entry points must check `CONS License Mgt.` (license gate) and sit behind a Feature Management key.
- A module never hard-depends on another add-on; cross-module integration goes through the **Foundation** module + event subscribers (so customers can buy modules à la carte).

## ISV / AppSource discipline (the product layer beyond the greenfield template)

Even though we ship in the PTE range, architect to AppSource standards so the listing path stays open:

- **Upgrade-safe** — once data ships, never break tenant data: use `ObsoleteState`/`ObsoleteReason`/`ObsoleteTag` and data-upgrade codeunits; never delete/repurpose live fields.
- **Telemetry** — emit partner Application Insights signals on key transactions (estimate→budget, progress certificate, retention release).
- **Feature Management** — gate not-yet-GA modules behind feature keys so a release is always installable.
- **Sample data** — ship a Configuration Package (RapidStart) demo construction company for trials/reviewers.
- **Tests** — `test/` app targets meaningful coverage on calculation/posting logic (cost roll-up, EAC, progress %, retention math) — that's where bugs hurt.
- **CI/CD** — **AL-Go for GitHub** (PTE template, v9.0): compile + run tests + Cops on every push/PR. System files in `.github/workflows/` + `.github/AL-Go-Settings.json`; project settings in `.AL-Go/settings.json` (`appFolders: ["app"]`, `testFolders: ["test"]`, `country: w1`). Keep current via the **Update AL-Go System Files** workflow.

See `PLAN.md` for the full roadmap and feature decomposition.
