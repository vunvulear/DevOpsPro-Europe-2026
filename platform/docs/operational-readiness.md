# Operational Readiness

This document captures what "running in production" looks like for
the Brasov Sunset API on Azure App Service. It is intentionally
short and practical - "deployed" is not the same as "operational".

## Health endpoint

- **Endpoint:** `GET /`
- **Expected status:** `200 OK`
- **Behaviour:** returns a small JSON payload describing the API
  and its endpoints.
- **Why this one:** the app already exposes it, it requires no
  authentication, and it exercises the Express stack end-to-end.

A dedicated `/health` (and later `/ready`) endpoint is a future
improvement. Until then, `GET /` plays both roles.

## Smoke tests

After every deploy, the deployment workflow runs:

```bash
curl --fail --silent --show-error --max-time 30 "$BASE/"
curl --fail --silent --show-error --max-time 30 "$BASE/sunset"
```

- `/` validates the app is up.
- `/sunset` validates the actual business logic (SunCalc + timezone).
- `--fail` flips any non-2xx into a non-zero exit code, so the
  deployment is marked failed if either endpoint is broken.

## What to check after deployment

1. **Workflow status** in the GitHub Actions tab is green.
2. **App Service overview blade** in Azure shows status `Running`.
3. **Public URL** responds to `GET /sunset` with today's sunset
   time in `Europe/Bucharest`.
4. **Tags** on the App Service include `environment`, `owner`,
   `project`, and `managed_by = terraform`.
5. **Log Stream** shows the request hitting the app.

## Where to view logs in Azure App Service

- **Log stream:** App Service -> Monitoring -> Log stream.
- **Deployment logs:** Deployment Center -> Logs.
- **Console:** App Service -> Development Tools -> SSH or Console.
- **Kudu (advanced):** `https://<app-name>.scm.azurewebsites.net`.

For Node.js on Linux, application `console.log` output goes
straight to the log stream by default.

## Basic rollback considerations

- **Re-deploy a previous commit.** Trigger
  `Deploy to Azure App Service` again and pick a known-good ref.
- **Use slot swap (future).** Real production setups should deploy
  to a `staging` slot and swap on success; this is intentionally
  not configured in the demo.
- **Keep deployments small.** The smaller the change set, the
  cheaper the rollback decision.
- **Keep IaC in step.** If a rollback requires resource changes,
  revert the Terraform change too and run the validation workflow
  before re-applying.

## Future improvements

These are deliberately *not* implemented today; they are called out
so that the gap is visible.

1. **Structured logging.**
   - Adopt JSON logs (e.g. `pino`) with correlation IDs.
   - Stable field names so dashboards survive code changes.

2. **Application Insights.**
   - Auto-instrument the Node.js app with the Azure Monitor SDK.
   - Live metrics, dependency tracking, failure rates.

3. **OpenTelemetry.**
   - Vendor-neutral traces and metrics from the app and the
     workflows.
   - Export to Azure Monitor or any OTLP-compatible backend.

4. **Alerts and SLOs.**
   - Define a small number of SLOs (availability, latency).
   - Alert on burn rate, not on raw thresholds.
   - Route alerts to an on-call channel, not to email.

## What is intentionally simplified

- **No full observability stack.** A handful of curl-based smoke
  tests and the App Service log stream is all the demo carries.
- **No Application Insights, OpenTelemetry, or APM** in the repo.
- **No SLOs, error budgets, or alert routing.**
- **No incident process.** Documented as a future step, not
  pretending to exist.
- **No runbooks per failure mode.** The few that matter (rollback,
  log access) are above; everything else is a future improvement.
