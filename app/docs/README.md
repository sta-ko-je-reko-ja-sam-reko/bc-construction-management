# Feature Documentation

One folder per feature: `FEAT-<AREA>-<NNN>-<Title>/` (dots → dashes; PascalCase title suffix).

## Required files (every feature)

| # | File | Audience | Language |
|---|---|---|---|
| 1 | `technical-documentation.md` | Developers | English |
| 2 | `getting-started-english.md` | End users | English |
| 3 | `getting-started-<lang>.md` | End users | Customer language (optional, e.g. Serbian) |

## Optional files

- `test-plan-unit-test.md`, `test-plan-integration-test.md` — Given/When/Then, cases `TEST-01`…
- `todo.md` — open questions / commented-out code.

## Conventions

- `technical-documentation.md` H1 exactly `# {MARK} - {Title}`.
- `getting-started-*` H1 exactly `# {MARK} - {Title}` (no ` - Getting Started` suffix).
- Never hand-number `###`/`####` headings — Word/PDF templates auto-number.
- Source/legacy reference is always `N/A (greenfield)`. No `nav2bc-object-mapping.md`.

## Feature index

| MARK | Title | Module | Phase | Status |
|---|---|---|---|---|
| FEAT-SET-001 | Construction Setup & Foundation | Foundation (base) | 1 | Implemented (pending build) |
| FEAT-EST-001 | Bill of Quantities | Estimating | 1 | Implemented (pending build) |
| FEAT-WBS-001 | Cost Breakdown Structure | Cost Control | 1 | Implemented (pending build) |
| FEAT-CST-001 | Cost Control & Forecasting | Cost Control | 1 | Implemented (pending build) |

Cross-session context (portable substitute for Claude's local memory): [PROJECT-NOTES.md](PROJECT-NOTES.md).

Modules & licensing: [../../MODULES.md](../../MODULES.md). Roadmap: [../../PLAN.md](../../PLAN.md). Research: [../../docs/research/project-operations-vs-bc-projects.md](../../docs/research/project-operations-vs-bc-projects.md).
