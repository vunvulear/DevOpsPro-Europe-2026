Add the first real golden path capability: CI.

Repository context:
- Existing Node.js/Express app
- App code is in `App/`
- Tests are in `App_Test/`
- Do not move or replace the application
- Do not add deployment yet

Create:

`.github/workflows/ci.yml`

The workflow should:
- run on pull requests and pushes to `main`
- use a suitable Node.js version based on the repository
- install dependencies for the app
- install dependencies for the tests
- run the Jest/Supertest tests
- use dependency caching where appropriate
- be readable and easy to explain live

Also update the README with a short “CI” section:
- what the workflow does
- when it runs
- how it supports the golden path

Constraints:
- no secrets
- no deployment
- no unnecessary complexity
- keep the workflow demo-friendly

After making changes, summarize:
- files changed
- how CI works
- how to validate locally
- any assumptions made