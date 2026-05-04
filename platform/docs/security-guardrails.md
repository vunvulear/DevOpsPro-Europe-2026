# Security Guardrails

The Security workflow ([`.github/workflows/security.yml`](../../.github/workflows/security.yml))
is the second capability of the golden path. It runs on every PR, on pushes to `main`,
on a weekly schedule, and on demand (`workflow_dispatch`).

## What checks run

| Check | Tool | Scope | Failure threshold |
|---|---|---|---|
| Dependency audit | `npm audit` | `App/` (prod only) and `App_Test/` | `--audit-level=high` |
| Secret scanning | [Gitleaks](https://github.com/gitleaks/gitleaks-action) | Full git history | Any leak |
| Filesystem & dependency vulns | [Trivy](https://github.com/aquasecurity/trivy-action) | Whole repo (`fs` scan) | `HIGH` or `CRITICAL`, fixed only |
| IaC (Terraform) | [Checkov](https://github.com/bridgecrewio/checkov-action) | `infra/terraform/` | Any failed policy (active **only** when `*.tf` files exist) |

Trivy results are also uploaded to the **Security** tab as SARIF so findings appear next to CodeQL alerts.

## Why these are part of the golden path

- **Shift-left.** Catch vulnerable deps and leaked secrets at PR time, not in production.
- **Free and public-repo friendly.** No license, no paid tier, no cloud credentials.
- **Cheap to run.** Each check is a few seconds to a couple of minutes — fits a 30-minute demo.
- **Layered.** Different tools catch different classes of issues (deps vs. secrets vs. IaC misconfig).

## What developers should do when a check fails

### `npm audit` failed

1. Read the advisory link in the job log.
2. Try `npm audit fix` (or `npm audit fix --force` only if the breaking change is acceptable).
3. If the fix is not yet available upstream, document the rationale in the PR and consider pinning a transitive dep via `overrides` in `package.json`.

### Gitleaks flagged a secret

1. **Treat the secret as compromised** — rotate it immediately at the source (Azure, GitHub, etc.).
2. Remove the secret from the working tree and use a placeholder or environment variable.
3. Rewriting history is not enough on a public repo — the value must be rotated regardless.
4. Add the offending pattern to a Gitleaks allowlist **only** if it's a confirmed false positive (e.g. a sample fixture).

### Trivy reported a vulnerability

1. Open the SARIF entry in the Security tab to see the affected component and version.
2. Bump the dependency or base image to the fixed version listed by Trivy.
3. If no fix exists yet, the finding is automatically suppressed by `ignore-unfixed: true` in the workflow — but track it.

### Checkov failed (once Terraform lands)

1. Read the failed check ID (e.g. `CKV_AZURE_*`) and follow the link in the log.
2. Update the Terraform resource to satisfy the policy (e.g. enable HTTPS-only, configure TLS 1.2+).
3. Suppress only with an inline `#checkov:skip=...` comment **and** a written justification in the PR.

## Intentionally simplified for the demo

- **No CodeQL job here.** CodeQL is mentioned in the golden-path plan but lives in its own workflow path (default setup via repo settings or a future `codeql.yml`). Keeping `security.yml` to four focused tools keeps the live walkthrough explainable.
- **`HIGH`/`CRITICAL` only for Trivy.** Filtering to fixable, high-severity findings prevents the Security tab from drowning the audience in noise during the talk.
- **Checkov is conditional.** The job is wired up but skips itself with a clear notice until `infra/terraform/*.tf` exists. This mirrors how a real platform team would stage rollout: workflow first, policies enforced as soon as the surface they protect appears.
- **No supply-chain attestation, SBOM upload, or container scanning yet.** The app is not containerized in the demo; SBOM/attestation can be added in a future iteration.
- **Default Gitleaks ruleset.** No custom allowlist; the public-repo demo doesn't need tuning.

## How to validate locally (optional)

```powershell
# Dependency audit (matches CI thresholds)
npm audit --omit=dev --audit-level=high --prefix App
npm audit --audit-level=high --prefix App_Test

# Gitleaks (Docker)
docker run --rm -v "${PWD}:/repo" zricethezav/gitleaks:latest detect --source=/repo --no-banner

# Trivy filesystem scan (Docker)
docker run --rm -v "${PWD}:/repo" aquasec/trivy:latest fs --severity HIGH,CRITICAL --ignore-unfixed /repo

# Checkov (once Terraform exists)
docker run --rm -v "${PWD}:/repo" bridgecrew/checkov:latest -d /repo/infra/terraform --framework terraform
```
