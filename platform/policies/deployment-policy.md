# Deployment Policy

Lightweight rules that govern how code reaches Azure App Service.
Most of these are documented expectations today; a few are already enforced by
the workflows under `.github/workflows/`.

## 1. Branching

- **Production deployments only run from `main`.** Feature branches MUST NOT deploy to `prod`.
- The `dev` environment is the only auto/manual deployment target during the demo.
- Hotfixes follow the `/hotfix` workflow: branch → failing test → fix → green checks → merge to `main` → deploy.

## 2. Authentication

- All Azure auth uses **GitHub Actions OIDC**.
- **No publish profiles**, no client secrets, no service principal passwords in this repo.
- IDs (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`) live as GitHub Actions **Variables**, not Secrets.

## 3. Required pre-deploy checks

A change MUST NOT deploy unless the following are green on the merge commit:

| Check | Workflow |
|---|---|
| Build & unit tests | `.github/workflows/ci.yml` |
| Security scans (`npm audit`, Gitleaks, Trivy, Checkov) | `.github/workflows/security.yml` |
| Terraform `fmt` + `validate` (and `plan` when configured) | `.github/workflows/terraform-plan.yml` |

These should be **required status checks** in branch protection on `main`.

## 4. App Service SKU selection

- The SKU is set explicitly via Terraform (`var.sku_name`). It MUST NOT be left to provider defaults.
- For each environment, the choice MUST be intentional:
  - `dev` → `B1` (cheapest reasonable Linux tier).
  - `prod` → `P1v3` or higher (zone-redundant where SLA matters).
- Any SKU change MUST appear in the Terraform plan PR comment **and** the cost-awareness comment (Infracost) before merge.

## 5. Cost visibility

- Infrastructure changes MUST surface a cost diff on the PR before approval (Infracost or equivalent).
- See [`cost-policy.yaml`](./cost-policy.yaml).

## 6. Post-deploy smoke tests

- Every deployment MUST be followed by an automated smoke test of `GET /` and `GET /sunset` against the live URL.
- The smoke test step is part of `.github/workflows/deploy-azure-app-service.yml` and fails the workflow on a non-200 or unexpected payload.

## 7. Health endpoint

- The application MUST expose `GET /healthz` (liveness). `GET /readyz` (readiness) is RECOMMENDED.
- App Service MUST be configured with `health_check_path = "/healthz"` (already wired in `infra/terraform/main.tf`).

## Summary: enforcement status

| Rule | Status | Enforcement |
|---|---|---|
| OIDC only, no secrets | Enforced | Workflows reference `vars.*`, not `secrets.*` |
| Required tags on resources | Enforced (Terraform) | `local.common_tags` in `main.tf` |
| Required CI checks | Enforced (when branch protection is on) | Repo settings + workflows |
| `main`-only prod deploy | Documented | Branch protection rule (manual) |
| Intentional SKU | Documented | Terraform variable + plan review |
| Cost visibility | Planned | Infracost workflow (next step) |
| Smoke test after deploy | Enforced | `deploy-azure-app-service.yml` |
| Health endpoint | Documented (Terraform-wired) | App-side change covered in operational readiness step |
