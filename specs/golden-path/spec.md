# Golden Path — Specification

> Companion to `plan.md` and `tasks.md`. This file is the single source of truth
> for **what** the golden path delivers. The plan describes **how** to build it;
> the tasks describe **what to do next**.

## Context

The Brașov Sunset API (`App/`) is a Node.js/Express service that returns
today's sunset time for Brașov, Romania, on `GET /sunset`. The application is
already complete and well-tested (`App_Test/`). It serves as the realistic
sample workload around which the platform team builds a *golden path* —
the recommended, paved way to take a change from a developer's machine to
production on Azure App Service.

This spec is intentionally small. It supports the conference talk
**"Platform Engineering in 30 Minutes: Build a Golden Path, Not a PowerPoint"**
and is not a replacement for an internal developer platform.

## Goal

Provide an end-to-end, in-repo, demo-grade golden path that lets a small team
ship the Brașov Sunset API to Azure App Service safely, repeatably, and
visibly — without secrets, portals, or hidden config.

A change should travel:

> developer → PR → CI green → security green → IaC plan reviewed → cost reviewed → merge → manual deploy → smoke green → live URL

…in under **5 minutes of human time** for a typical small change, and entirely
**within this one repository**.

## In scope

1. **CI** — build and test the app on every PR to `main`.
2. **Security scanning** — dependency audit, secret scanning, filesystem
   vulnerabilities, IaC misconfigurations.
3. **Infrastructure as code** — Terraform that provisions a Linux App Service
   for Node.js, plus minimal hardening and required tags.
4. **Terraform validation and plan** — fmt + validate on every infra PR;
   `terraform plan` against Azure when OIDC variables are configured.
5. **Deployment** — manual `workflow_dispatch` deploy with OIDC auth and a
   post-deploy smoke test.
6. **Cost awareness** — a reviewer reminder on infra PRs that surfaces SKU
   choices and policy expectations.
7. **Operational readiness** — health endpoint, smoke test, log access path,
   simple rollback story.
8. **Platform policies** — small YAML/Markdown files that capture the rules of
   the road (ownership, tags, deploys, cost).
9. **Demo flow & hotfix scenario** — a one-page on-stage script and a safe
   failure scenario that demonstrates the path under stress.

## Out of scope (explicitly)

- Multi-environment promotion (`test`/`prod`) beyond `dev` placeholders.
- Remote Terraform state, state locking.
- Deployment slots, zero-downtime swap, blue/green.
- Application Insights, Log Analytics, OpenTelemetry, SLO dashboards.
- Infracost, Azure Cost Management budgets, anomaly detection.
- A central service catalog (Backstage, etc.).
- Identity-based environment promotion, on-call rotation, paging.
- Any internal portal, ticketing system, or approval workflow.
- A "real" application; the existing sunset API is the workload.

## Constraints

- **No secrets in the repo.** No tokens, no client secrets, no publish profiles.
- **No hardcoded Azure subscription, tenant, client, or resource IDs.** Repo
  Variables only; placeholders elsewhere.
- **OIDC for Azure auth.** `azure/login@v2` with federated credentials.
- **Public-repo friendly.** Forks must run CI, security, and Terraform validate
  with no setup; sensitive jobs auto-skip green when variables are missing.
- **Spec-driven.** Spec → plan → tasks → implement, in that order.
- **Visibility over enforcement.** Where a guardrail risks blocking a live
  demo (e.g. Checkov), it surfaces as an annotation and stays soft.
- **Simplicity over completeness.** Each capability is one or two small files,
  readable in under a minute on stage.

## Capabilities

For each capability, this spec captures *what success looks like*. Implementation
details live in `plan.md`; ordered execution lives in `tasks.md`.

### CI

- Triggered on PRs to `main` and pushes to `main`.
- Installs `App/` and `App_Test/` deps via `npm ci` with cache.
- Runs `npm test` (Jest + Supertest); failure blocks the workflow.

### Security scanning

- `npm audit` (`high` threshold, prod-only for `App/`).
- Gitleaks on full git history.
- Trivy filesystem scan, `HIGH`/`CRITICAL`, `ignore-unfixed`, SARIF to Security tab.
- Checkov on Terraform when present, `soft_fail: true` for the demo.

### Infrastructure as code

- Single Terraform stack under `infra/terraform/`.
- Three resources: Resource Group, Linux App Service Plan, Linux Web App.
- Common tags on every resource: `project`, `environment`, `owner`,
  `managed_by="terraform"`, `repo`.
- Hardening: `https_only`, TLS 1.2 min, FTPS disabled, HTTP/2 on, websockets &
  remote debugging off.
- `health_check_path = "/healthz"`.
- Local state (documented as a deliberate demo simplification).

### Terraform validation and plan

- `validate` job: fmt + init (no backend) + validate. Always runs, no auth.
- `plan` job: OIDC login, plan against Azure, post as PR comment. Skips
  cleanly when OIDC repo Variables are missing.

### Deployment

- `workflow_dispatch` only.
- Build `App/` with `npm ci --omit=dev`, upload artifact.
- OIDC login, deploy with `azure/webapps-deploy@v3`.
- `smoke-test` job hits `/` (with cold-start retries) and `/sunset` (asserting
  city = "Brasov" and timezone = "Europe/Bucharest").

### Cost awareness

- On infra PRs: extract `sku_name` from each `environments/*.tfvars`, post or
  update a single sticky reviewer-checklist comment.
- No external services, no tokens, no fake dollar amounts.
- Per-environment SKU defaults documented in `cost-policy.yaml`; budgets are
  team-set placeholders.

### Operational readiness

- App exposes `GET /healthz` returning `{status:"ok"}` (covered by tests).
- App Service uses `/healthz` as `health_check_path`.
- `/sunset` payload assertions are the de-facto SLI via the smoke test.
- Logs accessed via Azure-native tooling only (Log stream, Deployment Center,
  `az webapp log tail`).
- Rollback = re-run a previous green deploy or `git revert` + redeploy.

### Platform policies

- Five short files under `platform/policies/` covering service metadata,
  tagging, deployments, and cost.
- An enforcement matrix in `policy-guardrails.md` mapping each rule to its
  current status (Enforced / Documented / Planned) and to a credible hardening
  path.

### Demo flow & hotfix scenario

- One-page demo script with time budget, per-step what-can-fail and fallback.
- A safe, fast hotfix scenario: smoke-test assertion drift (diacritic on the
  city name) — one character to break, one character to fix.

## Acceptance criteria

The golden path is "done" for the talk when:

1. A fresh fork of this repo runs CI, security, and Terraform validate green
   on day one with no setup.
2. With OIDC repo Variables and a federated credential configured, a manual
   deploy ships the API to Azure App Service and the smoke test passes
   automatically.
3. Every workflow file fits on one screen and explains its purpose in a header
   comment.
4. The Terraform module fits in seven files under `infra/terraform/` and
   provisions the App Service from `dev.tfvars` with no further inputs.
5. There are no secrets, no hardcoded Azure IDs, and no private hostnames in
   the repository at any commit on `main`.
6. The complete demo flow, including a hotfix story, runs end-to-end in
   ≤ 30 minutes on a warm cache.

## Non-goals (worth restating)

- This repo is not a starter template for production platforms. It is a
  *teaching artifact*. Anyone copying it is expected to re-evaluate every
  "intentionally simplified" callout in the docs.
- The policies, costs, and operational guidance are deliberately small. They
  are meant to start a conversation, not end one.
