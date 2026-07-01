# FEAT-BIL-001 / FEAT-RET-001 — Unit Test Plan (DB-free)

Progress-billing line math and retention math are tested by calling the logic codeunits directly
with in-memory records — no `Insert`, no SQL.

## Progress billing line — `CONS Prog Billing Line Tests` (50504)

### TEST-01 — Completed-to-date, % complete, retention and net due

**Given** a SoV line: scheduled 10,000, previous 2,000, this period 3,000, stored 500, retention 10%
**When** `Validate_Amounts` runs
**Then** Completed To Date = 5,500; % Complete = 55; Retention This Period = 350; Net Due = 3,150

**Automation:** `CONS Prog Billing Line Tests.ValidateAmounts_ComputesProgressRetentionAndNetDue`
**Status:** ✅ Pass (logic-direct, no DB)

### TEST-02 — Zero scheduled value does not divide by zero

**Given** a line with scheduled value 0, this period 1,000, retention 5%
**When** `Validate_Amounts` runs
**Then** % Complete = 0; Retention = 50; Net Due = 950

**Automation:** `CONS Prog Billing Line Tests.ValidateAmounts_ZeroScheduledValue_NoDivideByZero`
**Status:** ✅ Pass (logic-direct, no DB)

## Retention math — `CONS Retention Mgt Tests` (50505)

### TEST-03 — Retention = amount × pct

**Given** billed 3,500 and 10% → **Then** 350. **Automation:** `CalcRetention_ComputesPercentage`. ✅ Pass

### TEST-04 — Zero percent withholds nothing

**Given** billed 3,500 and 0% → **Then** 0. **Automation:** `CalcRetention_ZeroPercent_IsZero`. ✅ Pass

### TEST-05 — Retention rounds to currency precision

**Given** 1,000 × 3.33% → **Then** 33.3 (Round explicit 0.01). **Automation:** `CalcRetention_Rounds`. ✅ Pass

## Deferred to integration (slice 2 — need DB / posting)

- `CONS Prog. Billing Seed.SeedFromProject` (reads billable Job Planning Lines).
- `CONS Retention Mgt.OutstandingRetention` (CalcSums over the ledger).
- Invoice generation (`Job Create-Invoice` + retention G/L line) + the `Sales-Post` retention
  subscriber writing `CONS Retention Entry` — built in slice 2, then integration-tested in the container.
