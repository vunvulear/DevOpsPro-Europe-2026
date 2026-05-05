# Infrastructure as Code Standards

This page captures the small set of IaC standards used by the golden
path. The actual Terraform lives under
[`infra/terraform/`](../../infra/terraform).

## Why IaC is part of the golden path

- **Reviewable.** Infrastructure changes go through pull requests
  just like application changes.
- **Reproducible.** A new environment can be created from the same
  code with a different `tfvars` file.
- **Auditable.** Tags and resource names are consistent and predictable.
- **Pairable with policies.** Policies (tags, SKUs, ownership) can
  reference the same variables and resources.

## What is standardised

- **Provider:** `hashicorp/azurerm` `~> 4.0`.
- **Terraform version:** `>= 1.6.0`.
- **Layout:** `versions.tf`, `providers.tf`, `variables.tf`,
  `main.tf`, `outputs.tf`, `environments/*.tfvars`, `README.md`.
- **Naming:** values come from variables; no hardcoded IDs.
- **Tags:** every resource carries `environment`, `owner`, `project`,
  `managed_by = terraform`.
- **Authentication:** no static credentials. OIDC in CI, `az login`
  locally.
- **State:** local for the demo, remote (Azure Storage with locking)
  for real projects.

## What developers can customise

- Per-environment values via `environments/<env>.tfvars`.
- SKU and Node.js version through variables.
- Adding extra resources in `main.tf` (databases, Key Vault, etc.) as
  long as they keep the standard tags.

## What is intentionally simplified

- **No remote backend.** Documented but not configured.
- **One module, one app.** Real estates would split shared services
  (networking, Key Vault) from per-app modules.
- **No workspaces.** Environments are differentiated by `tfvars`
  files, not Terraform workspaces.
- **No policy as code yet.** Checkov is wired into the security
  workflow; OPA / Conftest are future work.
- **No secret backends.** App Service settings carry only
  non-sensitive values; secrets would come from Key Vault references
  in a real deployment.

## Related

- [`infra/terraform/README.md`](../../infra/terraform/README.md) -
  how to validate and plan locally.
- [`platform/policies/tagging-policy.yaml`] - tags expected on every
  resource.
- [`platform/policies/cost-policy.yaml`] - SKU rules and cost
  ownership.
