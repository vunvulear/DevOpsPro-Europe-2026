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

## Notes

- `Prompts/` is git-ignored (see `.gitignore`).
- The API exports the Express `app` and only calls `listen()` when executed directly, which lets tests import it via Supertest without binding a port.

## Platform Engineering

This repo ships a full Platform Engineering setup for Azure. See:

- `docs/PLATFORM.md` — architecture, components, and decisions.
- `docs/RUNBOOK.md` — day-2 operations.
- `docs/DR.md` — disaster recovery posture.
- `infra/terraform/` — IaC (bootstrap + dev/prod environments).
- `.github/workflows/` — CI, CodeQL, CD-Dev, CD-Prod, Release.

### Layout

```
.
├── App/                      # Node.js API + Dockerfile
├── App_Test/                 # Jest + Supertest tests
├── infra/terraform/
│   ├── bootstrap/            # Remote state + GitHub OIDC
│   ├── modules/              # observability, registry, identity, keyvault, container_app
│   └── envs/{dev,prod}/      # Per-env root modules
├── .github/
│   ├── workflows/            # ci, codeql, cd-dev, cd-prod, release
│   ├── dependabot.yml
│   ├── CODEOWNERS
│   └── pull_request_template.md
├── scripts/                  # bootstrap-azure.ps1, local-dev.ps1
├── docs/                     # PLATFORM.md, RUNBOOK.md, DR.md
└── Makefile
```

### Operational endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /` | API info |
| `GET /sunset` | Today's sunset for Brașov |
| `GET /healthz` | Liveness probe |
| `GET /readyz` | Readiness probe (verifies SunCalc) |

### Quick start (Azure)

```powershell
# 1. One-time bootstrap (creates state backend + GitHub OIDC AAD app)
./scripts/bootstrap-azure.ps1 -GitHubRepo vunvulear/DevOpsPro-Europe-2026

# 2. Set the printed outputs as GitHub repository secrets:
#    AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID,
#    TFSTATE_RG, TFSTATE_STORAGE

# 3. Create GitHub Environments 'dev' and 'prod' (add reviewers to 'prod').

# 4. Push to main -> CD-Dev runs.
# 5. Tag a release v1.0.0 -> CD-Prod runs (after manual approval).
```

### Local container test

```powershell
./scripts/local-dev.ps1
# or:  make docker-run
```
