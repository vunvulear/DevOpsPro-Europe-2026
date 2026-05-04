# Infrastructure-as-Code Requirements Quality Checklist

> **Purpose:** Unit tests for the *Terraform / Azure App Service requirements*
> in `spec.md` and `plan.md` — covering module shape, hardening defaults,
> tagging, validation/plan flow, and cost-aware SKU selection. Validates how
> the requirements are **written**, not whether the implementation works.
>
> **Audience:** PR reviewer for any change under `infra/terraform/` or the
> `terraform.yml` / `cost.yml` workflows.
> **Depth:** Standard.

## Requirement Completeness

- [ ] CHK001 — Are the three required Azure resources (Resource Group, Linux App Service Plan, Linux Web App) named exhaustively in the spec? [Completeness, Spec §IaC]
- [ ] CHK002 — Are all five required tag keys (`project`, `environment`, `owner`, `managed_by`, `repo`) listed with their value sources? [Completeness, Spec §IaC]
- [ ] CHK003 — Are all six hardening attributes (`https_only`, TLS 1.2 min, FTPS disabled, HTTP/2 on, websockets off, remote debugging off) enumerated? [Completeness, Spec §IaC]
- [ ] CHK004 — Are the seven Terraform files (`versions`, `providers`, `variables`, `locals`, `main`, `outputs`, `environments/dev.tfvars`) each given a defined responsibility? [Completeness, Plan §Stage 4]
- [ ] CHK005 — Are required Terraform variables typed (string / map / number) in the spec, or only named? [Completeness, Gap]
- [ ] CHK006 — Are health-check requirements paired with the corresponding app-side endpoint (`/healthz`)? [Completeness, Spec §IaC, §Operational readiness]
- [ ] CHK007 — Are requirements defined for the *absence* of a remote backend (i.e. local state is intentional, not an oversight)? [Completeness, Spec §IaC]

## Requirement Clarity

- [ ] CHK008 — Is "minimal hardening" quantified by the explicit attribute list, or left to reviewer interpretation? [Clarity, Spec §In scope]
- [ ] CHK009 — Is "required tags" defined as a *failure-blocking* contract or only a convention? [Clarity, Spec §IaC]
- [ ] CHK010 — Is "fits in seven files" measured by *top-level* files, *all files including environments/*, or *non-empty files*? [Clarity, Ambiguity, Spec §Acceptance #4]
- [ ] CHK011 — Is the `azurerm` provider major version constraint stated in the spec, or deferred entirely to the plan? [Clarity, Plan §Open items]
- [ ] CHK012 — Is "placeholder values only" in `dev.tfvars` defined precisely (e.g. `<APP_NAME>` literal vs a fictitious-but-real-looking string)? [Clarity, Plan §Stage 4]

## Requirement Consistency

- [ ] CHK013 — Do the spec's tag list and the plan's `locals.common_tags` list match exactly in keys and casing? [Consistency, Spec §IaC, Plan §Stage 4]
- [ ] CHK014 — Are hardening attributes consistently named between spec ("TLS 1.2 min") and plan (`minimum_tls_version = "1.2"`)? [Consistency, Spec §IaC, Plan §Stage 4]
- [ ] CHK015 — Does the spec's "single Terraform stack" align with the plan's per-environment `tfvars` approach without implying multi-stack? [Consistency, Spec §IaC, Plan §Stage 4]
- [ ] CHK016 — Are SKU expectations consistent between `cost-policy.yaml` (Stage 7) and `dev.tfvars` defaults (Stage 4)? [Consistency, Plan §Stage 7/Stage 8]

## Acceptance Criteria Quality

- [ ] CHK017 — Can "provisions the App Service from `dev.tfvars` with no further inputs" be objectively verified (e.g. `terraform plan` exit code, no prompts)? [Measurability, Spec §Acceptance #4]
- [ ] CHK018 — Can "Terraform validate green on day one with no setup" be measured on a fork without Azure credentials? [Measurability, Spec §Acceptance #1]
- [ ] CHK019 — Are Terraform validation success conditions for `fmt`, `init -backend=false`, and `validate` each defined? [Measurability, Plan §Stage 5]

## Coverage / Scenario Classes

- [ ] CHK020 — Are requirements specified for the **fork without Azure vars** scenario (validate runs, plan skips clean)? [Coverage, Plan §Stage 5]
- [ ] CHK021 — Are requirements specified for the **provider download fails / cache cold** scenario? [Coverage, Recovery, Plan §Stage 4]
- [ ] CHK022 — Are requirements specified for **Azure quota / region capacity** failure on first apply? [Coverage, Exception, Plan §Stage 6]
- [ ] CHK023 — Are requirements specified for the **`tfvars` parse error** scenario in the cost-comment job? [Coverage, Plan §Stage 8]
- [ ] CHK024 — Are requirements defined for **multi-environment** behaviour even though `test`/`prod` are out of scope (e.g. variable shape forward-compatible)? [Coverage, Spec §Out of scope]

## Edge Cases

- [ ] CHK025 — Is behaviour specified when a tag value contains characters Azure rejects? [Edge Case, Gap]
- [ ] CHK026 — Is behaviour specified when `app_name` collides with an existing Azure global name? [Edge Case, Gap]
- [ ] CHK027 — Is behaviour specified when the `locals.common_tags` map is missing one of the five required keys? [Edge Case, Gap]
- [ ] CHK028 — Is behaviour specified when `health_check_path` returns 5xx during a deploy? [Edge Case, Plan §Stage 6, §Stage 9]

## Non-Functional

- [ ] CHK029 — Are deploy-time budgets defined for `terraform plan` and `apply` so they fit the live-demo budget? [NFR, Plan §Demo time budget]
- [ ] CHK030 — Are state-locking expectations stated *as a known omission* (single user, demo-only)? [NFR, Spec §IaC]
- [ ] CHK031 — Are observability requirements explicitly out of scope for the IaC layer (no diagnostic settings)? [NFR, Spec §Out of scope]

## Dependencies & Assumptions

- [ ] CHK032 — Is the dependency on `azurerm` (vs `azapi`) documented, with rationale? [Dependency, Gap]
- [ ] CHK033 — Is the assumption that the subscription has Linux App Service quota in the chosen region validated before the talk? [Assumption, Plan §Stage 4 risk]
- [ ] CHK034 — Is the dependency on Node LTS runtime alignment between `App/` and `azurerm_linux_web_app.site_config.application_stack` stated? [Dependency, Plan §Stage 4]

## Ambiguities & Conflicts

- [ ] CHK035 — Does the spec's "intentionally simplified" framing protect every individual simplification (local state, no slots, single env), or only some? [Ambiguity, Spec §Non-goals]
- [ ] CHK036 — Does the requirement for **immutability of resource names** conflict with the need for **placeholder names** in `dev.tfvars`? [Conflict, Plan §Stage 4]
- [ ] CHK037 — Is the boundary between *platform policy* (Stage 7) and *Terraform module* (Stage 4) for tag enforcement defined, or do they overlap? [Ambiguity, Conflict, Spec §IaC, §Platform policies]
