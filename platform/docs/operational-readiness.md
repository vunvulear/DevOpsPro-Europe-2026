# Operational Readiness

Sixth capability of the golden path. Just enough operational discipline for the
Brașov Sunset API on Azure App Service — no full observability stack.

## Health endpoint

- The app exposes `GET /healthz` (liveness). `GET /readyz` is recommended.
- App Service uses it via `health_check_path = "/healthz"` in
  `infra/terraform/main.tf` to gate traffic to a healthy instance.
- Expected response: HTTP `200` with a small JSON body. No external
  dependencies are checked from `/healthz` (liveness); add them only to
  `/readyz`.

## Smoke tests

Run automatically by `.github/workflows/deploy-azure-app-service.yml`
(`smoke-test` job) after every deployment:

- `GET /` retried up to 5× with linear backoff (cold-start tolerant).
- `GET /sunset` asserts HTTP `200`, plus `"city": "Brasov"` and
  `"timezone": "Europe/Bucharest"` in the JSON body.

A red smoke test fails the workflow. The deployment is still in place — fix
forward or roll back.

## What to check after deployment

Quick checklist (≤ 2 minutes):

1. **Workflow run** — `Deploy to Azure App Service` is green, `smoke-test` job included.
2. **Live URL** — `curl https://<app>.azurewebsites.net/sunset` returns the expected JSON.
3. **Health** — `curl https://<app>.azurewebsites.net/healthz` returns `200`.
4. **Azure portal → App Service → Overview** — status is `Running`, no recent restarts.
5. **Tags** — `project`, `environment`, `owner` present on the App Service and its plan.

## Where to view logs (Azure App Service only)

No external observability service is required at this stage:

- **Log stream:** Azure portal → App Service → *Monitoring* → **Log stream**. Live `stdout`/`stderr` from the Node process.
- **Deployment Center:** Azure portal → App Service → **Deployment Center** → *Logs*. Build/deploy output for each release.
- **Diagnose and solve problems:** Azure portal → App Service → **Diagnose and solve problems**. Built-in detectors for restarts, swap failures, slow requests.
- **Kudu (advanced):** `https://<app>.scm.azurewebsites.net/` → *Bash*/*PowerShell* + filesystem browser. Useful when the app won't even start.
- **CLI:** `az webapp log tail --name <app> --resource-group <rg>`.

## Rollback

Two simple options, in order of preference:

1. **Re-run a previous green deployment.**
   - GitHub → *Actions* → *Deploy to Azure App Service* → pick a previous successful run on `main` → **Re-run all jobs**.
   - Confirms via `smoke-test` that the older artifact still works.

2. **Revert the offending commit.**
   - `git revert <bad-sha>` on `main` → push → run the deploy workflow.
   - Use this when the bad change has already merged.

Bigger workloads should add a **deployment slot** (`staging` → swap with `production`) so rollback is one swap. Out of scope here; called out as future work.

## Future improvements (not in this repo)

Listed roughly in the order a real team typically adds them:

### Structured logging

- Replace ad-hoc `console.log` with a structured logger (e.g. `pino`).
- Emit JSON to `stdout` so App Service captures it; correlate with a `request_id` per request.
- Cheap, big payoff: queries become `where level = "error"` instead of grep.

### Application Insights

- Attach Application Insights to the App Service (auto-instrumentation for Node).
- Get out-of-the-box: live metrics, request/dependency telemetry, failures, exceptions, traces.
- Wire `APPLICATIONINSIGHTS_CONNECTION_STRING` via App Service config (Key Vault reference).

### OpenTelemetry

- Adopt the OpenTelemetry Node.js SDK once you have more than one service.
- Export traces/metrics to Application Insights or a vendor of choice via OTLP.
- Standardizes instrumentation so changing backends doesn't rewrite the app.

### Alerts and SLOs

- Define one or two SLOs first (e.g. *99% of `/sunset` requests in <300 ms over 30 days*).
- Alert on **error budget burn**, not on every spike.
- Channel: Action Group → Teams/Slack/PagerDuty. Start with one channel, one severity.
- Add an availability test in Application Insights for `/healthz`.

## What is intentionally simplified for the demo

- **No Application Insights, no Log Analytics workspace.** App Service's built-in log stream is enough for a 30-minute demo.
- **No structured logging in the app.** The Brașov Sunset API uses default Express output.
- **No deployment slots.** Single production slot; rollback is "redeploy a known-good commit".
- **No SLO/SLI dashboards.** The smoke test is the de-facto SLI.
- **No on-call rotation, no paging.** Documented as future work.
- **No synthetic transactions.** A real production app should add at least one Application Insights availability test.
- **Runbook is this file.** Real services typically have a per-service `docs/runbook.md`; here we point at this doc + the deployment workflow.
