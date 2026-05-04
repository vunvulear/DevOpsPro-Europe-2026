# DevOps2026 — Brasov Sunset API

A small DevOps lab project: a Node.js/Express API that returns today's sunset time for **Brașov, Romania** (timezone `Europe/Bucharest`), together with a separate test suite.

## Golden Path Demo

This repo backs the conference talk **"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"**. If you're an attendee landing here, this section is the map.

### What this repository is

A live, end-to-end example of a *golden path* built around a tiny real app. Everything is in this one repo: the app, the tests, the CI/CD workflows, the infrastructure-as-code, the policies, and the docs. No internal portals, no hidden config — what you see is what runs.

### What the original app does

`App/` is an Express API with a single useful endpoint: `GET /sunset` returns today's sunset time for Brașov, Romania, computed locally with `suncalc`. `App_Test/` is a Jest + Supertest suite that locks in the contract (status codes, payload shape, timezone, sunset parity).

### What the golden path adds

On top of the app, the golden path layers six small capabilities — each in one file, each easy to read:

| # | Capability | Lives in |
|---|---|---|
| 1 | **CI** (build + tests on every PR) | `.github/workflows/ci.yml` |
| 2 | **Security scanning** (npm audit, Gitleaks, Trivy, Checkov) | `.github/workflows/security.yml` |
| 3 | **Infrastructure as code** (Azure App Service, Linux, Node 20) | `infra/terraform/` |
| 4 | **Terraform plan on PRs** (fmt + validate always; plan when Azure OIDC vars set) | `.github/workflows/terraform-plan.yml` |
| 5 | **Manual deploy with smoke test** (`workflow_dispatch`, OIDC, no publish profiles) | `.github/workflows/deploy-azure-app-service.yml` |
| 6 | **Cost reminder on infra PRs** (no Infracost token, no fake numbers) | `.github/workflows/cost-awareness.yml` |

Plus a small policy + docs layer that explains the rules: `platform/policies/`, `platform/docs/`.

### How to run the app locally

```powershell
cd App
npm install
npm start
# → http://localhost:3000/sunset
```

### How to run the tests

```powershell
cd App_Test
npm install
npm test
```

### What each GitHub Actions workflow does

- **`ci.yml`** — On PRs and pushes to `main`. `npm ci` for `App/` and `App_Test/`, then `npm test`. No secrets.
- **`security.yml`** — On PRs, pushes to `main`, weekly schedule. Runs `npm audit`, Gitleaks (free on public repos), Trivy filesystem scan (HIGH/CRITICAL, fixed only, SARIF to Security tab), and Checkov on Terraform when present (`soft_fail: true` for the demo).
- **`terraform-plan.yml`** — On PRs/pushes that touch `infra/terraform/**`. Always: `fmt -check` + `init -backend=false` + `validate`. Conditionally: `terraform plan` against Azure via OIDC, posted as a PR comment — only when the three Azure repo variables are set.
- **`deploy-azure-app-service.yml`** — Manual (`workflow_dispatch`) only. Builds `App/` with `npm ci --omit=dev`, uploads an artifact, logs into Azure with OIDC, deploys with `azure/webapps-deploy@v3`, then runs a smoke test of `GET /` (with cold-start retries) and `GET /sunset` (asserts `"city": "Brasov"`).
- **`cost-awareness.yml`** — On PRs touching `infra/terraform/**`. Reads `sku_name` from each `environments/*.tfvars` and posts/updates a single PR comment with a reviewer checklist linking to the cost policy and the Azure pricing calculator. No tokens, no cloud calls.

### How Terraform is structured

```
infra/terraform/
├── versions.tf            # Terraform >= 1.6, azurerm ~> 4.0
├── providers.tf           # No hardcoded subscription/tenant/client IDs
├── variables.tf           # location, RG/plan/app names, env, owner, project, node_version, sku_name
├── main.tf                # Resource Group + Linux App Service Plan + Linux Web App (Node 20, /healthz)
├── outputs.tf             # resource group name, app name, public URL, hostname
├── environments/
│   └── dev.tfvars         # placeholder values for dev
└── README.md
```

State is **local** for the demo (one folder, one plan, one apply). Real projects must move to a remote `azurerm` backend with state locking — the file's README walks through the migration in two paragraphs.

### How deployment to Azure App Service works

1. Click **Actions → Deploy to Azure App Service → Run workflow**.
2. The workflow builds `App/`, logs into Azure via OIDC (no client secret, no publish profile), and deploys to the App Service named in `AZURE_WEBAPP_NAME` (or the workflow input).
3. The `smoke-test` job hits `/` and `/sunset` against `AZURE_WEBAPP_URL` and fails the run on a non-200 or unexpected payload.
4. Rollback is "re-run a previous green run" or `git revert <sha>` + redeploy. Full notes in [`platform/docs/operational-readiness.md`](platform/docs/operational-readiness.md).

### What GitHub variables/secrets are needed

There are **no GitHub Secrets** in this demo. Everything sensitive (the Azure connection itself) goes through OIDC, and the IDs aren't sensitive.

GitHub Actions **Variables** (Settings → Secrets and variables → Actions → *Variables*):

| Variable | Used by | Required for |
|---|---|---|
| `AZURE_CLIENT_ID` | `terraform-plan.yml`, `deploy-azure-app-service.yml` | Real `terraform plan` and any deploy |
| `AZURE_TENANT_ID` | same | same |
| `AZURE_SUBSCRIPTION_ID` | same | same |
| `AZURE_WEBAPP_NAME` | `deploy-azure-app-service.yml` | Deploy target (or pass as workflow input) |
| `AZURE_RESOURCE_GROUP` | informational | — |
| `AZURE_WEBAPP_URL` | `deploy-azure-app-service.yml` | Smoke test (or pass as workflow input) |

You also need a one-time Azure-side **federated identity credential** on an app registration / managed identity, scoped to this repo + branch. The doc at [`platform/docs/deployment-path.md`](platform/docs/deployment-path.md) lists the exact subject claim and the recommended role (`Website Contributor`).

If the Azure variables are missing, the affected jobs **skip themselves with a green status** — the repo is safe for forks and casual contributors.

### What is intentionally simplified for a 30-minute talk

- **Local Terraform state**, not remote `azurerm`. Real projects must move to remote state with locking.
- **Single environment (`dev`)**. The structure supports `test`/`prod` `tfvars` — they're just not in the repo.
- **Manual deploy only** (`workflow_dispatch`). One trigger change makes it push-to-deploy.
- **No deployment slots, no zero-downtime swap.** Rollback = redeploy a known-good commit.
- **No Application Insights, no Log Analytics.** App Service log stream is good enough live.
- **No Infracost, no real cost numbers.** Cost is *visible* (a reviewer comment), not *blocking*.
- **Checkov runs in `soft_fail` mode.** Findings surface as annotations; they don't block the demo PR.
- **No Key Vault, no managed identity for the app**, because the API has no secrets.
- **`prompts/` files are intentionally light.** They're a script, not a manual.
- **Branch protection, CODEOWNERS, PR template** are recommended in `platform/policies/deployment-policy.md` but not all enabled in this repo — they live in repo settings, which a forked clone doesn't carry.

### Where to read more

- [`specs/golden-path/`](specs/golden-path/) — the spec, plan, and tasks behind everything above.
- [`platform/docs/`](platform/docs/) — one short doc per capability (CI, security, IaC, deploy, cost, ops, policies, Spec Kit setup).
- [`platform/policies/`](platform/policies/) — the rules of the road as YAML/Markdown, in five small files.
- [`prompts/`](prompts/) — the live demo script, numbered `00`..`15`.

### Tone-check before you copy this pattern

A golden path is **not** an enterprise governance framework. It's a path. The first version should be small enough that one person can maintain it, and useful enough that a second team chooses to adopt it. Then the third team breaks something the first didn't think about, and the path improves.

> **Start small. Make the path real. Improve it with every team that uses it.**

## Project structure

```
DevOps2026/
├── App/                # Express API (production code)
├── App_Test/           # Jest + Supertest unit/integration tests
├── infra/terraform/    # Terraform for Azure App Service (Linux, Node 20)
├── platform/
│   ├── docs/           # Short docs per capability (ci, security, iac, deploy, cost, ops, policies)
│   └── policies/       # service-metadata, tagging, deployment, cost
├── prompts/            # Live demo prompt scripts (numbered)
├── specs/golden-path/  # spec.md, plan.md, tasks.md
├── .github/workflows/  # ci, security, terraform-plan, deploy, cost-awareness
├── .specify/           # Spec Kit templates, scripts, constitution
├── .windsurf/          # Cascade rules + slash commands (speckit.*, hotfix, bugfix, modify, refactor)
└── .gitignore
```

- **`App/`** — Express server using [`suncalc`](https://www.npmjs.com/package/suncalc) to compute sunset based on Brașov coordinates (`45.6427, 25.5887`).
- **`App_Test/`** — Jest test suite that imports the Express `app` via Supertest (no port binding) and validates endpoints, payload shape, timezone, and SunCalc parity.

## Prerequisites

- Node.js 18+
- npm

## Run the API

```powershell
cd App
npm install
npm start
```

Server: `http://localhost:3000`

### Endpoints

| Method | Path       | Description                        |
|-------:|------------|------------------------------------|
| GET    | `/`        | API info                           |
| GET    | `/sunset`  | Today's sunset time for Brașov     |

#### Example response — `GET /sunset`

```json
{
  "city": "Brasov",
  "country": "Romania",
  "timezone": "Europe/Bucharest",
  "date": "04.05.2026",
  "sunset_local": "20:38:12",
  "sunset_utc": "2026-05-04T17:38:12.000Z",
  "coordinates": { "latitude": 45.6427, "longitude": 25.5887 }
}
```

## Run the tests

```powershell
cd App_Test
npm install
npm test
```

The suite (`App_Test/tests/sunset.test.js`) covers:

- **Constants** — Brașov latitude/longitude and timezone.
- **`GET /`** — status, JSON content-type, payload shape.
- **`GET /sunset`** — status, city/country, timezone, coordinates, `HH:MM:SS` formatting, valid ISO `sunset_utc`, sunset day matches today in `Europe/Bucharest`, and parity with a fresh `SunCalc` computation.
- **Unknown routes** — returns `404`.

## CI

Continuous integration is the first capability of the golden path.

- **Workflow:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
- **Triggers:** pull requests targeting `main` and pushes to `main`.
- **What it does:**
  1. Checks out the repo on `ubuntu-latest`.
  2. Sets up Node.js 20 with built-in `npm` caching for both lockfiles.
  3. Runs `npm ci` in `App/` and in `App_Test/`.
  4. Runs `npm test` in `App_Test/` (Jest + Supertest against the Express `app`).
- **Why it matters for the golden path:** every change is validated on a clean runner before it can reach `main`. No secrets, no deployment — just a fast, reliable safety net that the rest of the golden path (security, infra, deploy) builds on.

To validate locally before pushing:

```powershell
cd App; npm ci; cd ..\App_Test; npm ci; npm test
```

## Operational readiness

Just enough to run the Brașov Sunset API in Azure App Service without surprises.

- **Health:** `GET /healthz` (liveness); `GET /readyz` recommended. App Service uses `/healthz` via `health_check_path` in Terraform.
- **Smoke test:** runs automatically after every deployment (`smoke-test` job in [`.github/workflows/deploy-azure-app-service.yml`](.github/workflows/deploy-azure-app-service.yml)) — asserts `/` and `/sunset` return 200 with the expected payload.
- **Logs:** Azure portal → App Service → **Log stream** / **Deployment Center** / **Diagnose and solve problems**, or `az webapp log tail`.
- **Rollback:** re-run a previous green `Deploy to Azure App Service` run, or `git revert` and redeploy.

Full guidance — including future improvements (structured logging, Application Insights, OpenTelemetry, SLOs/alerts) — is in [`platform/docs/operational-readiness.md`](platform/docs/operational-readiness.md).

## Spec-driven demo workflow

This repo backs the conference talk **"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"**.

- **Spec Kit** ([github/spec-kit](https://github.com/github/spec-kit)) structures the work. The golden-path artifacts live under `specs/golden-path/` and are produced via `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`.
- **Windsurf / Cascade** is the coding agent that implements each step. Slash commands are defined in `.windsurf/workflows/`. Extension workflows added for the demo: `/modify`, `/refactor`, `/bugfix`, `/hotfix`.
- **GitHub Actions** validates the golden path: build/test, security scan, Terraform plan, deploy.
- **Azure App Service** is the deployment target for the Brașov Sunset API.

The live demo script is in `prompts/` (numbered `00`..`15`). Setup details are in [`platform/docs/spec-kit-setup.md`](platform/docs/spec-kit-setup.md).

## Notes

- `prompts/` is tracked in git (demo script). Local private scratch notes (`prompts/_01.md`) are ignored via `.gitignore`.
- The API exports the Express `app` and only calls `listen()` when executed directly, which lets tests import it via Supertest without binding a port.
