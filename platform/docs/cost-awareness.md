# Cost Awareness

Cost is a first-class concern in this golden path. The aim is not
exact numbers - it is making cost **visible and intentional** at the
moment a change is proposed.

The rules live in
[`platform/policies/cost-policy.yaml`](../policies/cost-policy.yaml).
The Terraform that enforces some of them lives in
[`infra/terraform/`](../../infra/terraform).

## App Service Plan SKU selection

The SKU is exposed as a Terraform variable (`sku_name`) so that:

- it shows up in PR diffs,
- it is part of the `terraform plan`,
- and it can be different per environment via `tfvars`.

`cost-policy.yaml` documents the expected defaults:

| Environment | Default SKU | Always-on |
|-------------|-------------|-----------|
| `dev`       | `B1`        | false     |
| `test`      | `B1`        | false     |
| `staging`   | `P1v3`      | true      |
| `prod`      | `P1v3`      | true      |

These are starting points, not contracts. Real workloads should
revisit them with traffic and SLO data.

## Environment-specific sizing

- **`dev` / `test`** are sized for *learning and CI*, not for
  performance. `B1` and `always_on = false` keep the bill close to
  the noise floor.
- **`staging`** mirrors `prod` for SKU and `always_on` so that
  pre-prod surprises are caught.
- **`prod`** uses an SKU intentionally - never Free or Shared.

## Tags for cost allocation

Every resource carries the same `local.common_tags` block from
`infra/terraform/main.tf`:

- `environment`
- `owner`
- `project`
- `managed_by = terraform`

These tags are what make Azure Cost Management slice and dice cost
by team and service. Tags are required by
[`tagging-policy.yaml`](../policies/tagging-policy.yaml).

## Why cost should be visible before deployment

- **PR review is the cheapest place to fix cost.** Once resources
  exist, fixing them costs change windows, downtime risk, and time.
- **`terraform plan` already shows the SKU change.** The reviewer
  just needs to know what to look for.
- **A rough estimate is better than no estimate.** Even
  `dev: B1, prod: P1v3` written down beats "the team will figure it
  out".

## What we do NOT do today

- We do **not** put fake currency numbers in the repo. They go stale
  immediately and create false confidence.
- We do **not** require Infracost tokens or paid SaaS accounts.
- We do **not** block PRs on cost - cost is part of review, not a
  hard gate.

## What would be added later

- **Infracost** PR comments showing the cost diff of a `terraform
  plan`. Free for self-hosted; no token needed for the FOSS CLI.
- **Azure Cost Management** dashboards filtered by `project` and
  `owner` tags.
- **Budgets and alerts** in Azure for non-prod and prod.
- **A monthly platform cost review** using the same tags.

## How this supports FinOps in a golden path

- **Inform.** Tags and SKU choices make cost attributable.
- **Optimize.** Per-environment sizing avoids paying for prod-grade
  capacity in dev.
- **Operate.** Cost is part of the platform's documented contract,
  not an afterthought.

## Optional: cost-awareness workflow

A minimal `.github/workflows/cost-awareness.yml` can be added later
if it is kept simple and useful (for example: a placeholder job
that prints the configured SKU and tags from `tfvars` on each PR).
It is intentionally **not** added in this iteration to avoid
shipping a fragile or noisy workflow.
