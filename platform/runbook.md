# Operational Runbook — Brașov Sunset API

> Minimum operational contract. Deliberately small. App Insights, alerts, and
> SLO dashboards are explicitly out of scope (see `specs/golden-path/spec.md`).
> Task: T9.2.

## Health

- **Endpoint:** `GET /healthz` returns `{"status":"ok"}` with HTTP 200.
- **Platform integration:** `azurerm_linux_web_app.app.site_config.health_check_path = "/healthz"`. Azure removes unhealthy instances from rotation automatically.
- **De-facto SLI:** the deploy workflow's `smoke-test` job hits `/healthz` plus `/sunset` and asserts `city == "Brasov"` and `timezone == "Europe/Bucharest"`. A green smoke job is the minimum signal that the service is serving correct data.

## Logs

Use Azure-native tooling only. No App Insights wired up by the golden path.

```pwsh
# Live tail
az webapp log tail -g <RESOURCE_GROUP> -n <APP_NAME>

# Download recent logs
az webapp log download -g <RESOURCE_GROUP> -n <APP_NAME> --log-file logs.zip
```

Or in the Portal: **App Service → Monitoring → Log stream**.

Replace `<RESOURCE_GROUP>` and `<APP_NAME>` with the values from your repo
Variables (`AZURE_RESOURCE_GROUP`, `AZURE_APP_NAME`).

## Rollback

Two paths, both observable from the GitHub Actions tab:

1. **Re-run a previous green deploy.**
   - GitHub → Actions → `deploy` → pick the last green run → **Re-run all jobs**.
   - Fastest path; no code change needed.
2. **`git revert` + redeploy.**

   ```pwsh
   git revert <BAD_SHA>
   git push
   # Then GitHub → Actions → deploy → Run workflow → environment: dev
   ```

   Use this when the bad change reached `main` and a follow-up commit is
   the cleaner story for the audit log.

The smoke-test job is the rollback gate: if it fails, the deploy is
considered unsuccessful regardless of whether `webapps-deploy` reported
green. Re-run the previous deploy immediately.

## Out of scope (intentional)

- Application Insights, custom metrics, distributed tracing.
- PagerDuty / on-call rotation.
- Automated alerts on `/healthz` failure (Azure restarts instances; that
  is the only automated response in this artifact).
- Blue/green or slot swap. Deploys are in-place.
