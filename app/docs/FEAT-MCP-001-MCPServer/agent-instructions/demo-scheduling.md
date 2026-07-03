# Agent instructions — `Construction Demo Scheduling` (demo-import, 1 tool)

> Built by `CONS MCP Demo Config` (codeunit 50038). Single tool: `importDemoData`. Keep in sync with the tool.

---

**Purpose.** Seed **sample/demo** scheduling data. Single tool: **importDemoData**.

**What it seeds.** The `CONS-DEMO` project schedule: planned dates and durations on the two posting tasks and a
finish-to-start **dependency** between them (so the Gantt shows a realistic two-bar plan). It first ensures the
`CONS-DEMO` project and tasks exist, so it can be run on its own.

**When to use / avoid.** Only when the user asks to load scheduling sample data for evaluation. Not for real
schedules — use the functional `Construction` configuration.

**Constraints.** Sample data on `CONS-DEMO` — trial/evaluation only. **Idempotent** — safe to retry, never
duplicates. Single tool only. Does **not** enable the Scheduling & Resource Planning module.
