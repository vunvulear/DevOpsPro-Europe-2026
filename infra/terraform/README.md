# Terraform — Brașov Sunset API on Azure App Service

Infrastructure-as-code for the **dev** environment of the Brașov Sunset API.
Target: **Azure App Service for Node.js on Linux**, in a single resource group.

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform & provider version pins |
| `providers.tf` | `azurerm` provider configuration (no hardcoded IDs) |
| `variables.tf` | Input variables with defaults and descriptions |
| `main.tf` | Resource Group + Linux App Service Plan + Linux Web App |
| `outputs.tf` | Resource group name, app name, public URL, hostname |
| `environments/dev.tfvars` | Dev environment values (placeholders included) |
| `.gitignore` | Excludes state, plans, and lock from git |

## Resources defined

- **`azurerm_resource_group.main`** — holds everything for one environment.
- **`azurerm_service_plan.main`** — Linux plan, default SKU `B1`.
- **`azurerm_linux_web_app.main`** — Node.js Web App with:
  - `application_stack.node_version` (default `20-lts`)
  - `health_check_path = "/healthz"` (wired to the app's health endpoint)
  - `https_only = true`, `minimum_tls_version = "1.2"`
  - `app_settings`: `WEBSITES_PORT=3000`, `SCM_DO_BUILD_DURING_DEPLOYMENT=true`, `ENVIRONMENT`
  - Common tags: `project`, `environment`, `owner`, `managed_by`, `repo`

## Variables

`location`, `resource_group_name`, `app_service_plan_name`, `app_service_name`, `environment`, `owner`, `project`, `node_version`, `sku_name`. See `variables.tf` for descriptions and defaults; only the names without defaults must be provided per environment.

## Authentication

No credentials in this repo. The provider reads auth from the environment:

- **Locally:** `az login` (Azure CLI auth).
- **In GitHub Actions:** Azure OIDC via `azure/login@v2` — no client secrets, no publish profiles.

`subscription_id`, `tenant_id`, and `client_id` are **never** hardcoded; they are supplied via env vars / GitHub repo variables at runtime.

## State

State is **local** for the live demo (no `backend` block). This keeps the demo flow simple — one folder, one `plan`, one `apply`.

> **Real projects must use remote state.** Recommended pattern:
>
> ```hcl
> terraform {
>   backend "azurerm" {
>     resource_group_name  = "rg-tfstate"
>     storage_account_name = "sttfstate<unique>"
>     container_name       = "tfstate"
>     key                  = "brasov-sunset/dev.tfstate"
>   }
> }
> ```
>
> With remote state you also get state locking (Azure Blob lease) and shared visibility for the team. Add the `backend` block, run `terraform init -migrate-state`, and commit.

## Validate locally

```powershell
# Prerequisites: Terraform 1.6+, Azure CLI, az login
cd infra\terraform

terraform fmt -check
terraform validate
terraform init
terraform plan -var-file="environments/dev.tfvars"
```

`terraform validate` works **without** Azure credentials. `terraform plan` needs `az login` (read-only access to the target subscription is enough). Edit `environments/dev.tfvars` and replace `<unique-suffix>` so `app_service_name` is globally unique on `*.azurewebsites.net`.

## Apply (only when you actually want to provision)

```powershell
terraform apply -var-file="environments/dev.tfvars"
```

Tear down with `terraform destroy -var-file="environments/dev.tfvars"`.

## Cost note

Default `sku_name = "B1"` is the cheapest reasonable Linux App Service tier (≈ $13/mo as of writing). Switch to `F1` (free) only for short experiments — `always_on` and custom domains are not supported there.
