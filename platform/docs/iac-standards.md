# IaC Standards

Infrastructure-as-Code with Terraform is the third capability of the golden path.
Reference implementation: [`infra/terraform/`](../../infra/terraform/).

## Why IaC is part of the golden path

- **Reproducible environments.** A new `dev`/`test`/`prod` is a `tfvars` file away — no clicking in the portal.
- **Reviewable changes.** Infra diffs land in PRs alongside the code that needs them; `terraform plan` is the diff a reviewer can read.
- **Auditable history.** `git log` is the audit trail for what was provisioned, by whom, when, and why.
- **Policy enforcement at PR time.** Static checks (Checkov, etc.) catch misconfigurations before they hit Azure.
- **Drift visibility.** Re-running `plan` shows whether anyone "fixed something in the portal" out-of-band.

## What is standardized (don't override without good reason)

- **Provider:** `hashicorp/azurerm ~> 4.0`.
- **Terraform version:** `>= 1.6.0`.
- **Folder layout:** one Terraform module per stack under `infra/terraform/`, with `environments/<env>.tfvars`.
- **Naming convention:** `<resource-type>-<project>-<env>[-<suffix>]` (e.g. `app-brasov-sunset-dev-xyz`).
- **Required tags on every resource:** `project`, `environment`, `owner`, `managed_by = "terraform"`, `repo`.
- **Security defaults:**
  - `https_only = true`
  - `minimum_tls_version = "1.2"`
  - `health_check_path = "/healthz"` for web apps
- **Authentication:** Azure OIDC for CI; `az login` locally. Never commit credentials, subscription IDs, tenant IDs, or client IDs.
- **State:** remote `azurerm` backend with state locking (relaxed only for this demo — see below).

## What developers can customize

- **`sku_name`** — pick the right size for the workload (within the team's cost budget).
- **`location`** — closest region to users / data residency requirements.
- **`node_version`** — pin to a supported LTS.
- **Application-specific `app_settings`** — feature flags, log levels, etc. (no secrets here; use Key Vault references).
- **Additional resources** — Storage Account, Key Vault, Application Insights, etc. — as long as the standards above still hold.
- **Module composition** — extract repeated patterns into local modules under `infra/terraform/modules/`.

## What is simplified for the demo

- **Local state** instead of a remote `azurerm` backend. Real teams must use remote state with locking; the README describes the migration.
- **Single environment (`dev`).** No `test`/`prod` `tfvars` files yet; the structure supports adding them.
- **No Key Vault / managed identity wiring.** The Brașov Sunset API has no secrets, so we skipped the secret-management plumbing. Adding it is straightforward and recommended for any real workload.
- **No Application Insights / Log Analytics.** Operational readiness covers `/healthz`, `/readyz`, and a runbook in a later step.
- **No Private Endpoints / VNet integration.** The demo app is a public sample.
- **`B1` SKU** — cheapest reasonable Linux plan; production workloads typically need `P1v3` or higher.
- **No Checkov enforcement yet.** The Security workflow has the Checkov job wired up but conditional on `*.tf` existing — it activates as soon as this folder is committed.

## Pre-merge checklist for IaC PRs

- `terraform fmt -check` passes.
- `terraform validate` passes.
- `terraform plan` posted to the PR is what the author intended (no surprise destroys).
- Required tags present on every new resource.
- No secrets, no Azure IDs, no private hostnames in the diff.
- Cost impact understood (Infracost comment, when enabled).
