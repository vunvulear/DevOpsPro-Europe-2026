# Golden Path — Implementation Plan

> Companion to `spec.md`. Optimized for a **30-minute live conference demo** ("Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint").
> Target app: Brașov Sunset API (`App/`, Node.js/Express + Jest tests in `App_Test/`).
> Target cloud: Azure App Service. Agent: Windsurf/Cascade. Spec framework: GitHub Spec Kit.

## Guiding constraints

- **No secrets in the repo.** No tokens, no Azure subscription IDs, tenant IDs, client IDs, or private resource names.
- **Placeholders only** for configuration: `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_CLIENT_ID>`, `<RESOURCE_GROUP>`, `<APP_NAME>`.
- **Auth:** GitHub Actions → Azure via **OIDC federated credentials** (`azure/login@v2` with `client-id` / `tenant-id` / `subscription-id` from repo variables, never secrets).
- **Simplicity over completeness.** Each stage is a few minutes of live code + run.
- **Spec-driven.** Every stage edits `spec.md` / `plan.md` / `tasks.md` first, then code.

---

## Stage 1 — Existing app baseline

- **Goal:** Show the starting point so the audience trusts what's real.
- **Files likely to change:** none (read-only). Optionally `README.md` for one-liner context.
- **Expected outcome:** `npm install && npm start` serves `GET /sunset`; `npm test` is green.
- **What to show live:**
  - `App/server.js` (the small Express app)
  - `App_Test/tests/sunset.test.js` passing locally
  - `curl http://localhost:3000/sunset`
- **Live-demo risk:** Node version mismatch; port 3000 in use.
- **Fallback strategy:** Pre-recorded GIF of `npm test`; pre-baked terminal split with the server already running.

## Stage 2 — CI (GitHub Actions)

- **Goal:** Every push validates the app on a clean runner.
- **Files likely to change:**
  - `.github/workflows/ci.yml` (new)
- **Expected outcome:** Workflow runs `npm ci` in `App/` and `App_Test/`, then `npm test`. Green check on PRs.
- **What to show live:**
  - Cascade generates `ci.yml` from `/speckit.implement`.
  - Push to a branch, watch the Actions tab go green.
- **Live-demo risk:** Slow runner queue; `npm ci` failure due to lockfile drift.
- **Fallback strategy:** Have the workflow already merged on `main` from a dry-run; show the previous green run and replay locally with `act` if needed.

## Stage 3 — Security scanning

- **Goal:** Catch known-vulnerable dependencies and obvious code issues before merge.
- **Files likely to change:**
  - `.github/workflows/security.yml` (new) — runs `npm audit --audit-level=high` and **CodeQL** (`github/codeql-action`) for JavaScript.
  - `.github/dependabot.yml` (new, optional) — weekly npm updates.
- **Expected outcome:** Security workflow runs on PRs; findings appear in the **Security** tab.
- **What to show live:** Open the Security tab; show one CodeQL alert (or "no alerts").
- **Live-demo risk:** CodeQL run is slow (3–5 min).
- **Fallback strategy:** Trigger run before the talk; switch to `npm audit` only if CodeQL is still queued.

## Stage 4 — Terraform infrastructure for Azure App Service

- **Goal:** One command provisions Resource Group + App Service Plan (Linux, B1) + App Service for Node 20.
- **Files likely to change:**
  - `infra/terraform/main.tf` (new) — `azurerm_resource_group`, `azurerm_service_plan`, `azurerm_linux_web_app`.
  - `infra/terraform/variables.tf` — `location`, `app_name`, `sku` (default `B1`), `node_version` (default `20-lts`).
  - `infra/terraform/providers.tf` — `azurerm` with **no** hardcoded subscription; relies on `ARM_*` env vars from OIDC.
  - `infra/terraform/outputs.tf` — `default_hostname`.
- **Expected outcome:** `terraform init && terraform plan` succeeds locally with placeholders.
- **What to show live:** Open `main.tf`; explain three resources in plain language ("group, plan, app").
- **Live-demo risk:** Provider download time; subscription auth.
- **Fallback strategy:** Pre-run `terraform init` so the `.terraform/` cache is warm; show plan output from a previous run if auth fails.

## Stage 5 — Terraform validation and plan workflow

- **Goal:** Every PR shows what infra would change, before merge.
- **Files likely to change:**
  - `.github/workflows/terraform-plan.yml` (new) — `fmt`, `validate`, `plan` against `infra/terraform/`, posts plan as a PR comment.
- **Expected outcome:** PR comment with `terraform plan` summary; `fmt`/`validate` failures block merge.
- **What to show live:** Open a PR that tweaks SKU; show the plan diff in the PR comment.
- **Live-demo risk:** OIDC misconfiguration; plan permissions on the comment.
- **Fallback strategy:** Use `permissions: pull-requests: write` explicitly; have a backup PR ready showing a previous successful plan.

## Stage 6 — Azure App Service deployment

- **Goal:** Merge to `main` deploys the API to Azure App Service.
- **Files likely to change:**
  - `.github/workflows/deploy.yml` (new) — on `push: main`, build the app, `azure/login@v2` (OIDC), `azure/webapps-deploy@v3`.
  - `App/package.json` — ensure a `start` script and a clean install path.
- **Expected outcome:** Public URL (`https://<APP_NAME>.azurewebsites.net/sunset`) returns the JSON payload.
- **What to show live:** Watch the deploy job; `curl` the live URL after it finishes.
- **Live-demo risk:** Cold start; deployment slot timeout.
- **Fallback strategy:** Pre-deploy once before the talk so the warm app is already live; the demo merge becomes a redeploy.

## Stage 7 — Platform policies

- **Goal:** Encode "the rules of the road" so devs don't have to remember them.
- **Files likely to change:**
  - `.github/CODEOWNERS` — platform team owns `infra/` and `.github/workflows/`.
  - `.github/branch-protection.md` (doc only — actual rules set in repo settings) — required checks: `ci`, `security`, `terraform-plan`.
  - `.github/pull_request_template.md` — checklist: spec updated, tests added, no secrets.
  - `.specify/memory/constitution.md` — extend with platform principles.
- **Expected outcome:** New PRs auto-request platform reviewers, show the checklist, and can't merge without green checks.
- **What to show live:** Open a PR; show the auto-populated reviewers and template.
- **Live-demo risk:** Branch protection requires admin access during the talk.
- **Fallback strategy:** Show settings via screenshots if live UI is slow.

## Stage 8 — Cost awareness

- **Goal:** Make cost visible at PR time, not at month end.
- **Files likely to change:**
  - `.github/workflows/cost.yml` (new) — runs **Infracost** against `infra/terraform/` and posts a PR comment. Uses `INFRACOST_API_KEY` as a repo-level GitHub secret (only secret in the demo; mention it explicitly).
  - `infra/terraform/README.md` — note the default SKU and rough monthly cost.
- **Expected outcome:** PR comment with monthly cost diff (e.g. "+$12.41/mo") on infra changes.
- **What to show live:** PR that bumps SKU from `B1` to `S1`; Infracost comment shows the delta.
- **Live-demo risk:** Missing API key, rate limits.
- **Fallback strategy:** Show a screenshot of a prior Infracost comment; mention the principle even if the live tool fails.

## Stage 9 — Operational readiness

- **Goal:** Make the running app observable enough for a real on-call.
- **Files likely to change:**
  - `App/server.js` — add `GET /healthz` (liveness) and `GET /readyz` (readiness).
  - `App_Test/tests/health.test.js` (new) — verify both endpoints.
  - `infra/terraform/main.tf` — set App Service `health_check_path = "/healthz"`.
  - `docs/runbook.md` (new) — 1-page runbook: how to check, how to roll back.
- **Expected outcome:** Tests cover health endpoints; App Service uses them to gate traffic.
- **What to show live:** `curl /healthz` on the live URL; show the runbook.
- **Live-demo risk:** Adding endpoints breaks an existing test assumption.
- **Fallback strategy:** Keep the change to a single new route; run `App_Test` locally first.

## Stage 10 — Demo flow (hotfix story)

- **Goal:** Tie everything together with a believable end-to-end story.
- **Files likely to change:**
  - `prompts/13-create-demo-flow.md`, `prompts/14-create-hotfix-demo.md` — final scripts.
  - One small intentional change in `App/server.js` (e.g. fix a date-formatting bug) introduced via `/hotfix`.
- **Expected outcome:** From "bug reported" → branch → failing test → one-line fix → green CI/security/plan → deploy → verified live, in under 3 minutes.
- **What to show live:**
  - `/hotfix` workflow in Cascade.
  - Failing test, then green test.
  - PR with all checks green and Infracost = $0 diff.
  - Auto-deploy on merge; `curl` live URL shows the fix.
- **Live-demo risk:** Anything in stages 2–6 fails on the live runner.
- **Fallback strategy:**
  - Pre-recorded screen capture of the full hotfix flow as backup.
  - Have `main` already in a known-good state; the demo branch is the only thing changing.

---

## Cross-cutting checklist (apply at every stage)

- Spec updated **before** code.
- Tests added or updated; `npm test` stays green.
- No secrets, no Azure IDs, no private hostnames committed.
- Workflows scoped with least-privilege `permissions:` blocks.
- OIDC for Azure auth; **only** repo variables for IDs (not secrets), Infracost API key being the lone GitHub Actions secret used.
