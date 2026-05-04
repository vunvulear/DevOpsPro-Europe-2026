# DevOps2026 — Brasov Sunset API

A small DevOps lab project: a Node.js/Express API that returns today's sunset time for **Brașov, Romania** (timezone `Europe/Bucharest`), together with a separate test suite.

## Project structure

```
DevOps2026/
├── App/          # Express API (production code)
├── App_Test/     # Jest + Supertest unit/integration tests
├── Prompts/      # Local prompt notes (git-ignored)
└── .gitignore
```

- **`App/`** — Express server using [`suncalc`](https://www.npmjs.com/package/suncalc) to compute sunset based on Brașov coordinates (`45.6427, 25.5887`).
- **`App_Test/`** — Jest test suite that imports the Express `app` via Supertest (no port binding) and validates endpoints, payload shape, timezone, and SunCalc parity.

## Prerequisites

- Node.js 18+
- npm

## Run the API

```powershell
cd App
npm install
npm start
```

Server: `http://localhost:3000`

### Endpoints

| Method | Path       | Description                        |
|-------:|------------|------------------------------------|
| GET    | `/`        | API info                           |
| GET    | `/sunset`  | Today's sunset time for Brașov     |

#### Example response — `GET /sunset`

```json
{
  "city": "Brasov",
  "country": "Romania",
  "timezone": "Europe/Bucharest",
  "date": "04.05.2026",
  "sunset_local": "20:38:12",
  "sunset_utc": "2026-05-04T17:38:12.000Z",
  "coordinates": { "latitude": 45.6427, "longitude": 25.5887 }
}
```

## Run the tests

```powershell
cd App_Test
npm install
npm test
```

The suite (`App_Test/tests/sunset.test.js`) covers:

- **Constants** — Brașov latitude/longitude and timezone.
- **`GET /`** — status, JSON content-type, payload shape.
- **`GET /sunset`** — status, city/country, timezone, coordinates, `HH:MM:SS` formatting, valid ISO `sunset_utc`, sunset day matches today in `Europe/Bucharest`, and parity with a fresh `SunCalc` computation.
- **Unknown routes** — returns `404`.

## CI

Continuous integration is the first capability of the golden path.

- **Workflow:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
- **Triggers:** pull requests targeting `main` and pushes to `main`.
- **What it does:**
  1. Checks out the repo on `ubuntu-latest`.
  2. Sets up Node.js 20 with built-in `npm` caching for both lockfiles.
  3. Runs `npm ci` in `App/` and in `App_Test/`.
  4. Runs `npm test` in `App_Test/` (Jest + Supertest against the Express `app`).
- **Why it matters for the golden path:** every change is validated on a clean runner before it can reach `main`. No secrets, no deployment — just a fast, reliable safety net that the rest of the golden path (security, infra, deploy) builds on.

To validate locally before pushing:

```powershell
cd App; npm ci; cd ..\App_Test; npm ci; npm test
```

## Operational readiness

Just enough to run the Brașov Sunset API in Azure App Service without surprises.

- **Health:** `GET /healthz` (liveness); `GET /readyz` recommended. App Service uses `/healthz` via `health_check_path` in Terraform.
- **Smoke test:** runs automatically after every deployment (`smoke-test` job in [`.github/workflows/deploy-azure-app-service.yml`](.github/workflows/deploy-azure-app-service.yml)) — asserts `/` and `/sunset` return 200 with the expected payload.
- **Logs:** Azure portal → App Service → **Log stream** / **Deployment Center** / **Diagnose and solve problems**, or `az webapp log tail`.
- **Rollback:** re-run a previous green `Deploy to Azure App Service` run, or `git revert` and redeploy.

Full guidance — including future improvements (structured logging, Application Insights, OpenTelemetry, SLOs/alerts) — is in [`platform/docs/operational-readiness.md`](platform/docs/operational-readiness.md).

## Spec-driven demo workflow

This repo backs the conference talk **"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"**.

- **Spec Kit** ([github/spec-kit](https://github.com/github/spec-kit)) structures the work. The golden-path artifacts live under `specs/golden-path/` and are produced via `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`.
- **Windsurf / Cascade** is the coding agent that implements each step. Slash commands are defined in `.windsurf/workflows/`. Extension workflows added for the demo: `/modify`, `/refactor`, `/bugfix`, `/hotfix`.
- **GitHub Actions** validates the golden path: build/test, security scan, Terraform plan, deploy.
- **Azure App Service** is the deployment target for the Brașov Sunset API.

The live demo script is in `prompts/` (numbered `00`..`15`). Setup details are in [`platform/docs/spec-kit-setup.md`](platform/docs/spec-kit-setup.md).

## Notes

- `prompts/` is tracked in git (demo script). Local private notes like `Prompts/1.md` remain ignored via `.gitignore`.
- The API exports the Express `app` and only calls `listen()` when executed directly, which lets tests import it via Supertest without binding a port.
