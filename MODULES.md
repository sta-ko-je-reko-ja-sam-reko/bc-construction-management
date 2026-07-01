# Module & Licensing Architecture

Construction Management is built as a set of **independently sellable modules**. Each module has its **own permission set(s)** and its **own entitlement**, and premium modules are **license-gated** so they can be sold à la carte ("Base + add-ons").

## How modularity / "selling" works in BC

Three distinct layers — don't conflate them:

1. **Access — permission sets.** Each module ships its own permission set(s) (`CONS <ShortCode> - Edit` / `- Read`, object names **≤20 chars**, full name in `Caption`), plus a composite `CONS Admin`. Permission sets control *who can use what once installed*.
2. **Licensing — entitlements.** Each module ships an `entitlement` object mapping the module's permission set to a license plan, so SaaS license assignment can grant/deny the module.
3. **Sales gate — license check + Feature Management.** Permission sets/entitlements alone don't *monetize* on AppSource. A `CONS License Mgt.` codeunit checks which modules a tenant has purchased and **enables/hides** premium module UI accordingly. Premium modules are also wrapped in Feature Management keys so a release is always installable.

> **Packaging decision (current):** **one app**, feature-grouped folders, per-module permission sets + entitlements + the license-gate codeunit. This gives à-la-carte selling without the overhead of many extensions.
> **Escape hatch:** folders are module-clean, so any module can later be lifted into its **own extension** (its own AppSource listing / independent versioning) if true separate-SKU sale is required. The base/foundation module would become a dependency.

## Module map

Permission-set / entitlement **object names are capped at 20 characters** (legacy `Code[20]` Role ID), so names use a compact `CONS <code> - Edit/Read` scheme; the **full descriptive name lives in the `Caption`** (e.g. name `CONS Cost - Edit`, caption `'Construction Cost Control - Edit'`). Keep `<code>` ≤ 8 chars.

| Module | Tier | Features (FEAT areas) | Permission sets (name → caption) | Entitlement | License-gated |
|---|---|---|---|---|---|
| **Construction Foundation** | Base (required) | `SET` | `CONS Found - Edit` / `- Read` (Construction Foundation) | `CONS Found Ent` | No (prerequisite for all) |
| **Estimating** | Add-on | `EST` (Bill of Quantities) | `CONS Est - Edit` / `- Read` (Construction Estimating) | `CONS Est Ent` | Yes |
| **Cost Control** | Add-on | `WBS` + `CST` (cost breakdown, committed cost, EAC/forecast) | `CONS Cost - Edit` / `- Read` (Construction Cost Control) | `CONS Cost Ent` | Yes |
| **Progress Billing** | Add-on | `BIL` + `RET` (schedule of values, retention) | `CONS Bill - Edit` / `- Read` (Construction Progress Billing) | `CONS Bill Ent` | Yes |
| **Subcontracts** | Add-on | `SUB` + `CHG` (subcontract claims, back-charges, change orders) | `CONS Subc - Edit` / `- Read` (Construction Subcontracts) | `CONS Subc Ent` | Yes |
| **Equipment & Plant** | Add-on | `EQP` | `CONS Equip - Edit` / `- Read` (Construction Equipment & Plant) | `CONS Equip Ent` | Yes |
| **Scheduling & Resource Planning** | **Premium add-on** | `SCH` + `RES` | `CONS Sched - Edit` / `- Read` (Construction Scheduling & Resource Planning) | `CONS Sched Ent` | Yes |

Composite: **`CONS Admin`** (caption `Construction Management - Admin`) includes every module's Edit set + Setup. Each module also contributes to a suggested role-tailored permission set later.

## The "Scheduling & Resource Planning" premium module (reclassified from "skip")

Research said to skip the Dataverse/Project-for-the-web pieces. We keep that boundary for the **engine**, but package a **native, lightweight** subset as a **premium add-on** customers can buy:

- **In scope (native, sellable):** task **dates / durations / % complete**, simple **predecessor** links, a **read-only timeline/Gantt-style** view, and **crew & equipment assignment** lists against tasks.
- **Explicitly NOT replicated:** Microsoft Project for the web's interactive scheduling/auto-reschedule engine, and the Dataverse **universal resource-scheduling board** (Field Service). Too heavy, low BC fit. We also don't replicate **OCR expense capture** or PSA's dual-entity estimate data model (we model estimating natively in the Estimating module).

This makes the "advanced scheduling" an upsell rather than dead scope, without committing to rebuilding Project for the web.

## Entitlements & transactability (scaffolded — finish at AppSource onboarding)

Each module ships an `entitlement` object (`CONS Found Ent`, `CONS Est Ent`, `CONS Cost Ent`, `CONS Bill Ent`) referencing a **non-assignable license permission set** (`CONS <Mod> License`, which wraps the module's `- Edit` set). These exist now as **scaffolding**; two facts shape how they work:

- **Online only.** Entitlements are honored only on **BC online (SaaS)** — they are inert on the on-prem `bcconstr28` container, so they can't be tested there. The container relies on directly-assigned permission sets.
- **Offer-bound `Id`.** Type is **`PerUserOfferPlan`**; the `Id` must be the **Service ID of the plan in Partner Center** for the app's transactable Marketplace offer. Until the offer is registered, each `Id` is a **`REPLACE-WITH-APPSOURCE-SERVICE-ID-…` placeholder** — replace with the real Service IDs at onboarding. This is what delivers true per-user, per-purchase gating (the "5 of 15 users" case).
- **PTE build can't contain them.** A PTE extension rejects entitlements with **PTE0013** (*"cannot be defined in an extension"*). So the entitlement objects **and** their license permission sets are wrapped in **`#if APPSOURCE … #endif`**. The default (PTE) build leaves `APPSOURCE` undefined → they're excluded → builds clean. An AppSource build defines the symbol (add `"preprocessorSymbols": ["APPSOURCE"]` to `app.json`, or a build-variant) → they're included. `CONS License Mgt.` carries the mirrored `#else` (PTE) branch, so exactly one licensing path compiles per target.

**Interim monetization gate (works on-prem and online):** `CONS License Mgt.` (currently a stub returning licensed) + Feature Management keys. Premium entry points call it; subscribers default to `SkipOnMissingLicense/Permission = true` so unentitled users are never blocked. Finalize the commercial model (which modules are paid plans vs. bundled with Foundation, and a `Type = Unlicensed` side-by-side entitlement) when the Marketplace offer is set up.

## Conventions for module authoring

- Every object lives under `app/src/<Module>/…` (or a feature subfolder) so module boundaries stay clean for a future extension split.
- Every module's objects are added **only** to that module's permission set (and the composite Admin) — never to another module's set.
- Premium module entry points call `CONS License Mgt.` to check entitlement before showing UI/running logic.
- A module never hard-depends on another add-on module; cross-module integration is via the **Foundation** layer + event subscribers (so a customer can buy Estimating without Cost Control, etc.).
