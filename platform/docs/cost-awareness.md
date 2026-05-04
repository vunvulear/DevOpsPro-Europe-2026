# Cost Awareness

Cost is the fifth capability of the golden path. The goal is **visibility before
spend**, not micro-optimization. The rule of thumb: a developer should see the
cost impact of an infrastructure change in the same PR where they review the
correctness and security impact.

Reference policy: [`platform/policies/cost-policy.yaml`](../policies/cost-policy.yaml).

## App Service Plan SKU selection

The Brașov Sunset API runs on a Linux App Service Plan whose SKU is set
**explicitly** via `var.sku_name` in `infra/terraform/variables.tf`. There is no
provider default fallthrough — choosing a SKU is a deliberate decision.

Common Linux tiers and when to consider them:

| SKU | Typical use | Notes |
|---|---|---|
| `F1` | Throwaway experiments | Free tier; `always_on` not supported, cold starts hurt UX. |
| `B1` | Dev / small demos | Cheapest reasonable tier; one small instance. |
| `S1` | Light production | Adds custom domains/SSL, deployment slots, manual scale. |
| `P1v3` | Production | Better CPU/memory, zone redundancy options, recommended baseline. |
| `P2v3` / `P3v3` | Higher load | Scale up before scaling out for CPU-bound apps. |

Pricing changes over time and varies by region — always verify against the
[Azure pricing calculator](https://azure.microsoft.com/pricing/calculator/) for
the **target region** before settling on a tier. We deliberately avoid quoting
hard dollar values in this repo.

## Environment-specific sizing

Defaults from `cost-policy.yaml`:

- `dev` → `B1`
- `test` → `B1`
- `prod` → `P1v3` (starting point; revisit per workload SLO)

Sizing rules of thumb:

- **Don't pay for `always_on` you don't need.** `B1` is fine for low-traffic dev.
- **Match SKU to SLO**, not to "the team next door". A demo API doesn't need `P3v3`.
- **Prefer scale-out over scale-up** for stateless web apps once a single instance is saturated.
- **Right-size on review cadence.** Every quarter, look at Cost Management metrics for under-utilized plans.

## Owner / project tags for cost allocation

Cost is allocated by the tags applied via Terraform `local.common_tags` in
`infra/terraform/main.tf`:

- `project` → which logical service the cost belongs to.
- `environment` → split spend across `dev` / `test` / `prod`.
- `owner` → which team is accountable.
- `managed_by = "terraform"` and `repo` → which automation produced the resource.

In Azure Cost Management you can group by these tags directly to answer:
"how much does the Brașov Sunset API cost in `dev` this month?".

These are aspirational on resources created out-of-band (portal clicks); only an
Azure Policy "Append a tag" or "Require a tag" rule makes them universal — out
of scope for this demo, called out as future work.

## Why cost must be visible before deployment

- **Review parity.** Cost is a code-review concern in the same way correctness
  and security are. Surprises at month end are platform team's problem AND
  developer's problem; both should see them at PR time.
- **Decisions are cheap on a PR, expensive in production.** A SKU change is one
  variable today; in a busy month it's an emergency.
- **Tags only help if cost is mapped to them.** Visibility on the PR forces the
  team to assign `owner`/`project` correctly because the number lands on
  someone's chart.
- **No surprises = trust.** Developers trust the platform when the platform
  doesn't drop a bill on them.

## What this repo ships today

| Capability | Status | Where |
|---|---|---|
| Explicit SKU selection | Enforced | `var.sku_name` in `infra/terraform/variables.tf` |
| Required cost-allocation tags | Enforced for Terraform-managed resources | `local.common_tags` in `main.tf` |
| Per-environment SKU defaults | Documented | `cost-policy.yaml` `defaults.app_service_plan` |
| Per-environment budgets | Placeholder | `cost-policy.yaml` `monthly_budget_usd` |
| Cost comment on PRs | Lightweight reminder via GitHub Actions | `.github/workflows/cost-awareness.yml` |
| Hard cost numbers | **Intentionally not provided** | Use the Azure pricing calculator + Cost Management |

## What would be added later

### Infracost (PR-time monthly cost diff)

```yaml
# .github/workflows/cost-infracost.yml (future)
- uses: infracost/actions/setup@v3
- run: infracost breakdown --path infra/terraform --terraform-var-file environments/dev.tfvars --format json --out-file infracost.json
- uses: infracost/actions/comment@v3
  with:
    path: infracost.json
    behavior: update
```

Requires `INFRACOST_API_KEY` (free for OSS) as a GitHub Secret. We don't ship it
in this repo to keep the demo secret-free.

### Azure Cost Management

- **Budgets** per resource group / subscription with email + Action Group
  alerts, populated from `cost-policy.yaml.monthly_budget_usd`.
- **Cost views** grouped by the tags above (`project`, `environment`, `owner`).
- **Anomaly alerts** for spend deviating from the rolling 30-day baseline.

These live in Azure, not in this repo. The repo provides the tag scaffolding;
Cost Management slices spend by it.

### Policy enforcement

- **Block SKU changes without justification.** Custom check on `terraform plan`
  JSON that fails when `sku_name` changes and the PR description has no
  `Cost-Justification:` section.
- **Block missing cost comment.** Required check that the cost workflow has
  posted on the PR.

## How to run cost awareness in this repo today

1. Open a PR that touches `infra/terraform/` (e.g. change `sku_name` in `environments/dev.tfvars`).
2. The `Cost Awareness` workflow comments on the PR with:
   - the detected `sku_name` per environment file,
   - a pointer to the Azure pricing calculator,
   - the cost-policy expectations.
3. Reviewer asserts the change is intentional, documented in the PR description, and within the team's budget.

The comment is a **reminder**, not a calculator. Real numbers come from
Infracost / Azure Cost Management when the team is ready to wire them up.
