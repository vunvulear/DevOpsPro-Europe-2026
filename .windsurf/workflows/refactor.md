---
description: Refactor code without changing observable behavior. Use to improve structure, naming, or readability.
---

## User Input

```text
$ARGUMENTS
```

## Steps

1. Confirm the refactor target (file, module, or function) and the goal (readability, structure, dedup).
2. State the invariant: external behavior and public API must not change.
3. Ensure tests exist and pass BEFORE refactoring. If coverage is missing, add characterization tests first.
4. Apply the refactor in small steps. Do not mix in feature changes or bug fixes.
5. Re-run `npm test` from `App_Test/`. All previously passing tests must still pass.
6. Update spec/plan only if internal architecture notes are documented there.
7. Suggest a commit message: `refactor(<area>): <short summary>`.
