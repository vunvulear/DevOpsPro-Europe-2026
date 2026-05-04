# Golden Path — Task Breakdown

> Companion to `spec.md` and `plan.md`. Each task is small enough to be implemented and reviewed independently.
> Demo readiness tag (one per task):
> - 🟢 **safe to do live** — quick, deterministic, low risk
> - 🟡 **better prepared before the session** — works live but eats time or is finicky
> - 🔴 **fallback branch recommended** — pre-build a `demo/<task-id>-ready` branch as a safety net

---

## T-01 — CI workflow skeleton

- **Title:** GitHub Actions CI workflow
- **Description:** Create a single workflow that runs on `push` and `pull_request` for `main`, sets up Node 20, and is the entry point for build + test.
- **Files changed:** `.github/workflows/ci.yml` (new)
- **Acceptance criteria:**
  - Workflow triggers on PRs to `main` and pushes to `main`.
  - Uses `actions/checkout@v4` and `actions/setup-node@v4` with `node-version: 20`.
  - Job name `build-and-test` shows up as a required check.
- **Demo notes:** 🟢 Show the file, push, watch the green check.

## T-02 — Test execution in CI

- **Title:** Run unit tests inside the CI workflow
- **Description:** Extend `ci.yml` to install and run tests for both `App/` and `App_Test/`.
- **Files changed:** `.github/workflows/ci.yml`
- **Acceptance criteria:**
  - `npm ci` runs in `App/` and `App_Test/`.
  - `npm test --prefix App_Test` exits 0 on the current code.
  - Failing test causes the workflow to fail.
- **Demo notes:** 🟢 Push a deliberately failing test on a branch to show the red check, then revert.

## T-03 — Dependency caching

- **Title:** Cache npm dependencies in CI
- **Description:** Use `actions/setup-node` `cache: npm` with `cache-dependency-path` for both lockfiles to speed up CI.
- **Files changed:** `.github/workflows/ci.yml`
- **Acceptance criteria:**
  - First run populates the cache; subsequent runs report a cache hit.
  - Total CI time on cached run is noticeably shorter.
- **Demo notes:** 🟡 Cache hit only visible on the second run — pre-warm before the session.

## T-04 — Security workflow

- **Title:** Security scanning workflow (CodeQL + npm audit)
- **Description:** New workflow running CodeQL for JavaScript and `npm audit --audit-level=high` on PRs and a weekly schedule.
- **Files changed:** `.github/workflows/security.yml` (new)
- **Acceptance criteria:**
  - CodeQL analysis job completes and uploads results to the Security tab.
  - `npm audit` step fails the job on `high`/`critical` advisories.
  - Workflow has `permissions: security-events: write, contents: read`.
- **Demo notes:** 🟡 CodeQL takes 3–5 minutes — pre-trigger before talking, point at the Security tab.

## T-05 — Secret scanning

- **Title:** Enable secret scanning + push protection
- **Description:** Document and enable GitHub-native secret scanning + push protection at repo level. Add a `gitleaks` action as a defense-in-depth check on PRs.
- **Files changed:** `.github/workflows/secret-scan.yml` (new), `platform/docs/spec-kit-setup.md` (note the repo settings)
- **Acceptance criteria:**
  - Repo settings have **Secret scanning** and **Push protection** enabled (manual, documented).
  - `gitleaks-action` runs on every PR; intentionally-leaked test string is blocked.
- **Demo notes:** 🔴 Pushing a fake secret live can trigger real alerts — pre-build a `demo/secret-blocked` branch with a screenshot.

## T-06 — Terraform folder structure

- **Title:** Initialize `infra/terraform/` layout
- **Description:** Establish the folder layout and provider config that all later Terraform tasks build on.
- **Files changed:**
  - `infra/terraform/providers.tf`
  - `infra/terraform/variables.tf`
  - `infra/terraform/outputs.tf`
  - `infra/terraform/README.md`
  - `infra/terraform/.gitignore` (`.terraform/`, `*.tfstate*`)
- **Acceptance criteria:**
  - `terraform fmt` and `terraform validate` pass with no resources defined.
  - `azurerm` provider configured to read auth from env (no hardcoded IDs).
  - Variables: `location`, `app_name`, `sku`, `node_version` — all with sane defaults or placeholders.
- **Demo notes:** 🟢 Pure scaffolding; safe and fast.

## T-07 — Azure App Service Terraform resources

- **Title:** Define RG + Plan + Linux Web App
- **Description:** Add three resources: `azurerm_resource_group`, `azurerm_service_plan` (Linux, default `B1`), `azurerm_linux_web_app` (Node 20). Output `default_hostname`.
- **Files changed:** `infra/terraform/main.tf`, `infra/terraform/outputs.tf`
- **Acceptance criteria:**
  - `terraform plan` produces a 3-resource plan with placeholders for IDs/names.
  - `health_check_path` is wired to `/healthz` (used later in T-13).
  - No subscription, tenant, or client ID hardcoded.
- **Demo notes:** 🟡 First-time provider download is slow — pre-run `terraform init`.

## T-08 — Terraform validation workflow

- **Title:** GitHub Actions: terraform fmt / validate / plan
- **Description:** New workflow that runs `fmt -check`, `validate`, and `plan` against `infra/terraform/`. Posts the plan summary as a PR comment via `actions/github-script` or `terraform-plan` action.
- **Files changed:** `.github/workflows/terraform-plan.yml` (new)
- **Acceptance criteria:**
  - Workflow uses `azure/login@v2` with **OIDC** (`client-id`, `tenant-id`, `subscription-id` from repo **variables**, not secrets).
  - PR comment shows additions/changes/destroys count.
  - `permissions: pull-requests: write, id-token: write, contents: read`.
- **Demo notes:** 🔴 OIDC misconfig kills the demo — keep `demo/tf-plan-ready` branch with a previous successful run.

## T-09 — Deployment workflow

- **Title:** Build + deploy to Azure App Service on push to `main`
- **Description:** New workflow that builds the app, logs in via OIDC, and deploys with `azure/webapps-deploy@v3`.
- **Files changed:** `.github/workflows/deploy.yml` (new)
- **Acceptance criteria:**
  - Triggers only on `push: main`, after CI passes (via `needs:` or branch protection).
  - Uses `azure/login@v2` (OIDC) — no publish profile, no secrets.
  - Deploys the contents of `App/` (with `package.json` + `node_modules` from `npm ci --omit=dev`).
- **Demo notes:** 🔴 Pre-deploy once before the talk; the live merge becomes a redeploy. Keep the previous run's URL handy.

## T-10 — Post-deployment smoke tests

- **Title:** Smoke-test the live URL after deploy
- **Description:** Add a job (or final step in `deploy.yml`) that `curl`s `GET /sunset` and `GET /healthz` against the deployed App Service and fails the workflow on non-200 or unexpected payload.
- **Files changed:** `.github/workflows/deploy.yml`, optional `scripts/smoke.sh`
- **Acceptance criteria:**
  - Smoke step retries 3× with backoff (cold start tolerance).
  - Asserts `200` on `/healthz` and `city: "Brasov"` in `/sunset` payload.
- **Demo notes:** 🟢 Quick visible win after the deploy job goes green.

## T-11 — Platform policies

- **Title:** CODEOWNERS, PR template, branch protection notes
- **Description:** Encode platform guardrails as files; document the matching repo-settings configuration.
- **Files changed:**
  - `.github/CODEOWNERS`
  - `.github/pull_request_template.md`
  - `platform/docs/branch-protection.md`
  - `.specify/memory/constitution.md` (extend with platform principles)
- **Acceptance criteria:**
  - PRs auto-request platform reviewers for `infra/**` and `.github/workflows/**`.
  - PR template forces a checkbox: "spec updated, tests added, no secrets".
  - Doc lists required checks: `ci`, `security`, `terraform-plan`.
- **Demo notes:** 🟢 Open a PR; show auto-reviewers + checklist appearing.

## T-12 — Cost awareness

- **Title:** Infracost on PRs
- **Description:** Add an Infracost workflow that posts monthly cost diff for infra changes.
- **Files changed:** `.github/workflows/cost.yml` (new), `infra/terraform/README.md`
- **Acceptance criteria:**
  - PR comment shows `+/- $X/mo` for `infra/terraform/` changes.
  - Uses `INFRACOST_API_KEY` from GitHub **secrets** (the only secret in the demo, called out explicitly).
  - Workflow no-ops on PRs that don't touch `infra/**`.
- **Demo notes:** 🟡 Pre-create the secret; show a SKU-bump PR for the visible "+$/mo" punchline.

## T-13 — Operational readiness

- **Title:** Health endpoints + runbook
- **Description:** Add `GET /healthz` and `GET /readyz` to the API, cover them with tests, wire `health_check_path` in Terraform, write a 1-page runbook.
- **Files changed:**
  - `App/server.js`
  - `App_Test/tests/health.test.js` (new)
  - `infra/terraform/main.tf` (`health_check_path = "/healthz"`)
  - `docs/runbook.md` (new)
- **Acceptance criteria:**
  - Both endpoints return `200` with a JSON body.
  - New tests pass; existing tests untouched.
  - Runbook covers: how to check health, how to read logs, how to roll back deploy.
- **Demo notes:** 🟢 Small, contained code change — good live demo material.

## T-14 — README update

- **Title:** Document the golden path in the root README
- **Description:** Expand the "Spec-driven demo workflow" section with a short architecture diagram (text or mermaid), the list of workflows, and a "how to use this repo" pointer.
- **Files changed:** `README.md`
- **Acceptance criteria:**
  - README explains: spec → plan → tasks → implement → deploy.
  - Lists every workflow under `.github/workflows/` with a one-line purpose.
  - Links to `platform/docs/spec-kit-setup.md` and `specs/golden-path/`.
- **Demo notes:** 🟢 Pure docs; safe filler if a live demo step needs time to recover.

## T-15 — Demo flow documentation

- **Title:** Final demo script (happy path + hotfix)
- **Description:** Fill out `prompts/13-create-demo-flow.md` and `prompts/14-create-hotfix-demo.md` with the exact prompts and the timing per stage. Include the fallback branches per task.
- **Files changed:** `prompts/13-create-demo-flow.md`, `prompts/14-create-hotfix-demo.md`, `prompts/15-final-review.md`
- **Acceptance criteria:**
  - Each stage has: prompt to paste, expected outcome, time budget, fallback branch name.
  - Hotfix story is 3 minutes end-to-end on a warm cache.
  - Final-review prompt has a checklist for "no secrets, no Azure IDs" before the talk.
- **Demo notes:** 🟡 Rehearse end-to-end at least once with a stopwatch.

---

## Suggested execution order

`T-01 → T-02 → T-03 → T-04 → T-05 → T-06 → T-07 → T-08 → T-09 → T-10 → T-13 → T-11 → T-12 → T-14 → T-15`

Rationale: app + CI green first, then security, then infra and deploy, then ops & guardrails, then docs and demo polish.

## Pre-talk checklist (must be done before going on stage)

- 🟡 T-03 cache pre-warmed
- 🟡 T-04 CodeQL run already completed on `main`
- 🔴 T-05 `demo/secret-blocked` branch ready (do not push real-looking secrets live)
- 🟡 T-07 `terraform init` cache present locally
- 🔴 T-08 `demo/tf-plan-ready` branch with a known-good plan comment
- 🔴 T-09 first deploy already done; live URL warm
- 🟡 T-12 Infracost API key configured; sample SKU-bump PR drafted
- 🟡 T-15 full rehearsal with a stopwatch
