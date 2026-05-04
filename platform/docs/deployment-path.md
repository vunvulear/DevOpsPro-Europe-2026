# Deployment Path

The deployment workflow ([`.github/workflows/deploy-azure-app-service.yml`](../../.github/workflows/deploy-azure-app-service.yml))
deploys the Brașov Sunset API to **Azure App Service for Node.js on Linux**.
It is the fourth capability of the golden path, after CI, security, and IaC.

## How deployment works

Three jobs, run sequentially on `workflow_dispatch`:

1. **`build`** — Checks out the repo, sets up Node.js 20 with npm caching, runs `npm ci --omit=dev` inside `App/`, and uploads the resulting folder as an artifact (`brasov-sunset-api`).
2. **`deploy`** — Downloads the artifact, logs into Azure via OIDC (`azure/login@v2`), and ships it with `azure/webapps-deploy@v3` to the App Service whose name is in the `AZURE_WEBAPP_NAME` repo variable (or the workflow input). Uses the GitHub `dev` environment for protected URL display.
3. **`smoke-test`** — Optional. Runs only when `AZURE_WEBAPP_URL` (variable or input) is provided. `curl`s `GET /` (with retry/backoff for cold start) and `GET /sunset` (asserting `"city": "Brasov"` and `"timezone": "Europe/Bucharest"` are present).

The workflow has **no `push:` trigger** — deployment only happens when someone clicks **Actions → Deploy to Azure App Service → Run workflow**. This is documented as the deliberate "manual demo" posture; promoting to push-to-deploy is one extra trigger line away.

## OIDC auth configuration

GitHub Actions authenticates to Azure with **federated credentials** — no client secrets, no publish profiles ever live in this repo.

One-time Azure setup (out-of-repo, done by the platform team):

1. Create (or reuse) an Azure AD **App Registration** or **User-Assigned Managed Identity**.
2. Grant it the minimum role on the target Resource Group: `Website Contributor` is enough for `webapps-deploy`. (`Contributor` works but is broader than needed.)
3. Add a **Federated identity credential** on that identity, scoped to:
   - Issuer: `https://token.actions.githubusercontent.com`
   - Subject: `repo:vunvulear/DevOpsPro-Europe-2026:ref:refs/heads/main` (or `:environment:dev` if you wire the `dev` environment up).
   - Audience: `api://AzureADTokenExchange`.

Microsoft docs: ["Configure a federated identity credential on an app"](https://learn.microsoft.com/azure/active-directory/develop/workload-identity-federation-create-trust).

## Required GitHub repo configuration

All values live as **GitHub Actions Variables** (Settings → Secrets and variables → Actions → **Variables** tab). **No GitHub Secrets are required**: OIDC removes the need for a client secret, and the variable values themselves (UUIDs, resource names) are not sensitive.

| Name | Where | Purpose |
|---|---|---|
| `AZURE_CLIENT_ID` | Variables | App registration / managed identity client ID |
| `AZURE_TENANT_ID` | Variables | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Variables | Subscription that hosts the resource group |
| `AZURE_WEBAPP_NAME` | Variables | Target App Service name (e.g. `app-brasov-sunset-dev-xyz`) |
| `AZURE_RESOURCE_GROUP` | Variables | Resource group hosting the App Service (informational; `webapps-deploy` resolves by app name) |
| `AZURE_WEBAPP_URL` | Variables | Base URL used by smoke test (e.g. `https://app-brasov-sunset-dev-xyz.azurewebsites.net`) |

If the three `AZURE_*` OIDC variables are missing, the `deploy` job is **skipped** with a green status, the workflow stays safe for forks, and only `build` runs. If `AZURE_WEBAPP_URL` is missing (and no input override), `smoke-test` is also skipped.

## Triggering the deployment

1. **Actions** tab → **Deploy to Azure App Service** → **Run workflow**.
2. (Optional) Provide `webapp_name` and/or `webapp_url` as inputs to override the repo variables for ad-hoc demos.
3. Click **Run workflow**.

## Smoke testing

After deploy, `smoke-test`:

- Retries `GET /` up to 5 times with linear backoff (5s, 10s, 15s, 20s, 25s) to absorb cold start.
- Then `GET /sunset` once, asserting status `200` and that the JSON body contains `"city": "Brasov"` and `"timezone": "Europe/Bucharest"`.
- Fails the workflow on any non-200 or missing assertion. The deployment is still in place — investigate logs in App Service before retrying.

## What is simplified for the demo

- **Manual trigger only.** Real teams typically auto-deploy on `push: main` after `ci.yml` and `terraform-plan.yml` succeed; one trigger change makes it so.
- **Single environment (`dev`).** The GitHub `dev` environment is referenced but no protection rules are defined. Add reviewers, wait timers, or branch policies for higher environments.
- **No deployment slots.** A real production setup would deploy to a `staging` slot and swap after warm-up. Skipped to keep the demo under two minutes.
- **Smoke test is HTTP only.** No synthetic transactions, no Application Insights availability tests.
- **No rollback automation.** Recovery is "redeploy a known-good commit" — documented in the runbook (operational readiness step).
- **`Website Contributor` not enforced** — the doc recommends it; the actual role assignment lives in Azure, not in this repo.
- **No artifact signing / SLSA provenance.** Out of scope for the talk.
