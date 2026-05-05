# Deployment Policy

This policy describes when and how deployments to Azure App Service
are allowed in the golden path. It is intentionally short and
readable; enforcement is mostly through workflow design, not external
tooling.

## Scope

Applies to:

- The Brasov Sunset API
- The deployment workflow
  [`.github/workflows/deploy-azure-app-service.yml`](../../.github/workflows/deploy-azure-app-service.yml)

## Rules

1. **Only `main` and `prompt_only` may deploy to non-prod.**
   - Feature branches are not allowed to deploy to dev/test/prod.
   - In the demo, `prompt_only` is the working branch.

2. **Production deploys never run from feature branches.**
   - The deployment workflow uses GitHub Environments.
   - The `prod` environment must require an approval reviewer.
   - The `prod` environment must restrict deployments to the
     default branch (`main`).

3. **Manual trigger only.**
   - Deployments are triggered with `workflow_dispatch`.
   - No automatic deploy on push or merge.

4. **OIDC only.**
   - Azure authentication uses GitHub Actions OIDC.
   - No long-lived client secrets, publish profiles, or shared
     credentials are stored in the repository or in GitHub Secrets.

5. **App Service SKU is intentional.**
   - SKU comes from the `sku_name` Terraform variable.
   - The default `B1` is for demo only.
   - See `cost-policy.yaml` for environment-specific SKU rules.

6. **Smoke tests are required after deploy.**
   - The deployment workflow hits `/` and `/sunset` and fails fast
     on any non-2xx response.
   - The workflow only marks a deployment as successful if the
     smoke tests pass.

7. **Health endpoint is required.**
   - Every service in the golden path exposes a health-style
     endpoint reachable without authentication.
   - For this service, `GET /` returns the API info payload and
     acts as a basic liveness signal.

## Enforcement

| Rule | Today                | Future improvement                |
|------|----------------------|-----------------------------------|
| 1    | Branch protection    | Add CODEOWNERS                    |
| 2    | GitHub Environments  | Required reviewers, prod approvals|
| 3    | Workflow definition  | Disable on `push`                 |
| 4    | Workflow definition  | OIDC enforced via repo policy     |
| 5    | Terraform variable   | Checkov / OPA in CI               |
| 6    | Workflow `curl` step | Synthetic monitoring              |
| 7    | Service contract     | Dedicated `/health` endpoint      |
