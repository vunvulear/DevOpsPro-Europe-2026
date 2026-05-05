# Security Guardrails

This document describes the lightweight security checks that run on
every pull request and push, defined in
[`.github/workflows/security.yml`](../../.github/workflows/security.yml).

## What runs

| Check         | Tool            | Scope                              |
|---------------|-----------------|------------------------------------|
| Dependency    | `npm audit`     | `App/` and `App_Test/` lockfiles   |
| Secret scan   | Gitleaks        | Whole repository history           |
| Filesystem    | Trivy (fs)      | Whole repository, HIGH + CRITICAL  |
| IaC scan      | Checkov         | `infra/terraform/` if it exists    |

A weekly scheduled run (`Mondays 06:00 UTC`) re-runs the workflow so
that newly disclosed CVEs are surfaced even when nothing in the repo
has changed.

## Why these are part of the golden path

- **Cheap and predictable.** All four tools are free and run on
  GitHub-hosted runners with no cloud credentials.
- **Public-repo friendly.** Nothing here requires private tokens or
  paid SaaS accounts.
- **Catch the obvious.** They will not catch advanced threats, but
  they reliably catch leaked secrets, vulnerable dependencies, and
  obvious misconfigurations.
- **Shift-left.** Findings are visible at PR time, before code is
  merged or deployed.

## What developers should do when a check fails

1. **`npm audit` failure**
   - Run `npm audit` locally in `App/` or `App_Test/`.
   - Prefer `npm audit fix` for non-breaking upgrades.
   - For breaking changes, raise a small dedicated PR.
   - If a finding cannot be fixed today, document it in the PR
     description with an expiry date.

2. **Gitleaks finding**
   - **Do not** commit the fix on top.
   - Rotate the credential immediately at the source.
   - Rewrite or revert the offending commit.
   - Add a Gitleaks `.gitleaksignore` entry only if the finding is a
     genuine false positive.

3. **Trivy finding**
   - High and critical issues fail visibly but the workflow is
     configured with `exit-code: "0"` so it does not block the PR
     while we are still tuning. Treat findings as required reading,
     not optional noise.
   - For vulnerable transitive dependencies, upgrade the parent or
     add a documented exception.

4. **Checkov finding** (once Terraform is in place)
   - Read the rule ID and rationale.
   - Either fix the Terraform code or add a justified `skip` in the
     PR description.

## What is intentionally simplified for the demo

- **Soft-fail by default.** The workflow surfaces findings without
  blocking the PR. In a real platform, high/critical findings should
  block merges via branch protection.
- **No SARIF upload to the Security tab.** Easy to add, but skipped
  here to keep the workflow short and demo-friendly.
- **No SAST.** Tools like CodeQL are great but add minutes to the
  build; a real platform should add CodeQL on top of this baseline.
- **Single Trivy mode.** Only filesystem scanning is configured.
  Image scanning would be added once we publish container images.
- **Public-repo defaults.** No private mirrors, no air-gapped
  feeds, no compliance-grade reporting.

## Roadmap

- Promote findings to required checks on `main` once the noise level
  is acceptable.
- Add CodeQL for Node.js.
- Upload SARIF to the GitHub Security tab.
- Wire Checkov into Terraform PRs once `infra/terraform/` exists.
