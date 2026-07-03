# Agent instructions — `Construction Demo Progress Billing` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed the **sample/demo** context for Progress Billing. Single tool: **importDemoData**.

**What it seeds.** Ensures the `CONS-DEMO` project context so there is a project to bill against. A progress billing
application is then created and seeded from the project interactively in BC (create an application, then *Seed from
Project*).

**When to use / avoid.** Only when the user asks to prepare Progress Billing demo data for evaluation. Not for real
billing — use the functional `Construction` configuration.

**Constraints.** Sample context on `CONS-DEMO` — trial/evaluation only. **Idempotent** — safe to retry. Single tool
only. Does **not** enable the Progress Billing module.
