# Golden Path — Implementation Plan

> Companion to `spec.md` (the **what**) and `tasks.md` (the **next steps**).
> This file describes **how** the golden path is built, optimized for a
> **30-minute live conference demo** of the talk
> *"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"*.

## Demo time budget (30 min total)

| # | Stage | Live time |
|---|---|---|
| 1 | Existing app baseline | 2 min |
| 2 | CI | 3 min |
| 3 | Security scanning | 3 min |
| 4 | Terraform infrastructure for Azure App Service | 4 min |
| 5 | Terraform validation and plan | 3 min |
| 6 | Azure App Service deployment | 4 min |
| 7 | Platform policies | 2 min |
| 8 | Cost awareness | 2 min |
| 9 | Operational readiness | 2 min |
| 10 | Demo flow (hotfix + recap) | 5 min |

Buffer: about 30s slack per stage absorbed into transitions.

## Cross-cutting principles

- **No secrets in the repo.** All Azure identifiers come from GitHub repo
  **Variables** (not Secrets), referenced as `${{ vars.* }}`. Local files use
  placeholders like `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`,
  `<AZURE_CLIENT_ID>`, `<APP_NAME>`, `<RESOURCE_GROUP>`.
- **OIDC only.** GitHub Actions authenticates to Azure via
  `azure/login@v2` with `permissions: id-token: write` and a federated
  credential on a User-Assigned Managed Identity / App Registration. No
  client secrets, no publish profiles.
- **Skip-clean on forks.** Any job needing Azure variables guards on
  `if: ${{ vars.AZURE_CLIENT_ID != '' }}` and exits green when unset, so
  forks stay green with zero setup.
- **One screen per file.** Every workflow and Terraform file is small enough
  to read on stage; each opens with a header comment stating its purpose.
- **Visibility over enforcement.** Demo-risky tools (Checkov, audits) are
  `soft_fail` / `continue-on-error` so a CVE published the morning of the
  talk does not derail the show.

---

## Stage 1 — Existing app baseline

**Goal.** Anchor the audience in a tiny, real, already-tested workload so the
rest of the talk is about the *path*, not the app.

**Files likely to change.** None. Read-only walkthrough of:

- `@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App/server.js`
- `@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App/package.json`
- `@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App_Test/`
- `@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/README.md`

**Expected outcome.** Audience understands: Express app, `GET /sunset` returns
sunset for Brașov, `GET /healthz` returns `{status:"ok"}`, Jest+Supertest
suite is green locally.

**What to show live.**

- `npm test` from `App_Test/` going green in ~2s.
- `curl localhost:3000/sunset` returning JSON with `city: "Brasov"`.

**Live-demo risk.** Node version mismatch; port 3000 already bound.

**Fallback strategy.** Pre-recorded terminal cast (`asciinema`) of the same
two commands; switch to it without comment if local fails.

---

## Stage 2 — CI

**Goal.** Every PR builds and tests the app automatically; failure blocks the
workflow.

**Files likely to change.**

- `.github/workflows/ci.yml` (new)

**Implementation notes.**

- Triggers: `pull_request` to `main`, `push` to `main`.
- Single job `test` on `ubuntu-latest`, Node 20 LTS.
- `actions/setup-node@v4` with `cache: npm` and `cache-dependency-path`
  pointing at both `App/package-lock.json` and `App_Test/package-lock.json`.
- Steps: `npm ci` in `App/`, `npm ci` in `App_Test/`, `npm test` in `App_Test/`.
- Header comment in the workflow: "CI — install + test on every PR. No
  secrets, no Azure auth."

**Expected outcome.** Green check on PRs; red X on broken tests.

**What to show live.**

- Open a PR with a one-character break to a test assertion → red CI.
- Push the fix → green CI within ~60s.

**Live-demo risk.** GitHub Actions queue latency; npm registry hiccup.

**Fallback strategy.** Open a previously merged PR that already shows the
red→green transition in its checks tab; narrate over it.

---

## Stage 3 — Security scanning

**Goal.** Make supply-chain, secret, and IaC issues visible on every PR
without becoming a demo blocker.

**Files likely to change.**

- `.github/workflows/security.yml` (new)
- `.gitleaks.toml` (optional, only if false positives need silencing)

**Implementation notes.** One workflow, four jobs, all `continue-on-error:
false` for real signal but with deliberately scoped thresholds:

- `npm-audit`: `npm audit --omit=dev --audit-level=high` in `App/`.
- `gitleaks`: `gitleaks/gitleaks-action@v2` with `fetch-depth: 0`.
- `trivy-fs`: `aquasecurity/trivy-action@0.x` filesystem scan,
  `severity: HIGH,CRITICAL`, `ignore-unfixed: true`, SARIF uploaded via
  `github/codeql-action/upload-sarif@v3`.
- `checkov`: runs only if `infra/terraform/` exists; `soft_fail: true`.

**Expected outcome.** Findings show in the PR checks and Security tab; demo
stays green because thresholds are realistic.

**What to show live.**

- Security tab with a pre-seeded Trivy finding from a known-old transitive dep.
- Workflow file on screen, highlight the four jobs and their thresholds.

**Live-demo risk.** A CVE published that morning bumps the count; Gitleaks
flags an example placeholder.

**Fallback strategy.** Pre-screenshot the Security tab; keep the spoken line
*"this is signal, not a gate — gating is a follow-up conversation with the
team"*. If Gitleaks barks on a placeholder, point at `.gitleaks.toml`
allowlist as the answer and move on.

---

## Stage 4 — Terraform infrastructure for Azure App Service

**Goal.** One small Terraform stack provisions a hardened Linux App Service
for Node.js with required tags.

**Files likely to change.** All under
`@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/infra/terraform/` (new):

- `versions.tf` — `terraform { required_version }` and `azurerm` provider pin.
- `providers.tf` — `provider "azurerm" { features {} }`, subscription via env.
- `variables.tf` — `project`, `environment`, `location`, `owner`, `sku_name`,
  `app_name`, `repo`.
- `locals.tf` — `common_tags` map (`project`, `environment`, `owner`,
  `managed_by = "terraform"`, `repo`).
- `main.tf` — `azurerm_resource_group`, `azurerm_service_plan` (Linux),
  `azurerm_linux_web_app` with `node` runtime, `health_check_path = "/healthz"`,
  `https_only = true`, `ftps_state = "Disabled"`, `minimum_tls_version = "1.2"`,
  `http2_enabled = true`, `websockets_enabled = false`,
  `remote_debugging_enabled = false`.
- `outputs.tf` — `default_hostname`, `resource_group_name`, `app_name`.
- `environments/dev.tfvars` — placeholder values, no real names.

**Expected outcome.** `terraform validate` passes; `terraform plan` against a
real subscription shows three resources to create.

**What to show live.**

- Open `main.tf` once on screen; point to the four hardening lines.
- `terraform fmt -check` and `terraform validate` running locally.

**Live-demo risk.** Provider download time on a cold cache; `azurerm` version
break; subscription quota.

**Fallback strategy.** Pre-warm `~/.terraform.d/plugin-cache`; keep a recorded
plan output to paste if `plan` stalls.

---

## Stage 5 — Terraform validation and plan

**Goal.** Every infra PR gets fmt + validate; if Azure variables are
configured, also a real `terraform plan` posted as a PR comment.

**Files likely to change.**

- `.github/workflows/terraform.yml` (new)

**Implementation notes.**

- Triggers: `pull_request` paths-filtered on `infra/terraform/**`.
- `permissions: id-token: write, contents: read, pull-requests: write`.
- Job `validate` (always runs, no auth):
  `terraform fmt -check -recursive`, `terraform init -backend=false`,
  `terraform validate`.
- Job `plan` (gated by `if: ${{ vars.AZURE_CLIENT_ID != '' }}`):
  `azure/login@v2` with `client-id`, `tenant-id`, `subscription-id` from
  `vars`; `terraform init`, `terraform plan -var-file=environments/dev.tfvars
  -out=tfplan`, post `terraform show -no-color tfplan` as a sticky PR comment
  via `marocchino/sticky-pull-request-comment@v2`.

**Expected outcome.** Forks see a green `validate`; the demo repo also sees a
real `plan` comment.

**What to show live.**

- A PR that bumps `sku_name` in `dev.tfvars`; the plan comment updates with
  the diff.

**Live-demo risk.** OIDC federation misconfigured; `azurerm` plan timeout;
PR comment race.

**Fallback strategy.** Two pre-staged PRs: one with the plan comment already
posted (screenshot ready), one fresh to attempt live. If live fails within
20s, switch to the staged PR.

---

## Stage 6 — Azure App Service deployment

**Goal.** Manual, observable deploy that ships the app and proves it with a
smoke test.

**Files likely to change.**

- `.github/workflows/deploy.yml` (new)

**Implementation notes.**

- Trigger: `workflow_dispatch` with input `environment` (default `dev`).
- `permissions: id-token: write, contents: read`.
- Job `build`: `npm ci --omit=dev` in `App/`, zip the directory, upload
  artifact.
- Job `deploy` (needs `build`): `azure/login@v2` (OIDC),
  `azure/webapps-deploy@v3` with `app-name: ${{ vars.AZURE_APP_NAME }}` and
  the artifact path. No publish profile.
- Job `smoke-test` (needs `deploy`):
  - `curl --retry 10 --retry-delay 5 --retry-all-errors
    https://${{ vars.AZURE_APP_NAME }}.azurewebsites.net/` for cold start.
  - `curl .../sunset`, pipe to `jq`, assert
    `.city == "Brasov"` and `.timezone == "Europe/Bucharest"`.
  - Fail the job on assertion mismatch.

**Expected outcome.** Green run lands the app at the public hostname; smoke
test confirms `/sunset` shape.

**What to show live.**

- Click "Run workflow" → watch the three jobs go green → `curl` the live URL
  in a terminal → JSON appears.

**Live-demo risk.** Cold-start > retry budget; conference Wi-Fi flakes;
quota or region capacity error on first deploy.

**Fallback strategy.**

- App is **pre-deployed** the morning of the talk so the live deploy is an
  *update*, not a first-create. Cold-start window is much smaller.
- Keep the previous green run pinned in a browser tab; if the live run
  stalls, narrate over the previous run and `curl` the already-live URL.

---

## Stage 7 — Platform policies

**Goal.** Make the unwritten rules of the road visible, short, and editable.

**Files likely to change.** All under
`@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/platform/policies/` (new):

- `service.yaml` — service metadata schema (name, owner, repo, runtime, tier).
- `tagging-policy.yaml` — required tag keys, allowed values for `environment`.
- `deployment-policy.yaml` — who can deploy, when, with which approval.
- `cost-policy.yaml` — per-environment SKU defaults and placeholder budgets.
- `policy-guardrails.md` — table mapping each rule to status
  (Enforced / Documented / Planned) and the hardening path (Azure Policy,
  branch protection, OPA, etc.).

**Expected outcome.** A reviewer can answer "what are the rules?" in 60s.

**What to show live.**

- Open `policy-guardrails.md` once; point to the Enforced vs Documented vs
  Planned column.

**Live-demo risk.** None — these are static files.

**Fallback strategy.** N/A.

---

## Stage 8 — Cost awareness

**Goal.** On infra PRs, surface SKU choices and cost-policy expectations
without tokens or fake dollar amounts.

**Files likely to change.**

- `.github/workflows/cost.yml` (new)
- `scripts/cost-comment.sh` (new, small awk/grep over `*.tfvars`)

**Implementation notes.**

- Trigger: `pull_request` paths-filtered on
  `infra/terraform/environments/*.tfvars` and `platform/policies/cost-policy.yaml`.
- Single job: parse each `environments/*.tfvars` for `sku_name`, render a
  Markdown checklist that includes the SKU, the policy default from
  `cost-policy.yaml`, and a reminder line ("Has the team owner approved this
  SKU?"). Post or update one sticky comment via
  `marocchino/sticky-pull-request-comment@v2`.

**Expected outcome.** A predictable, idempotent reviewer-checklist comment;
no external API, no secrets.

**What to show live.**

- The PR from Stage 5 (SKU bump) now also has a refreshed cost comment.

**Live-demo risk.** Sticky-comment action rate-limit; awk parse fails on a
file with comments.

**Fallback strategy.** The script is `set -euo pipefail` with a trivial
fallback `echo` of the raw `sku_name` lines if parsing fails. Keep a
screenshot of the comment ready.

---

## Stage 9 — Operational readiness

**Goal.** A 60-second story for "is it healthy, how do I see logs, how do I
roll back?"

**Files likely to change.**

- `@/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App/server.js` already exposes `/healthz`. No code change.
- `platform/runbook.md` (new) — three sections: Health, Logs, Rollback.

**Implementation notes.**

- Health: `/healthz` returns `{status:"ok"}`; App Service uses it as
  `health_check_path`; smoke test asserts `/sunset` shape.
- Logs: `az webapp log tail -g <RESOURCE_GROUP> -n <APP_NAME>` and the Log
  stream blade. No App Insights in scope.
- Rollback: re-run the last green `deploy.yml` run, or `git revert` +
  redeploy. Document the two-command path.

**Expected outcome.** Audience leaves knowing the *minimum* operational
contract — and where it would grow next (App Insights, alerts, SLOs).

**What to show live.**

- `az webapp log tail` printing a request line as `curl /sunset` is run from
  another terminal.

**Live-demo risk.** Azure CLI auth expiry; log stream lag.

**Fallback strategy.** Pre-authenticate `az login` before the talk; have a
screenshot of a log line tied to a `/sunset` call.

---

## Stage 10 — Demo flow

**Goal.** Tie the nine stages together with a live story (small change → PR →
green → deploy → live URL) and a hotfix scenario that demonstrates the path
under stress.

**Files likely to change.**

- `specs/golden-path/demo-script.md` (new) — one-page on-stage script with
  per-step time budget, what-can-fail, and fallback.
- `specs/golden-path/hotfix-scenario.md` (new) — the diacritic-drift story:
  smoke test asserts `city == "Brasov"`; intentionally rename the response to
  `"Brașov"` to break the smoke test, then the hotfix is a one-character
  revert. One character to break, one character to fix.

**Expected outcome.** A repeatable, low-cognitive-load script that the
speaker can run while talking.

**What to show live.**

- Open the hotfix PR live (already drafted in a branch), watch CI go red on
  smoke, push the one-character fix, watch it go green.
- Final slide is just the live `/sunset` URL in the browser.

**Live-demo risk.** Time overrun; Wi-Fi failure during the final deploy;
audience question stretches the buffer.

**Fallback strategy.**

- Hard cap each stage with a visible timer on the speaker's second screen.
- If Wi-Fi dies, switch to a pre-recorded screencast of the same hotfix flow
  and keep narrating; the script is identical to the recording.
- Park audience questions to the end; the last 5 minutes is intentionally
  Q&A buffer borrowed from the hotfix slack.

---

## Open items deferred to `tasks.md`

- Concrete file scaffolding order and the smallest viable PR sequence.
- Exact action versions to pin (`azure/login@v2.x.y`, `azurerm ~> 4.x`, etc.).
- Pre-flight checklist for the morning of the talk (pre-deploy, `az login`,
  cache warm, staged PRs open).
