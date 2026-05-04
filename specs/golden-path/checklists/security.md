# Security Requirements Quality Checklist

> **Purpose:** Unit tests for the *security-related requirements* in
> `spec.md` and `plan.md` — covering secrets handling, Azure auth, hardcoded
> identifiers, scanning thresholds, and fork-safety. This file validates how
> the requirements are **written**, not whether the implementation works.
>
> **Audience:** PR reviewer for any infra/CI/security change.
> **Depth:** Standard.
> **Created:** alongside `tasks.md` (post-/speckit.tasks).

## Requirement Completeness

- [ ] CHK001 — Are the GitHub repo Variables required for Azure auth listed exhaustively (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_APP_NAME`, `AZURE_RESOURCE_GROUP`, `AZURE_LOCATION`)? [Completeness, Plan §Cross-cutting principles]
- [ ] CHK002 — Are the four security-scanning categories (dependency audit, secret scanning, FS vulnerabilities, IaC misconfig) each given a tool, threshold, and failure mode? [Completeness, Spec §Security scanning]
- [ ] CHK003 — Are SARIF upload requirements specified for every scanner that supports it? [Completeness, Gap]
- [ ] CHK004 — Is the no-secrets requirement extended explicitly to historical commits, not just `HEAD`? [Completeness, Spec §Acceptance #5]
- [ ] CHK005 — Are requirements defined for what to do when a scanner finds a *new* HIGH/CRITICAL CVE between rehearsal and the talk? [Completeness, Gap]

## Requirement Clarity

- [ ] CHK006 — Is "no secrets in the repo" defined precisely enough to distinguish a secret from a public identifier (e.g. `AZURE_TENANT_ID` is not a secret but is still treated as a Variable)? [Clarity, Spec §Constraints]
- [ ] CHK007 — Is "no hardcoded Azure subscription, tenant, client, or resource IDs" measurable — i.e. is the regex/format the reviewer should look for stated anywhere? [Clarity, Spec §Acceptance #5]
- [ ] CHK008 — Is "private hostname" defined (e.g. does `*.azurewebsites.net` literal count, only when prefixed with a real app name)? [Clarity, Spec §Acceptance #5]
- [ ] CHK009 — Is the `npm audit` threshold (`high`, prod-only) justified or just stated? [Clarity, Spec §Security scanning]
- [ ] CHK010 — Is the Trivy `ignore-unfixed` policy explained as a deliberate choice, not an accident? [Clarity, Spec §Security scanning]

## Requirement Consistency

- [ ] CHK011 — Do `spec.md` Constraints and `plan.md` Cross-cutting principles state the no-secrets rule with the same scope? [Consistency, Spec §Constraints, Plan §Cross-cutting]
- [ ] CHK012 — Is the OIDC-only stance consistently applied to *all* Azure-touching workflows (`terraform.yml` plan job, `deploy.yml`)? [Consistency, Plan §Stage 5/Stage 6]
- [ ] CHK013 — Are skip-clean conditions (`vars.AZURE_CLIENT_ID != ''`) consistently named across stages, or do they drift? [Consistency, Plan §Stage 5/Stage 6]
- [ ] CHK014 — Does Checkov's `soft_fail: true` conflict with the spirit of "security green" in the spec's pipeline metaphor? [Consistency, Conflict, Spec §Goal]

## Acceptance Criteria Quality

- [ ] CHK015 — Can "no secrets, no hardcoded Azure IDs, no private hostnames at any commit on `main`" be objectively verified, and by what tool/check? [Measurability, Spec §Acceptance #5]
- [ ] CHK016 — Can "fork runs CI, security, and Terraform validate green on day one with no setup" be measured without manually forking the repo? [Measurability, Spec §Acceptance #1]
- [ ] CHK017 — Are the success conditions for each of the four security jobs (audit/gitleaks/trivy/checkov) defined as exit codes or thresholds? [Measurability, Spec §Security scanning]

## Coverage / Scenario Classes

- [ ] CHK018 — Are requirements specified for the **fork** scenario (sensitive jobs auto-skip green)? [Coverage, Spec §Constraints]
- [ ] CHK019 — Are requirements specified for the **misconfigured Variables** scenario (e.g. `AZURE_CLIENT_ID` set but `AZURE_TENANT_ID` empty)? [Coverage, Gap]
- [ ] CHK020 — Are requirements specified for **expired federated credentials** between rehearsal and talk? [Coverage, Recovery, Gap]
- [ ] CHK021 — Are requirements specified for **leaked secret discovery** during the live demo? [Coverage, Exception, Gap]
- [ ] CHK022 — Are requirements defined for **Gitleaks false positives** on placeholder strings? [Coverage, Plan §Stage 3]

## Edge Cases

- [ ] CHK023 — Is behaviour defined when `infra/terraform/` is absent (Checkov job)? [Edge Case, Plan §Stage 3]
- [ ] CHK024 — Is behaviour defined when `App/package-lock.json` is missing or out of sync (npm audit)? [Edge Case, Gap]
- [ ] CHK025 — Is the response defined when SARIF upload fails (e.g. fork without Security tab access)? [Edge Case, Gap]

## Non-Functional

- [ ] CHK026 — Are runtime budgets specified for the security workflow so it does not exceed the CI feedback window? [NFR, Gap]
- [ ] CHK027 — Are caching requirements specified for scanners (Trivy DB, npm cache) to keep the talk demo fast? [NFR, Gap]

## Dependencies & Assumptions

- [ ] CHK028 — Is the assumption that GitHub Variables (not Secrets) are sufficient for *all* non-credential Azure identifiers stated and validated? [Assumption, Spec §Constraints]
- [ ] CHK029 — Is the dependency on a User-Assigned Managed Identity / App Registration with federated credential documented? [Dependency, Plan §Cross-cutting]
- [ ] CHK030 — Are external action versions pinned in the requirements, or only in the plan? [Dependency, Plan §Open items]

## Ambiguities & Conflicts

- [ ] CHK031 — Does "visibility over enforcement" (spec) potentially conflict with "failure blocks the workflow" (CI) — is the precedence rule documented? [Conflict, Spec §Constraints]
- [ ] CHK032 — Is the term "demo-grade" defined anywhere as a security posture, or left to interpretation? [Ambiguity, Spec §Goal]
