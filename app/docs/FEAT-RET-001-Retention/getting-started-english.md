# FEAT-RET-001 - Retention

Withhold a percentage (retention / retainage) of each customer progress invoice and subcontractor claim as security, track it in the retention sub-ledger, and release it later. Requires the **Progress Billing** module (subcontractor retention also requires the **Subcontracts** feature).

## Steps

1. **Set the retention defaults.** Open **Construction Setup** and fill in:
   - **Default Retention %** — the percentage defaulted onto new progress billing applications (e.g. 10).
   - **Retention Receivable Account** — the G/L account that holds retention withheld from customer progress invoices.
   - **Retention Payable Account** — the G/L account that holds retention withheld from subcontractor claims.
2. **Withhold automatically on customer progress invoices.** When you invoice a progress billing application, the retention is computed and withheld automatically: the posted invoice shows full revenue, the customer is billed for the net (earned minus retention), and the held amount lands on the Retention Receivable account.
3. **Withhold automatically on subcontractor claims.** When you post a subcontractor's purchase invoice for a project, retention is withheld the same way against the Retention Payable account.
4. **View the retention entries.** Open the **Retention Entries** list to see every withholding and release: project, direction (Receivable / Payable), entry type (Withheld / Released), document, account, amount and whether it is still open. The per-project balance of these entries is the outstanding retention currently held.
5. **Release retention.** When the held amount falls due, run the retention release for the project. This creates a **draft sales invoice** that bills the customer for the released amount (moving it from the retention account back to a normal receivable). Review the draft and **Post** it — posting records a Released entry and reduces the outstanding retention. You can release a partial amount or the full outstanding balance.

> _Screenshots and field reference to be completed at implementation._
