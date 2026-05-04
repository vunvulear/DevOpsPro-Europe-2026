# Spec Kit Setup

This document describes how the spec-driven foundation was set up for this repository
and how to use it during the live demo.

## How Spec Kit was initialized

Initialized in-place using the official GitHub Spec Kit:

```powershell
uvx --from git+https://github.com/github/spec-kit.git specify init . `
  --ai windsurf --script ps --force --ignore-agent-tools
```

This created:

- `.specify/` — Spec Kit templates, scripts, and project memory
- `.windsurf/rules/` — agent rules
- `.windsurf/workflows/speckit.*.md` — slash commands (`/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`, etc.)

Verification:

```powershell
uvx --from git+https://github.com/github/spec-kit.git specify check
```

## Agent configuration

- **Selected agent: Windsurf / Cascade** (native Spec Kit integration).
- Script flavor: PowerShell (`--script ps`) since the demo runs on Windows.
- `--ignore-agent-tools` was used because the agent runs inside the IDE (no CLI binary needed).

## Extension workflows added

Inspired by [`MartyBonacci/spec-kit-extensions`](https://github.com/MartyBonacci/spec-kit-extensions),
adapted and shortened for this demo. Added under `.windsurf/workflows/`:

- `modify.md` — scoped, spec-aware feature modification
- `refactor.md` — behavior-preserving refactor
- `hotfix.md` — urgent production fix through the golden path
- `bugfix.md` — non-urgent bug fix with regression test

These are invoked from Cascade as `/modify`, `/refactor`, `/hotfix`, `/bugfix`.

## Using Windsurf / Cascade with this repo

1. Open the repo in Windsurf.
2. Use Spec Kit slash commands in order:
   - `/speckit.constitution` (optional, once)
   - `/speckit.specify` → fills `specs/golden-path/spec.md`
   - `/speckit.plan` → fills `plan.md`
   - `/speckit.tasks` → fills `tasks.md`
   - `/speckit.implement` → executes the tasks
3. Use the demo prompts in `prompts/` (numbered `00`..`15`) as the live script.
4. For incident demos use `/hotfix`; for normal change use `/modify`.

## Intentional simplifications for the 30-minute demo

- No secrets, tokens, Azure credentials, subscription/tenant/client IDs are committed.
  Real deployments would use OIDC federated credentials configured outside the repo.
- Terraform examples target a single Azure App Service — not multi-region, not production-grade.
- Policy, cost, and operational-readiness prompts cover the spirit of platform guardrails,
  not a full internal developer platform.
- Tests focus on the existing sunset API; the golden path itself is illustrative.
