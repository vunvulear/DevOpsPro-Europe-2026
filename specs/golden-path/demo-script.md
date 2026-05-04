# Demo Script — Platform Engineering in 30 Minutes

> One-page on-stage script. Companion to `plan.md` (stage definitions) and
> `hotfix-scenario.md` (Stage 10 break/fix). Read top-to-bottom on stage.
> Each row: spoken cue → click/command → expected outcome → if-it-fails.
> Task: T10.1.

## Pre-flight (morning of the talk)

Tick every box before walking on stage:

- [ ] `az login` complete; subscription set; `az account show` returns the demo subscription.
- [ ] `~/.terraform.d/plugin-cache/` warm (`azurerm` plugin already downloaded).
- [ ] **Pre-deploy run is green** earlier today so the live deploy is an *update*, not a first-create.
- [ ] Browser tabs pinned, in this order:
    1. `https://github.com/<ORG>/<REPO>/actions` (Actions tab)
    2. The staged **Stage 5 PR** (SKU bump) — already has `terraform-plan` sticky comment
    3. The staged **Stage 10 hotfix PR** (break) — already authored, not yet pushed
    4. The pre-deploy green run from earlier today
    5. `https://<APP_NAME>.azurewebsites.net/sunset` — live URL
- [ ] Asciinema fallback open in a hidden window (Stage 1 cast).
- [ ] Timer running on second screen — 30:00 countdown.
- [ ] Wi-Fi tethering hotspot ready as backup.
- [ ] Conference Wi-Fi tested with `curl /sunset`.

## On-stage script

### Stage 1 — Existing app baseline (2:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Real workload, already tested." | Open `App/server.js` | 56 lines on screen | Switch to asciinema cast |
| "Tests are green." | `npm test` in `App_Test/` | All tests pass in ~2s | Asciinema cast |
| "And it serves." | `curl localhost:3000/sunset` | JSON, `city: "Brasov"` | Asciinema cast |

### Stage 2 — CI (3:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Every PR builds and tests." | Open `.github/workflows/ci.yml` | One screen, header comment visible | — |
| "Here's it red, here's it green." | Show pre-recorded red→green PR (T2.2 screenshots) | Both screenshots | — |

### Stage 3 — Security scanning (3:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Four scanners, one workflow." | Open `.github/workflows/security.yml` | One screen | — |
| "Findings are signal, not gates." | Open Security tab → SARIF findings | At least one Trivy entry | Pre-screenshot |
| "Checkov is soft-fail. Visibility over enforcement." | Highlight `soft_fail: true` | — | — |

### Stage 4 — Terraform infrastructure (4:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Seven small files." | `ls infra/terraform/` | Six `.tf` + `environments/` | — |
| "Three resources." | Open `main.tf` | RG + plan + Web App on screen | — |
| "Hardened by default." | Highlight `https_only`, TLS 1.2, FTPS off, websockets off | — | — |
| "Tagged by default." | Show `local.common_tags` | Five keys | — |

### Stage 5 — Terraform validate + plan (3:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Validate runs everywhere, even on forks." | Open `terraform.yml`, highlight `validate` job | No auth | — |
| "Plan runs only with vars set." | Highlight `if: ${{ vars.AZURE_CLIENT_ID != '' }}` | — | — |
| "Here's a real plan." | Open staged Stage 5 PR | `terraform-plan` sticky comment with diff | Screenshot fallback |

### Stage 6 — Azure App Service deployment (4:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Manual, observable, OIDC." | Open `deploy.yml`; show `workflow_dispatch` only | — | — |
| "Run it." | Actions → `deploy` → **Run workflow** → `dev` | Three jobs go green | Switch to pinned pre-deploy tab |
| "Smoke asserts the data, not just the status." | Highlight `jq -e '.city == "Brasov"'` | — | — |
| "And it's live." | `curl https://<APP_NAME>.azurewebsites.net/sunset` | JSON | Pinned live-URL tab |

### Stage 7 — Platform policies (2:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Five short files. Rules of the road." | `ls platform/policies/` | Five entries | — |
| "Honest about what's enforced." | Open `policy-guardrails.md` | Enforced/Documented/Planned column | — |

### Stage 8 — Cost awareness (2:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "No tokens, no fake dollars." | Open `cost.yml` | One job, sticky comment | — |
| "Here's it on the staged PR." | Switch to Stage 5 PR | `cost-checklist` comment with SKU diff | Screenshot fallback |

### Stage 9 — Operational readiness (2:00)

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "Health, logs, rollback." | Open `platform/runbook.md` | One page, three sections | — |
| "Logs, the Azure-native way." | `az webapp log tail -g <RG> -n <APP_NAME>` while curling `/sunset` | Live log line for the request | Screenshot of a previous tail |

### Stage 10 — Demo flow / hotfix (5:00)

> See `hotfix-scenario.md` for the exact diff. Story: smoke-test asserts
> `city == "Brasov"`; we change the response to `"Brașov"` (with diacritic);
> CI smoke goes red; we revert one character; smoke goes green. One
> character to break, one character to fix.

| Cue | Action | Expected | If-it-fails |
|---|---|---|---|
| "It's not a golden path until it survives a hotfix." | Push the staged break PR | CI red (smoke fails) | Pre-recorded screencast |
| "One character." | Show the diacritic diff | — | — |
| "Revert. Redeploy. Smoke green." | Push the fix; re-dispatch `deploy` | Smoke green | Pre-recorded screencast |
| "And the path was the documentation." | Land on the live URL | JSON response | Pinned live-URL tab |

## Hard rules during the talk

- Never edit anything live that isn't on the script.
- If a step takes more than 30s of dead air, switch to its fallback without
  comment.
- Park audience questions until the last 5 minutes (buffer borrowed from
  hotfix slack only when necessary).
- If Wi-Fi dies: switch to tethering hotspot. If that also dies: switch to
  the asciinema/screencast fallback and keep narrating.

## Time-overrun strategy (if at 25:00 and only at Stage 7)

Sacrifice in this order to stay under 30:00:

1. Skip Stage 8 narration; show the comment for 10s and move on.
2. Skip Stage 9 `az webapp log tail` demo; keep the runbook open as a slide.
3. Compress Stage 10 to "break + fix, no narration" — one character each way.
