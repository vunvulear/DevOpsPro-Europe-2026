<!--
Sync Impact Report
==================
Version change: (none) → 1.0.0
Bump rationale: Initial ratification. No prior version existed; the file
                was a placeholder template at HEAD before this commit.

Modified principles: n/a (initial set)

Added sections:
  - Core Principles (5 principles)
  - Additional Constraints (Demo & Talk Constraints)
  - Development Workflow (Spec → Plan → Tasks → Implement)
  - Governance

Removed sections: n/a

Templates requiring updates:
  - .specify/templates/plan-template.md          ⚠ pending  (file missing in repo;
                                                            no Constitution Check
                                                            block to align yet)
  - .specify/templates/spec-template.md          ⚠ pending  (file missing in repo)
  - .specify/templates/tasks-template.md         ⚠ pending  (file missing in repo)
  - .specify/templates/commands/*.md             ⚠ pending  (templates dir empty)
  - .windsurf/workflows/speckit.*.md             ✅ no change required (workflows
                                                            already reference the
                                                            constitution generically)
  - specs/golden-path/spec.md                    ✅ aligned (Constraints already
                                                            mirror Principles I–V)
  - specs/golden-path/plan.md                    ✅ aligned (Cross-cutting
                                                            principles mirror P-I–V)
  - specs/golden-path/tasks.md                   ✅ aligned (per-stage Constraint
                                                            checks reference these
                                                            principles)
  - README.md                                    ⚠ pending  (consider linking
                                                            this constitution from
                                                            the repo overview)

Follow-up TODOs:
  - When Spec Kit templates are seeded into .specify/templates/, add an
    explicit "Constitution Check" gate referencing P-I … P-V.
  - Consider adding a README pointer to .specify/memory/constitution.md.
-->

# DevOpsPro Europe 2026 — Golden Path Constitution

> Scope: this constitution governs the *teaching artifact* in this repository
> (the Brașov Sunset API and the golden path around it) used for the talk
> **"Platform Engineering in 30 Minutes: Build a Golden Path, Not a
> PowerPoint"**. It is intentionally narrow. It is not a generic platform
> standard, nor a starter template for production systems.

## Core Principles

### I. No Secrets In The Repository (NON-NEGOTIABLE)

The repository MUST NOT contain credentials of any kind: tokens, client
secrets, publish profiles, connection strings, SAS URIs, certificates, or
private keys — at any commit on `main`, in any branch intended to be merged,
and in any historical commit that becomes reachable from `main`.

Rationale: the talk repo is public-friendly and forkable. A leaked secret in
history is permanent. Excluding secrets categorically removes a whole class
of incidents from the demo and from anyone who copies the repo.

### II. OIDC-Only Azure Authentication

GitHub Actions MUST authenticate to Azure exclusively via federated
credentials and `azure/login@v2` with `id-token: write`. Use of
`AZURE_CREDENTIALS` JSON, service-principal client secrets, or App Service
publish profiles is forbidden. Azure identifiers (`AZURE_CLIENT_ID`,
`AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, resource names) are non-secret
configuration and MUST live in GitHub repo **Variables**, never Secrets.

Rationale: OIDC is short-lived, auditable, and revocable per repository.
Putting public IDs in Variables (not Secrets) makes the auth model
inspectable on stage without leaking anything sensitive.

### III. Fork-Safe Skip-Clean

Any workflow job that requires Azure access MUST be guarded by an explicit
condition (e.g. `if: ${{ vars.AZURE_CLIENT_ID != '' }}`) that causes the job
to **succeed without running** when the variables are absent. CI, security
scanning, and `terraform validate` MUST run end-to-end on a fresh fork with
zero configuration. No job may fail solely because Azure variables are
unset.

Rationale: a viewer who forks during the talk should see green checks within
minutes. Failing on missing config trains people to ignore CI.

### IV. One Screen Per File

Every workflow file (`.github/workflows/*.yml`), Terraform file, and policy
file SHOULD fit on a single screen at a typical conference projector
resolution (~50 lines). Each file MUST open with a header comment stating
its purpose in one sentence. Files that exceed this budget MUST justify the
overflow in their header comment.

Rationale: the talk is the documentation. If a file cannot be read aloud or
absorbed in 60 seconds, it cannot be defended on stage and it cannot be
adopted by a small team without ceremony.

### V. Visibility Over Enforcement

When a guardrail (security scanner, policy check, cost reminder) risks
blocking the live demo for reasons unrelated to the change under review,
it MUST surface findings as comments, annotations, or SARIF — and SHOULD
NOT hard-fail the workflow during the talk timeline. Hard-fail gates are
reserved for: build failures, unit-test failures, smoke-test failures, and
explicit P-I / P-II violations (secrets / non-OIDC auth).

Rationale: a CVE published the morning of the talk should not derail the
30-minute demo. Visibility builds the conversation; gating is a follow-up
decision the adopting team owns.

## Additional Constraints — Demo & Talk

- The end-to-end demo flow (PR → CI → security → IaC plan → cost → merge →
  manual deploy → smoke → live URL → hotfix) MUST fit in **≤ 30 minutes** on
  a warm cache.
- Every Terraform resource MUST carry the five common tags `project`,
  `environment`, `owner`, `managed_by`, `repo`. Hardening defaults
  (`https_only`, `minimum_tls_version = "1.2"`, FTPS disabled, HTTP/2 on,
  websockets off, remote debugging off) are mandatory on Linux Web Apps.
- Hardcoded Azure subscription, tenant, client, or resource IDs are
  forbidden in any committed file. Placeholders (`<APP_NAME>`,
  `<RESOURCE_GROUP>`, etc.) MUST be used in `tfvars`, docs, and runbooks.
- Application Insights, Infracost, deployment slots, and remote Terraform
  state are explicitly **out of scope** for the artifact and MUST NOT be
  re-introduced under "completeness" arguments without an amendment.

## Development Workflow — Spec → Plan → Tasks → Implement

1. Every change to capability MUST be reflected in `specs/golden-path/spec.md`
   first.
2. Implementation strategy lives in `plan.md`; ordered execution in
   `tasks.md`. PRs MAY skip these only for trivial doc/typo fixes.
3. `/speckit.analyze` MUST be run after `tasks.md` is generated; CRITICAL
   findings MUST be resolved before `/speckit.implement`.
4. Each PR SHOULD map to one task ID (`T<stage>.<n>`) and stay reviewable on
   one screen wherever feasible.
5. Branch protection on `main` (when enabled) MUST require, at minimum,
   `ci/test` and the security workflow's jobs as required checks.

## Governance

- This constitution **supersedes** ad-hoc conventions in any other file in
  the repository. Where `spec.md`, `plan.md`, or `tasks.md` conflict with
  a principle here, those documents are wrong and MUST be amended.
- Amendments require: (a) an entry in the Sync Impact Report at the top of
  this file, (b) a version bump per the rules below, (c) an explicit commit
  whose message starts with `docs(constitution):`.
- **Versioning**: MAJOR for backward-incompatible removals/redefinitions of
  a principle; MINOR for new principles or materially expanded guidance;
  PATCH for clarifications, wording, or typo fixes.
- **Compliance review**: every PR reviewer is expected to verify that the
  change does not violate principles I–V. Violations of P-I or P-II are
  blocking and cannot be waived inside a PR — they require a constitution
  amendment first.
- **Out-of-scope justifications** (Application Insights, multi-env
  promotion, etc.) MUST cite the explicit "Out of scope" list in `spec.md`
  or amend it.

**Version**: 1.0.0 | **Ratified**: 2026-05-04 | **Last Amended**: 2026-05-04
