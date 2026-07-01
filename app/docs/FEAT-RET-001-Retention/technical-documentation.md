# FEAT-RET-001 - Retention

> **Source/legacy reference:** N/A (greenfield).
> **Module:** Progress Billing (add-on, license-gated) — receivable retention; payable retention is gated by the Subcontracts feature. See [MODULES.md](../../../../MODULES.md).
> **Affected objects:** Retention Entry sub-ledger (table + list + API page), retention math/recording codeunit, sales/purchase posting logic + event subscribers, release codeunit, Sales Header / Sales Invoice Header table extensions, direction/entry-type enums, reactions interface.
> **Namespaces:** Construction.Retention.
> **Proposed ID block:** 50200–50210, plus API page 50287, table-ext 50165–50166 (as implemented).
> **Depends on:** Foundation module (Construction Setup, Feature Mgt., License Mgt., Service Locator), Progress Billing module (Progress Billing Header / Application No.), standard BC Sales & Purchase posting.

## Business Process

Retention (retainage) is a percentage of each certified payment that is withheld as security and **released later**. Revenue is recognised in full; only the cash currently due is reduced. The withheld balance is parked on a dedicated **Retention Receivable / Payable G/L account** and tracked row-by-row in the **Retention Entry sub-ledger** so the held / released / outstanding balance is always reportable per project. The design follows the recorded posting spike (Option D — retention as a G/L-account sales line + our own sub-ledger; the module never owns GL posting). See [retention-posting-spike.md](retention-posting-spike.md).

1. **Setup.** In **Construction Setup** the admin records a **Default Retention %**, a **Retention Receivable Account** (customer side) and a **Retention Payable Account** (subcontractor side).
2. **Withhold on customer progress invoices.** When a progress billing application is invoiced, the posted invoice carries the retention split (`CONS Retention Amount`, `CONS Project No.`, `CONS Progress Billing No.`). On insert of the posted **Sales Invoice Header**, the module records a **Withheld** retention entry (Direction = Receivable, positive amount) against the bill-to customer and the receivable G/L account.
3. **Withhold on subcontractor claims.** Symmetrically, posting a purchase invoice for a project (Subcontracts feature enabled) records a **Withheld** entry (Direction = Payable, positive amount) against the buy-from vendor and the payable G/L account.
4. **Track in the sub-ledger.** Each withholding and release is one Retention Entry row. The per-project, per-direction **sum of Amount** (withheld positive, released negative) is the **outstanding retention**; entries are flagged **Open** while still held.
5. **Release later.** When the held amount falls due, the user runs the release routine: it creates a **draft sales invoice** with a single positive retention G/L line (Dr AR / Cr Retention Receivable) stamped as a release. Posting that invoice records a **Released** entry (negative amount), reducing the outstanding balance. Release can be a partial amount or the full outstanding.

## Data Model

### New Tables
| Table | Key fields | Notes |
|---|---|---|
| CONS Retention Entry | Entry No. (Integer, AutoIncrement, PK) | Project No. (TableRelation Job); Direction (enum Receivable/Payable); Entry Type (enum Withheld/Released); Document No.; Posting Date; Account No. (customer or vendor); Amount (positive=withheld, negative=released, AutoFormatType 1); G/L Account No. (TableRelation G/L Account); Application No.; Due Date; Open (Boolean). Secondary key (Project No., Direction, Open) with SumIndexFields = Amount drives held/released/outstanding sums; key on Document No. |

### New Fields on Existing Tables
| Object | Field | Type | Notes |
|---|---|---|---|
| Sales Header (ext 50165) | CONS Progress Billing No. | Code[20] | Source progress billing application. |
| Sales Header | CONS Project No. | Code[20] | Construction project the retention relates to. |
| Sales Header | CONS Retention Amount | Decimal | Retention withheld (or released) on this invoice. |
| Sales Header | CONS Retention Is Release | Boolean | Marks the invoice as a retention release rather than a withholding. |
| Sales Invoice Header (ext 50166) | CONS Progress Billing No. / CONS Project No. / CONS Retention Amount / CONS Retention Is Release | (as above) | Posted-invoice copies read by the Sales-Post subscriber to write the retention entry. |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| table | 50200 | CONS Retention Entry | Retention sub-ledger — one row per withholding / release. |
| enum | 50202 | CONS Retention Direction | Receivable (customer) / Payable (subcontractor). |
| enum | 50203 | CONS Retention Entry Type | Withheld / Released. |
| codeunit | 50205 | CONS Retention Mgt | Retention math (`CalcRetention`) + records withheld/released entries and sums outstanding (`OutstandingRetention`, `OutstandingForAccount`). |
| codeunit | 50206 | CONS Sales Retention Events | Subscribes to Sales Invoice Header OnAfterInsert; delegates via Service Locator. |
| codeunit | 50207 | CONS Retention Logic | Default impl of `CONS IRetentionReactions` — writes the receivable/payable entry from a posted sales/purchase invoice (feature-gated). |
| page | 50208 | CONS Retention Entries | List page over the sub-ledger (DrillDown/Lookup target). |
| codeunit | 50209 | CONS Retention Release | Builds a draft release sales invoice (partial or full outstanding); license-gated. |
| codeunit | 50210 | CONS Purch Retention Events | Subscribes to Purch. Inv. Header OnAfterInsert; delegates via Service Locator. |
| page | 50287 | CONS Retention Entry API | Read API (`retentionEntries`) over the sub-ledger. |
| interface | — | CONS IRetentionReactions | Polymorphic contract for reacting to posted sales/purchase invoices (no object ID). |
| tableextension | 50165 | CONS Sales Header | Retention/project stamp fields on Sales Header. |
| tableextension | 50166 | CONS Sales Invoice Header | Same stamp fields on the posted Sales Invoice Header. |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Sales withhold/release | `Sales Invoice Header.OnAfterInsertEvent` → `CONS Retention Logic.OnAfterPostedSalesInvoice` | Records receivable Withheld/Released entry from the posted invoice's stamp fields. |
| Purchase withhold/release | `Purch. Inv. Header.OnAfterInsertEvent` → `CONS Retention Logic.OnAfterPostedPurchInvoice` | Records payable Withheld/Released entry. |
| Polymorphic dispatch | `CONS Service Locator.RetentionReactions()` → `CONS IRetentionReactions` | Resolves the reactions implementation (default `CONS Retention Logic`). |
| Outstanding query | `CONS Retention Mgt.OutstandingRetention` / `OutstandingForAccount` | Per-project (and per-account) held-minus-released sum via the SIFT key. |
| Release | `CONS Retention Release.CreateReleaseInvoice` / `ReleaseFullOutstanding` | Creates the draft release sales invoice; checks amount ≤ outstanding. |
| Setup | `CONS Construction Setup."Default Retention %"`, `"Retention Receivable Acc."`, `"Retention Payable Acc."` | Default percentage and the G/L accounts the held amounts post to. |
| Feature / license gates | `CONS Feature Mgt.IsEnabled(ProgressBilling / Subcontracts)`, `CONS License Mgt.CheckModuleLicensed(Progress Billing)` | Sales withhold gated by ProgressBilling; purchase withhold by Subcontracts; release entry by Progress Billing license. |

## Dependencies

| Dependency | App / Module | Usage |
|---|---|---|
| Foundation (this app) | internal | Construction Setup, Feature Mgt., License Mgt., Service Locator. |
| Progress Billing (this app) | internal | Progress Billing Header → Application No. on the receivable entry. |
| Base Application | Microsoft | Sales Header / Sales Invoice Header, Purch. Inv. Header, Sales Post, Job, G/L Account. |

## Tests

`test/CONS Retention Mgt Tests` (codeunit 50505) — covers the retention math (`CalcRetention`: percentage, zero-percent, rounding) and the sub-ledger record/outstanding logic.

## Known Limitations

- **Release is customer-side only.** `CONS Retention Release` builds a sales (receivable) release invoice; payable retention release rides the same Purch. Inv. subscriber but has no dedicated release builder yet.
- **No staged release schedule.** `Due Date` is stored but the staged-release schedule (e.g. 50% at completion / 50% after defects period) from the spike is not yet automated; release is a manual partial/full action.
- Retention G/L line construction on the progress invoice itself is owned by the Progress Billing feature; this module records and releases, it does not post GL.
