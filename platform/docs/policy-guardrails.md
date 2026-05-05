# Policy Guardrails

This page describes the lightweight platform policies that live under
[`platform/policies/`](../policies). They are part of the golden path
because they make the non-negotiables explicit, reviewable, and close
to the developer workflow.

## What is a guardrail?

A guardrail is a rule that:

- is **discoverable** in the repository,
- is **explainable** in plain language,
- is **automated where it is cheap** to automate,
- and is **reviewable as code** even when enforcement is manual.

Guardrails are not a substitute for trust or judgement. They make
the default path safe and the unsafe paths visible.

## Why guardrails belong close to the developer workflow

- Developers see them while they work (in the repo, in PRs, in CI).
- Changes to guardrails follow the same review process as code.
- New team members onboard by reading the policies, not by waiting
  for tribal knowledge.
- Platform engineers can iterate on guardrails without rolling out
  new tooling each time.

## Policies in this repository

| File                         | Kind                | Status               |
|------------------------------|---------------------|----------------------|
| `service-metadata.yaml`      | Service contract    | Documented           |
| `tagging-policy.yaml`        | Tag rules           | Implemented in IaC   |
| `deployment-policy.md`       | Deployment rules    | Workflow-enforced    |
| `cost-policy.yaml`           | Cost & SKU rules    | Documented           |

## Documented vs enforceable

Most policies in this demo are **documented only** today, with hooks
into existing workflows where it is cheap.

| Policy          | Today                        | Could enforce in CI/CD with    |
|-----------------|------------------------------|--------------------------------|
| Tagging         | Terraform `local.common_tags`| Checkov / OPA                  |
| Deployment      | `workflow_dispatch` only     | Branch protection + env gates  |
| Cost / SKU      | Variables and reviewer notes | Infracost + OPA on plan        |
| Service metadata| YAML file in the repo        | Backstage-style validation     |

## What is intentionally simplified

- **No central policy engine.** Pure files in the repo. Enough for
  one service and a 30-minute demo.
- **No mandatory enforcement.** Real platforms should fail PRs that
  violate critical policies (e.g. missing tags, prod from a feature
  branch, Free SKU in prod).
- **No policy versioning.** Treated as living documents.
- **No self-service portal.** Policies are read directly from the
  repository.

## Roadmap

- Wire Checkov rules to enforce tagging on Terraform PRs.
- Add an Infracost step that comments cost diffs on PRs.
- Lift `service-metadata.yaml` into a Backstage / IDP catalog.
- Promote critical rules from documented to required CI checks.
