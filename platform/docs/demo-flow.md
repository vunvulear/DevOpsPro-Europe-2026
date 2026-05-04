# Demo Flow

Live script for **"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"**.
Designed to be glanced at, not read on stage. One page, nine steps, ~30 minutes.

## Time budget at a glance

| # | Step | Live time |
|---|---|---|
| 1 | Existing app baseline | 1 min |
| 2 | Add CI | 3 min |
| 3 | Add security scanning | 2 min |
| 4 | Add Terraform for Azure App Service | 4 min |
| 5 | Add Terraform validation/plan | 3 min |
| 6 | Add Azure App Service deployment | 4 min |
| 7 | Add policies and cost awareness | 3 min |
| 8 | Add operational readiness | 2 min |
| 9 | Show the complete golden path | 3 min |
| — | Buffer / Q&A | 5 min |

---

## 1. Existing app baseline

- **Show:** the repo as a "normal" Node.js app — no platform scaffolding yet.
- **Key message:** golden paths start from a real, ordinary app. Not a green-field theory.
- **Files to open:** `App/server.js`, `App_Test/tests/sunset.test.js`, root `README.md` (top section).
- **Command:** `npm test --prefix App_Test`
- **What can fail:** Node version mismatch; port 3000 in use.
- **Fallback:** Pre-recorded GIF of `npm test` green; pre-warmed terminal with the server already running.

## 2. Add CI

- **Show:** PR opens → `ci.yml` runs → green check on `main`.
- **Key message:** the cheapest safety net comes first. Every change validated on a clean runner.
- **Files to open:** `.github/workflows/ci.yml`, root `README.md` "CI" section.
- **Command:** push the branch; open the PR in the Actions tab.
- **What can fail:** Slow runner queue; lockfile drift breaking `npm ci`.
- **Fallback:** point at a previous green run; replay locally with `npm ci && npm test` if the runner is slow.

## 3. Add security scanning

- **Show:** `security.yml` runs four jobs (npm audit, Gitleaks, Trivy, Checkov) in parallel; Security tab gets SARIF.
- **Key message:** shift-left isn't a slogan — it's four free tools wired into a workflow. Public-repo friendly.
- **Files to open:** `.github/workflows/security.yml`, `platform/docs/security-guardrails.md` (briefly).
- **Command:** push; show the four jobs running.
- **What can fail:** Trivy/Checkov resolve fragile action versions; Gitleaks alerting on a fixture.
- **Fallback:** Pre-trigger before going on stage; if a job is slow, narrate the four checks and click into a previous successful run.

## 4. Add Terraform for Azure App Service

- **Show:** Three resources (`azurerm_resource_group`, `azurerm_service_plan`, `azurerm_linux_web_app`) and the tag map.
- **Key message:** infra is reviewable code. Three resources are enough to ship a Node app.
- **Files to open:** `infra/terraform/main.tf`, `infra/terraform/variables.tf`, `infra/terraform/environments/dev.tfvars`, `infra/terraform/README.md` (state-is-local note).
- **Command:** `terraform fmt -check` and `terraform validate` (no Azure auth needed).
- **What can fail:** Provider download time; `azurerm` major version mismatch; tfvars typo.
- **Fallback:** Pre-warm `.terraform/` cache locally; if `validate` errors, narrate `main.tf` and skip the run.

## 5. Add Terraform validation/plan

- **Show:** `terraform-plan.yml` — `validate` job always runs; `plan` job runs only when Azure OIDC vars exist; PR comment with the plan.
- **Key message:** the plan is the diff a reviewer can read. No publish profiles, no secrets — OIDC and three repo Variables.
- **Files to open:** `.github/workflows/terraform-plan.yml`, `platform/docs/iac-standards.md` (auth section).
- **Command:** open a PR that touches `infra/terraform/dev.tfvars` (e.g. SKU bump); show the comment.
- **What can fail:** OIDC misconfiguration on the federated credential; permissions on PR comment.
- **Fallback:** Keep a `demo/tf-plan-ready` branch with a previously successful plan PR comment to reference.

## 6. Add Azure App Service deployment

- **Show:** `Run workflow` → build → OIDC login → `webapps-deploy@v3` → `smoke-test` job → `curl https://<app>/sunset` from your terminal.
- **Key message:** deploy is just the last 30 seconds — most of the value is everything that ran before.
- **Files to open:** `.github/workflows/deploy-azure-app-service.yml`, `platform/docs/deployment-path.md`.
- **Command:** **Actions → Deploy to Azure App Service → Run workflow**. Then `curl https://<AZURE_WEBAPP_URL>/sunset`.
- **What can fail:** Cold start on first deploy; smoke test asserts; OIDC role assignment missing.
- **Fallback:** Pre-deploy once before the talk so the live URL is warm. If the deploy job fails, `curl` the previously-deployed URL to show the smoke test logic against a known-good app.

## 7. Add policies and cost awareness

- **Show:** `platform/policies/*.yaml`, the cost-awareness PR comment from a SKU bump, the enforcement matrix.
- **Key message:** policies live next to the code. Five small files cover ownership, tags, deploys, cost. No governance portal.
- **Files to open:** `platform/policies/service-metadata.yaml`, `platform/policies/tagging-policy.yaml`, `platform/policies/cost-policy.yaml`, `platform/policies/deployment-policy.md`, `platform/docs/cost-awareness.md`.
- **Command:** open the SKU-bump PR from step 5; scroll to the **Cost awareness reminder** comment and the cost-policy file.
- **What can fail:** `cost-awareness.yml` finds no tfvars (e.g. you renamed a folder).
- **Fallback:** Show the policy YAML directly; emphasize the matrix in `policy-guardrails.md`.

## 8. Add operational readiness

- **Show:** `/healthz` endpoint, App Service `health_check_path`, smoke-test job logs, where logs would live in App Service.
- **Key message:** "good enough to be on call" beats "theoretically observable". `/healthz`, smoke test, log stream, two ways to roll back.
- **Files to open:** `platform/docs/operational-readiness.md`, `infra/terraform/main.tf` (`health_check_path` line).
- **Command:** `curl https://<AZURE_WEBAPP_URL>/healthz` (returns 200).
- **What can fail:** App Service still cold; `/healthz` not yet implemented in the app for that step's branch.
- **Fallback:** Show the Terraform line + the log stream UI; promise it works without making it work live.

## 9. Show the complete golden path

- **Show:** A single PR that exercises the whole path — small change in `App/server.js`, failing test, fix, all checks green (CI, security, terraform-plan, cost-awareness), merge, manual deploy, smoke test green, live URL serves the new behavior.
- **Key message:** the path is the product. One PR, one merge, one deploy — and every guardrail you've built has a chance to do its job.
- **Files to open:** the PR's **Files changed** tab and the **Checks** tab side by side.
- **Command:** merge → **Run workflow** for deploy → `curl` the live URL.
- **What can fail:** Anything from steps 2–6 has a worse day than expected.
- **Fallback:** Pre-recorded screen capture of the full happy-path flow as a 90-second backup. Have `main` already in a known-good state so the demo branch is the only thing changing.

---

## Branch / tag structure

Cut tags ahead of the talk so you can roll forward by checking out the next one if a step misbehaves:

| Tag | What's in the repo at this point |
|---|---|
| `step-00-existing-app` | App + tests + README only. Pre-platform baseline. |
| `step-01-ci` | + `.github/workflows/ci.yml`, README "CI" section. |
| `step-02-security` | + `.github/workflows/security.yml`, `platform/docs/security-guardrails.md`. |
| `step-03-terraform` | + `infra/terraform/` (versions, providers, variables, main, outputs, dev.tfvars, README), `platform/docs/iac-standards.md`. Checkov soft-fail wired. |
| `step-04-terraform-plan` | + `.github/workflows/terraform-plan.yml`, README updates. |
| `step-05-azure-deploy` | + `.github/workflows/deploy-azure-app-service.yml`, `platform/docs/deployment-path.md`. |
| `step-06-policies-and-docs` | + `platform/policies/*` (service-metadata, tagging, deployment, cost), `platform/docs/policy-guardrails.md`, `platform/docs/cost-awareness.md`, `.github/workflows/cost-awareness.yml`. |
| `step-07-golden-path-complete` | + `platform/docs/operational-readiness.md`, README "Golden Path Demo" section, `platform/docs/demo-flow.md`. |

Suggested cuts on `main`:

```bash
git tag step-00-existing-app <sha-before-ci>
git tag step-01-ci          <sha-after-ci>
# ...repeat for each step on the matching commit
git push --tags
```

Branches mirroring the tags (`step-00-existing-app`, ...) are useful if you want to demo a step in isolation without rewinding `main`.

## During the talk: tiny survival kit

- **Two terminals open:** one for `curl`, one for `npm test`.
- **Browser tabs ready:** GitHub Actions, the PR you'll merge, the App Service Overview blade, Azure Pricing Calculator.
- **A previous green run** of every workflow bookmarked, in case live runs are slow.
- **Pre-deploy** once before the talk so the live URL is warm.
- **Don't fight a red workflow live.** Narrate, fall back to the pre-recorded clip, move on.
- **Time check** at step 6 (~15 min in). If you're behind, compress steps 7 and 8 to one slide each.
