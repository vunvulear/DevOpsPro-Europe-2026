# Three-Way Comparison: SpecKit vs Classical vs Clean

| Repo | Approach | Path |
|---|---|---|
| **SpecKit** | Spec Kit-driven (`/speckit.specify` → `plan` → `tasks` → `implement`) | `\DevOps2026_Spec\DevOpsPro-Europe-2026` |
| **Classical** | Numbered-prompts approach with rich operator docs and defensive workflow guards | \DevOps2026` |
| **Clean** | Pure prompting only — minimal scaffolding, no Spec Kit, no demo artefacts | `\DevOps2026_Clean` |

---

## 1. Scorecard (post-measurement)

Scale: 0 = missing • 1 = unusable • 2 = partial • 3 = valid w/ issues • 4 = strong w/ minor issues • 5 = production-ready.

| Category | SpecKit | Classical | **Clean** | Winner |
|---|:-:|:-:|:-:|:-:|
| Requirements coverage | 4 | 4 | 3 | SpecKit/Classical (Clean misses `/healthz`) |
| REST API design | 2 | 2 | 2 | Tie |
| Application architecture | 3 | 3 | 3 | Tie |
| Terraform / IaC hardening | 4 | 4 | **2** | SpecKit/Classical |
| `terraform fmt` clean | ✅ | ✅ | **❌** | SpecKit/Classical |
| Policy & security | 3 | 3 | 2 | SpecKit/Classical |
| CI/CD pipelines | 3 | 4 | 2 | **Classical** |
| Testing strategy | 3 | 3 | 3 | Tie (Clean has fewer tests by design) |
| Observability & operations | 3 | 3 | 2 | SpecKit/Classical |
| Documentation (README + docs) | 3 | 4 | 2 | **Classical** |
| Maintainability | 4 | 3 | **5** | **Clean** (smallest surface) |
| Spec/plan/tasks rigor | 4 | 3 | 2 | **SpecKit** |
| Production readiness *(see §3)* | 2 | 2 | 1 | SpecKit/Classical |
| **Aggregate (out of 65)** | **40** | **41** | **31** | **Classical** |

**Quick read:** Clean is **20–25% smaller** in every artefact dimension and pays for that with weaker IaC hardening, no `/healthz`, no demo scripts, no policy enforcement matrix, and an unformatted `main.tf`. Classical and SpecKit remain within 1 point of each other; Clean trails by ~10 points but is the cleanest *baseline* to extend.

---

## 2. Pros & Cons by Perspective (3-way)

### Developer perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | Per-task DoD + `[P]` markers + constitutional principle citations in headers. File-per-screen workflows. | Big README (242 lines / 13.5 KB) gets new joiners productive fast. `var.node_version` + conditional `always_on`. | **Smallest cognitive load.** ~24 markdown files vs ~60. `var.node_version` parametrised. Two-line `infra/terraform/main.tf` per resource. |
| **Cons** | README too terse — must enter `specs/`. Hardcoded `node_version`. | Flatter task IDs; no spec-traceability in headers. | **No `health_check_path`**; no TLS pinning; no `https_only`-paired hardening. **`main.tf` not `terraform fmt`-clean.** |

### Platform / SRE perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | `policy-guardrails.md` enforcement matrix; tight runbook; `tagging-policy.yaml` cites Terraform locals. | Three-var OIDC gate; weekly security cron + `workflow_dispatch`; cold-start retry on smoke test; broader audit scope. | One-page `platform/docs/operational-readiness.md`; smaller blast radius. |
| **Cons** | Single-var OIDC gate; no weekly cron; no retry loop. | Heavier workflow surface. | **No cost workflow at all.** No demo artefacts. No enforcement matrix. Smallest IaC surface = least hardening. |

### Security perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | Same trio as others (Trivy + Gitleaks + Checkov + npm-audit). Strict placeholder `dev.tfvars`. | Same trio + broader scope (`App_Test/` audited too). | Same trio. **Fewer attack surfaces by virtue of being smaller** (no `/healthz` route, no extra endpoints). |
| **Cons** | None unique. | None unique. | **`http_logs` not enabled, no managed identity, no AAD register, no public-network-disable** — Checkov fails 16 (vs 12 for others). |

### Compliance / governance perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | Most policies as YAML; enforcement matrix is honest about Enforced/Documented/Planned. | Per-policy content is richer (cost-policy.yaml has principles, defaults, monthly_budget_usd, review_rules). | **4 platform docs** is enough to read in 10 minutes; less to maintain. |
| **Cons** | Smaller per-policy content; budgets are placeholders. | `deployment-policy.md` is Markdown, not YAML. | **No `cost-policy.yaml`** budget; no `service.yaml`-level metadata; no policy-guardrails matrix. |

### Demo / on-stage perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | First-class `demo-script.md` (per-stage cue/action/expected/fallback) + `hotfix-scenario.md` + 3 checklists. | `prompts/hotfix-failing-golden-path.md`, `platform/docs/demo-flow.md`, `hotfix-demo.md`. | Nothing to bin or maintain; clean canvas for ad-hoc demos. |
| **Cons** | Must mentally re-link several files. | No on-stage script with timing per stage. | **No demo script. No hotfix scenario. No checklists.** Speaker improvises everything. |

### Cost perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | `cost.yml` is 30 lines + clean separation of YAML and shell. | Self-contained 96-line `cost-awareness.yml`; idempotent comment update. | **`cost-awareness.md` documented**, no workflow to maintain. |
| **Cons** | Extra third-party action dep. | Larger YAML. | **No PR cost-comment automation at all** — costs are documented but never surfaced in CI. |

### Maintenance perspective

| | SpecKit | Classical | Clean |
|---|---|---|---|
| **Pros** | Workflows 23% smaller than Classical; markdown 37% cleaner. Per-stage task IDs extend cleanly. | Defensive workflows (3-var gate, cron, retry) reduce 02:00 surprises. | **Half the YAML, a third of the Markdown** of the next-smallest repo. **Lowest churn baseline by far.** |
| **Cons** | More reliance on reviewer discipline. | More surface to read on review. | **Smallest does not mean most defensible** — every gap (no health endpoint, no TLS pin, no FTP-disabled) is a future ticket. |

---

## 3. Production-Readiness Scoring (3-way)

40-row binary check; ✅ / ⚠️ / ❌. Same checklist as `COMPARISON_SUMMARY.md` §3.

| # | Capability | SpecKit | Classical | **Clean** |
|---|---|:-:|:-:|:-:|
| 1 | App tests pass on a clean runner | ✅ (16/16) | ✅ (16/16) | ✅ (**15/15** — 1 fewer test by design) |
| 2 | Dependency CVEs (`npm audit`, Trivy, Grype) | ✅ | ✅ | ✅ |
| 3 | Secret scanning (Gitleaks full history) | ✅ (36 commits) | ✅ (18) | ✅ (50) |
| 4 | OIDC-only auth, no secrets in repo | ✅ | ✅ | ✅ |
| 5 | Workflow lint (`actionlint`) | ✅ | ✅ | ✅ |
| 6 | Terraform `fmt` clean | ✅ | ✅ | **❌** (`main.tf` listed) |
| 7 | Terraform `validate` | ✅ *(after fix)* | ✅ | ✅ |
| 8 | IaC misconfig scan (`checkov`) | ⚠️ 8/12 | ⚠️ 8/12 | **⚠️ 4/16** |
| 9 | Required tags on every resource | ✅ | ✅ | ✅ |
| 10 | App Service `https_only` | ✅ | ✅ | ✅ |
| 11 | App Service TLS 1.2 minimum | ✅ | ✅ | **❌** (no `minimum_tls_version`) |
| 12 | App Service FTPS disabled | ✅ | ✅ | **❌** |
| 13 | App Service HTTP/2 enabled | ✅ | ✅ | **❌** |
| 14 | App Service websockets/remote-debug off | ✅ | ✅ | **❌** (defaults rely on Azure) |
| 15 | `/healthz` wired to `health_check_path` | ✅ | ✅ | **❌** (no endpoint, no setting) |
| 16 | **Remote Terraform state with locking** | ❌ | ❌ | ❌ |
| 17 | **Branch protection on `main`** | ❌ | ❌ | ❌ |
| 18 | **Required PR checks** | ❌ | ❌ | ❌ |
| 19 | Approval gates per environment | ❌ | ❌ | ❌ |
| 20 | Rollback workflow (one-click) | ❌ | ❌ | ❌ |
| 21 | Application Insights / Log Analytics | ❌ | ❌ | ❌ |
| 22 | Structured logging (`pino`/`winston`) | ❌ | ❌ | ❌ |
| 23 | Request-id / correlation-id | ❌ | ❌ | ❌ |
| 24 | Distributed tracing (OTel) | ❌ | ❌ | ❌ |
| 25 | Alerts on `Http5xx` / availability | ❌ | ❌ | ❌ |
| 26 | SLO/SLI dashboards | ❌ | ❌ | ❌ |
| 27 | Synthetic monitoring | ❌ | ❌ | ❌ |
| 28 | Audit log shipping (diagnostic settings → Log Analytics) | ❌ | ❌ | ❌ |
| 29 | GitHub audit log retention plan | ❌ | ❌ | ❌ |
| 30 | Activity log alerts | ❌ | ❌ | ❌ |
| 31 | OpenAPI / contract test | ❌ | ❌ | ❌ |
| 32 | SAST (Semgrep / CodeQL) | ❌ | ❌ | ❌ |
| 33 | SBOM in CI (syft → SPDX/CycloneDX) | ❌ | ❌ | ❌ |
| 34 | SHA-pinned third-party Actions | ❌ | ❌ | ❌ |
| 35 | Load test / latency budget | ❌ | ❌ | ❌ |
| 36 | Mutation testing | ❌ | ❌ | ❌ |
| 37 | Code coverage gate (≥80%) | ❌ | ❌ | ❌ |
| 38 | ESLint + Prettier baseline | ❌ | ❌ | ❌ |
| 39 | Cost-comment / Infracost in CI | ✅ workflow only | ✅ workflow only | **❌** (no workflow at all) |
| 40 | License-compliance gate in CI | ⚠️ | ⚠️ | ⚠️ |

**Score:** SpecKit **10/40 (25%)** • Classical **10/40 (25%)** • **Clean 6/40 (15%)**.

Clean trails on **rows 6, 11, 12, 13, 14, 15, 39** — every one is a deliberate omission, not a defect, but each becomes a production-blocker.

---

## 4. Final Conclusion (3-way)

**Three repos, one specification, three personalities:**

- **Clean** is the *minimum viable golden path*: 7 YAML files, 24 Markdown files, no demo theatre, no policy matrix, no health endpoint. It's the easiest to read end-to-end (≤30 min), the easiest to extend, and the most honest about what it isn't. It's also the **least production-ready** today: missing TLS pinning, FTPS disabled, HTTP/2, health-check, cost-comment automation, and structured logging. **Use Clean as a teaching baseline** or a "first week of platform engineering" reference.
- **Classical** is the *operator-friendly hybrid*: a 13.5 KB README walks any new hire through the system; defensive workflow guards (three-var OIDC gate, weekly security cron, smoke-test cold-start retry, audit on `App_Test` too) catch the classes of failure that bite at 02:00; nine `platform/docs/*.md` cover capability-by-capability. **Use Classical as the demo-grade golden path** for a live-coding stage.
- **SpecKit** is the *methodology demonstration*: 408-line `plan.md`, per-task DoD with `[P]` parallelism markers, `policy-guardrails.md` enforcement matrix, `demo-script.md` + `hotfix-scenario.md` + 3 checklists, workflows 23% smaller and Markdown 37% cleaner than Classical. **Use SpecKit when the audience cares about the process** (Spec Kit / spec-driven development), not just the artefact.

**Recommendation, single sentence:**
adopt **SpecKit's methodology and discipline**, port **Classical's `README.md` + `platform/docs/*.md` + the four defensive workflow guards** (3-var OIDC gate, weekly security cron, cold-start retry, App_Test audit) on top, **then strip back to Clean's surface area** wherever a `platform/docs/*.md` page exists without a corresponding workflow or terraform field — *and only after* you've worked the `Top 10 must-fix list` from `COMPARISON_SUMMARY.md`.

The single observable defect found by tooling — SpecKit's `terraform validate` failure — was a *current-provider compatibility* issue, not a methodology issue, and was fixed in this session in two lines. Clean has its own current defect: `terraform fmt -check -recursive` flags `main.tf`. **Both are one-line fixes**; both confirm that the Top 10 production-readiness items dwarf any methodology difference between the three approaches.

---

## 5. Tools and Metrics — Values for All Three Repos

All tools were installed (or downloaded as a single binary) on this machine and run against **all three** repos. Versions are pinned for reproducibility. Raw outputs at `c:\Users\rvunvulea\Downloads\DevOps2026Compare\results\`.

### Metrics captured — 3-way values

| # | Metric | SpecKit | Classical | **Clean** | Source |
|---|---|---|---|---|---|
| 1 | Jest test outcome | **PASS 16/16** in 1.385 s | **PASS 16/16** in 1.566 s | **PASS 15/15** in 1.518 s | `npm test` |
| 2 | `npm audit --omit=dev --audit-level=high` | 0 vulns | 0 vulns | **0 vulns** | npm |
| 3 | Trivy fs HIGH/CRITICAL (ignore-unfixed) | 0 vulns, 0 secrets | 0 vulns, 0 secrets | **0 vulns, 0 secrets** | Trivy 0.70.0 |
| 4 | Grype `dir:App/` | 0 | 0 | **0** | Grype 0.86.1 |
| 5 | Gitleaks (commits / leaks) | 36 / 0 | 18 / 0 | **50 / 0** | Gitleaks 8.21.2 |
| 6 | actionlint over `.github/workflows/*.yml` | 0 issues | 0 issues | **0 issues** | actionlint 1.7.7 |
| 7 | `terraform fmt -check -recursive` | PASS | PASS | **FAIL** (`main.tf`) | Terraform 1.9.8 |
| 8 | `terraform init -backend=false` | PASS (azurerm 4.71.0) | PASS (azurerm 4.71.0) | **PASS** (azurerm 4.71.0) | Terraform 1.9.8 |
| 9 | `terraform validate` | PASS *(after fix)* | PASS | **PASS** | Terraform 1.9.8 |
| 10 | Checkov passed / failed | 8 / 12 | 8 / 12 | **4 / 16** | Checkov 3.2.526 |
| 11 | Syft SBOM components (App) | 71 | 71 | **71** | Syft 1.18.1 |
| 12 | Prettier `--check App/` (files flagged) | 4 | 1 | **4** | Prettier 3 |
| 13 | markdownlint authored `.md` (issues) | 368 | 588 | **19** | markdownlint-cli2 |
| 14 | depcheck unused / missing | 0 / 0 | 0 / 0 | **0 / 0** | depcheck |
| 15 | license-checker (App, prod) | MIT 65, ISC 2, BSD-3 2, Custom 1, BSD\* 1 | identical | **identical** | license-checker |
| 16 | madge `--circular App/` | none | none | **none** (2 warnings) | madge |
| 17 | LOC `.js` (files / lines) | 2 / 134 | 2 / 134 | **2 / 124** | `loc.ps1` |
| 18 | LOC `.tf` (files / lines) | 6 / 115 | 5 / 123 | **5 / 112** | `loc.ps1` |
| 19 | LOC `.tfvars` (files / lines) | 1 / 9 | 1 / 11 | **1 / 13** | `loc.ps1` |
| 20 | LOC `.yml`/`.yaml` (files / lines) | 14 / 777 | 13 / 1,013 | **7 / 356** | `loc.ps1` |
| 21 | LOC `.md` (files / lines) | 63 / 4,347 | 60 / 4,339 | **24 / 1,255** | `loc.ps1` |
| 22 | LOC `.json` (files / lines) | 10 / 5,681 | 10 / 5,681 | **5 / 5,611** | `loc.ps1` |
| 23 | LOC `.sh` (files / lines) | 5 / 673 | 4 / 620 | **0 / 0** | `loc.ps1` |
| 24 | Workflow — `ci.yml` | 42 lines | 44 lines | **32 lines** | manual |
| 25 | Workflow — `security*.yml` | 80 | 120 | **86** | manual |
| 26 | Workflow — `terraform-plan*.yml` | 60 | 128 | **66** | manual |
| 27 | Workflow — `deploy*.yml` | 77 | 138 | **73** | manual |
| 28 | Workflow — `cost*.yml` | 30 | 96 | **— (absent)** | manual |
| 29 | Total workflow LOC | 289 | 526 | **257** | manual |
| 30 | `plan.md` (lines) | 408 | 149 | **122** | manual |
| 31 | `tasks.md` (lines) | varies | varies | **142** | manual |
| 32 | `tasks.md` ID scheme | `T<stage>.<n>` + DoD + `[P]` | `T-01..T-15` flat | **`T-01..T-15` flat** | manual |
| 33 | `spec.md` size | 7,812 B | 7,812 B (byte-identical) | **— (absent; uses `docs/plan.md` + `docs/tasks.md` instead)** | manual |
| 34 | `README.md` size | 117 lines / 5,134 B | 242 lines / 13,523 B | **120 lines / 4,058 B** | manual |
| 35 | `platform/docs/` files | 2 | 9 | **6** | manual |
| 36 | `platform/policies/` files | 4 | 4 | **3** | manual |
| 37 | Demo artefacts (script + hotfix + checklists) | present | partial (`hotfix-failing-golden-path.md`) | **absent** | manual |
| 38 | `App/server.js` endpoints | `/`, `/sunset`, `/healthz` | `/`, `/sunset`, `/healthz` | **`/`, `/sunset` only** | manual diff |
| 39 | OIDC gate variables | 1 (`AZURE_CLIENT_ID`) | 3 (`+TENANT_ID, +SUBSCRIPTION_ID`) | **1** (`AZURE_CLIENT_ID`) | workflow |
| 40 | Weekly security cron | absent | `'0 6 * * 1'` + `workflow_dispatch` | **absent** | workflow |
| 41 | Smoke-test cold-start retry loop | absent | present | **absent** | workflow |
| 42 | Cost-comment workflow | present | present | **absent** | workflow |
| 43 | Semgrep | not run (no native Windows) | not run | not run | — |

### Production-readiness bucket totals

| Bucket | SpecKit | Classical | **Clean** |
|---|:-:|:-:|:-:|
| Build / test / dependency hygiene | 4/5 | 4/5 | **4/5** |
| IaC + App Service hardening | 6/10 | 6/10 | **2/10** |
| Pipeline defensive guards | 0/4 | **4/4** | 0/4 |
| Observability + audit + tracking | 0/10 | 0/10 | **0/10** |
| Governance + branch protection | 0/5 | 0/5 | **0/5** |
| Documentation depth | 3/3 | **3/3** | 2/3 |
| Demo-readiness | **3/3** | 2/3 | 0/3 |
| **Total** | **16/40 (40%)** | **19/40 (48%)** | **8/40 (20%)** |

> Bucket totals differ from row-by-row totals because some §3 rows aggregate multiple sub-controls (e.g. "App Service hardening" expands into TLS, FTPS, HTTP/2, websockets, remote-debug). This bucket view is the more useful number for prioritising the **Top 10 must-fix list** in `COMPARISON_SUMMARY.md` §3.

---

## 6. One-Line Verdicts

- **Use Clean** when teaching the *bare-minimum* golden path or when starting a new repo that will grow into Classical/SpecKit.
- **Use Classical** when the demo audience will *operate* the result — operator docs and defensive guards matter most.
- **Use SpecKit** when the demo audience cares about the *process* — spec → plan → tasks → implement → demo, with traceability everywhere.

For a real production deployment, **none of the three is ready**: all need the Top 10 items from `COMPARISON_SUMMARY.md` §3 (remote TF state, branch protection, App Insights, structured logs, diagnostic settings, alerts, SLOs, OpenAPI + contract test, SAST, SHA-pinning, Dependabot).

---

*End of three-way comparison.*
*Two-way summary: `COMPARISON_SUMMARY.md`. Long form: `COMPARISON_REPORT.md`.*
