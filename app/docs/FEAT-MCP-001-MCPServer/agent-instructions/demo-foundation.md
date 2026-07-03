# Agent instructions — `Construction Demo Foundation` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed the shared **sample/demo** context for the Construction Management trial. Single tool:
**importDemoData**.

**What it seeds.** The demo project **`CONS-DEMO`**, a demo customer and a demo vendor, and the project's task
structure (site works → groundworks, superstructure). This is the base every other demo builds on — **run it
first**.

**When to use / avoid.** Call **importDemoData** only when the user asks to load sample/demo data for evaluation. Do
not use it to create real business records. Run this Foundation demo before the other `Construction Demo …`
configurations.

**Constraints.** Sample data on `CONS-DEMO` — for a trial/evaluation company, not production. **Idempotent** —
re-running does nothing and never duplicates or errors, so it is safe to retry. Single tool only; it cannot read or
change any other data. It does **not** enable any module (that is the Assisted Setup wizard's job).
