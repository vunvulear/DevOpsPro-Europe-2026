# Policy Guardrails — Enforcement Matrix

> Honest mapping of each rule of the road to *how* it is enforced today and
> *how* it could harden later. Task: T7.5. Status legend:
>
> - **Enforced**: a tool fails the workflow if violated.
> - **Documented**: written down; reviewer-enforced; would benefit from automation.
> - **Planned**: intentional next step; not yet implemented.

| Rule | Source | Status | Enforced by today | Hardening path |
|---|---|---|---|---|
| No secrets in repo (constitution P-I) | `.specify/memory/constitution.md` | **Enforced** | `security.yml` → `gitleaks` | Add pre-commit hook; require Gitleaks check on `main` branch protection |
| OIDC-only Azure auth (P-II) | constitution | **Enforced** | All workflows use `azure/login@v2` with `id-token: write`; no `secrets.AZURE_*` references | Org-level policy banning `AZURE_CREDENTIALS` secrets; tenant conditional access |
| Fork-safe skip-clean (P-III) | constitution | **Documented** | `if: ${{ vars.AZURE_CLIENT_ID != '' }}` on plan/deploy/smoke jobs | Linter/Action that fails CI when an Azure-touching job lacks the guard |
| One screen per file (P-IV) | constitution | **Documented** | Reviewer judgement | Add a soft `wc -l` lint job on workflows + Terraform |
| Visibility over enforcement (P-V) | constitution | **Documented** | `soft_fail: true` on Checkov; `continue-on-error` not used | Promote Checkov from soft to hard once policy stabilizes |
| Required tags on every resource | `tagging-policy.yaml` | **Enforced** | `infra/terraform/locals.tf:common_tags` on all three resources | Azure Policy: deny resources without required tags at subscription scope |
| App Service hardening defaults | `spec.md` §IaC | **Enforced** | `infra/terraform/main.tf` (`https_only`, TLS 1.2, FTPS off, HTTP/2 on, websockets off, remote-debug off) | Azure Policy: built-in initiative for App Service security baseline |
| Health check `/healthz` wired to platform | spec | **Enforced** | `site_config.health_check_path = "/healthz"` + smoke test | Add Azure Monitor availability test |
| No hardcoded Azure subscription/tenant/client/resource IDs | constitution | **Documented** | Reviewer judgement; `dev.tfvars` uses placeholders | Add `scripts/check-no-azure-ids.sh` regex job to `security.yml` |
| Manual deploys only (workflow_dispatch) | `deployment-policy.yaml` | **Enforced** | `deploy.yml` has no `push:` / `pull_request:` triggers | Branch protection on `main` + environment review approvals |
| Required CI checks on `main` | `deployment-policy.yaml` | **Planned** | Documented intent; not configured | Enable branch protection in repo settings; require `ci/test` + `security/*` |
| Cost-policy SKU defaults | `cost-policy.yaml` | **Documented** | Reviewer checklist comment posted by `cost.yml` | Wire Azure Policy: deny SKUs above tier per environment |
| Spec → Plan → Tasks → Implement flow | constitution §Workflow | **Documented** | Author discipline; `/speckit.analyze` recommended | PR template that links the relevant `T<stage>.<n>` task ID |

## Notes

- "Enforced" here means *blocks merge or run on violation*. Non-blocking
  signals (Trivy SARIF in the Security tab, npm audit at `high+`) are
  classified **Enforced** when the workflow fails on threshold breach,
  otherwise **Documented**.
- Several **Documented** rows could become **Enforced** with branch
  protection — that switch is itself documented, not enabled, to avoid
  blocking the live demo.
