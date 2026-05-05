# SpecKit vs Classical — Short Comparison


---

## 1. Scorecard (post-measurement, post-fix)

Scale: 0 = missing • 1 = unusable • 2 = partial • 3 = valid w/ issues • 4 = strong w/ minor issues • 5 = production-ready.

| Category | SpecKit | Classical | Winner |
|---|:-:|:-:|:-:|
| Requirements coverage | 4 | 4 | Tie |
| REST API design | 2 | 2 | Tie |
| Application architecture | 3 | 3 | Tie |
| Terraform / IaC | 4 | 4 | Tie *(after fix)* |
| Policy & security | 3 | 3 | Tie *(SpecKit edge on matrix)* |
| CI/CD pipelines | 3 | 4 | **Classical** |
| Testing strategy | 3 | 3 | Tie |
| Observability & operations | 3 | 3 | Tie |
| Documentation (README + docs) | 3 | 4 | **Classical** |
| Maintainability | 4 | 3 | **SpecKit** |
| Spec/plan/tasks rigor | 4 | 3 | **SpecKit** |
| Production readiness *(see §3)* | 2 | 2 | Tie |
| **Aggregate** | **38** | **39** | within noise |

---

## 2. Pros & Cons by Perspective

### Developer perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | Header comments cite `Task: T<x>.<n>` + constitutional principle — every artefact is traceable to its origin. File-per-screen discipline keeps every workflow ≤80 lines and every `.tf` ≤45 lines. Strict placeholder-only `dev.tfvars`. | Larger, narrative `README.md` (242 lines) gets a new joiner productive in ~10 min without opening `specs/`. `var.node_version` and conditional `always_on` give more knobs. Per-folder `infra/terraform/README.md` walks the migration to remote state. |
| **Cons** | Hardcoded `node_version = "20-lts"` in `main.tf` — bumps require code change. `always_on` not set (provider default; brittle on `F1`/`Y1` SKUs). README too terse — must enter `specs/` to learn the system. | No DoD per task; `T-01..T-15` flat IDs harder to extend per stage. Header comments don't link back to the spec. Slightly looser `dev.tfvars` (real-looking names like `rg-brasov-sunset-dev`). |

### Platform / SRE perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | `policy-guardrails.md` enforcement matrix (Rule × Source × Status × Enforced-by-today × Hardening-path) — strongest single artefact in either repo. `tagging-policy.yaml` cites `infra/terraform/locals.tf:common_tags` for direct traceability. `runbook.md` is one focused page. | Three-variable OIDC gate on plan/deploy (`AZURE_CLIENT_ID && TENANT_ID && SUBSCRIPTION_ID`). Weekly security cron + `workflow_dispatch`. Smoke-test cold-start retry loop. `App_Test` audited too. `platform/docs/operational-readiness.md` includes a roadmap (Structured logs → App Insights → OTel → Alerts/SLOs). |
| **Cons** | Single-variable OIDC gate — fails late at `azure/login` if only one var is set. No App_Test audit. No weekly security cron. No cold-start retry loop on smoke test. `marocchino/sticky-pull-request-comment` extra third-party dep. | Plan-comment renderer is 96-line inline `actions/github-script` — heavier file. `repo` is a literal in `local.common_tags` (rename = code change). |

### Security perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | Zero secrets in repo, OIDC-only, fork-safe skip-clean. Strict placeholder `dev.tfvars`. Variable validation on `environment ∈ {dev,test,prod}`. Same Trivy/Gitleaks/Checkov/npm-audit posture as Classical. | Same OIDC story; **broader audit scope** (`App_Test/` also audited at `high+`). Trivy pinned to a newer major (`v0.36.0` vs SpecKit's `0.28.0`). |
| **Cons** | None unique. | None unique. **Both** ship `soft_fail: true` on Checkov, no SBOM/Grype/Semgrep, no SHA-pinned third-party Actions, no Rego/conftest enforcement of the YAML guardrails. |

### Compliance / governance perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | Most policy artefacts written as YAML (`deployment-policy.yaml`, `cost-policy.yaml`, `tagging-policy.yaml`, `service.yaml`) — lintable, OPA-able later. Enforcement matrix is honest about Enforced/Documented/Planned. | Each policy file is *richer* (e.g. `cost-policy.yaml`: principles, defaults, monthly_budget_usd, required_signals_on_pr, review_rules, enforcement). `service-metadata.yaml` uses `apiVersion/kind` Kubernetes-style schema. |
| **Cons** | Smaller per-policy content; budgets are placeholders. | `deployment-policy.md` is Markdown, not YAML — harder to lint. No enforcement matrix; the "Enforced/Documented/Planned" story is split across two files. |

### Demo / on-stage perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | First-class `demo-script.md` (per-stage cue / action / expected / fallback) and `hotfix-scenario.md` (the diacritic-drift story, 4:45 timing). Three pre-flight `checklists/` (demo, iac, security). Time budget per stage in `plan.md`. | `prompts/` has a single `hotfix-failing-golden-path.md` covering the same concept; `platform/docs/demo-flow.md` and `hotfix-demo.md` cover the on-stage narrative. |
| **Cons** | Speaker must mentally re-link several files. | No on-stage script with timing per stage; no checklist artefacts. Higher cognitive load if a step fails. |

### Cost perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | `cost.yml` is 30 lines: clean separation between YAML (workflow) and shell (`scripts/cost-comment.sh`). | Self-contained `cost-awareness.yml` (96 lines, no extra script): one workflow, idempotent comment update via `actions/github-script`. |
| **Cons** | Extra third-party action dep (`marocchino/sticky-pull-request-comment`). | Larger workflow file; SKU extraction is inline shell embedded in YAML. |

### Maintenance perspective

| | SpecKit | Classical |
|---|---|---|
| **Pros** | YAML workflows are 23% smaller (777 vs 1,013 lines). Markdown 37% cleaner per markdownlint (368 vs 588 issues on authored `.md`). Task IDs `T<stage>.<n>` extend cleanly per stage. | Bigger workflows are more defensive (three-var gate, retry loops, weekly cron) — fewer 02:00 surprises. |
| **Cons** | Fewer defensive guards; more reliance on reviewer discipline. | More surface to read on review; flat task IDs harder to extend. |

---

## 3. Production-Readiness Scoring

Treat each row as a binary "would I run this in production today?" check. **Both repos are intentionally demo-grade**; this table makes the gap explicit.

| # | Capability | SpecKit | Classical | Notes |
|---|---|:-:|:-:|---|
| 1 | App tests pass on a clean runner | ✅ | ✅ | Jest 16/16 in both |
| 2 | Dependency CVEs (`npm audit`, Trivy, Grype) | ✅ | ✅ | 0 vulns in both |
| 3 | Secret scanning (Gitleaks full history) | ✅ | ✅ | 0 leaks in both |
| 4 | OIDC-only auth, no secrets in repo | ✅ | ✅ | Verified by `gitleaks` + grep |
| 5 | Workflow lint (`actionlint`) | ✅ | ✅ | 0 issues in both |
| 6 | Terraform `fmt` + `validate` | ✅ *(after fix)* | ✅ | SpecKit needed `health_check_eviction_time_in_min` |
| 7 | IaC misconfig scan (`checkov`) | ⚠️ | ⚠️ | 8 pass / 12 fail identical; `soft_fail` in CI |
| 8 | Required tags on every resource | ✅ | ✅ | `local.common_tags` in both |
| 9 | App Service hardening (HTTPS, TLS 1.2, FTPS off, HTTP/2, websockets/remote-debug off) | ✅ | ✅ | Identical |
| 10 | `/healthz` wired to App Service `health_check_path` | ✅ | ✅ | Smoke-test asserts data |
| 11 | **Remote Terraform state with locking** | ❌ | ❌ | **Local state in both — top blocker** |
| 12 | **Branch protection on `main` enabled** | ❌ | ❌ | Documented intent, not enabled |
| 13 | **Required PR checks (CI / security / TF validate)** | ❌ | ❌ | Same |
| 14 | Approval gates per environment | ❌ | ❌ | Documented for `test`/`prod`, not implemented |
| 15 | Rollback workflow (one-click) | ❌ | ❌ | Both rely on "re-run previous green" |
| 16 | Deployment slots / zero-downtime swap | ❌ | ❌ | Out of scope by spec |
| 17 | **Application Insights / Log Analytics** | ❌ | ❌ | Both: no metrics, no traces, no historical query |
| 18 | **Structured logging** (`pino` / `winston`) | ❌ | ❌ | Both: default `console.log` |
| 19 | **Request-id / correlation-id** | ❌ | ❌ | Neither |
| 20 | **Distributed tracing (OTel)** | ❌ | ❌ | Neither |
| 21 | **Alerts on `Http5xx` / availability** | ❌ | ❌ | Neither |
| 22 | **SLO/SLI dashboards** | ❌ | ❌ | Neither — smoke test is the de-facto SLI |
| 23 | **Synthetic monitoring (availability tests)** | ❌ | ❌ | Neither |
| 24 | **Audit log shipping** (resource-level diagnostic settings → Log Analytics) | ❌ | ❌ | No `azurerm_monitor_diagnostic_setting` |
| 25 | **GitHub audit log retention plan** | ❌ | ❌ | Documented nowhere |
| 26 | **Activity log alerts** (subscription scope) | ❌ | ❌ | Neither |
| 27 | OpenAPI / contract test | ❌ | ❌ | Neither has `openapi.yaml` |
| 28 | SAST (Semgrep / CodeQL) | ❌ | ❌ | Both removed CodeQL between plan and impl |
| 29 | SBOM (`syft` → SPDX/CycloneDX, published) | ❌ | ❌ | Generated locally in this review; not in CI |
| 30 | SHA-pinned third-party Actions | ❌ | ❌ | Both pin majors only |
| 31 | Load test / latency budget | ❌ | ❌ | No k6/Artillery in either |
| 32 | Mutation testing | ❌ | ❌ | No Stryker.js |
| 33 | Code coverage gate (≥80%) | ❌ | ❌ | Neither has `collectCoverageFrom` config |
| 34 | ESLint + Prettier baseline | ❌ | ❌ | No `.eslintrc` / `.prettierrc` in either |
| 35 | Container image (signed, scanned) | n/a | n/a | Zip-deploy; container path documented nowhere |
| 36 | Disaster recovery / multi-region | ❌ | ❌ | Single region (`westeurope`) |
| 37 | Backup / restore plan | ❌ | ❌ | Stateless app — but no documented assumption |
| 38 | DPIA / data classification | ❌ | ❌ | Public sunset times — no PII; documented nowhere |
| 39 | License compliance check | ⚠️ | ⚠️ | `license-checker` shows clean MIT/ISC/BSD; not gated in CI |
| 40 | Vendor / dependency review automation (Dependabot) | ❌ | ❌ | Mentioned in plan, not configured |

**Score:** SpecKit **10/40 (25%)** • Classical **10/40 (25%)** — both demo-grade, identical production-readiness profile.

✅ = present and working • ⚠️ = present but soft / advisory only • ❌ = missing.

### Top 10 must-fix items before either repo is production-ready

1. Move Terraform to **remote `azurerm` backend with state locking**.
2. Enable **branch protection** on `main` with required checks (`ci/test`, `security/*`, `terraform/validate`).
3. Add **Application Insights** + **`pino`** structured logs + request-id middleware.
4. Wire **diagnostic settings** on App Service → Log Analytics (audit log shipping).
5. Add **alerts** on `Http5xx`, availability test on `/healthz`, action group → Teams/Slack/PagerDuty.
6. Promote **Checkov** from `soft_fail: true` to hard-fail on a triaged baseline.
7. Add **`openapi.yaml`** + Spectral lint + Dredd contract test.
8. Add **SBOM (syft)** + **vuln scan (grype)** + **SAST (Semgrep / CodeQL)** as CI jobs.
9. **SHA-pin** third-party GitHub Actions; enable Dependabot for `github-actions`, `npm`, `terraform`.
10. Define one **SLO** (e.g. `p95 /sunset latency < 300 ms over 30 days`); alert on burn.

---

## 4. Final Conclusion

**SpecKit and Classical produce essentially the same artefact — but reach it through measurably different methodologies.** Both pass the same 16 Jest tests, audit clean, lint clean for workflows, scan clean for secrets and CVEs, share an identical Checkov-finding baseline, and live within 1 aggregate score point of each other.

What's actually different is the **shape of the working artefacts**:

- **SpecKit wins on rigor and discipline.** Its `plan.md` (408 lines vs Classical's 149), its `tasks.md` with per-task DoD, its `policy-guardrails.md` enforcement matrix, its 23%-smaller YAML, and its 37%-cleaner authored markdown all point at a process that *compounds well over time*. The price is leaner operator-facing docs.
- **Classical wins on operator-facing polish.** Its 13.5 KB `README.md`, its 9 capability docs, its three-var OIDC gate, its weekly security cron, its cold-start retry loop, and its broader audit scope (`App_Test/` too) make it more *defensive on day one*. The price is heavier files, flatter task IDs, and less spec-traceability.

**Recommendation, single sentence:** adopt **SpecKit as the methodology baseline**, **port Classical's `README.md` + `platform/docs/*.md` + four defensive workflow guards** on top, and treat the resulting hybrid as a *demo-grade golden path* that needs the **Top 10 must-fix list** above before any team should run it in production.

The single observed defect (SpecKit's `terraform validate` failing on azurerm 4.71.0) was found by running `terraform validate` once — it would have been caught the first time CI executed the workflow against a current provider. **Fixed in this session** with a two-line patch; SpecKit's IaC score restored to 4.

---

## 5. Tools and Metrics Used

All tools were installed (or downloaded as a single binary) on this machine and run against **both** repos. Versions are pinned for reproducibility. Raw outputs at `c:\Users\rvunvulea\Downloads\DevOps2026Compare\results\`. Reproduction script: `c:\Users\rvunvulea\Downloads\DevOps2026Compare\run-validations.ps1`.

### Executed

| Tool | Version | Purpose | Source |
|---|---|---|---|
| Node.js / npm | 25.9.0 / 11.12.1 | Runtime + package manager | preinstalled |
| Jest + Supertest | via `App_Test/package.json` | Unit/integration tests (`npm test`, `--coverage`) | npm |
| `npm audit` | bundled | Dependency CVE check (`--omit=dev --audit-level=high`) | npm |
| Terraform | 1.9.8 (windows-amd64) | `fmt -check -recursive`, `init -backend=false`, `validate` | hashicorp.com download |
| `actionlint` | 1.7.7 | GitHub Actions YAML lint | github.com/rhysd/actionlint |
| `gitleaks` | 8.21.2 | Full-history secret scan | github.com/gitleaks/gitleaks |
| `trivy` | 0.70.0 | Filesystem scan (HIGH,CRITICAL, ignore-unfixed) + secrets | github.com/aquasecurity/trivy |
| `checkov` | 3.2.526 | Terraform misconfig scan (`--framework terraform`) | `pip --user --only-binary=:all:` |
| `syft` | 1.18.1 | SBOM generation (CycloneDX JSON) | github.com/anchore/syft |
| `grype` | 0.86.1 | Vulnerability scan against SBOM | github.com/anchore/grype |
| ESLint | 9.x via `npx` | JS lint (no project config — both repos lacked one) | npm |
| Prettier | 3.x via `npx` | Style check on `App/` | npm |
| `markdownlint-cli2` | 0.22.x via `npx` | Markdown lint on authored docs (excl. `.specify/`, `node_modules`) | npm |
| `madge` | via `npx` | Circular-dependency check on `App/` | npm |
| `depcheck` | via `npx` | Unused / missing deps in `App/` | npm |
| `license-checker` | via `npx` | License inventory of `App/` production deps | npm |
| Custom PowerShell `loc.ps1` | — | LOC + file count by extension (excl. `node_modules`, `.git`, `.terraform`) | repo-local |
| Manual diff inspection | — | `App/server.js`, `App_Test/tests/sunset.test.js`, `spec.md` | — |

### Not executed (with reason)

| Tool | Reason |
|---|---|
| Semgrep | No native Windows support (requires WSL/Docker) |
| `terraform plan` | Requires Azure OIDC; both workflows already do this conditionally in CI |
| Infracost | Out of scope; no token; deferred per spec |
| Dredd / Spectral | Neither repo has `openapi.yaml` to lint or contract-test |
| k6 / Artillery | Out of scope; no perf/latency budget defined |
| Stryker.js (mutation) | Out of scope at this stage |
| `act` (local CI) | Time budget; both workflows already exercised in GitHub Actions |
| `zizmor` | Time budget; finding (third-party Actions not SHA-pinned) is already known and shared by both repos |
| `tflint` | Time budget; redundant with `checkov` for the demo's purpose |
| `terrascan`, `tfsec` | Time budget; would add noise to an already-identical Checkov result |
| OPA / `conftest` | Neither repo has Rego policies to enforce |

### Metrics captured — values obtained

| # | Metric | SpecKit | Classical | Source |
|---|---|---|---|---|
| 1 | Jest test outcome | **PASS 16/16** in 1.385 s | **PASS 16/16** in 1.566 s | `npm test` in `App_Test/` |
| 2 | `npm audit --omit=dev --audit-level=high` (App) | **0 vulns** | **0 vulns** | npm |
| 3 | Trivy fs HIGH/CRITICAL (ignore-unfixed) | **0 vulns, 0 secrets** | **0 vulns, 0 secrets** | Trivy 0.70.0 |
| 4 | Grype `dir:App/` | **No vulnerabilities found** | **No vulnerabilities found** | Grype 0.86.1 |
| 5 | Gitleaks (commits scanned / leaks) | 36 / **0** | 18 / **0** | Gitleaks 8.21.2 |
| 6 | actionlint (`.github/workflows/*.yml`) | **0 issues** | **0 issues** | actionlint 1.7.7 |
| 7 | ESLint v9 (no project config) | 7 errors (all `no-undef` for Node globals — config gap, false positives) | identical 7 errors | ESLint 9 via `npx` |
| 8 | Prettier `--check App/` (files flagged) | **4** (`server.js`, `README.md`, `package.json`, `package-lock.json`) | **1** (`server.js`) | Prettier 3 |
| 9 | markdownlint authored `.md` (issues) | **368** | **588** | markdownlint-cli2 |
| 10 | `terraform fmt -check -recursive` | **PASS** (no diff) | **PASS** (no diff) | Terraform 1.9.8 |
| 11 | `terraform init -backend=false` | PASS (azurerm v4.71.0) | PASS (azurerm v4.71.0) | Terraform 1.9.8 |
| 12 | `terraform validate` | **PASS** *(after fix)* — pre-fix: FAIL on `health_check_eviction_time_in_min` pairing | **PASS** | Terraform 1.9.8 |
| 13 | Checkov `--framework terraform` | **8 passed / 12 failed** | **8 passed / 12 failed** (identical rule IDs: `CKV_AZURE_212/225/211/13/17/65/66/63/213/16/78/214`) | Checkov 3.2.526 |
| 14 | Syft SBOM components (App) | **71** | **71** | Syft 1.18.1 (CycloneDX) |
| 15 | depcheck (unused / missing in App) | 0 / 0 | 0 / 0 | depcheck |
| 16 | license-checker (App, prod) | MIT 65, ISC 2, BSD-3-Clause 2, Custom 1, BSD\* 1 | identical | license-checker |
| 17 | madge `--circular App/` | none | none | madge |
| 18 | `jest --coverage` | 0/0 (config gap — neither has `collectCoverageFrom`) | 0/0 (same) | Jest |
| 19 | LOC `.js` (files / lines) | 2 / **134** | 2 / **134** | `loc.ps1` |
| 20 | LOC `.tf` (files / lines) | **6** / 115 | 5 / 123 | `loc.ps1` |
| 21 | LOC `.tfvars` (files / lines) | 1 / 9 | 1 / 11 | `loc.ps1` |
| 22 | LOC `.yml` / `.yaml` (files / lines) | 14 / **777** | 13 / **1,013** | `loc.ps1` |
| 23 | LOC `.md` (files / lines) | 63 / 4,347 | 60 / 4,339 | `loc.ps1` |
| 24 | LOC `.json` (files / lines) | 10 / 5,681 | 10 / 5,681 | `loc.ps1` |
| 25 | LOC `.sh` (files / lines) | 5 / 673 | 4 / 620 | `loc.ps1` |
| 26 | Workflow size — `ci.yml` (lines) | 42 | 44 | manual |
| 27 | Workflow size — `security*.yml` | 80 | 120 | manual |
| 28 | Workflow size — `terraform-plan*.yml` | 60 | 128 | manual |
| 29 | Workflow size — `deploy*.yml` | 77 | 138 | manual |
| 30 | Workflow size — `cost*.yml` | 30 | 96 | manual |
| 31 | `plan.md` (lines) | **408** | 149 | manual |
| 32 | `tasks.md` ID scheme | `T<stage>.<n>` with DoD + `[P]` markers | `T-01..T-15` flat | manual |
| 33 | `spec.md` size | 7,812 B | 7,812 B (**byte-identical**) | manual diff |
| 34 | `README.md` size | 117 lines / 5,134 B | 242 lines / **13,523 B** | manual |
| 35 | `platform/docs/` files | 2 | **9** | manual |
| 36 | Demo artefacts (`demo-script.md`, `hotfix-scenario.md`, `checklists/`) | **present** (3 + 3 checklists) | absent (single `hotfix-failing-golden-path.md`) | manual |
| 37 | `App/server.js` diff | identical except `endpoints: ['/sunset']` | identical except `endpoints: ['/sunset', '/healthz']` | manual diff |
| 38 | `App_Test/tests/sunset.test.js` diff | identical 16-test suite | identical 16-test suite | manual diff |
| 39 | OIDC gate variables | 1 (`AZURE_CLIENT_ID`) | **3** (`+TENANT_ID, +SUBSCRIPTION_ID`) | workflow inspection |
| 40 | Weekly security cron | absent | **`'0 6 * * 1'`** + `workflow_dispatch` | workflow inspection |
| 41 | Smoke-test cold-start retry loop | absent | **`for i in 1..5; sleep $((5*i))`** | workflow inspection |
| 42 | Semgrep | **not run** (no native Windows support) | not run | — |

---

*End of summary. Long version with detailed findings: `COMPARISON_REPORT.md`.*
