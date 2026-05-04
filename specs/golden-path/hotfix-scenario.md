# Hotfix Scenario — Diacritic Drift

> Stage 10's safe, fast failure scenario. One character to break, one
> character to fix. Demonstrates the path under stress: a small, localised
> change ships through CI → smoke → red → revert → green in under five
> minutes. Task: T10.2.

## Story

The smoke-test job in `deploy.yml` asserts:

```text
.city == "Brasov" and .timezone == "Europe/Bucharest"
```

A "well-meaning" PR fixes the city name to use the proper Romanian
diacritic, `Brașov`. The change is a one-character edit in
`@c:/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App/server.js`. CI passes (it never asserted the
diacritic). On deploy, the smoke-test asserts `city == "Brasov"` and the
job goes red. We revert the one character and redeploy. Smoke green.
The audit trail is two short PRs.

This is intentionally **not** a security incident, **not** a config
mistake, and **not** a flaky test. It is the kind of small, plausible
content change that real teams ship every week — the golden path catches
it because the smoke test asserts the *data*, not just the status code.

## Pre-staged branches

Both branches are authored and *waiting locally* before the talk. Pushing
them on stage is the only live action.

| Branch | Purpose | Push during |
|---|---|---|
| `hotfix/diacritic-break` | The break. One char in `App/server.js`. | Stage 10, ~26:00 |
| `hotfix/diacritic-fix`   | The revert. One char back. | Stage 10, ~28:00 |

## The break (one character)

```diff
-    city: 'Brasov',
+    city: 'Brașov',
```

Path: `@c:/Users/rvunvulea/Downloads/DevOps2026_Spec/DevOpsPro-Europe-2026/App/server.js`. Line containing `city:` inside the
`/sunset` handler.

The unit tests in `App_Test/tests/sunset.test.js` already use `'Brasov'`
in their assertion (`expect(res.body.city).toBe('Brasov')`), so this
break also fails CI — even better for the talk: red appears immediately,
before deploy is even dispatched.

## The fix (one character)

```diff
-    city: 'Brașov',
+    city: 'Brasov',
```

Same line. Just revert.

## On-stage timing (≈ 5 minutes)

| t+   | Action | Expected |
|---|---|---|
| 0:00 | "It's not a golden path until it survives a hotfix." | — |
| 0:15 | Push `hotfix/diacritic-break`; open PR | CI starts |
| 1:00 | CI red on the test assertion | Test fails |
| 1:30 | Show the diff (one character) | Audience sees the diacritic |
| 2:00 | Push `hotfix/diacritic-fix` to the same PR (or merge fix-PR) | CI starts |
| 3:00 | CI green | All tests pass |
| 3:15 | Actions → `deploy` → Run workflow → `dev` | Three jobs go green |
| 4:30 | `curl https://<APP_NAME>.azurewebsites.net/sunset` | JSON, `city: "Brasov"` |
| 4:45 | "And the path was the documentation." | End. |

## Why this scenario

- **Safe.** No infra change, no Azure resource churn, no secret rotation.
- **Fast.** One character. CI feedback in ~60s with the warm cache.
- **Visible.** The diacritic is legible from the back row.
- **Honest.** The smoke-test's data assertion is the real point of the
  whole talk: *signals that mean something*, not just HTTP 200.
- **Recoverable.** If anything goes sideways during the live break, the
  fix branch is one push away.

## Fallbacks

- **Wi-Fi dies between break and fix.** Switch to the pre-recorded
  screencast of the same flow; narration is identical.
- **CI queue stalls > 90s.** Open the previously-recorded run in a
  pinned tab; narrate over it; merge the fix when CI catches up.
- **Diacritic font missing on projector.** Mention it verbally
  ("Romanian diacritic on the s") and zoom in on the diff.
- **You forgot to pre-stage the branches.** The break diff is one line;
  type it live. The fix is the same line reverted. The whole point is
  that it's a one-character story.

## What this scenario does NOT demonstrate

- Rollback via `git revert` of a *merged* commit (the simpler path here is
  to push a fix to the same PR).
- Database migrations or stateful rollback — out of scope.
- Multi-environment promotion — there is only `dev`.
- Approval gates — `deploy.yml` is `workflow_dispatch` with no environment
  protection by design (constitution P-V).
