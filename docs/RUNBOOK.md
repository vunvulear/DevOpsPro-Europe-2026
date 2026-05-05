# Runbook — Brasov Sunset API

Operational procedures for the dev and prod Azure Container Apps deployments.

## Quick links

| What | Command |
|---|---|
| Tail live logs | `az containerapp logs show -n ca-sunsetapi-<env> -g rg-sunsetapi-<env> --follow` |
| List revisions | `az containerapp revision list -n ca-sunsetapi-<env> -g rg-sunsetapi-<env> -o table` |
| Show ingress URL | `az containerapp show -n ca-sunsetapi-<env> -g rg-sunsetapi-<env> --query properties.configuration.ingress.fqdn -o tsv` |
| Probe health | `curl https://<fqdn>/healthz` |

## Common procedures

### 1. Roll back to the previous revision

```powershell
$env = "dev"   # or prod
$app = "ca-sunsetapi-$env"
$rg  = "rg-sunsetapi-$env"

# List revisions, newest first
az containerapp revision list -n $app -g $rg -o table

# Activate the previous good revision (replace <revision>)
az containerapp revision activate -n $app -g $rg --revision <revision>

# Send 100% traffic there
az containerapp ingress traffic set -n $app -g $rg --revision-weight <revision>=100
```

### 2. Pin the image to a specific tag

```powershell
az containerapp update -n $app -g $rg --image acrsunsetapi$env.azurecr.io/brasov-sunset-api:<tag>
```

### 3. Scale manually

```powershell
az containerapp update -n $app -g $rg --min-replicas 2 --max-replicas 6
```

### 4. Rotate Key Vault secret

```powershell
az keyvault secret set --vault-name kv-sunsetapi-$env --name <secret> --value <new>
# Container App secret refs are versionless; restart to force re-fetch
az containerapp revision restart -n $app -g $rg --revision (az containerapp revision list -n $app -g $rg --query "[?properties.active].name" -o tsv)
```

### 5. View Application Insights data

Azure Portal → Application Insights `appi-sunsetapi-<env>` → Logs (KQL):

```kql
requests
| where timestamp > ago(1h)
| summarize count(), avg(duration) by bin(timestamp, 5m), resultCode
| order by timestamp desc
```

### 6. Re-run the deployment manually

GitHub UI → Actions → "CD - Dev" / "CD - Prod" → Run workflow.

### 7. Recreate the OIDC federated credential

If `AZURE_CLIENT_ID` is rotated, re-run `terraform apply` in `infra/terraform/bootstrap/` and update GitHub secrets with the new outputs.

## Incident response

| Symptom | First check | Action |
|---|---|---|
| 5xx spike | App Insights `requests` failing | Roll back revision (procedure 1) |
| Pod CrashLoopBackoff | `az containerapp logs show --follow` | Roll back; capture logs |
| ACR pull errors | Check MI role assignment `AcrPull` | Re-apply terraform |
| Cert expiry warning | Container Apps managed cert auto-renews | If custom domain: check DNS CNAME |
| Cost anomaly | Log Analytics ingestion | Lower `log_retention_days` or filter logs |

## Severity & escalation

- **SEV-1** (prod down): page on-call, roll back within 10 minutes.
- **SEV-2** (degraded): roll back within 1 hour or hotfix forward.
- **SEV-3** (dev only / cosmetic): next business day.
