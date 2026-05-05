# Terraform - Azure App Service

This module provisions an Azure App Service for the Brasov Sunset API.

## Files

| File                      | Purpose                                  |
|---------------------------|------------------------------------------|
| `versions.tf`             | Terraform and provider version pins      |
| `providers.tf`            | `azurerm` provider configuration         |
| `variables.tf`             | Input variables (no secrets)             |
| `main.tf`                 | Resource Group, Plan, Linux Web App      |
| `outputs.tf`              | Resource Group name, Web App URL, etc.   |
| `environments/dev.tfvars` | Example values for the `dev` environment|

## Resources created

- `azurerm_resource_group`
- `azurerm_service_plan` (Linux)
- `azurerm_linux_web_app` with Node.js runtime

All resources are tagged with `environment`, `owner`, `project`, and
`managed_by`.

## Variables

See `variables.tf`. The interesting ones:

- `location` - Azure region (default `westeurope`)
- `resource_group_name`, `app_service_plan_name`, `app_service_name`
- `environment`, `owner`, `project`
- `node_version` (default `20-lts`)
- `sku_name` (default `B1`)

## Validate locally

```powershell
cd infra/terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

`terraform plan` requires Azure authentication. For local use, run
`az login` first.

## Authentication

The provider deliberately does **not** hardcode credentials.

- **CI/CD:** GitHub Actions OIDC.
- **Local:** `az login`.

Do not commit `subscription_id`, `tenant_id`, or `client_id` values.

## Demo simplifications

- **Local state.** State is kept on disk for the demo. A real
  project should use a remote backend (Azure Storage with locking).
- **Single environment example.** Only `environments/dev.tfvars` is
  included; production-grade modules would have `staging`/`prod`
  files plus separate state.
- **Minimal sizing.** `B1` is cheap enough for a demo. Real
  workloads should pick a SKU based on cost and traffic.
- **No diagnostics settings, private endpoints, or VNet
  integration.** All called out as future work.
