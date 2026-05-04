---
description: Fix a non-urgent bug with proper test coverage and minimal change.
---

## User Input

```text
$ARGUMENTS
```

## Steps

1. Restate the bug: expected vs. actual behavior, reproduction steps.
2. Locate the root cause. Do NOT patch the symptom downstream if the upstream cause is fixable.
3. Add a failing test in `App_Test/` that captures the bug.
4. Apply the minimal fix. Prefer a one-line change when sufficient.
5. Run `npm test` and confirm the new test passes and nothing else broke.
6. If the bug reveals a spec gap, update the relevant file under `specs/`.
7. Suggest a commit message: `fix(<area>): <short summary>`.
