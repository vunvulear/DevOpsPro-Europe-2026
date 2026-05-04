# DevOpsPro-Europe-2026 Constitution

The non-negotiable principles of the golden path in this repository.
Short on purpose. Every other doc, workflow, or policy must align with these.

## Core Principles

### I. Spec-First

Every change begins with a spec, plan, or task update under `specs/`.
Code follows the spec, not the other way around.
Drive-by changes that don't fit any spec must surface that gap explicitly.

### II. Small, Readable, Demo-Friendly

Each capability is one or two short files that fit on a screen.
Workflows, Terraform, and policies must be explainable in under a minute on stage.
Prefer one focused tool over four overlapping ones.

### III. No Secrets, No Hardcoded IDs

The repository contains no tokens, no client secrets, and no Azure
subscription, tenant, client, or resource IDs at any commit on `main`.
Azure auth uses GitHub Actions OIDC; non-sensitive IDs live as repo Variables.

### IV. Visibility Over Enforcement (for now)

Guardrails surface findings — annotations, PR comments, plan diffs — before
they block merges. As the team gains confidence, soft guardrails harden into
required checks. Never the other way around.

### V. Public-Repo Friendly by Default

A fresh fork must run CI, security, and Terraform validate green on day one
with no setup. Jobs that need Azure access auto-skip with a green status when
the relevant repo Variables are missing.

### VI. The Path Is the Product

The same CI, security, plan, deploy, and cost checks run on every PR — bug
fixes, hotfixes, refactors, and infra changes alike. The path is never
bypassed under pressure; if it's slowing the team down, fix the path.

## Demo Constraints

This repository backs the conference talk **"Platform Engineering in 30 Minutes:
Build a Golden Path, Not a PowerPoint"**. Two extra rules apply during the demo
phase and are documented inline as "intentionally simplified":

- Local Terraform state, single environment (`dev`), manual deploy.
- Checkov runs in `soft_fail` mode; cost is visible, not blocking.

When the demo phase ends, those simplifications must be reviewed against the
principles above before the path is reused for any real workload.

## Change Process

- Spec / plan / tasks update before code (Principle I).
- One focused PR per capability or hotfix.
- Required checks on `main`: `ci`, `security`, `terraform-plan` (when infra
  changes), and the smoke test on deploy.
- Constitution amendments require a PR description that names the principle
  being added, removed, or relaxed and the reason.

## Governance

This constitution supersedes any conflicting guidance elsewhere in the repo.
Reviewers must check PRs against the principles above; complexity that violates
any principle must be justified in writing on the PR.

**Version**: 1.0.0 | **Ratified**: 2026-05-04
