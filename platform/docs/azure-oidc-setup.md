# Azure OIDC Setup — One-Time Configuration

> One-page setup so the `terraform.yml` plan job and the `deploy.yml`
> deploy + smoke jobs can authenticate to Azure **without secrets**, per
> constitution principles I and II.
>
> Estimated time: **10 minutes**. No portal clicks; everything is `az` CLI.

## Prerequisites

- Logged-in Azure CLI: `az login`
- An Azure subscription you can create resources in
- Repo admin on `vunvulear/DevOpsPro-Europe-2026`

## Step 1 — Choose names and capture IDs

```pwsh
$ORG  = "vunvulear"
$REPO = "DevOpsPro-Europe-2026"
$APP_REG_NAME = "gh-$REPO"          # App Registration display name
$RG_NAME      = "rg-brasov-sunset-dev"
$LOCATION     = "westeurope"

$SUB_ID    = (az account show --query id -o tsv)
$TENANT_ID = (az account show --query tenantId -o tsv)
Write-Host "SUB_ID    = $SUB_ID"
Write-Host "TENANT_ID = $TENANT_ID"
```

## Step 2 — Create the App Registration + Service Principal

```pwsh
$CLIENT_ID = (az ad app create --display-name $APP_REG_NAME --query appId -o tsv)
az ad sp create --id $CLIENT_ID | Out-Null
Write-Host "CLIENT_ID = $CLIENT_ID"
```

## Step 3 — Federated credential (trust GitHub Actions)

Three credentials cover the workflows the golden path runs:

```pwsh
# (a) Pull-request runs (terraform plan)
az ad app federated-credential create --id $CLIENT_ID --parameters (@{
  name        = "github-pr"
  issuer      = "https://token.actions.githubusercontent.com"
  subject     = "repo:$ORG/${REPO}:pull_request"
  audiences   = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress)

# (b) Push to main (informational; not used today but recommended)
az ad app federated-credential create --id $CLIENT_ID --parameters (@{
  name      = "github-main"
  issuer    = "https://token.actions.githubusercontent.com"
  subject   = "repo:$ORG/${REPO}:ref:refs/heads/main"
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress)

# (c) Manual workflow_dispatch deploy (no environment scoping)
az ad app federated-credential create --id $CLIENT_ID --parameters (@{
  name      = "github-dispatch"
  issuer    = "https://token.actions.githubusercontent.com"
  subject   = "repo:$ORG/${REPO}:ref:refs/heads/Specs"
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress)
```

> If you later switch to GitHub Environments (e.g. `dev`), add a fourth
> credential with subject `repo:$ORG/$REPO:environment:dev`.

## Step 4 — Pre-create the Resource Group, then grant Contributor on it

Per constitution P-V (least privilege over convenience): scope the role
to the RG, not the subscription.

```pwsh
az group create -n $RG_NAME -l $LOCATION --tags `
  project=brasov-sunset environment=dev owner=demo `
  managed_by=terraform "repo=$ORG/$REPO" | Out-Null

$RG_ID = (az group show -n $RG_NAME --query id -o tsv)
az role assignment create --assignee $CLIENT_ID `
  --role "Contributor" --scope $RG_ID | Out-Null
```

## Step 5 — Choose a globally-unique App Service name

```pwsh
$APP_NAME = "brasov-sunset-$([guid]::NewGuid().ToString('N').Substring(0,6))"
Write-Host "APP_NAME = $APP_NAME (must be globally unique under .azurewebsites.net)"
```

## Step 6 — Set GitHub repository **Variables** (not Secrets)

> Constitution P-II: Azure identifiers are *non-secret configuration*.
> Set them under **Settings → Secrets and variables → Actions → Variables**.

| Variable | Value |
|---|---|
| `AZURE_CLIENT_ID` | `$CLIENT_ID` from Step 2 |
| `AZURE_TENANT_ID` | `$TENANT_ID` from Step 1 |
| `AZURE_SUBSCRIPTION_ID` | `$SUB_ID` from Step 1 |
| `AZURE_RESOURCE_GROUP` | `$RG_NAME` from Step 1 |
| `AZURE_APP_NAME` | `$APP_NAME` from Step 5 |
| `AZURE_LOCATION` | `$LOCATION` from Step 1 (e.g. `westeurope`) |

If you have GitHub CLI:

```pwsh
gh variable set AZURE_CLIENT_ID       --body $CLIENT_ID -R "$ORG/$REPO"
gh variable set AZURE_TENANT_ID       --body $TENANT_ID -R "$ORG/$REPO"
gh variable set AZURE_SUBSCRIPTION_ID --body $SUB_ID    -R "$ORG/$REPO"
gh variable set AZURE_RESOURCE_GROUP  --body $RG_NAME   -R "$ORG/$REPO"
gh variable set AZURE_APP_NAME        --body $APP_NAME  -R "$ORG/$REPO"
gh variable set AZURE_LOCATION        --body $LOCATION  -R "$ORG/$REPO"
```

## Step 7 — Update `infra/terraform/environments/dev.tfvars`

> Replace placeholders with values that match the Variables above.
> This file is committed; values must NOT be subscription/tenant/client IDs.

```hcl
project     = "brasov-sunset"
environment = "dev"
location    = "westeurope"
owner       = "demo"
sku_name    = "B1"
app_name    = "<APP_NAME from Step 5>"
repo        = "vunvulear/DevOpsPro-Europe-2026"
```

## Step 8 — First apply (do this on talk day morning)

The talk's golden path uses **manual `workflow_dispatch`** for deploys.
The first time, you also need infra. Two options:

**Option A — local `terraform apply` (fastest, demo simplification).**

```pwsh
$env:ARM_USE_OIDC      = "true"
$env:ARM_SUBSCRIPTION_ID = $SUB_ID
$env:ARM_TENANT_ID       = $TENANT_ID
$env:ARM_CLIENT_ID       = $CLIENT_ID
# For local, you can keep your az login; OIDC kicks in only inside Actions.
cd infra/terraform
terraform init
terraform plan  -var-file=environments/dev.tfvars -out=tfplan
terraform apply tfplan
```

**Option B — let the deploy workflow create everything.** Skip if the
Web App does not yet exist; `azure/webapps-deploy@v3` requires the
target App Service to already exist. Use Option A for the first apply.

## Step 9 — Pre-deploy verification

```pwsh
# Trigger the deploy workflow and wait for green
gh workflow run deploy.yml -R "$ORG/$REPO" -r Specs -f environment=dev
gh run watch -R "$ORG/$REPO"

# Smoke
curl https://$APP_NAME.azurewebsites.net/healthz
curl https://$APP_NAME.azurewebsites.net/sunset
```

## Cleanup (after the talk)

```pwsh
az group delete -n $RG_NAME --yes --no-wait
az ad app delete --id $CLIENT_ID
```

## Troubleshooting

- **"AADSTS70021: No matching federated identity record found."** The
  subject claim does not match. Re-check Step 3; the subject must match
  the *exact* triggering context (`pull_request`, `ref:refs/heads/<branch>`,
  or `environment:<env>`).
- **`webapps-deploy` 404.** The Web App does not exist yet. Run
  `terraform apply` first (Step 8 Option A).
- **Plan job skipped on a fork.** Expected — constitution P-III. The
  `validate` job still runs.
- **Plan job fails with `AuthorizationFailed`.** The role assignment in
  Step 4 may not have propagated yet (~60s) or the scope is wrong.
