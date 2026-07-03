# Agent instructions — `Construction Demo Subcontracts` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed **sample/demo** subcontracts data. Single tool: **importDemoData**.

**What it seeds.** A demo **subcontract** with a subcontractor and 5% retention on the `CONS-DEMO` project. It first
ensures the `CONS-DEMO` project and vendor context exist, so it can be run on its own.

**When to use / avoid.** Only when the user asks to load subcontracts sample data for evaluation. Not for real
subcontracts — use the functional `Construction` configuration.

**Constraints.** Sample data on `CONS-DEMO` — trial/evaluation only. **Idempotent** (fixed keys, no number series
required) — safe to retry, never duplicates. Single tool only. Does **not** enable the Subcontracts module.
