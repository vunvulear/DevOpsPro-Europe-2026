# Golden Path - Task Breakdown

Tasks are small, independently reviewable units of work. They map
back to the stages in `docs/plan.md` but can be picked up in any
order that makes sense during the demo build-up.

Each task is tagged with one of:

- **[live-safe]** - safe to do live on stage
- **[pre-session]** - better prepared before the session
- **[fallback-branch]** - fallback branch recommended

---

## T-01 - CI workflow scaffold

- **Title:** Add GitHub Actions CI workflow.
- **Description:** Create `.github/workflows/ci.yml` triggered on PRs
  and pushes to `main`. Use Node.js LTS.
- **Files changed:** `.github/workflows/ci.yml`.
- **Acceptance criteria:** workflow shows up in the Actions tab and
  runs on a test PR.
- **Demo notes:** [live-safe] - perfect "first capability" to show.

## T-02 - Test execution in CI

- **Title:** Run the Jest/Supertest suite from `App_Test/`.
- **Description:** Install dependencies for both `App/` and
  `App_Test/`, then `npm test` in `App_Test/`.
- **Files changed:** `.github/workflows/ci.yml`.
- **Acceptance criteria:** the test job is green on a PR with no
  app changes.
- **Demo notes:** [live-safe].

## T-03 - Dependency caching

- **Title:** Cache npm downloads in CI.
- **Description:** Use `actions/setup-node@v4` with `cache: npm` and
  point it at both `package-lock.json` files.
- **Files changed:** `.github/workflows/ci.yml`.
- **Acceptance criteria:** second CI run is visibly faster than the
  first.
- **Demo notes:** [pre-session] - cache only helps after a warm-up.

## T-04 - Security workflow scaffold

- **Title:** Add `.github/workflows/security.yml`.
- **Description:** Triggered on PRs and pushes. Combines dependency
  audit, Gitleaks, Trivy.
- **Files changed:** `.github/workflows/security.yml`.
- **Acceptance criteria:** workflow runs without secrets.
- **Demo notes:** [live-safe].

## T-05 - Secret scanning

- **Title:** Add Gitleaks step.
- **Description:** Use the official `gitleaks/gitleaks-action`. No
  paid token required for public repos.
- **Files changed:** `.github/workflows/security.yml`.
- **Acceptance criteria:** Gitleaks step runs and reports findings (or
  none).
- **Demo notes:** [pre-session] - have a known-good run to point at.

## T-06 - Terraform folder structure

- **Title:** Create `infra/terraform/` skeleton.
- **Description:** Add `versions.tf`, `providers.tf`, `main.tf`,
  `variables.tf`, `outputs.tf`, `environments/dev.tfvars`, and a
  short `README.md`.
- **Files changed:** `infra/terraform/*`.
- **Acceptance criteria:** `terraform fmt -check` passes locally.
- **Demo notes:** [live-safe].

## T-07 - Azure App Service Terraform resources

- **Title:** Define Resource Group, Linux App Service Plan, and Linux
  Web App with Node.js runtime.
- **Description:** All values come from variables. Tags include
  environment, owner, project. State is local for the demo.
- **Files changed:** `infra/terraform/main.tf`,
  `infra/terraform/variables.tf`, `infra/terraform/outputs.tf`.
- **Acceptance criteria:** `terraform validate` passes.
- **Demo notes:** [live-safe].

## T-08 - Terraform validation workflow

- **Title:** Add `.github/workflows/terraform-plan.yml`.
- **Description:** Runs `terraform fmt -check`, `init`, `validate`
  always. Runs `plan` only when Azure OIDC variables are configured.
- **Files changed:** `.github/workflows/terraform-plan.yml`,
  `infra/terraform/README.md`.
- **Acceptance criteria:** workflow is green on a PR with no Azure
  credentials configured.
- **Demo notes:** [pre-session] - rehearse without auth first.

## T-09 - Deployment workflow

- **Title:** Add
  `.github/workflows/deploy-azure-app-service.yml`.
- **Description:** Manual `workflow_dispatch`, OIDC login to Azure,
  build/package `App/`, deploy with `azure/webapps-deploy`.
- **Files changed:** `.github/workflows/deploy-azure-app-service.yml`,
  `platform/docs/deployment-path.md`.
- **Acceptance criteria:** dry run with placeholder variables shows
  the steps clearly.
- **Demo notes:** [fallback-branch] - have a pre-deployed App Service
  ready in case the live deploy fails.

## T-10 - Post-deployment smoke tests

- **Title:** Smoke-test `/` and `/sunset` after deploy.
- **Description:** Use `curl` or a tiny script. Fail the workflow if
  either endpoint returns non-200.
- **Files changed:** `.github/workflows/deploy-azure-app-service.yml`.
- **Acceptance criteria:** smoke step fails fast if the URL is wrong.
- **Demo notes:** [live-safe] once deployment is stable.

## T-11 - Platform policies

- **Title:** Add `platform/policies/*` files.
- **Description:** Service metadata, tagging, deployment, and cost
  policies. Lightweight YAML / Markdown.
- **Files changed:** `platform/policies/service-metadata.yaml`,
  `tagging-policy.yaml`, `deployment-policy.md`, `cost-policy.yaml`,
  and `platform/docs/policy-guardrails.md`.
- **Acceptance criteria:** policies are short, readable, and
  reference real files in the repo.
- **Demo notes:** [live-safe].

## T-12 - Cost awareness

- **Title:** Document cost policy and SKU choices.
- **Description:** Update `cost-policy.yaml` with environment-specific
  SKUs. Add `platform/docs/cost-awareness.md`. Optional simple
  `cost-awareness.yml` workflow.
- **Files changed:** `platform/policies/cost-policy.yaml`,
  `platform/docs/cost-awareness.md`,
  `.github/workflows/cost-awareness.yml` (optional).
- **Acceptance criteria:** no fake numbers; placeholders where real
  data is missing.
- **Demo notes:** [live-safe].

## T-13 - Operational readiness docs

- **Title:** Add `platform/docs/operational-readiness.md`.
- **Description:** Health endpoint, smoke tests, log locations,
  rollback, future improvements (structured logs, App Insights,
  OpenTelemetry, alerts, SLOs).
- **Files changed:** `platform/docs/operational-readiness.md`,
  `README.md`.
- **Acceptance criteria:** short, practical, no full observability
  stack.
- **Demo notes:** [live-safe].

## T-14 - README update

- **Title:** Tie everything together in the root README.
- **Description:** Short sections for CI, security, IaC, deployment,
  policies, cost awareness, operational readiness, with links to the
  relevant files.
- **Files changed:** `README.md`.
- **Acceptance criteria:** README reads top-to-bottom as a tour of
  the golden path.
- **Demo notes:** [live-safe].

## T-15 - Demo flow documentation

- **Title:** Optional `platform/docs/demo-flow.md`.
- **Description:** Numbered running order with timings and fallbacks.
- **Files changed:** `platform/docs/demo-flow.md`.
- **Acceptance criteria:** can be followed top-to-bottom in 30
  minutes.
- **Demo notes:** [pre-session].

---

This file is updated iteratively as work progresses. It is **not**
managed by Spec Kit.
