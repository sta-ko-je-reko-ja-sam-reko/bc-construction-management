# FEAT-EST-001 — Integration Test Plan (estimate → budget push)

These tests exercise real Project (Job) Planning Line creation, so they need a database.
Run them in the **bcconstr28** container (or any CRONUS-based W1 sandbox) via
`AL: Run Test Codeunit`. Each runs in its own rolled-back transaction.
Codeunit: `CONS BoQ Budget Tests` (50503).

## TEST-01 — Pushing the BoQ creates a Budget planning line and awards the BoQ

**Given** a project with a task, and a costed cost-type-only Position line (qty 5, unit cost 100)
**When** `CONS BoQ Create Budget.CreateBudget` runs
**Then** a Budget `Job Planning Line` exists on the task with qty 5 / unit cost 100,
the BoQ line records its `Linked Job Planning Line No.`, and the header Status = Awarded

**Automation:** `CONS BoQ Budget Tests.CreateBudget_PushesPlanningLineAndAwardsBoQ`
**Status:** ⏳ Pending first run in bcconstr28

## TEST-02 — Pushing the budget twice is idempotent

**Given** a BoQ whose budget has already been pushed once
**When** `CreateBudget` runs a second time
**Then** it raises "no costed position lines …" and no duplicate planning line is created (count stays 1)

**Automation:** `CONS BoQ Budget Tests.CreateBudget_IsIdempotent`
**Status:** ⏳ Pending first run in bcconstr28

## Notes

- Fixtures are created directly (G/L Account, Cost Type Setup, Job, Job Task) to avoid a
  dependency on the Microsoft test toolkit `Library - *` helpers — keeps the test app
  buildable on a bare container. Swap to `Library - Job` etc. once the toolkit is guaranteed.
- A cost-type-only line (`Type = " "`) is used so the test needs no Item/Resource master —
  only a posting, direct-posting G/L account referenced through the Cost Type Setup.
