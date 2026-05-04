# Demo-Readiness Requirements Quality Checklist

> **Purpose:** Unit tests for the *talk-readiness requirements* in `spec.md`
> and `plan.md` — covering the 30-minute time budget, per-stage live risks
> and fallbacks, the hotfix scenario, and pre-flight expectations. Validates
> how the requirements are **written**, not whether the demo will succeed.
>
> **Audience:** Speaker rehearsing the talk; co-presenter / room operator
> reviewing the demo plan.
> **Depth:** Standard.

## Requirement Completeness

- [ ] CHK001 — Is a per-stage time budget defined for *all ten* stages, summing to ≤ 30 minutes? [Completeness, Plan §Demo time budget]
- [ ] CHK002 — Does every stage in `plan.md` define all six required fields (goal, files, expected outcome, what to show live, live-demo risk, fallback)? [Completeness, Plan §Stages 1–10]
- [ ] CHK003 — Are pre-flight requirements enumerated (`az login`, plugin cache warm, pre-deploy, staged PRs, asciinema fallback, timer)? [Completeness, Plan §Stage 10]
- [ ] CHK004 — Is the hotfix scenario's break/fix delta specified down to the character? [Completeness, Plan §Stage 10]
- [ ] CHK005 — Are requirements defined for **post-talk cleanup** (de-provision, revoke OIDC creds)? [Completeness, Gap]
- [ ] CHK006 — Are requirements defined for what to do if the talk **runs short** (5–10 min remaining)? [Completeness, Gap]

## Requirement Clarity

- [ ] CHK007 — Is "30 minutes on a warm cache" defined precisely (which caches: npm, Terraform plugin, Trivy DB, browser)? [Clarity, Spec §Acceptance #6]
- [ ] CHK008 — Is "warm cache" reproducible from the pre-flight checklist alone? [Clarity, Plan §Stage 10]
- [ ] CHK009 — Is "≤ 5 minutes of human time per typical change" defined as wall-clock or speaker-active time? [Clarity, Spec §Goal]
- [ ] CHK010 — Is "small change" exemplified concretely (e.g. one-line message edit, one-character assertion fix)? [Clarity, Spec §Goal]
- [ ] CHK011 — Is the difference between **live deploy** and **pre-deployed update** explicitly framed for the audience? [Clarity, Plan §Stage 6 fallback]

## Requirement Consistency

- [ ] CHK012 — Do the time budgets in `plan.md` and any later `demo-script.md` agree to the minute? [Consistency, Plan §Demo time budget]
- [ ] CHK013 — Is the smoke-test assertion (`city == "Brasov"`) consistent across spec, plan, and the hotfix scenario (intentional drift to `"Brașov"`)? [Consistency, Spec §Deployment, Plan §Stage 10]
- [ ] CHK014 — Are fallbacks per stage consistent in form (named medium: pre-recorded cast, screenshot, pinned tab)? [Consistency, Plan §Stages 1–10]
- [ ] CHK015 — Does each stage's "what to show live" align with the matching "live-demo risk" — i.e. do the things shown match the things that can fail? [Consistency, Plan §Stages 1–10]

## Acceptance Criteria Quality

- [ ] CHK016 — Can "complete demo flow runs end-to-end in ≤ 30 minutes" be measured during rehearsal (timestamped checkpoints)? [Measurability, Spec §Acceptance #6]
- [ ] CHK017 — Can "every workflow file fits on one screen" be measured (line count threshold, screen resolution assumption)? [Measurability, Spec §Acceptance #3]
- [ ] CHK018 — Are the success conditions for the hotfix scenario stated (CI red within X seconds, fix green within Y seconds)? [Measurability, Plan §Stage 10]

## Coverage / Scenario Classes

- [ ] CHK019 — Are requirements specified for the **conference Wi-Fi failure** scenario (offline fallback path)? [Coverage, Recovery, Plan §Stage 10 risk]
- [ ] CHK020 — Are requirements specified for the **GitHub Actions queue stalls** scenario (>2 min wait)? [Coverage, Plan §Stage 2 risk]
- [ ] CHK021 — Are requirements specified for the **Azure Portal blade outage** scenario (logs unreachable)? [Coverage, Plan §Stage 9 risk]
- [ ] CHK022 — Are requirements specified for **audience question overrun** consuming the buffer? [Coverage, Plan §Stage 10 risk]
- [ ] CHK023 — Are requirements defined for **time overrun beyond Stage 8** (which stages are sacrificable)? [Coverage, Gap]
- [ ] CHK024 — Are requirements defined for the **demo machine crashes** worst case? [Coverage, Recovery, Gap]

## Edge Cases

- [ ] CHK025 — Is behaviour specified when the cold-start retry budget for the smoke test is exceeded *during* the live deploy? [Edge Case, Plan §Stage 6]
- [ ] CHK026 — Is behaviour specified when a CVE published the morning of the talk pushes Trivy/audit over threshold? [Edge Case, Plan §Stage 3 fallback]
- [ ] CHK027 — Is behaviour specified when the staged "Stage 5" PR shows an unexpected diff (drift)? [Edge Case, Plan §Stage 5 fallback]
- [ ] CHK028 — Is behaviour specified when the asciinema fallback is itself broken? [Edge Case, Gap]

## Non-Functional

- [ ] CHK029 — Are cognitive-load requirements addressed (one-page script, one-screen files)? [NFR, Plan §Cross-cutting]
- [ ] CHK030 — Are accessibility requirements for the live demo addressed (font size, terminal contrast, narration over screen actions)? [NFR, Gap]
- [ ] CHK031 — Are recording / replay requirements specified (will the talk be recorded; does that change any fallback)? [NFR, Gap]

## Dependencies & Assumptions

- [ ] CHK032 — Is the assumption "warm cache" possible at venue (no fresh laptop) stated? [Assumption, Spec §Acceptance #6]
- [ ] CHK033 — Is the dependency on `az login` session not expiring mid-talk addressed? [Dependency, Plan §Stage 9 fallback]
- [ ] CHK034 — Is the dependency on a pre-deploy *the same day* documented as required, not optional? [Dependency, Plan §Stage 6 fallback]
- [ ] CHK035 — Is the assumption that the audience knows the spec/plan/tasks framework explicit, or do you need a 30-second framing slide? [Assumption, Gap]

## Ambiguities & Conflicts

- [ ] CHK036 — Does "no PowerPoint" (talk title implication) conflict with the need for a framing slide (CHK035)? [Conflict, Spec §Goal]
- [ ] CHK037 — Does "5-minute Q&A buffer borrowed from hotfix slack" conflict with the hotfix being mandatory in the demo? [Conflict, Plan §Stage 10]
- [ ] CHK038 — Is the term "small change" used consistently with the hotfix's character-level edit, or do they refer to different shapes of change? [Ambiguity, Spec §Goal, Plan §Stage 10]
- [ ] CHK039 — Is the precedence between **"under 5 min human time"** (spec) and **30-min total budget** (plan) clear when they would conflict? [Ambiguity, Spec §Goal, Plan §Demo time budget]
