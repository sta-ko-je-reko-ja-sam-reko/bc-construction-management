# FEAT-RET-001 — Retention Posting Design Spike

> **Status:** decision spike (no AL yet). PLAN.md §5 flags retention posting as the trickiest AL
> in the product — *"how withheld amounts post and release (deferred GL vs separate ledger).
> Design spike before Phase 2."* This document resolves that. Module: **Progress Billing**.

## 1. What retention (retainage) must do

On a construction contract the owner **withholds a percentage** (typically 5–10%) of each certified
progress payment as security. The contractor has **earned** the full amount (revenue is recognised in
full), but the customer **pays less now**; the withheld balance (the *retention receivable*) is
**released later** — usually in stages: a portion at substantial completion, the remainder at the end
of the defects-liability period.

Requirements:

1. **Revenue is full, cash is reduced.** A progress invoice for 100,000 with 10% retention recognises
   100,000 revenue but only 90,000 becomes currently-due AR; 10,000 sits as a *retention receivable*.
2. **Track every withholding** per project (and per application/invoice) for reporting: "retention held
   to date", "retention released", "retention outstanding".
3. **Release on a schedule** — bill the customer for the held amount when it falls due (one or more
   release events), moving it from *retention receivable* back to current AR.
4. **Symmetry for AP** (Phase 3, Subcontracts): the same mechanism, mirrored, withholds retention from
   subcontractor claims. The design must not box us out of the AP side.
5. **Upgrade-safe & international** — no dependency on a country-specific localisation feature; standard
   posting only, obsoletion-friendly data model.

## 2. Standard BC starting point (from `.alpackages`, BC 28.2)

- **Job Planning Line** (1003) `Line Type = Billable` carries what can be invoiced; `Qty. to Transfer
  to Invoice` / `Qty. Transferred to Invoice` drive incremental billing.
- **`Job Create-Invoice`** (codeunit 1002) transfers billable planning lines into a **Sales Invoice**
  (Sales Header 36 / Sales Line 37), posted by **`Sales-Post`** (80).
- Standard BC has **no retention concept** — no withholding split on the customer ledger entry, no
  staged-release receivable. This is a genuine gap and our differentiator (PLAN.md §1).
- BC **Payment Terms** can set a due date but **cannot natively split one invoice into two
  installments with different due dates** internationally (multi-installment is a localisation-only
  feature) — so we cannot lean on payment terms for the held portion.

## 3. Options considered

### Option A — Negative "retention" sales line reducing revenue ❌
Add a negative line to the invoice. **Rejected:** it understates revenue (revenue must be full), and
distorts VAT/tax base. Accounting-wrong.

### Option B — Split into two customer ledger entries via payment terms/installments ❌
**Rejected:** relies on multi-installment payment terms that aren't part of W1/most localisations;
not portable, not upgrade-safe.

### Option C — Custom journal: post our own GL + a private retention sub-ledger ⚠️
Subscribe to posting, then post a manual GL journal (Dr Retention Receivable / Cr AR) ourselves and
write our own sub-ledger. **Workable but heavy:** we own a second posting routine (rounding, dimensions,
VAT, reversal, correction all become our problem) — exactly the fragile custom-posting PLAN.md warns
about. Keep as fallback only.

### Option D — Retention as an automatic **G/L-account sales line** + our own **Retention Entry** sub-ledger ✅ (recommended)
On a progress invoice, in addition to the revenue line(s), add **one G/L-account line** posting to a
**"Retention Receivable" G/L account** with the sign that **moves the retained amount out of the
current customer balance into the retention-receivable asset account** — all inside one *standard*
posted sales invoice:

```
Progress invoice, earned 100,000, retention 10%:
  Dr  Accounts Receivable        90,000      (customer pays this now)
  Dr  Retention Receivable       10,000      (the withheld asset, our G/L line)
      Cr  Construction Revenue          100,000
  (+ VAT/tax computed on the full 100,000 revenue base — unaffected by the split)
```

- The retention line is a **`Type = G/L Account`** sales line for the retention G/L account, amount
  `-(earned × retention%)`, **VAT-exempt / no tax** (it is a balance reclassification, not revenue).
- Net customer ledger entry (currently due) = `earned − retention`. Revenue and VAT are **full and
  correct**. No custom posting routine — we ride standard `Sales-Post`.
- **Release** = a later invoice (or a release line on a later application) with the retention line
  **reversed** (`Type = G/L Account`, amount `+retention`): `Dr AR / Cr Retention Receivable` — bills
  the customer for the held amount, collectible normally.
- We additionally keep a **`CONS Retention Entry`** ledger (our own table), one row per withholding and
  per release, written by a **thin event subscriber on `Sales-Post` (`OnAfterPostSalesDoc`)** —
  delegating a single line to a logic interface per the polymorphic pattern. This gives
  held/released/outstanding reporting and drives the **release schedule** without owning GL posting.

**Why D wins:** correct revenue & tax, standard posting (upgrade-safe, dimension/VAT/rounding handled
by MS), our sub-ledger only *records* (never *posts*), works in W1 and any localisation, and mirrors
cleanly to AP for subcontractor retention in Phase 3 (Retention Payable G/L + the same Retention Entry
table with a Direction field).

## 4. Recommended data model (sketch — confirm before AL)

- **`CONS Retention Setup`** (or fields on `CONS Construction Setup`): default Retention %, Retention
  Receivable G/L account, Retention Payable G/L account (AP, Phase 3), retention release stages
  (e.g. 50% at completion / 50% after defects period).
- **`CONS Retention Entry`** (ledger): Entry No., Project No., Application No. / Document No.,
  Direction (Receivable/Payable), Entry Type (Withheld/Released), Date, Amount, Released Amount,
  Open (Boolean), Due Date, Source customer/vendor. SIFT keys for held/released sums.
- **Posting-event subscriber** `CONS Sales Retention Events` → `Logic().OnAfterPostSalesDoc(...)`
  writes the Retention Entry; **no GL posting in our code**.

## 5. Open question for the user (the one real fork)

The retention **withholding mechanism** is the decision with lasting data-model + accounting
consequences (an ISV can't break it after data ships). Recommendation: **Option D**. See the question
posed alongside this spike. The schedule-of-values / Application-for-Payment design that drives these
invoices is in [../FEAT-BIL-001-ProgressBilling/technical-documentation.md](../FEAT-BIL-001-ProgressBilling/technical-documentation.md).
