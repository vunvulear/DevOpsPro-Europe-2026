# Disaster Recovery — Brasov Sunset API

## Recovery objectives

| Tier | RPO | RTO |
|---|---|---|
| Stateless app (App Service) | n/a (no state) | < 30 min via redeploy |
| Deployment artifacts | retained 14d (dev) / 90d (prod) in GitHub Actions | < 30 min |
| Terraform state (Azure Storage GRS + versioning) | < 15 min | < 15 min via blob version restore |
| Key Vault secrets | < 1h (soft-delete 7d, purge protection in prod) | < 30 min via restore |

The application has **no persistent data** of its own — sunset times are computed from coordinates and the current time. DR therefore reduces to "redeploy the zip and infra in another region".

## Backup posture

- **Terraform state**: storage account has blob versioning + 30d soft-delete + GRS replication.
- **Deployment artifacts**: GitHub Actions retention (14d dev, 90d prod). For long-term retention, push artifacts to a Storage Account.
- **Key Vault**: soft-delete enabled; `purge_protection = true` in prod.
- **Log Analytics**: not backed up (treat as ephemeral telemetry).

## Failover playbook

### Scenario A — regional outage (West Europe down)

1. Trigger `CD - Dev` / `CD - Prod` with `TF_VAR_location=northeurope`.
2. Terraform creates parallel RG, App Service Plan, Web App, Key Vault, observability in the secondary region.
3. CI re-deploys the most recent zip artifact.
4. Update DNS / Front Door origin to point to the new `*.azurewebsites.net` host.

### Scenario B — corrupted Terraform state

1. Azure Portal → storage account → blob versioning.
2. Restore the previous version of `envs/<env>.tfstate`.
3. Run `terraform plan` to confirm drift; remediate as needed.

### Scenario C — bad release in prod

1. Swap back: `az webapp deployment slot swap --slot staging --target-slot production` (the staging slot still holds the previous code immediately after a swap).
2. If `staging` no longer holds the good version, redeploy the previous zip artifact from GitHub Actions to `production` directly.
3. Rotate any secrets the bad release may have leaked.

## Validation cadence

- Quarterly: restore TF state from a versioned blob into a sandbox subscription and run `terraform plan`.
- Quarterly: re-deploy the latest production zip into a fresh resource group in a secondary region.
- After every major release: verify `/healthz`, `/readyz`, `/sunset` from at least two geographies.
