Using:

`specs/golden-path/spec.md`

Create:

`specs/golden-path/plan.md`

The plan should be optimized for a 30-minute live conference demo.

Break the golden path implementation into stages:

1. Existing app baseline
2. CI
3. Security scanning
4. Terraform infrastructure for Azure App Service
5. Terraform validation and plan
6. Azure App Service deployment
7. Platform policies
8. Cost awareness
9. Operational readiness
10. Demo flow

For each stage, include:
- goal
- files likely to change
- expected outcome
- what to show live
- live-demo risk
- fallback strategy

Important constraints:
- no secrets in the repository
- no hardcoded Azure subscription IDs, tenant IDs, client IDs, or private resource names
- use placeholders where configuration is needed
- prefer GitHub Actions with Azure OIDC
- keep it simple and explainable