# Golden Path Implementation Plan

This plan is optimised for a **30-minute live conference demo**. Each
stage is small, reviewable, and can be skipped or replaced by a
fallback branch if something goes wrong on stage.

The repository is a Node.js/Express app (`App/`) with a Jest +
Supertest suite (`App_Test/`). The platform capabilities are layered
around it.

---

## Stage 1 - Existing app baseline

- **Goal:** confirm the app and its tests run locally and form the
  baseline of the golden path.
- **Files likely to change:** none (read-only baseline).
- **Expected outcome:** `npm test` in `App_Test/` is green; `npm
  start` in `App/` serves `/` and `/sunset`.
- **What to show live:** `GET /sunset` in a browser/Postman.
- **Live-demo risk:** low.
- **Fallback:** pre-recorded screenshot of the response.

## Stage 2 - CI

- **Goal:** every change is automatically built and tested.
- **Files likely to change:** `.github/workflows/ci.yml`, `README.md`.
- **Expected outcome:** PRs and pushes to `main` run the test suite
  on a Node.js LTS runner with dependency caching.
- **What to show live:** open a PR, watch the CI job turn green.
- **Live-demo risk:** medium (network, Actions queue time).
- **Fallback:** pre-merged PR with green status to point at.

## Stage 3 - Security scanning

- **Goal:** practical, public-repo-friendly security guardrails.
- **Files likely to change:** `.github/workflows/security.yml`,
  `platform/docs/security-guardrails.md`.
- **Expected outcome:** dependency audit, Gitleaks secret scan, and
  Trivy filesystem scan run on PRs and pushes.
- **What to show live:** the security workflow run, plus a
  deliberately broken example in a separate branch (optional).
- **Live-demo risk:** medium (Trivy can be noisy).
- **Fallback:** show the workflow file and a previous green run.

## Stage 4 - Terraform infrastructure for Azure App Service

- **Goal:** describe Azure App Service infrastructure as code.
- **Files likely to change:** `infra/terraform/*`,
  `platform/docs/iac-standards.md`.
- **Expected outcome:** `versions.tf`, `providers.tf`, `main.tf`,
  `variables.tf`, `outputs.tf`, `environments/dev.tfvars`, and a
  short `README.md` describing the module.
- **What to show live:** open `main.tf`, walk through Resource Group
  -> Plan -> Web App -> tags.
- **Live-demo risk:** low (no execution).
- **Fallback:** keep the file open in the editor.

## Stage 5 - Terraform validation and plan

- **Goal:** Terraform is automatically formatted, validated, and
  optionally planned in CI.
- **Files likely to change:** `.github/workflows/terraform-plan.yml`,
  `infra/terraform/README.md`.
- **Expected outcome:** `fmt -check`, `init`, `validate` run on every
  PR; `plan` runs only when Azure OIDC variables are configured.
- **What to show live:** the workflow file and a recent green run.
- **Live-demo risk:** medium (auth).
- **Fallback:** skip `plan`, show only `fmt`/`validate`.

## Stage 6 - Azure App Service deployment

- **Goal:** deploy the app to Azure App Service via GitHub Actions
  OIDC, on demand only.
- **Files likely to change:**
  `.github/workflows/deploy-azure-app-service.yml`,
  `platform/docs/deployment-path.md`.
- **Expected outcome:** `workflow_dispatch` job logs in via OIDC,
  builds `App/`, deploys, and runs a smoke test against `/` and
  `/sunset`.
- **What to show live:** trigger the workflow, then hit the URL.
- **Live-demo risk:** high (cloud auth + cold start).
- **Fallback:** pre-deployed App Service URL to demo against.

## Stage 7 - Platform policies

- **Goal:** make the non-negotiables explicit and reviewable.
- **Files likely to change:** `platform/policies/*`,
  `platform/docs/policy-guardrails.md`.
- **Expected outcome:** small YAML / Markdown files for service
  metadata, tagging, deployment, and cost.
- **What to show live:** open `tagging-policy.yaml`, link it to the
  `tags = {...}` block in `main.tf`.
- **Live-demo risk:** low.
- **Fallback:** none needed.

## Stage 8 - Cost awareness

- **Goal:** make cost a first-class concern in the golden path.
- **Files likely to change:** `platform/policies/cost-policy.yaml`,
  `platform/docs/cost-awareness.md`, optionally
  `.github/workflows/cost-awareness.yml`.
- **Expected outcome:** SKU choices documented, environment-specific
  sizing, owner/project tags, and a path to Infracost / Azure Cost
  Management called out as a future step.
- **What to show live:** the cost policy and its link to the SKU
  variable in Terraform.
- **Live-demo risk:** low.
- **Fallback:** skip the optional workflow.

## Stage 9 - Operational readiness

- **Goal:** show that "deployed" is not the same as "operational".
- **Files likely to change:**
  `platform/docs/operational-readiness.md`, `README.md`.
- **Expected outcome:** documented health endpoint, smoke tests, log
  locations in Azure App Service, rollback notes, and a roadmap for
  structured logging, App Insights, OpenTelemetry, alerts, and SLOs.
- **What to show live:** the readiness checklist.
- **Live-demo risk:** low.
- **Fallback:** none needed.

## Stage 10 - Demo flow

- **Goal:** rehearseable script that ties all stages into a
  30-minute story.
- **Files likely to change:** `platform/docs/demo-flow.md` (optional
  in this iteration).
- **Expected outcome:** a numbered list of "show this, then this,
  then this" with timings and fallbacks.
- **What to show live:** the demo flow itself becomes the running
  order.
- **Live-demo risk:** low (this is the safety net).
- **Fallback:** read from the document.

---

## Cross-cutting constraints

- No secrets in the repository.
- No hardcoded Azure subscription IDs, tenant IDs, client IDs, or
  resource names.
- Use placeholders / GitHub variables and secrets for any
  environment-specific configuration.
- Prefer GitHub Actions with Azure OIDC over long-lived credentials.
- Keep everything simple enough to explain to a live audience.

This project does **not** use Spec Kit. Plan and tasks live under
`docs/` and are updated iteratively as the work progresses.
