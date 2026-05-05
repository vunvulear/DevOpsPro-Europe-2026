# Runbook — Brasov Sunset API

Operational procedures for the dev and prod **Azure App Service** deployments.

## Quick links

| What | Command |
|---|---|
| Tail live logs | `az webapp log tail -n app-sunsetapi-<env> -g rg-sunsetapi-<env>` |
| Show URL | `az webapp show -n app-sunsetapi-<env> -g rg-sunsetapi-<env> --query defaultHostName -o tsv` |
| List deployments | `az webapp deployment list-publishing-credentials -n app-sunsetapi-<env> -g rg-sunsetapi-<env>` |
| Probe health | `curl https://<host>/healthz` |
| Restart | `az webapp restart -n app-sunsetapi-<env> -g rg-sunsetapi-<env>` |

## Common procedures

### 1. Roll back to the previous zip (dev)

`WEBSITE_RUN_FROM_PACKAGE` makes deploys atomic. To roll back, redeploy the previous artifact from GitHub Actions:

1. Open the desired green run of `CD - Dev` for the previous SHA.
2. Re-run the `deploy` job; it will fetch and deploy that artifact again.

Alternatively from the CLI:

```powershell
az webapp deploy `
  --resource-group rg-sunsetapi-dev `
  --name app-sunsetapi-dev `
  --src-path .\brasov-sunset-api-<previous-sha>.zip `
  --type zip
```

### 2. Roll back prod (slot swap-back)

The previous production code lives in the `staging` slot immediately after a swap. To roll back:

```powershell
az webapp deployment slot swap `
  --resource-group rg-sunsetapi-prod `
  --name app-sunsetapi-prod `
  --slot staging `
  --target-slot production
```

This swaps the (now-old) production code back. Confirm with `/healthz` afterwards.

### 3. Scale manually

```powershell
# Scale up (SKU change)
az appservice plan update -g rg-sunsetapi-prod -n asp-sunsetapi-prod --sku P2v3

# Scale out (instance count)
az appservice plan update -g rg-sunsetapi-prod -n asp-sunsetapi-prod --number-of-workers 3
```

### 4. Rotate Key Vault secret

```powershell
az keyvault secret set --vault-name kv-sunsetapi-<env> --name <secret> --value <new>
# App Settings using @Microsoft.KeyVault(SecretUri=...) refresh within ~24h, or restart to force:
az webapp restart -n app-sunsetapi-<env> -g rg-sunsetapi-<env>
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

### 7. Inspect a slot before swap

```powershell
az webapp browse -n app-sunsetapi-prod -g rg-sunsetapi-prod --slot staging
```

## Incident response

| Symptom | First check | Action |
|---|---|---|
| 5xx spike | App Insights `requests` failing | Roll back (procedure 1 / 2) |
| Boot failures | `az webapp log tail` | Roll back; capture logs |
| `Application Error` page | `WEBSITE_RUN_FROM_PACKAGE` setting present? | Re-deploy zip; restart |
| Cert expiry warning | App Service managed cert auto-renews | If custom domain: check DNS CNAME |
| Cost anomaly | Log Analytics ingestion | Lower `log_retention_days` or filter logs |

## Severity & escalation

- **SEV-1** (prod down): page on-call, swap back within 5 minutes.
- **SEV-2** (degraded): swap back or hotfix forward within 1 hour.
- **SEV-3** (dev only / cosmetic): next business day.
