# Deployment Path

This page describes how the Brasov Sunset API is deployed to Azure
App Service from GitHub Actions, defined in
[`.github/workflows/deploy-azure-app-service.yml`](../../.github/workflows/deploy-azure-app-service.yml).

## How deployment works

1. A maintainer triggers the **Deploy to Azure App Service**
   workflow manually (`workflow_dispatch`) and picks an environment
   (`dev`, `test`, `prod`).
2. The workflow checks out the repository and sets up Node.js 20
   with npm caching.
3. Production dependencies are installed in `App/` (`npm ci
   --omit=dev`) and the folder is packaged into `app.zip`.
4. The workflow logs in to Azure with **OIDC** via
   `azure/login@v2` - no client secrets stored.
5. `azure/webapps-deploy@v3` uploads `app.zip` to the configured
   App Service.
6. A **smoke test** hits `/` and `/sunset` and fails the workflow
   if either endpoint does not return `200`.

## OIDC configuration

The workflow expects a federated credential to be configured on an
Azure AD application that points at this GitHub repository and the
target environment. The flow is:

- GitHub issues an OIDC token for the workflow run.
- `azure/login@v2` exchanges that token for an Azure access token
  using the federated credential.
- No long-lived secret ever leaves Azure.

See the [Microsoft documentation on GitHub Actions OIDC](https://learn.microsoft.com/azure/developer/github/connect-from-azure)
for the exact federated credential setup.

## Required GitHub configuration

These are GitHub **repository variables** (not secrets):

| Name                    | Purpose                                          |
|-------------------------|--------------------------------------------------|
| `AZURE_CLIENT_ID`       | Azure AD application (client) ID for OIDC.      |
| `AZURE_TENANT_ID`       | Azure AD tenant ID.                              |
| `AZURE_SUBSCRIPTION_ID` | Subscription where the App Service lives.       |
| `AZURE_RESOURCE_GROUP`  | Resource Group containing the App Service.      |
| `AZURE_WEBAPP_NAME`     | Name of the App Service to deploy to.           |
| `AZURE_WEBAPP_URL`      | (Optional) URL used by the smoke test.          |

If `AZURE_WEBAPP_URL` is not configured, the workflow input
`app_url` can be supplied at dispatch time. If neither is
provided, the smoke test is skipped (with a clear log message).

## How smoke testing works

After a successful deployment, the workflow runs:

```bash
curl --fail --silent --show-error --max-time 30 "$BASE/"
curl --fail --silent --show-error --max-time 30 "$BASE/sunset"
```

`--fail` flips non-2xx responses into a non-zero exit, so the
workflow turns red if either endpoint is broken after deploy. This
catches the most common deployment regressions: wrong start
command, missing dependency, broken route.

## What is simplified for the demo

- **Manual trigger only.** No automatic deploy on push or merge.
  In a real pipeline this would be gated by environments and
  approvals.
- **No blue/green or slot swap.** A real production setup should
  deploy to a staging slot and swap.
- **Single ZIP artifact.** No container build, no registry push.
- **No DB migrations or warm-up scripts.**
- **Smoke test is a tiny `curl`.** Real services would also check
  health endpoints, run synthetic checks, and validate
  Application Insights signals.
- **Public-repo placeholders.** All Azure identifiers are GitHub
  variables; nothing is hardcoded.

## How to validate deployment

1. Trigger **Deploy to Azure App Service** from the Actions tab
   with `environment = dev`.
2. Wait for the job to finish.
3. Open the App Service URL (`AZURE_WEBAPP_URL` or the deployment
   output) and hit `/sunset`.
4. Check Azure App Service **Log stream** if the smoke test fails.
