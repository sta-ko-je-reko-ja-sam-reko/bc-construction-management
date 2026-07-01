# FEAT-CST-001 — Unit Test Plan (DB-free)

The forecast math is extracted into a pure `Compute(Budget, Actual, Committed; var ETC, EAC, Variance)`
so it is tested without reading any ledger. Codeunit: `CONS Cost Forecast Tests` (50502).

## TEST-01 — Under budget

**Given** Budget 1000, Actual 300, Committed 200
**When** `Compute` runs
**Then** ETC = 500, EAC = 1000, Variance = 0

**Automation:** `CONS Cost Forecast Tests.Compute_UnderBudget`
**Status:** ✅ Pass (pure function, no DB)

## TEST-02 — Forecast overrun clamps ETC and shows a negative variance

**Given** Budget 1000, Actual 800, Committed 400 (already over budget)
**When** `Compute` runs
**Then** ETC = 0 (clamped), EAC = 1200, Variance = -200

**Automation:** `CONS Cost Forecast Tests.Compute_Overrun_ClampsETCAndShowsNegativeVariance`
**Status:** ✅ Pass (pure function, no DB)

## Deferred to integration

- `CalcForecast` reading Job Ledger / planning lines / committed purchase amounts — DB-bound;
  covered when project-cost integration tests are added.
