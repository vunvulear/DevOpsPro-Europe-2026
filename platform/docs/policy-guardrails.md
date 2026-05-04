# Policy Guardrails

This doc explains how policies are organized in this repo, why they're tiny,
and which ones are enforced versus documented today.

## What a guardrail is

A **guardrail** is a rule that helps developers stay on the golden path
without thinking about it. The good ones:

- Show up **inside the developer workflow** (PR, IDE, CLI), not in a separate compliance portal.
- Fail **early and loudly** when something is off.
- Explain **why** in the same place they trigger, with a fix one click away.

A guardrail is *not* a perimeter wall. It's a curb you can drive over if you really need to — with a comment in the PR explaining why.

## Why guardrails belong close to the developer workflow

- **Speed.** Catching a missing tag in `terraform plan` saves a meeting that would catch it in production.
- **Context.** The developer who wrote the change is the cheapest person to fix it.
- **Trust.** When the platform team owns the guardrail and the developer owns the change, both sides see what the other expects.
- **Reviewability.** Policies in YAML/Markdown next to the code are reviewable, version-controlled, and rollback-friendly.

## Where the policies live

```
platform/
├── policies/
│   ├── service-metadata.yaml     # service catalog entry (owner, project, runtime, ops)
│   ├── tagging-policy.yaml       # required and recommended Azure tags
│   ├── deployment-policy.md      # how code reaches Azure (branching, auth, checks, SKU)
│   └── cost-policy.yaml          # cost visibility and review thresholds
└── docs/
    ├── deployment-path.md        # the deploy workflow in plain English
    ├── iac-standards.md          # Terraform standards
    ├── security-guardrails.md    # security workflow in plain English
    ├── spec-kit-setup.md         # how this repo uses Spec Kit
    └── policy-guardrails.md      # this file
```

## Enforcement matrix

| Policy | Status | Where it lives today | How it could harden later |
|---|---|---|---|
| Every service has an owner | Documented | `service-metadata.yaml` (`owner.team`) | Required-fields check in CI; service catalog backstop (e.g. Backstage). |
| Every service has a project name | Documented | `service-metadata.yaml` (`project.name`) | Same CI check as above. |
| Required tags on resources (`project`, `environment`, `owner`) | Enforced (Terraform) | `local.common_tags` in `infra/terraform/main.tf`, declared in `tagging-policy.yaml` | Azure Policy "Require a tag and its value"; Checkov rule. |
| Prod deploys only from `main` | Documented | `deployment-policy.md` §1 | Branch protection rule + `if: github.ref == 'refs/heads/main'` on the deploy job. |
| OIDC, no publish profiles / client secrets | Enforced | All workflows use `vars.AZURE_*` and `azure/login@v2` (no `secrets.AZURE_*`) | Already enforced; secret scanning (Gitleaks) backstops. |
| Intentional App Service SKU | Documented | `var.sku_name` in Terraform; `cost-policy.yaml` defaults | Conftest/OPA rule on `terraform plan` JSON to fail on `null`/`Free`/unexpected SKU. |
| Cost visible before deploy | Planned | `cost-policy.yaml` | Infracost workflow (`cost.yml`) posting a PR comment. |
| Smoke tests required after deploy | Enforced | `deploy-azure-app-service.yml` `smoke-test` job | Already enforced; can be widened to k6/Newman suite. |
| Health endpoint required | Partly enforced | `health_check_path = "/healthz"` in Terraform; app endpoint added in operational-readiness step | CI check that probes `/healthz` against a preview deploy. |

## What is intentionally simplified for the demo

- **YAML is read by humans, not by a policy engine.** No OPA/Conftest/Sentinel runtime here. This keeps the demo readable; introducing OPA is a clean follow-up.
- **One service, one set of files.** A real platform might generate per-service files from a template; we keep it inline.
- **No central catalog.** `service-metadata.yaml` plays the role of a Backstage `catalog-info.yaml` without the Backstage instance.
- **No identity-based environment promotion.** Branch + manual `workflow_dispatch` is enough at this scale.
- **No cost block.** Cost is *visible*, not *blocking*. A real production setup would gate merges on Infracost output and Azure Cost Management budgets.
- **Tags are aspirational outside Terraform.** Resources created out-of-band (someone clicking in the portal) won't carry these tags until Azure Policy is wired up.

## Bottom line

The policy directory is small on purpose. Five short files cover the rules that matter for this app at this stage: who owns it, how it's tagged, how it gets deployed, what it costs, and what's expected after deploy. Anything bigger should earn its place by removing real friction.
