# Platform Engineering Overview

This document captures the Platform Engineering (PE) intent for the
`DevOpsPro-Europe-2026` repository. It is the result of the first
kickoff prompt and acts as a north star for the more detailed prompts
that follow.

## Application context

- Node.js / Express application: `Brasov Sunset API`
- Source code: `App/`
- Tests (Jest + Supertest): `App_Test/`
- Public, demo-friendly repository
- No production data, no secrets, no proprietary integrations

The application itself is intentionally simple: it returns the sunset
time for Brasov, Romania. The interesting parts of this repository are
the platform capabilities built **around** the app.

## Goals of the golden path

Build a small but realistic platform engineering golden path that a new
developer could realistically follow on day one:

1. **Source control hygiene** - clear branch strategy (`main` +
   short-lived branches) and a single working branch for the demo
   (`prompt_only`).
2. **Continuous Integration** - every change is built and tested in
   GitHub Actions before it can be merged.
3. **Security guardrails** - dependency audit, secret scanning, and a
   filesystem/dependency vulnerability scan run automatically.
4. **Infrastructure as Code** - Azure App Service infrastructure is
   described in Terraform, parameterised, and reviewable.
5. **Terraform validation** - `fmt`, `init`, `validate`, and (when
   credentials are available) `plan` run in CI.
6. **Deployment** - a manual `workflow_dispatch` pipeline deploys the
   application to Azure App Service using GitHub Actions OIDC.
7. **Policies** - lightweight, readable policy files describe the
   non-negotiables (tags, ownership, deployment rules, cost rules).
8. **Cost awareness** - SKU choices are explicit, tags support cost
   allocation, and the path to Infracost / Azure Cost Management is
   documented.
9. **Operational readiness** - health endpoint expectations, smoke
   tests, log locations, rollback notes, and the path to richer
   observability are documented.
10. **Demo flow** - the whole thing is optimised for a 30-minute live
    conference demo, not a production-grade enterprise platform.

## Non-goals

- No Spec Kit or other heavyweight scaffolding tools.
- No paid SaaS dependencies.
- No hardcoded Azure subscription IDs, tenant IDs, client IDs, or
  resource names.
- No secrets in the repository.
- No attempt to be a complete enterprise governance framework.

## Iterative workflow

Work is driven by short, focused prompts located in `prompts_clean/`
(gitignored locally). Each prompt produces a small, reviewable change
that is committed to the `prompt_only` branch with the prompt file
name as the commit message. A lightweight `docs/plan.md` and
`docs/tasks.md` track the work; they are updated iteratively rather
than generated up front.

## Standards used across the golden path

- **Cloud:** Microsoft Azure (App Service on Linux for Node.js).
- **IaC:** Terraform with the `azurerm` provider.
- **CI/CD:** GitHub Actions, Azure login via OIDC.
- **Tags:** every resource carries `environment`, `owner`, `project`.
- **Runtime:** Node.js LTS, matching the app's `package.json`.
- **Documentation lives next to the platform code** under
  `platform/docs/` and `docs/`.

## What "done" looks like for the demo

- CI is green on `main` and on `prompt_only`.
- Security workflow runs on every PR.
- `infra/terraform/` plans cleanly with placeholder variables.
- A manual deploy can push the app to an Azure App Service.
- Policies, cost awareness, and operational readiness are documented.
- The story can be told end-to-end in 30 minutes.
