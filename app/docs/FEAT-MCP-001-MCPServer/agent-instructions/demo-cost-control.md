# Agent instructions — `Construction Demo Cost Control` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed the **sample/demo** context for Cost Control. Single tool: **importDemoData**.

**What it seeds.** Ensures the `CONS-DEMO` project context so the Cost Control pages have a project to analyse. Cost
Control has no records of its own — for a populated budget-vs-actual picture, also run `Construction Demo Estimating`
(which seeds a BoQ → budget).

**When to use / avoid.** Only when the user asks to prepare Cost Control demo data for evaluation. Not for real data.

**Constraints.** Sample context on `CONS-DEMO` — trial/evaluation only. **Idempotent** — safe to retry. Single tool
only. Does **not** enable the Cost Control module.
