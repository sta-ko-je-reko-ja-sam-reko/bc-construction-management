# FEAT-EST-001 — Unit Test Plan (DB-free)

These tests call the BoQ line logic directly with in-memory records (no `Insert`, no SQL).
Codeunit: `CONS BoQ Line Logic Tests` (50501).

## TEST-01 — Position line computes totals and marked-up price

**Given** a Position line: quantity 10, unit cost 100, markup 20%
**When** `Validate_Amounts` runs
**Then** Total Cost = 1000, Unit Price = 120, Total Price = 1200

**Automation:** `CONS BoQ Line Logic Tests.ValidateAmounts_Position_ComputesTotals`
**Status:** ✅ Pass (logic-direct, no DB)

## TEST-02 — Non-position line carries no amounts

**Given** a Heading line with quantity/cost/markup set
**When** `Validate_Amounts` runs
**Then** Total Cost = 0 and Total Price = 0

**Automation:** `CONS BoQ Line Logic Tests.ValidateAmounts_NonPosition_Zeroes`
**Status:** ✅ Pass (logic-direct, no DB)

## TEST-03 — Changing Type clears the now-mismatched No.

**Given** a line with `No.` = 'ABC' whose Type changes from Resource to Item
**When** `Validate_Type` runs
**Then** `No.` is cleared

**Automation:** `CONS BoQ Line Logic Tests.ValidateType_Changed_ClearsNo`
**Status:** ✅ Pass (logic-direct, no DB)

## Deferred to integration (require master/related records)

- `Trigger_OnInsert` default-markup inheritance — reads the BoQ Header (`BoQHeader.Get`).
- `Validate_No` / `CopyFromReferencedRecord` — reads Resource / Item / G/L Account masters.
- `BoQ Header Logic.Trigger_OnInsert` (No. Series) and `Trigger_OnDelete` (cascade) — DB + No. Series.

These are inherently database-bound; they belong in integration coverage, not the DB-free unit layer.
