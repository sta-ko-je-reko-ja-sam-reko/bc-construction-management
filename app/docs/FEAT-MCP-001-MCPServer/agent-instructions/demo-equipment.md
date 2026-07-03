# Agent instructions — `Construction Demo Equipment` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed **sample/demo** equipment data. Single tool: **importDemoData**.

**What it seeds.** Two demo **equipment** cards (an excavator and a tower crane) with cost and hire rates. Self-
contained — equipment has no project dependency.

**When to use / avoid.** Only when the user asks to load equipment sample data for evaluation. Not for real
equipment — use the functional `Construction` configuration.

**Constraints.** Sample data — trial/evaluation only. **Idempotent** (fixed keys, no number series required) — safe
to retry, never duplicates. Single tool only. Does **not** enable the Equipment & Plant module.
