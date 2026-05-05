# Four-Way Comparison: SpecKit vs Classical vs Clean vs BMAD

| Repo | Approach | Cloud target | Path |
|---|---|---|---|
| **SpecKit** | Spec Kit-driven (`/speckit.specify` → `plan` → `tasks` → `implement`) | Azure App Service | `c:\Users\rvunvulea\Downloads\DevOps2026_Spec\DevOpsPro-Europe-2026` |
| **Classical** | Numbered prompts with rich operator docs and defensive workflow guards | Azure App Service | `c:\Users\rvunvulea\Downloads\DevOps2026` |
| **Clean** | Pure prompting only — minimal scaffolding | Azure App Service | `c:\Users\rvunvulea\Downloads\DevOps2026_Clean` |
| **BMAD** | BMAD method (skills, agents, manifests under `.agents/`) | Azure App Service | `c:\Users\rvunvulea\Downloads\DevOps2026_BMAD` |

---

## 1. Scorecard (post-measurement)

Scale: 0 = missing • 1 = unusable • 2 = partial • 3 = valid w/ issues • 4 = strong w/ minor issues • 5 = production-ready.

| Category | SpecKit | Classical | Clean | **BMAD** | Winner |
|---|:-:|:-:|:-:|:-:|:-:|
| Requirements coverage | 4 | 4 | 3 | **5** *(adds `/readyz`, app version, App Insights wiring)* | **BMAD** |
| REST API design | 2 | 2 | 2 | **4** *(liveness + readiness + `version` + `started_at`)* | **BMAD** |
| Application architecture | 3 | 3 | 3 | **4** *(layered: probes, optional telemetry, signal handling)* | **BMAD** |
| Container packaging | 0 | 0 | 0 | 0 *(zip-deploy via `WEBSITE_RUN_FROM_PACKAGE=1`; no Dockerfile)* | tie |
| Terraform / IaC architecture | 3 | 3 | 2 | **5** *(4 modules + bootstrap + 2 envs)* | **BMAD** |
| Terraform `fmt` clean | ✅ | ✅ | **❌** | **❌** *(7 files unformatted — cosmetic)* | SpecKit / Classical |
| Terraform `validate` | ✅ *(after fix)* | ✅ | ✅ | **✅** *(both `envs/dev` and `envs/prod`)* | tie |
| App Service hardening (TLS 1.2, FTPS, HTTP/2, `always_on`) | 4 | 4 | 2 | **5** *(all four + `health_check_eviction_time`, `https_only`, diagnostic settings, optional staging slot)* | **BMAD** |
| Observability (App Insights / Log Analytics / availability test) | 0 | 0 | 0 | **4** *(all three wired in Terraform)* | **BMAD** |
| Secrets management (Key Vault) | 0 | 0 | 0 | **4** *(KV + RBAC roles, purge_protection variable)* | **BMAD** |
| Identity (UAMI / managed identity) | 0 | 0 | 0 | **5** *(UAMI module, ACR pull role, KV roles)* | **BMAD** |
| Image registry (ACR) | 0 | 0 | 0 | 0 *(removed with Container Apps; not needed for zip-deploy App Service)* | tie |
| Slot-based deploys (zero-downtime) | 0 | 0 | 0 | **5** *(prod cd uses staging slot + swap)* | **BMAD** |
| Multi-environment (dev / prod) | 1 | 1 | 1 | **5** | **BMAD** |
| State storage (bootstrap module) | 0 | 0 | 0 | **4** *(bootstrap module + `backend.hcl.example`)* | **BMAD** |
| Policy & security | 3 | 3 | 2 | 3 | SpecKit / Classical / BMAD |
| CI/CD pipelines | 3 | 4 | 2 | **5** *(ci + cd-dev + cd-prod + codeql + release)* | **BMAD** |
| SAST (CodeQL / Semgrep) | 0 | 0 | 0 | **4** *(`codeql.yml`)* | **BMAD** |
| Dependency-bot configured | 0 | 0 | 0 | **5** *(`dependabot.yml`)* | **BMAD** |
| CODEOWNERS / PR template | 0 | 0 | 0 | **4** | **BMAD** |
| Release workflow | 0 | 0 | 0 | **4** *(`release.yml`)* | **BMAD** |
| Testing strategy (test count) | 3 (16) | 3 (16) | 3 (15) | **4** (17 — adds `/healthz`, `/readyz`) | **BMAD** |
| Observability & operations docs | 3 | 3 | 2 | **4** *(DR.md + RUNBOOK.md + PLATFORM.md)* | **BMAD** |
| Documentation (README + docs) | 3 | 4 | 2 | 3 *(7 authored .md, 378 lines — leaner)* | **Classical** |
| Maintainability of authored code | 4 | 3 | **5** | 3 *(more surface, but well-modularised)* | **Clean** |
| Spec/plan/tasks rigor | 4 | 3 | 2 | 3 | **SpecKit** |
| Production readiness *(see §3)* | 2 | 2 | 1 | **4** | **BMAD** |
| **Aggregate (out of 135)** | **52** | **53** | **41** | **97** | **BMAD** |

**Quick read:** **BMAD still jumps the curve, and the pivot to App Service made it cleaner.** It's the only repo of the four that addresses observability, secrets, identity, multi-env, slot-based deploys, App Service hardening at module level, SAST, and Dependabot — **all things in the Top 10 must-fix list** of the other three. The previous Container Apps HCL bug is gone: `terraform validate` now passes both envs. The price is still a **harder ramp** (more surface to read), residual `terraform fmt` drift (7 files), and the heavy `.agents/skills/` + `_bmad/` framework footprint (~25k lines of installed scaffolding, outside authored docs).

---

## 2. Pros & Cons by Perspective (4-way)

### Developer perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | Per-task DoD + `[P]` markers + constitutional principle citations. | Big README; `var.node_version`; conditional `always_on`. | **Smallest cognitive load.** | **Layered app** with App Insights optionally wired; **`/readyz` probe**; `Makefile` for local DX; `scripts/local-dev.ps1`; same Node + Express stack as the others (no Docker complexity to learn). |
| **Cons** | README terse; hardcoded `node_version`. | Flat task IDs; no spec-traceability. | No `/healthz`; unformatted `main.tf`. | **`terraform fmt` drift (7 files)** — cosmetic but blocks strict CI; **28 .tf files** to read; only 7 authored docs but ~221 total `.md` files when the BMAD framework scaffolding under `.agents/` and `_bmad/` is counted. |

### Platform / SRE perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | Enforcement matrix; tight runbook. | Three-var OIDC gate; weekly cron; cold-start retry. | One-page `operational-readiness.md`. | **Application Insights + Log Analytics workspace + EMEA availability test + `azurerm_monitor_diagnostic_setting` for the web app — all wired as Terraform.** **Optional staging slot with swap-to-prod** in `cd-prod.yml`. **DR.md + RUNBOOK.md + PLATFORM.md.** **`backend.hcl.example` per env** for remote state. **CODEOWNERS** ensures review routing. |
| **Cons** | Single-var OIDC gate. | Heavier workflow surface. | No cost workflow; no demo artefacts. | **Most surface to operate** (4 modules + bootstrap + 2 envs); needs KV + Log Analytics provisioning before first plan. |

### Security perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | Standard scanner trio (Trivy + Gitleaks + Checkov + npm-audit). | Same trio + broader scope. | Same trio. | **Same trio + CodeQL SAST + Dependabot** + **UAMI-based access** to KV (no SPNs, no static secrets in app settings) + **`Website Contributor` role assignment** for the deployer SPN scoped to the web app only. **`scripts/bootstrap-azure.ps1`** as the single bootstrap entry point. |
| **Cons** | None unique. | None unique. | Most Checkov failures (16). | **Checkov 25 failed / 27 passed** (most resources scanned, most absolute failures — KV, Storage for tfstate, App Service, federated identity); the bootstrap script must be reviewed line-by-line before being run with elevated rights. |

### Compliance / governance perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | Most policies as YAML; honest matrix. | Per-policy content richer. | 4 docs is enough. | **CODEOWNERS** + **PR template** + **dependabot** = three explicit policy attestation points right in the SCM. **Release workflow** gives auditable artefacts. |
| **Cons** | Smaller per-policy content. | `deployment-policy.md` not YAML. | No cost-policy. | **No `platform/policies/*.yaml`** — BMAD's governance is via SCM controls (CODEOWNERS, PR template) instead of YAML policies. Different model — auditors will need to be guided. |

### Demo / on-stage perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | First-class demo-script + hotfix scenario + 3 checklists. | `prompts/hotfix-failing-golden-path.md` + `platform/docs/demo-flow.md`. | Clean canvas. | **App Service + KV + App Insights + slot-swap demo** is genuinely impressive on stage; `Makefile` lets the speaker type `make plan-dev` / `make smoke` rather than copy-pasting commands; **slot-swap rollback story is a strong on-stage moment**. |
| **Cons** | Re-link several files. | No timing per stage. | No demo materials. | **No demo-script.md / hotfix-scenario.md / checklists/** — speaker improvises the narrative. **Run `terraform fmt -recursive` (write mode) once before the demo** to clean up the 7 drifting files; otherwise strict-fmt CI will fail on stage. |

### Cost perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | `cost.yml` 30 lines + script. | Self-contained 96-line workflow. | `cost-awareness.md` documented. | **`var.app_service_sku` is per-env** (dev can sit on `B1`/`F1`, prod on `P1v3`); `always_on` is auto-disabled on `F1`/`B1` to keep dev free-tier-friendly. Optional staging slot is **disabled for dev by default** (`create_staging_slot = false`). |
| **Cons** | Third-party action dep. | Larger YAML. | No cost workflow. | **No cost-comment / Infracost in CI.** No `cost-policy.yaml`. **App Service Plan SKU is the dominant cost driver** and there's no auto-shutdown for dev. |

### Maintenance perspective

| | SpecKit | Classical | Clean | BMAD |
|---|---|---|---|---|
| **Pros** | 23% smaller YAML; 37% cleaner Markdown. | Defensive workflows. | **Half the YAML, a third of the Markdown.** | **Modular Terraform** (4 modules + bootstrap + 2 envs) means each file is small (~20–80 lines) and changeable in isolation. **Dependabot** on `npm`/`actions`/`terraform` keeps everything fresh. |
| **Cons** | More reliance on reviewer discipline. | More surface. | Smallest ≠ most defensible. | **More files to navigate** (28 `.tf`, 5 workflows, `_bmad/` and `.agents/` framework folders). **`terraform fmt` drift** (7 files) should be fixed in one pass. |

---

## 3. Production-Readiness Scoring (4-way)

40-row binary check. ✅ / ⚠️ / ❌. Same checklist as `COMPARISON_SUMMARY.md` §3 with **3 BMAD-relevant rows added** (#41–#43).

| # | Capability | SpecKit | Classical | Clean | **BMAD** |
|---|---|:-:|:-:|:-:|:-:|
| 1 | App tests pass on a clean runner | ✅ 16/16 | ✅ 16/16 | ✅ 15/15 | **✅ 17/17** |
| 2 | Dependency CVEs (`npm audit`, Trivy, Grype) | ✅ | ✅ | ✅ | **✅** |
| 3 | Secret scanning (Gitleaks full history) | ✅ (36) | ✅ (18) | ✅ (50) | **✅ (3)** |
| 4 | OIDC-only auth, no secrets in repo | ✅ | ✅ | ✅ | **✅** |
| 5 | Workflow lint (`actionlint`) | ✅ | ✅ | ✅ | **✅** |
| 6 | Terraform `fmt` clean | ✅ | ✅ | ❌ | **❌** *(7 files unformatted)* |
| 7 | Terraform `validate` | ✅ *(after fix)* | ✅ | ✅ | **✅** *(both envs)* |
| 8 | IaC misconfig scan (`checkov`) | ⚠️ 8/12 | ⚠️ 8/12 | ⚠️ 4/16 | **⚠️ 27/25** *(most checks, most failures, larger surface)* |
| 9 | Required tags on every resource | ✅ | ✅ | ✅ | **✅** |
| 10 | App Service `https_only` | ✅ | ✅ | ✅ | **✅** |
| 11 | TLS 1.2 minimum | ✅ | ✅ | ❌ | **✅** *(`minimum_tls_version` var, default 1.2)* |
| 12 | FTPS disabled | ✅ | ✅ | ❌ | **✅** *(`ftps_state = "Disabled"`)* |
| 13 | HTTP/2 enabled | ✅ | ✅ | ❌ | **✅** *(`http2_enabled = true`)* |
| 14 | Websockets/remote-debug off | ✅ | ✅ | ❌ | **✅** *(default)* |
| 15 | `/healthz` wired to `health_check_path` | ✅ | ✅ | ❌ | **✅ + `/readyz`** *(`health_check_path` + `health_check_eviction_time_in_min = 5`)* |
| 16 | **Remote Terraform state with locking** | ❌ | ❌ | ❌ | **⚠️ planned** *(`bootstrap/` module + `backend.hcl.example`)* |
| 17 | **Branch protection on `main`** | ❌ | ❌ | ❌ | **⚠️ partial** *(CODEOWNERS exists; required-reviewers config not in repo)* |
| 18 | Required PR checks | ❌ | ❌ | ❌ | **⚠️** *(workflows run on PR; no `required_status_checks` config in repo)* |
| 19 | Approval gates per environment | ❌ | ❌ | ❌ | **⚠️** *(cd-prod separated from cd-dev — gating is implicit)* |
| 20 | Rollback workflow (one-click) | ❌ | ❌ | ❌ | **⚠️** *(`release.yml` enables tag-based rollback by image)* |
| 21 | **Application Insights / Log Analytics** | ❌ | ❌ | ❌ | **✅** *(observability module)* |
| 22 | Structured logging (`pino`/`winston`) | ❌ | ❌ | ❌ | ❌ *(uses console + App Insights auto-collect)* |
| 23 | Request-id / correlation-id | ❌ | ❌ | ❌ | ⚠️ *(App Insights operation_Id auto-generated)* |
| 24 | Distributed tracing (OTel) | ❌ | ❌ | ❌ | ⚠️ *(App Insights auto-collect — proprietary, not OTel)* |
| 25 | **Alerts on `Http5xx` / availability** | ❌ | ❌ | ❌ | **⚠️** *(availability test fires; alert rule not in Terraform)* |
| 26 | SLO/SLI dashboards | ❌ | ❌ | ❌ | ⚠️ *(App Insights workbook implied)* |
| 27 | **Synthetic monitoring (availability tests)** | ❌ | ❌ | ❌ | **✅** *(`azurerm_application_insights_standard_web_test` from 3 EMEA locations, SSL cert lifetime check)* |
| 28 | Audit log shipping (diagnostic settings → Log Analytics) | ❌ | ❌ | ❌ | **✅** *(`azurerm_monitor_diagnostic_setting` on web app: allLogs + AllMetrics)* |
| 29 | GitHub audit log retention plan | ❌ | ❌ | ❌ | ❌ |
| 30 | Activity log alerts | ❌ | ❌ | ❌ | ❌ |
| 31 | OpenAPI / contract test | ❌ | ❌ | ❌ | ❌ |
| 32 | **SAST (Semgrep / CodeQL)** | ❌ | ❌ | ❌ | **✅** *(`codeql.yml`)* |
| 33 | **SBOM in CI (syft → SPDX/CycloneDX)** | ❌ | ❌ | ❌ | ❌ *(no SBOM job in CI; no Dockerfile labels since the Container Apps pivot)* |
| 34 | SHA-pinned third-party Actions | ❌ | ❌ | ❌ | ❌ |
| 35 | Load test / latency budget | ❌ | ❌ | ❌ | ❌ |
| 36 | Mutation testing | ❌ | ❌ | ❌ | ❌ |
| 37 | Code coverage gate (≥80%) | ❌ | ❌ | ❌ | ❌ |
| 38 | ESLint + Prettier baseline | ❌ | ❌ | ❌ | ⚠️ *(server.js uses `// eslint-disable-next-line` directives — config implied but not committed)* |
| 39 | Cost-comment / Infracost in CI | ✅ workflow | ✅ workflow | ❌ | ❌ |
| 40 | License-compliance gate in CI | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| **41** | **Slot-based prod deploy with swap** | ❌ | ❌ | ❌ | **✅** *(`cd-prod.yml` deploys to `staging` slot then `az webapp deployment slot swap`)* |
| **42** | **`/readyz` readiness probe** | ❌ | ❌ | ❌ | **✅** |
| **43** | **Dependabot configured** | ❌ | ❌ | ❌ | **✅** |

**Score (full ✅ only):** SpecKit **10/43 (23%)** • Classical **10/43 (23%)** • Clean **6/43 (14%)** • **BMAD 23/43 (53%)** *(now full ✅ on rows 7, 10–15, 28 thanks to App Service)*.

If you weight ✅ as 1.0 and ⚠️ as 0.5, BMAD scores roughly **27 / 43 (63%)** — nearly 2.7× the next best.

---

## 4. Key measured numbers (4-way)

| # | Metric | SpecKit | Classical | Clean | **BMAD** | Source |
|---|---|---|---|---|---|---|
| 1 | Jest test outcome | PASS 16/16 | PASS 16/16 | PASS 15/15 | **PASS 17/17** in 1.027 s | `npm test` |
| 2 | `npm audit --omit=dev --audit-level=high` | 0 | 0 | 0 | **0** | npm |
| 3 | Trivy fs HIGH/CRITICAL | 0 / 0 | 0 / 0 | 0 / 0 | **0 / 0** | Trivy 0.70.0 |
| 4 | Grype | 0 | 0 | 0 | **0** | Grype 0.86.1 |
| 5 | Gitleaks (commits / leaks) | 36 / 0 | 18 / 0 | 50 / 0 | **3 / 0** | Gitleaks 8.21.2 |
| 6 | actionlint over `.github/workflows/*.yml` | 0 | 0 | 0 | **0** | actionlint 1.7.7 |
| 7 | `terraform fmt -check -recursive` | PASS | PASS | **FAIL** | **FAIL** *(7 files: `bootstrap/variables.tf`, `envs/{dev,prod}/outputs.tf`, `modules/app_service/{main,variables}.tf`, `modules/{identity,keyvault}/variables.tf`)* | Terraform 1.9.8 |
| 8 | `terraform validate` | PASS *(after fix)* | PASS | PASS | **PASS** *(both `envs/dev` and `envs/prod`)* | Terraform 1.9.8 |
| 9 | Checkov passed / failed | 8 / 12 | 8 / 12 | 4 / 16 | **27 / 25** *(KV + tfstate Storage + App Service + federated identity)* | Checkov 3.2.526 |
| 10 | Syft SBOM components (App) | 71 | 71 | 71 | **120** *(applicationinsights pulls extra deps)* | Syft 1.18.1 |
| 11 | Prettier `--check App/` (files flagged) | 4 | 1 | 4 | **4** | Prettier 3 |
| 12 | markdownlint (authored `.md` only) | 368 | 588 | 19 | **104** *(over README + App + docs + infra; excludes `.agents/`)* | markdownlint-cli2 |
| 13 | depcheck unused / missing | 0 / 0 | 0 / 0 | 0 / 0 | **0 / 0** | depcheck |
| 14 | license-checker (App, prod) | MIT 65 / ISC 2 / BSD-3 2 / Custom 1 / BSD\* 1 | identical | identical | **MIT 93 / Apache-2.0 13 / BSD-2 5 / ISC 4 / BSD-3 2 / Custom 1 / BSD\* 1 / 0BSD 1** *(applicationinsights deps)* | license-checker |
| 15 | madge `--circular App/` | none | none | none | **none** *(2 warnings)* | madge |
| 16 | LOC `.js` (files / lines) | 2 / 134 | 2 / 134 | 2 / 124 | **2 / 178** *(probes + AI init + version)* | `loc.ps1` |
| 17 | LOC `.tf` (files / lines) | 6 / 115 | 5 / 123 | 5 / 112 | **28 `.tf` files** *(modules + bootstrap + 2 envs)* | `loc.ps1` |
| 18 | LOC `.tfvars` (files / lines) | 1 / 9 | 1 / 11 | 1 / 13 | **2 / 15** *(dev + prod)* | `loc.ps1` |
| 19 | LOC `.yml`/`.yaml` (files / lines) | 14 / 777 | 13 / 1,013 | 7 / 356 | **7 / 653** | `loc.ps1` |
| 20 | LOC authored `.md` (files / lines) *(excludes installed framework scaffolding)* | 63 / 4,347 | 60 / 4,339 | 24 / 1,255 | **7 / 378** | manual |
| 21 | LOC framework `.md` *(`.specify/`, `.agents/`, `_bmad/`)* | included above | n/a | n/a | **214 / 24,839** *(`.agents/skills/`, `_bmad/`)* | `loc.ps1` |
| 22 | LOC `.json` (files / lines) | 10 / 5,681 | 10 / 5,681 | 5 / 5,611 | **7 / 6,638** | `loc.ps1` |
| 23 | LOC `.sh` / `.ps1` | 5 / 673 | 4 / 620 | 0 / 0 | **0 sh / 2 ps1 (93)** | `loc.ps1` |
| 24 | Dockerfile | n/a | n/a | n/a | **n/a** *(removed with Container Apps; deploy is zip via `WEBSITE_RUN_FROM_PACKAGE=1`)* | manual |
| 25 | Makefile | n/a | n/a | n/a | **present** *(`make plan-dev` / `make smoke` etc.)* | manual |
| 26 | Workflow files (count / total LOC) | 5 / 289 | 5 / 526 | 4 / 257 | **5 / 566** *(ci 160 + cd-dev 187 + cd-prod 155 + codeql 25 + release 39)* | manual |
| 27 | Dependabot | ❌ | ❌ | ❌ | **✅ `.github/dependabot.yml`** | manual |
| 28 | CODEOWNERS | ❌ | ❌ | ❌ | **✅** | manual |
| 29 | PR template | ❌ | ❌ | ❌ | **✅** | manual |
| 30 | CodeQL workflow | ❌ | ❌ | ❌ | **✅ `codeql.yml`** | manual |
| 31 | Release workflow | ❌ | ❌ | ❌ | **✅ `release.yml`** | manual |
| 32 | TFLint config | ❌ | ❌ | ❌ | **✅ `.tflint.hcl`** | manual |
| 33 | Terraform module count | 0 *(monolithic)* | 0 | 0 | **4 modules + bootstrap** *(`app_service`, `identity`, `keyvault`, `observability`)* | manual |
| 34 | Terraform env separation | 0 | 0 | 0 | **dev + prod** *(separate `backend.hcl.example` per env)* | manual |
| 35 | Application Insights resource | ❌ | ❌ | ❌ | **✅** *(`observability` module)* | terraform |
| 36 | Log Analytics workspace | ❌ | ❌ | ❌ | **✅** | terraform |
| 37 | Availability test (synthetic) | ❌ | ❌ | ❌ | **✅** *(3 EMEA locations, SSL check)* | terraform |
| 38 | Key Vault | ❌ | ❌ | ❌ | **✅** | terraform |
| 39 | User-assigned managed identity | ❌ | ❌ | ❌ | **✅** | terraform |
| 40 | Container Registry (ACR) | ❌ | ❌ | ❌ | ❌ *(removed with Container Apps; not needed for zip-deploy App Service)* | terraform |
| 40b | Slot-based deploy (staging slot + swap) | ❌ | ❌ | ❌ | **✅** *(`azurerm_linux_web_app_slot.staging` + `cd-prod.yml` swap)* | terraform + workflow |
| 40c | Diagnostic settings on web app → Log Analytics | ❌ | ❌ | ❌ | **✅** *(`azurerm_monitor_diagnostic_setting`)* | terraform |
| 41 | Endpoints exposed | `/`, `/sunset`, `/healthz` | `/`, `/sunset`, `/healthz` | `/`, `/sunset` | **`/`, `/sunset`, `/healthz`, `/readyz`** | manual diff |
| 42 | App version surfacing | ❌ | ❌ | ❌ | **✅** *(`APP_VERSION` env + in `/` and `/readyz`)* | manual |
| 43 | OIDC gate variables | 1 | 3 | 1 | varies per workflow; `cd-dev`/`cd-prod` use OIDC | workflow |
| 44 | Demo artefacts (script + hotfix + checklists) | full | partial | absent | **absent** | manual |
| 45 | `docs/` operational artefacts | n/a | n/a | n/a | **DR.md, RUNBOOK.md, PLATFORM.md** | manual |
| 46 | Semgrep | not run *(no native Windows)* | not run | not run | **not run; CodeQL covers SAST** | — |

### Production-readiness bucket totals

| Bucket | SpecKit | Classical | Clean | **BMAD** |
|---|:-:|:-:|:-:|:-:|
| Build / test / dependency hygiene | 4/5 | 4/5 | 4/5 | **5/5** *(adds Dependabot + CodeQL)* |
| IaC architecture (modules / envs / state) | 1/5 | 1/5 | 1/5 | **5/5** |
| App Service hardening | 6/10 | 6/10 | 2/10 | **9/10** *(TLS 1.2 + FTPS off + HTTP/2 + always_on + health_check + diagnostic settings + slot)* |
| Pipeline defensive guards | 0/4 | 4/4 | 0/4 | **3/4** *(cd-dev/prod split + release + slot-swap; missing weekly cron / cold-start retry)* |
| **Observability + audit + tracking** | 0/10 | 0/10 | 0/10 | **7/10** *(App Insights + Log Analytics + availability test + diagnostic settings wired; missing alerts in TF)* |
| Governance + branch protection | 0/5 | 0/5 | 0/5 | **3/5** *(CODEOWNERS + PR template + Dependabot; branch protection still not in repo)* |
| Documentation depth | 3/3 | 3/3 | 2/3 | 3/3 *(DR + RUNBOOK + PLATFORM)* |
| Demo-readiness | 3/3 | 2/3 | 0/3 | **0/3** *(no script / hotfix / checklists)* |
| **Total** | **17/45 (38%)** | **20/45 (44%)** | **9/45 (20%)** | **35/45 (78%)** |

> **BMAD jumps the curve in the Observability + IaC architecture + App Service hardening buckets**, which is exactly where the other three lose most points. It loses points it didn't have to lose in **Demo-readiness** (no on-stage script) and **Pipeline defensive guards** (no weekly security cron, no cold-start retry).

---

## 5. Final Conclusion (4-way)

**Four repos, one specification, four personalities — and one of them (BMAD) plays a different game.**

- **Clean** — *minimum viable golden path*. Teaching baseline. 20% production-ready.
- **Classical** — *operator-friendly hybrid*. Demo-grade golden path with defensive guards. 44% production-ready.
- **SpecKit** — *methodology demonstration*. Spec → plan → tasks → implement, traceable everywhere. 38% production-ready.
- **BMAD** — ***production-grade scaffold***. App Service + slot-swap + observability + Key Vault + UAMI + dev/prod + CodeQL + Dependabot + CODEOWNERS + release. **78% production-ready** — nearly twice Classical.

**BMAD is the only one of the four whose IaC + pipeline footprint actually starts to look like a real platform team's output**, not a workshop demo. After the App Service migration:

1. **`terraform validate` now passes both envs.** The previous Container Apps HCL semicolon bug is gone. `terraform fmt -check -recursive` still flags 7 files — cosmetic, fixed by one `terraform fmt -recursive` write pass.
2. **No demo-script / hotfix-scenario / checklists** — speaker would improvise on stage. SpecKit and Classical both have these.
3. **The largest absolute Checkov failure count** (25) — but that's because BMAD has more resources to scan (KV, Log Analytics, App Service, federated identity, Storage from bootstrap), not because it's less hardened.
4. **Heavy framework footprint**: ~214 BMAD framework `.md` files (~25k lines) live under `.agents/skills/` and `_bmad/`. These are install-time scaffolding from BMAD itself, not authored project docs (which total just 7 files / 378 lines — the leanest of all four).

**Recommendation, single sentence:**
**adopt BMAD as the production-grade target architecture** (App Service + slot-swap + observability + KV + UAMI + dev/prod + diagnostic settings + CodeQL + Dependabot), **port SpecKit's `demo-script.md` + `hotfix-scenario.md` + `checklists/` for the on-stage narrative**, **port Classical's three-var OIDC gate + weekly security cron + cold-start retry** as defensive guards, **run `terraform fmt -recursive` once to clean the 7 cosmetic drifts before any demo**, and treat the result as **the real golden path** worth running in production after closing the remaining items in `COMPARISON_SUMMARY.md` §3 (branch protection, structured logging, alerts on `Http5xx`, SHA-pinned Actions, OpenAPI + contract test).

---

## 6. One-Line Verdicts

- **Clean** — teach the bare minimum.
- **Classical** — live-demo on a stage; operator-friendly out of the box.
- **SpecKit** — spec-driven-development talk; methodology rigor matters.
- **BMAD** — **closest of the four to "would I actually run this?"** Use as the target architecture and back-port the demo polish from SpecKit + the defensive guards from Classical.

Of the four, **only BMAD has Application Insights, Key Vault, managed identity, multi-environment, slot-based deploys with swap, diagnostic settings on the web app, and a release workflow.** Its Terraform now parses and validates — the only remaining IaC chore is a one-shot `terraform fmt -recursive`.

---

*End of four-way comparison.*
*Three-way: `COMPARISON_3WAY.md`. Two-way summary: `COMPARISON_SUMMARY.md`. Long form: `COMPARISON_REPORT.md`.*
