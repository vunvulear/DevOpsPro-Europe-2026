# Hotfix prompt — failing golden path

Paste the prompt below into Cascade (with the `/hotfix` workflow) when a
golden-path check fails on a PR or `main`. It is intentionally short and
asks for the **smallest safe fix**, not a refactor.

See [`platform/docs/hotfix-demo.md`](../platform/docs/hotfix-demo.md) for the
recommended live demo scenario (smoke-test diacritic drift).

## Prompt to paste into Cascade

```text
A check on the golden path is failing. Apply the smallest safe fix.

1. Inspect the failing check.
   - Read the latest failed run for this branch (CI, security, terraform-plan,
     deploy/smoke-test, or cost-awareness — whichever is red).
   - Quote the exact failing step and the relevant lines from the log.

2. Identify the root cause.
   - State the upstream cause in one sentence.
   - Do NOT patch a symptom downstream if the upstream cause is fixable.

3. Make the smallest safe fix.
   - One file if possible, one line if possible.
   - Do not refactor, rename, or reformat unrelated code.
   - Preserve the golden path principles:
     * no secrets in the repo
     * no hardcoded Azure subscription/tenant/client IDs
     * no broadening of workflow permissions
     * no weakening of tests, security checks, or required tags
     * keep workflows readable and demo-friendly

4. Add or update the smallest test / assertion that would have caught this.
   - In `App_Test/` for app bugs.
   - In a workflow assertion (e.g. smoke step) for contract drift.
   - Skip this step if a regression test would be larger than the fix itself —
     and say so explicitly.

5. Explain the change.
   - One paragraph: what was broken, what you changed, why it is the smallest
     safe fix, and what you intentionally did NOT change.
   - Suggest a commit message: `hotfix(<area>): <short summary>`.
   - Suggest a branch name: `hotfix/<short-slug>`.

Constraints:
- Stay on a hotfix branch; do not push to `main`.
- Do not touch unrelated files.
- If the fix is not obvious within ~60 seconds of investigation, stop and ask
  the user to confirm the direction before editing.
```

## Why this prompt looks the way it does

- **Numbered steps** keep Cascade from running off in five directions.
- **"Smallest safe fix"** is explicit so the agent doesn't refactor while the
  audience is watching.
- **Golden path principles** are listed verbatim so the fix can't accidentally
  delete a guardrail under pressure.
- **Regression test guidance** prevents a 5-line fix from triggering a 50-line
  test rewrite live on stage.
- **The 60-second escape hatch** keeps the demo on time. If Cascade can't see
  the cause, it asks instead of guessing.
