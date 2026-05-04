# Hotfix Demo — Smoke Test Misconfigured

A small, safe failure scenario for the live demo.
**Goal:** show that the golden path catches a real divergence in seconds, and the fix is one line.

## Scenario

The `smoke-test` job in `.github/workflows/deploy-azure-app-service.yml` asserts
that `GET /sunset` returns a body containing the city name. We tweak the
assertion so it expects the city with a Romanian diacritic — `"Brașov"` — while
the API actually returns `"Brasov"` (ASCII, no diacritic).

This is the kind of harmless drift that happens when documentation and code
disagree. It's safe, fast to find, and one character to fix.

## Broken state (what to commit on the demo branch)

In `.github/workflows/deploy-azure-app-service.yml`, inside the `smoke-test`
job's "GET /sunset and assert payload" step, change:

```yaml
grep -q '"city": *"Brasov"'  /tmp/sunset.json
```

to:

```yaml
grep -q '"city": *"Brașov"'  /tmp/sunset.json
```

Nothing else changes. The app is healthy, deploys fine, returns its real
payload — only the smoke test thinks the contract is different from what was
deployed.

## How the failure is detected

1. **CI is green.** Tests pass — the app itself is fine.
2. **`Deploy to Azure App Service` runs.** Build OK. OIDC login OK. Deploy OK.
3. **`smoke-test` job fails** on the `GET /sunset and assert payload` step.
   The job log shows the actual JSON (with `"Brasov"`) right before the failed
   `grep`, so the divergence is obvious from the logs alone.
4. The workflow goes red; the deploy commit is flagged.

## How to fix it (live)

**One line.** Open `.github/workflows/deploy-azure-app-service.yml`, change the
assertion back to `"Brasov"` (no diacritic). Commit, push, re-run the deploy
workflow — smoke test goes green.

In the talk, you can use the `/hotfix` Cascade workflow:

1. Open Cascade.
2. Run `/hotfix` and paste the failing workflow URL.
3. Cascade reads the failing step's log, identifies the diacritic mismatch,
   proposes a one-character fix, runs the test/local smoke if applicable.
4. Commit on a `hotfix/sunset-smoke-assertion` branch, open the PR, watch the
   golden path light up green again.

## What to say during the talk

- "Notice the deploy succeeded. Notice the smoke test didn't." — slow down here.
- "This is exactly the kind of drift you want a smoke test to catch: code and
  contract disagree on something tiny."
- "We have one workflow, one log, one line to fix. No alerting platform, no
  paging, no 30-minute incident bridge."
- "And because the path is the product — the same CI, security, plan, and cost
  checks run on the hotfix PR — there's no temptation to skip them under
  pressure."
- Close on: "A golden path doesn't prevent every mistake. It makes the next one
  cheap to find and cheap to undo."

## Fallback strategy

- **Pre-build branch** `demo/hotfix-ready` with the broken assertion already in
  place, so you don't have to introduce the bug live.
- **Pre-build branch** `demo/hotfix-fixed` with the fix already applied, in case
  the live edit takes too long.
- **Backup screen capture** of the failing `smoke-test` log (the JSON line right
  next to the failing `grep`) — show it if Azure App Service is slow / cold and
  the live deploy can't finish in time.
- **Can't reach Azure?** The same demo works against any URL: pass `webapp_url`
  as a workflow input pointing at a previously-deployed copy, or even at a
  small mock server you ran locally with `ngrok` — the smoke step is just `curl`.

## Why this scenario was chosen

- ✅ Safe — no real secret, no real vulnerability, no destructive change.
- ✅ Fast — one character to break, one character to fix.
- ✅ Clear — the failure is in *one* step, with the actual response right above
  the failing assertion in the log.
- ✅ On-message — it tells the "smoke tests catch contract drift" story without
  needing to invent a contrived bug in the application code.
- ✅ Repeatable — if the live demo fails, you reset by checking out the fixed
  branch and re-running the deploy workflow.

## What we deliberately did **not** pick

- **Missing service metadata** — nothing in this repo enforces it yet, so the
  failure wouldn't be visible.
- **Missing tag in Terraform** — Checkov runs in `soft_fail` mode for the
  demo; it would annotate, not fail.
- **Missing required GitHub variable** — too vague on stage; the audience sees
  a skip, not a red check, which weakens the story.
- **Wrong `health_check_path`** — would break the App Service traffic gating
  in a way that could take minutes to recover; not a 30-second hotfix.
- **A real app bug** — fine for a longer talk, too easy to over-explain in 30
  minutes.
