# FEAT-BIL-001 - Progress Billing

Bill a construction project in stages against a schedule of values, withhold retention automatically, and issue a payment certificate / customer invoice for each period. Requires the **Progress Billing** module.

## Before you start

1. In **Construction Setup**, set the **Progress Billing** and **Progress Certificate** number series.
2. In **Construction Setup**, set the **Default Retention %** and the **Retention Receivable** and **Revenue** accounts.
3. Make sure the construction **Project** you are billing is **Open** and has its billable planning lines entered.

## Create a progress billing application

1. Open **Progress Billing** and choose **New**. The **No.** is assigned automatically.
2. Select the **Project No.** and enter the **Period Start / End** and **Posting Date**. The **Retention %** defaults from Construction Setup.
3. Choose **Create Lines from Project** to bring in a **schedule-of-values** line for each billable item on the project. (You can also add lines manually.)

## Enter this period's progress

1. For each line, enter the **% Complete** or the **This Period Amount** for the work done this period.
2. Each line shows **Completed to Date**, the **Retention This Period**, and the **Net Due This Period**; the header totals them for the certificate.
3. Review the totals — **This Period**, **Retention**, and **Net Due** — before certifying.

## Issue the certificate and invoice the customer

1. Choose **Create Sales Invoice** (payment certificate). A draft customer invoice is created with the period's lines and a retention line that withholds the retention amount.
2. Open the draft invoice, review it, and **post** it. The customer is billed the net amount and the withheld retention is recorded against the project.
3. Print the **Payment Certificate** report for the customer if required.

## Release retention

When the retention becomes due (for example at practical completion), open the project's **Retention Entries**, choose **Release Retention**, enter the amount to release, and post the resulting draft invoice to bill the held retention. See the **Retention** getting-started for details.

> _Screenshots and field reference to be completed at implementation._
