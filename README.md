# Construction Management for Business Central

An ISV vertical extension that turns standard **Business Central Projects (Jobs)** into a construction project-management solution: **Bill of Quantities estimating**, a **multi-level cost breakdown structure**, **committed-cost & cost-to-complete control**, **progress billing** and **retention**.

- **Foundation:** standard BC Projects — extends, never reinvents.
- **Distribution:** built to AppSource standards, shipped in the PTE ID range (50000–99999).
- **Methodology:** the `bc-greenfield-template` feature workflow + shared AL conventions/object-type guides from `bc-customer-project-template`.

## Repo layout

```
bc-construction-management/
├── CLAUDE.md                 # how Claude works in this repo
├── PLAN.md                   # product roadmap + feature decomposition
├── MODULES.md                # sellable modules: permission sets + entitlements + license gate
├── docs/research/            # product research (e.g. Project Operations vs BC Projects)
├── .github/                  # AL-Go for GitHub workflows + settings (CI/CD)
├── .AL-Go/                   # AL-Go project settings (appFolders/testFolders) + dev scripts
├── app/                      # the extension
│   ├── app.json, AppSourceCop.json, ruleset.json
│   ├── .vscode/
│   ├── docs/                 # FEAT-<MARK>-<Title>/ feature docs
│   └── src/                  # feature-grouped AL source
│       ├── Core/  PermissionSet/  Setup/
│       ├── Estimating/  CostBreakdown/  CostControl/
└── test/                     # AL test app (depends on app/)
```

## Before first build

1. Set **publisher** in `app/app.json`, `test/app.json`, and the affix/prefix in `app/AppSourceCop.json` (currently `YourCompany` / `CONS`).
2. Replace the **placeholder manifest URLs** in `app/app.json` (`EULA`, `privacyStatement`, `help`, `url`, `contextSensitiveHelpUrl` — currently `https://www.example.com/...`) and the **placeholder logo** `app/img/AppLogo.png` (1×1 stub) with real values before any AppSource submission. AppSourceCop requires non-empty values.
3. Confirm the **BC target version** (`application`/`runtime`) and run **AL: Download Symbols**.
4. Build → must be **zero CodeCop / AppSourceCop errors**.

## GitHub & AL-Go for GitHub

CI/CD runs on **AL-Go for GitHub** (PTE template, v9.0). The system files live in `.github/` (workflows + `AL-Go-Settings.json`) and `.AL-Go/settings.json` (points at `appFolders: ["app"]`, `testFolders: ["test"]`, `country: w1`).

To connect to GitHub:

1. Create a new (empty) GitHub repository.
2. `git remote add origin <your-repo-url>` then `git push -u origin main`.
3. On first push, AL-Go's **CI/CD** and **PullRequestHandler** workflows run automatically — compile `app/` + `test/`, run tests, run the Cops.
4. Keep AL-Go up to date with the **Update AL-Go System Files** workflow; cut releases with **Create release**.
5. Local dev environments: `.AL-Go/cloudDevEnv.ps1` (online sandbox) or `.AL-Go/localDevEnv.ps1` (container).

> No AppSource delivery is configured (we ship in the PTE range). If you later list on AppSource, switch the AL-Go template to AppSource and add the delivery context.

## Roadmap (see PLAN.md)

| Phase | Theme | Features |
|---|---|---|
| 0 | Product bootstrap | repo, config, CI, telemetry plumbing |
| 1 (MVP) | Estimate → budget → cost control | `SET`, `EST`, `WBS`, `CST` |
| 2 | Get paid | `BIL` (progress billing), `RET` (retention) |
| 3 | Supply side | `SUB` (subcontracts), `CHG` (change orders) |
| 4 | Depth | `EQP` (equipment), `RES` (scheduling), dashboards |
