---
description: Apply an urgent production hotfix through the golden path. Optimized for the live demo scenario.
---

## User Input

```text
$ARGUMENTS
```

## Steps

1. Capture the incident in one line: symptom, impact, suspected area.
2. Create a hotfix branch: `hotfix/<short-slug>`.
3. Reproduce the issue with a failing test in `App_Test/` whenever feasible.
4. Apply the smallest possible code change that fixes the root cause. No refactors, no scope creep.
5. Run `npm test` and confirm green.
6. Add a short note under `specs/golden-path/` (or the relevant spec) describing the incident and fix, so the spec stays truthful.
7. Suggest a commit message: `hotfix(<area>): <short summary>` and remind the user that CI + Terraform plan + deploy workflows should run on the PR.
