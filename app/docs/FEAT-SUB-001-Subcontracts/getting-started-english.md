# FEAT-SUB-001 - Subcontracts

Manage subcontractors end to end: the subcontract agreement, periodic progress claims, variations (change orders), and retention release. Requires the **Subcontracts** module.

## Before you start

1. In **Construction Setup**, set the number series: **Subcontract Nos.**, **Subcontract Claim Nos.**, and **Change Order Nos.**
2. In **Construction Setup**, set the G/L accounts: **Subcontract Cost Account**, **Retention Payable Acc.**, and a **Default Retention %**.
3. Make sure the construction **Project** (Job) you are subcontracting is **Open**.

## Create a subcontract

1. Open **Subcontracts** and choose **New**. The **No.** is assigned automatically.
2. Select the **Subcontractor No.** (vendor) — the **Retention %** defaults from Construction Setup.
3. Select the **Project No.** and enter a **Description** and **Starting / Ending Date**.
4. Add **Subcontract Lines**: cost type, **Quantity**, and **Unit Cost**. Each line shows **Line Amount = Quantity × Unit Cost**, and the header totals them into **Subcontract Value**.
5. Set **Status** to **Released** when the subcontract is agreed and ready for claims.

## Record a subcontractor claim

1. Open **Subcontract Claims** and choose **New**. The **No.** is assigned automatically.
2. Select the **Subcontract No.** — the **Project No.**, **Subcontractor No.**, and **Retention %** are copied in, and a sequential **Claim No.** is assigned.
3. Enter the **Period Start / End** and **Posting Date**.
4. Add **Claim Lines**: for each scope line enter the **Scheduled Value**, **Previous Amount**, and **This Period Amount**. The line computes **Completed To Date**, **% Complete**, **Retention This Period**, and **Net Payable This Period**.
5. Certify the claim, then choose **Create Purchase Invoice**. A draft purchase invoice is created with one cost line per claim line plus a single retention line. The claim status becomes **Invoiced**.
6. Open the draft purchase invoice, enter the **vendor invoice number**, review, and **post** it. Posting records the withheld payable retention.

## Raise a change order (variation)

1. Open **Change Orders** and choose **New**. The **No.** is assigned automatically.
2. Select the **Project No.**, choose the **Change Type** (**Owner** or **Subcontract**), and — for a subcontract change — the **Subcontract No.**
3. Enter a **Description** and **Reason**.
4. Add **Change Order Lines**: **Job Task No.**, **Cost Type**, and **Amount** (use a negative amount for an omission). The header shows the **Total Amount**.
5. If approval is configured, choose **Send for Approval**; the change order goes to **Pending Approval** and then **Approved** once approved.
6. Choose **Apply**. An *Owner* change adds the total to the project's contract value; a *Subcontract* change adds variation lines to the subcontract. Either way, lines with a job task and a cost-type G/L account are pushed to the project budget. The change order is set to **Approved**.

## Release subcontractor retention

1. From the subcontract (or the retention overview), choose **Release Retention**.
2. Enter the **amount** to release — it cannot exceed the outstanding payable retention for the project/subcontractor. To release everything held, use **Release Full Outstanding**.
3. A draft retention-release purchase invoice is created (a single positive retention line). Review and **post** it to pay the retention to the subcontractor.

> _Screenshots and field reference to be completed at implementation._
