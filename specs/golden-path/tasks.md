# Golden Path — Tasks

> Companion to `spec.md` (the **what**) and `plan.md` (the **how**).
> This file is the **ordered, actionable** list of work to bring the golden
> path to life in this repository. Tasks are sized to land as small,
> independently-reviewable PRs and grouped by the same ten stages used in
> `plan.md`.

## Conventions

- **ID** format: `T<stage>.<n>` (e.g. `T2.1` = Stage 2, task 1).
- **[P]** = can run in parallel with the previous task in the same stage.
- **DoD** = Definition of Done. A task is not complete until every DoD bullet
  is true.
- **Constraint check** appears once per stage as `Cx.y` reminders for the
  cross-cutting rules from `plan.md` (no secrets, OIDC, skip-clean, one screen
  per file).
- All file paths are relative to repo root unless cited absolutely.

## Pre-flight (do once, before Stage 1 PRs)

- **T0.1** Confirm GitHub repo **Variables** plan: `AZURE_CLIENT_ID`,
  `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_APP_NAME`,
  `AZURE_RESOURCE_GROUP`, `AZURE_LOCATION`. **No Secrets.** Document the list
  in `README.md` under a "Repository configuration" section.
  - **DoD:** Variables list is in `README.md`; no values committed; the word
    "Secrets" appears nowhere referencing Azure auth.
- **T0.2** Decide branch protection on `main`: required checks =
  `ci / test`, `security / *`. Document only; do not enable yet (avoid
  blocking the demo).
  - **DoD:** A short note in `platform/policies/deployment-policy.yaml`
    placeholder confirms the intent.

---

## Stage 1 — Existing app baseline

> Goal: anchor the talk in a tiny, real, already-tested workload. Read-only.

- **T1.1** Verify `App/` runs and `App_Test/` is green locally.
  - Commands: `npm ci` in `App/`, `npm ci` in `App_Test/`, `npm test` in
    `App_Test/`, `node App/server.js` then `curl localhost:3000/sunset` and
    `curl localhost:3000/healthz`.
  - **DoD:** All four commands succeed; `/sunset` returns `city: "Brasov"`
    and `timezone: "Europe/Bucharest"`; `/healthz` returns `{"status":"ok"}`.
- **T1.2** Record an `asciinema` cast of T1.1 as the Stage 1 fallback.
  - **DoD:** Cast file lives outside the repo (speaker-local); referenced
    from `specs/golden-path/demo-script.md` (created in Stage 10).

---

## Stage 2 — CI

> Goal: every PR builds and tests; failure blocks the workflow.

- **T2.1** Add `.github/workflows/ci.yml` with one job `test`.
  - Triggers: `pull_request` to `main`, `push` to `main`.
  - Steps: `actions/checkout@v4`, `actions/setup-node@v4` (Node 20, `cache:
    npm`, `cache-dependency-path` = both lockfiles), `npm ci` in `App/`,
    `npm ci` in `App_Test/`, `npm test` in `App_Test/`.
  - Header comment states purpose in one line.
  - **DoD:** PR run is green; the file fits on one screen.
- **T2.2** [P] Open a throwaway PR that breaks one assertion to capture a
  red→green screenshot for Stage 2 fallback.
  - **DoD:** Two screenshots saved speaker-local; PR closed without merge.

**Constraint check C2.1:** No `secrets.*` in `ci.yml`. No Azure auth.

---

## Stage 3 — Security scanning

> Goal: visible signal on PRs without becoming a gate.

- **T3.1** Add `.github/workflows/security.yml` with four jobs:
  `npm-audit`, `gitleaks`, `trivy-fs`, `checkov`.
  - `npm-audit`: `npm audit --omit=dev --audit-level=high` in `App/`.
  - `gitleaks`: `gitleaks/gitleaks-action@v2`, `fetch-depth: 0`.
  - `trivy-fs`: `aquasecurity/trivy-action`, `severity: HIGH,CRITICAL`,
    `ignore-unfixed: true`, output `sarif`, upload via
    `github/codeql-action/upload-sarif@v3`.
  - `checkov`: `if: hashFiles('infra/terraform/**') != ''`, `soft_fail:
    true`.
  - **DoD:** All four jobs run on a PR; SARIF appears in the Security tab.
- **T3.2** [P] Add `.gitleaks.toml` only if a placeholder triggers a false
  positive during T3.1.
  - **DoD:** Allowlist entry is the smallest possible regex; commented.

**Constraint check C3.1:** Workflow uses no `secrets.*`; runs green on a fork.

---

## Stage 4 — Terraform infrastructure for Azure App Service

> Goal: one small stack, hardened defaults, required tags.

Create under `infra/terraform/`:

- **T4.1** `versions.tf` — `terraform { required_version }`, `azurerm`
  provider pinned to a stable major.
- **T4.2** `providers.tf` — `provider "azurerm" { features {} }`.
- **T4.3** `variables.tf` — `project`, `environment`, `location`, `owner`,
  `sku_name`, `app_name`, `repo`. All typed; sensible defaults only for
  `location` and `sku_name`.
- **T4.4** `locals.tf` — `common_tags` map: `project`, `environment`,
  `owner`, `managed_by = "terraform"`, `repo`.
- **T4.5** `main.tf` — `azurerm_resource_group`, `azurerm_service_plan`
  (Linux, `os_type = "Linux"`), `azurerm_linux_web_app` with:
  - `site_config.application_stack.node_version` (LTS).
  - `site_config.health_check_path = "/healthz"`.
  - `site_config.http2_enabled = true`.
  - `site_config.minimum_tls_version = "1.2"`.
  - `site_config.ftps_state = "Disabled"`.
  - `site_config.websockets_enabled = false`.
  - `site_config.remote_debugging_enabled = false`.
  - `https_only = true`.
  - `tags = local.common_tags` on all three resources.
- **T4.6** `outputs.tf` — `default_hostname`, `resource_group_name`,
  `app_name`.
- **T4.7** `environments/dev.tfvars` — placeholder values only:
  `project = "<PROJECT>"`, `environment = "dev"`, `owner = "<OWNER>"`,
  `app_name = "<APP_NAME>"`, `repo = "<ORG>/<REPO>"`, `sku_name = "B1"`,
  `location = "westeurope"`. **No real names, no IDs.**
- **T4.8** Run locally: `terraform fmt -recursive`, `terraform init
  -backend=false`, `terraform validate`.
  - **DoD for Stage 4:** Seven files; all validate green; no Azure
    subscription/tenant/client IDs anywhere; `dev.tfvars` contains only
    placeholders.

**Constraint check C4.1:** No backend block (local state, deliberate). No
hardcoded Azure IDs. Header comment in `main.tf` calls out the demo
simplifications.

---

## Stage 5 — Terraform validation and plan

> Goal: every infra PR gets fmt + validate; if Azure vars set, also a real
> `plan` posted as a sticky PR comment.

- **T5.1** Add `.github/workflows/terraform.yml`.
  - Triggers: `pull_request` paths-filtered on `infra/terraform/**`.
  - `permissions: id-token: write, contents: read, pull-requests: write`.
  - Job `validate` (always, no auth): `terraform fmt -check -recursive`,
    `terraform init -backend=false`, `terraform validate`.
  - Job `plan` (`if: ${{ vars.AZURE_CLIENT_ID != '' }}`): `azure/login@v2`
    with `client-id`, `tenant-id`, `subscription-id` from `vars`;
    `terraform init`, `terraform plan -var-file=environments/dev.tfvars
    -out=tfplan`, `terraform show -no-color tfplan`, post sticky comment via
    `marocchino/sticky-pull-request-comment@v2` (header
    `<!-- terraform-plan -->`).
  - **DoD:** On a fork, only `validate` runs and is green. On the demo repo
    with vars set, `plan` posts a comment with the create diff.
- **T5.2** [P] Stage two PRs for the demo:
  - One that bumps `sku_name` in `dev.tfvars` to show the plan diff.
  - One previously-merged or screenshot-ready as fallback.
  - **DoD:** Both PR URLs noted in `demo-script.md` (Stage 10).

**Constraint check C5.1:** No `secrets.*`; OIDC only; skip-clean on missing
vars.

---

## Stage 6 — Azure App Service deployment

> Goal: manual deploy + smoke test.

- **T6.1** Add `.github/workflows/deploy.yml`.
  - Trigger: `workflow_dispatch` with input `environment` (default `dev`).
  - `permissions: id-token: write, contents: read`.
  - Job `build`: `npm ci --omit=dev` in `App/`; zip the `App/` directory;
    upload artifact `app-zip`.
  - Job `deploy` (`needs: build`): download artifact; `azure/login@v2`
    (OIDC); `azure/webapps-deploy@v3` with `app-name: ${{ vars.AZURE_APP_NAME
    }}` and the zip path. **No publish-profile.**
  - Job `smoke-test` (`needs: deploy`): `curl --retry 10 --retry-delay 5
    --retry-all-errors https://${{ vars.AZURE_APP_NAME
    }}.azurewebsites.net/`; then `curl .../sunset | jq -e '.city == "Brasov"
    and .timezone == "Europe/Bucharest"'`.
  - **DoD:** A manual run is green end-to-end; smoke job fails fast on a
    deliberate assertion drift.
- **T6.2** [P] Pre-deploy on the morning of the talk so the live run is an
  *update*, not a first-create.
  - **DoD:** A green run from earlier the same day is pinned in a browser
    tab.

**Constraint check C6.1:** No publish profiles, no `secrets.*`; only
`vars.*`.

---

## Stage 7 — Platform policies

> Goal: small, readable rules of the road.

Create under `platform/policies/`:

- **T7.1** `service.yaml` — schema for service metadata: `name`, `owner`,
  `repo`, `runtime`, `tier`. Comment with one example, all placeholders.
- **T7.2** `tagging-policy.yaml` — required tag keys, allowed values for
  `environment` (`dev`/`test`/`prod`), pointer to `locals.tf`.
- **T7.3** `deployment-policy.yaml` — who can deploy, when, with which
  approval. Captures the `workflow_dispatch`-only stance and the future
  branch-protection intent from T0.2.
- **T7.4** `cost-policy.yaml` — per-environment SKU defaults
  (`dev: B1`, `test: B2`, `prod: P1v3` as placeholder examples) and
  team-set placeholder budgets (`<TEAM_BUDGET_EUR>`).
- **T7.5** `policy-guardrails.md` — table mapping each rule to status
  (Enforced / Documented / Planned) and a credible hardening path
  (Azure Policy, branch protection, OPA/Conftest, etc.).
  - **DoD:** Five files; each fits on one screen; no real org/team names; the
    matrix is honest about what's only documented.

---

## Stage 8 — Cost awareness

> Goal: SKU-and-policy reviewer reminder on infra PRs. No external services.

- **T8.1** Add `scripts/cost-comment.sh` (`set -euo pipefail`) that:
  - Iterates `infra/terraform/environments/*.tfvars`.
  - Greps `^sku_name` per file, strips quotes, captures the env name from
    the filename.
  - Reads matching defaults from `platform/policies/cost-policy.yaml`
    (simple `grep`/`awk`; no YAML parser dependency).
  - Emits a Markdown checklist to stdout with: env, chosen `sku_name`,
    policy default, reviewer reminder line.
  - On any parse failure, falls back to echoing the raw `sku_name` lines.
- **T8.2** Add `.github/workflows/cost.yml`.
  - Triggers: `pull_request` paths-filtered on
    `infra/terraform/environments/*.tfvars` and
    `platform/policies/cost-policy.yaml`.
  - One job: run `scripts/cost-comment.sh`, capture to a file, post via
    `marocchino/sticky-pull-request-comment@v2` with header
    `<!-- cost-checklist -->`.
  - **DoD:** The Stage 5 SKU-bump PR also gets a refreshed cost comment;
    re-running the workflow updates the same comment, never duplicates.

**Constraint check C8.1:** No tokens, no fake currency amounts beyond
clearly-marked placeholders.

---

## Stage 9 — Operational readiness

> Goal: a 60-second story for health, logs, rollback.

- **T9.1** Confirm `App/server.js` exposes `GET /healthz` returning
  `{status:"ok"}`. **No code change expected.**
  - **DoD:** Test in `App_Test/` covers the route; if missing, add the
    smallest possible test in the same PR.
- **T9.2** Add `platform/runbook.md` with three sections:
  - **Health.** `/healthz` contract; App Service `health_check_path`; smoke
    test as the SLI.
  - **Logs.** `az webapp log tail -g <RESOURCE_GROUP> -n <APP_NAME>` and the
    Log stream blade. App Insights explicitly out of scope.
  - **Rollback.** Re-run last green `deploy.yml`; or `git revert` +
    re-dispatch. Two-command path documented.
  - **DoD:** One page; placeholders only; no private hostnames.

---

## Stage 10 — Demo flow

> Goal: tie it together; rehearse the hotfix.

- **T10.1** Add `specs/golden-path/demo-script.md`:
  - One-page on-stage script aligned to the time budget in `plan.md`.
  - Per-step: spoken cue, command/click, expected outcome, what-can-fail,
    fallback (cross-referenced to each stage's fallback in `plan.md`).
  - URLs of the staged PRs from T5.2; pinned-tab list; `az login` reminder.
  - **DoD:** Speaker can run the talk from this single page.
- **T10.2** Add `specs/golden-path/hotfix-scenario.md`:
  - The diacritic-drift story: smoke test asserts `city == "Brasov"`.
  - Break: change the response field to `"Brașov"` (with diacritic).
  - Watch `deploy.yml` smoke job go red.
  - Fix: revert the one character; redeploy; smoke green.
  - **DoD:** Both the break-PR and the fix-PR are pre-drafted on a branch
    and referenced from `demo-script.md`.
- **T10.3** Pre-flight checklist (morning of the talk), append to
  `demo-script.md`:
  - `az login` complete.
  - `~/.terraform.d/plugin-cache` warm.
  - Pre-deploy run green.
  - Staged PRs open in pinned tabs.
  - Asciinema fallback open in a hidden window.
  - Timer running on the second screen.
  - **DoD:** Checklist is a literal copy-pasteable list; no surprises.

---

## Tracking

Recommended PR sequence (one PR per `T*` unless paired with a `[P]`):

1. T0.1, T0.2 — `chore: document repo Variables and branch-protection intent`
2. T2.1 — `ci: add CI workflow`
3. T3.1 — `ci: add security scanning workflow`
4. T4.1–T4.8 — `infra: add Terraform App Service stack`
5. T5.1 — `ci: add Terraform validate + plan workflow`
6. T6.1 — `ci: add manual deploy workflow with smoke test`
7. T7.1–T7.5 — `platform: add policies`
8. T8.1, T8.2 — `ci: add cost-awareness reviewer comment`
9. T9.2 — `platform: add operational runbook`
10. T10.1, T10.2, T10.3 — `docs: add demo script, hotfix scenario, pre-flight`

Each PR is reviewable on one screen and either green-on-fork or
skip-clean-on-fork. When all ten land on `main`, the golden path meets the
acceptance criteria in `spec.md`.
