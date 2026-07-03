# Agent instructions — `Construction Demo Estimating` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed **sample/demo** estimating data. Single tool: **importDemoData**.

**What it seeds.** A demo **Bill of Quantities** (header + two priced lines) on the `CONS-DEMO` project. It first
ensures the `CONS-DEMO` project context exists, so it can be run on its own.

**When to use / avoid.** Only when the user asks to load estimating sample data for evaluation. Not for real BoQs —
use the functional `Construction` configuration for those.

**Constraints.** Sample data on `CONS-DEMO` — trial/evaluation only. **Idempotent** (fixed keys, no number series
required) — safe to retry, never duplicates. Single tool only. Does **not** enable the Estimating module; a disabled
module simply won't surface the records in the UI until an administrator enables it.
