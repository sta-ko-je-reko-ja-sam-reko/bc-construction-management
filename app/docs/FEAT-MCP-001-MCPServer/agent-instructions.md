# MCP Agent Instructions — Construction Management (index)

Natural-language **instructions** (system prompts) for the GitHub Copilot / Copilot Studio agents that bind to the
BC MCP configurations this app creates — **one file per configuration**. Following
`bc-dev-templates/.../_patterns/mcp-configuration-instructions.md` (Purpose · Tools & entities · When to use / avoid ·
Constraints · Domain model). Paste a file's body into the connected agent's instructions, or lift it into the AL
`MCP Config` facade as a `Label` set on that configuration. **Keep each in sync with its tools** — if a config's tool
set changes, update its file in the same change.

**N = 8 configurations → 8 instruction files** (in [`agent-instructions/`](agent-instructions/)):

| # | Configuration | Built by | Tools | Instruction file |
|---|---|---|---|---|
| 1 | `Construction` | `CONS MCP Config Demo` (50300) | 27 (functional) | [construction.md](agent-instructions/construction.md) |
| 2 | `Construction Demo Foundation` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-foundation.md](agent-instructions/demo-foundation.md) |
| 3 | `Construction Demo Estimating` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-estimating.md](agent-instructions/demo-estimating.md) |
| 4 | `Construction Demo Cost Control` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-cost-control.md](agent-instructions/demo-cost-control.md) |
| 5 | `Construction Demo Progress Billing` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-progress-billing.md](agent-instructions/demo-progress-billing.md) |
| 6 | `Construction Demo Subcontracts` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-subcontracts.md](agent-instructions/demo-subcontracts.md) |
| 7 | `Construction Demo Equipment` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-equipment.md](agent-instructions/demo-equipment.md) |
| 8 | `Construction Demo Scheduling` | `CONS MCP Demo Config` (50038) | 1 (`importDemoData`) | [demo-scheduling.md](agent-instructions/demo-scheduling.md) |

> If you add or remove an MCP configuration in the AL, N changes — add/remove the matching file here and update this
> table in the same change.
