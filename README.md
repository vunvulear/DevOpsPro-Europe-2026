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
