---
name: propagate-lessons-to-templates
description: "When a BC/AL gotcha is found in a project, update the three template methodologies too — not just the active project"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 28de1f7a-b25f-4d68-b9d6-aba1cab946b9
---

**Standing directive (confirmed 2026-06-29):** whenever we fix or learn something on the Construction product (or any concrete BC project) that is a **reusable AL/BC lesson or gotcha** (e.g. the permission-set/`permissionsetextension`/`entitlement` 20-char identifier limit), **also update the template methodology** — skills, instructions, agents, object guides, checklists — not just the active project. Do this as part of the fix, by default, without being asked.

**Scope boundary — what goes to templates vs stays in the product:** only **generalizable** AL/BC knowledge (language limits, conventions, object-authoring patterns, ruleset gotchas, BC-model usage) propagates to the templates. **Product/domain-specific** content (construction BoQ logic, situations, module/feature design, business rules) stays in the construction repo and must NOT pollute the generic templates — the templates' own hard rules require staying customer-generic (placeholders `<AFFIX>`, `5####`). When unsure whether something is generalizable, keep it product-side.

**Why:** the three templates in `Documents\` (`bc-customer-project-template`, `bc-greenfield-template`, `bc-nav2bc-reimplementation-template`) are reused for all future BC projects/products/modules/features; a fix that lives only in one project is lost next time.

**How to apply:**
- The **authoritative** home is the shared base `bc-customer-project-template` — the relevant `al-object-types/<type>.md` guide(s), `al-object-types/_reference/`, and `instructions/02-al-coding-standards.md`.
- Then **reinforce in every scenario**: the AL-authoring `skills/*/SKILL.md`, the migration template's `agents/al-object-author.md`, and the definition-of-done `checklists/` (feature-ready / gap-reimplementation-ready / code-review).
- Greenfield and migration templates defer AL rules to the base guides — so fix the base first, then add a one-line reminder + checklist gate in each scenario.
- Templates may not be git repos; edit the files directly. Keep customer specifics out (placeholders `<AFFIX>`, `5####`). See [[bc-construction-module]].
