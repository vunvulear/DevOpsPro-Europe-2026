# Disaster Recovery — Brasov Sunset API

## Recovery objectives

| Tier | RPO | RTO |
|---|---|---|
| Stateless app (Container Apps) | n/a (no state) | < 30 min via redeploy |
| ACR images | 0 (GRS replicated, geo-replication on Premium) | < 30 min |
| Terraform state (Azure Storage GRS + versioning) | < 15 min | < 15 min via blob version restore |
| Key Vault secrets | < 1h (soft-delete 7d, purge protection in prod) | < 30 min via restore |

The application has **no persistent data** of its own — sunset times are computed from coordinates + current time. DR therefore reduces to "redeploy the image and infra in another region".

## Backup posture

- **Terraform state**: storage account has blob versioning + 30d soft-delete + GRS replication.
- **ACR images**: dev = GRS storage (Standard SKU); prod = Premium with geo-replication enabled (extend `registry` module with `georeplications` block when adding a second region).
- **Key Vault**: soft-delete enabled; `purge_protection = true` in prod.
- **Log Analytics**: not backed up (treat as ephemeral telemetry).

## Failover playbook

**Scenario A: regional outage (West Europe down)**

1. Trigger the failover branch of `cd-dev.yml` / `cd-prod.yml` with `TF_VAR_location=northeurope`.
2. Terraform creates parallel RG/ACR/CA in the secondary region.
3. ACR import images from primary (or use geo-replicated registry).
4. Update DNS / Front Door origin to point to the new ingress FQDN.

**Scenario B: corrupted Terraform state**

1. Open Azure Portal → storage account → blob versioning.
2. Restore the previous version of `envs/<env>.tfstate`.
3. Run `terraform plan` to confirm drift; remediate as needed.

**Scenario C: compromised image**

1. Tag the bad image as quarantined; `az acr repository delete --image <tag>` if confirmed malicious.
2. Roll back via revision (see RUNBOOK §1).
3. Rotate any secrets the image had access to (Key Vault).
4. Audit `cosign verify` failures in `cd-prod.yml` — they should have caught it.

## Validation cadence

- Quarterly: restore TF state from a versioned blob into a sandbox subscription and `terraform plan`.
- Quarterly: `az acr import` a known-good image into a fresh ACR.
- After every major release: confirm `cosign verify` passes against the released digest.
