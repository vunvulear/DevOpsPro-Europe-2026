---
description: Modify an existing feature in a small, spec-aware way. Use when the change is intentional and scoped, not an emergency.
---

## User Input

```text
$ARGUMENTS
```

## Steps

1. Identify the affected spec under `specs/` (e.g. `specs/golden-path/`). If none exists, ask the user which feature this modification belongs to.
2. Summarize the requested change in 2-4 bullet points and confirm with the user before editing code.
3. Update the relevant `spec.md` / `plan.md` / `tasks.md` sections so the spec stays the source of truth.
4. Implement the minimal code change. Avoid drive-by refactors.
5. Update or add tests in `App_Test/` covering the modified behavior.
6. Run `npm test` from `App_Test/` and report results.
7. Suggest a clear commit message: `modify(<area>): <short summary>`.
