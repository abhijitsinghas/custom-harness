# Custom-Harness — Fresh Review & Gap Analysis

> Fresh look at the `custom-harness/` Flutter/Dart agent framework, verification of the previous
> Pi session's `HARNESS_UPDATE_PLAN.md`, and a prioritized improvement roadmap toward a robust,
> project-agnostic, autonomous Flutter-Android app builder.
>
> Method: read every agent/skill/doc in the harness, diff against the previous plan, and verify
> every tool/API assumption against the **actually-installed** Pi extensions
> (`pi-subagents@0.28.0`, `pi-ask-user@0.11.2`).
>
> Note: `the-little-library/v3` in this workspace is a **research sandbox**, not a target
> project. It is therefore *not* used as evidence of harness failure or of model-ID
> correctness. It is referenced only to describe the prior experimentation context.

---

## 1. Verification of the previous session's work

**Verdict: the previous session faithfully implemented its own plan. The writing quality is high
and the project-agnostic discipline is maintained. The plan's 9 gaps (G1–G9) are all addressed
in the files. The problem is that the plan itself was never validated against the real tooling
or run end-to-end.**

### What was correctly implemented (matches `HARNESS_UPDATE_PLAN.md`)

| Planned item | Status | Evidence |
|---|---|---|
| `pi/agents/visual-validator.md` + skill | ✅ created | vision loop, discrepancy report, iteration protocol |
| `pi/agents/architect.md` + `architecture-consistency-checker` skill | ✅ created | 9 checks, PASS/WARN/FAIL, read-only |
| `pi/skills/design-token-extractor` + `stitch-html-parser` | ✅ created | tailwind-config → `design_tokens.json` pipeline |
| `pi/skills/golden-test-generator` | ✅ created | light/dark baselines, immutable-mockup policy |
| `STITCH_PIPELINE.md`, `design-tokens-schema.md` | ✅ created | pipeline + schema docs |
| `AGENTS.md` extended (tokens, goldens, arch log, UI validation) | ✅ | all new fields present |
| `FRAMEWORK.md` updated pipeline + agent table | ✅ | visual loop + architect phases |
| `MODEL_STRATEGY.md` UI-critical tier + 4-model table | ✅ | tier mapping + escalation ladder |
| `orchestrator/SKILL.md` design-token phase + visual loop + arch check | ✅ | Phase 0/2/4 updates |
| `feature-agent.md` golden gen + token reading + arch log + visual iteration | ✅ | UI-critical protocol |
| `planner.md` token awareness + UI-critical annotation + golden planning | ✅ | tier rules |
| `reviewer.md` golden/token/arch-log verification | ✅ | blocker categories |
| `install.sh` new skills + verification step | ✅ | `OUR_CUSTOM_SKILLS`, `OFFICIAL_REQUIRED` |

### Where the previous session's verification stopped short

It never (a) checked that the orchestrator's `subagent({...})` calls match the **real**
`pi-subagents` package schema, (b) confirmed the hardcoded model IDs exist in the user's Pi
config, (c) deployed the harness into a target project, or (d) ran even one workstream through
the pipeline. The result is a well-written but **unvalidated** framework.

---

## 2. Critical gaps (with evidence)

### GAP-1 — No evidence of a validated end-to-end run in this workspace  *(CRITICAL — status, not failure)*

`the-little-library/v3` in this workspace is a **research sandbox**, not a target project, so
its state (no `.pi/agents`, no `.pi/skills`, older qwen/glm model config, non-git, no tests,
partial `lib/`) reflects the *prior experimentation*, **not** a deployment of the redesigned
harness. It must not be read as proof the harness fails.

The status finding that *does* hold: within this workspace I found **no record** of the
redesigned harness being installed into a target project and run end-to-end — no target
project, no run logs, no golden baselines, no review reports produced by the new pipeline.
That may simply be because target projects live outside this workspace. The implication is
**verification, not condemnation**: the framework's reliability claims are currently
unverified in any artifact I can inspect. The single most important next step is to install the
harness into an actual target project and run one workstream, capturing the produced
`plan.md`, `design_tokens.json`, golden PNGs, `ARCHITECTURE_LOG.md`, and `review.md` as the
first concrete evidence the pipeline works.

### GAP-2 — Hardcoded model IDs are not verified and not project-portable  *(CRITICAL)*

Agent frontmatter hardcodes:

- `openai-codex/gpt-5.5` (planner, feature-agent UI-critical, visual-validator, final review)
- `openai-codex/gpt-5.4` (reviewer)
- `opencode-go/deepseek-v4-pro` / `opencode-go/deepseek-v4-flash` (logic / mechanical)

`MODEL_STRATEGY.md` says "use `/models` as the source of truth," but the agents do not validate
these IDs at runtime. (The qwen/glm config seen in the v3 research sandbox is *not* used here
as evidence about these IDs — it predates the redesign.) The genuine issue: a
"project-agnostic" harness that hardcodes specific model IDs is **not model-portable** across
machines/providers. On any target project where those exact IDs are not configured, **every
dispatch fails at model resolution** with no graceful fallback.

Note: `pi-subagents@0.28.0` resolves a model string with an optional `:thinking` suffix
(`src/shared/model-info.ts: splitKnownThinkingSuffix`), e.g. `openai-codex/gpt-5.5:high`. This
is the clean way to encode both model + thinking in one field.

### GAP-3 — The framework reinvents reliability mechanisms that `pi-subagents@0.28.0` already provides  *(HIGH)*

I verified the **actual installed** package schema (`/tmp/pisub/package/src/extension/schemas.ts`).
The orchestrator's basic syntax is valid (`action:"status"`, `context:"fresh"`, `async:true`,
`agentScope` default `"both"`, `flutter-dev.<agent>` names — confirmed by
`identity.ts: buildRuntimeName`), but the harness ignores the tool's most powerful features:

| Native feature (pi-subagents) | What it does | Harness status |
|---|---|---|
| `acceptance` contract (`criteria`, `evidence`, `verify`, `review`, `stopRules`, `maxFinalizationTurns`) | Per-task definition-of-done with a **bounded self-review/repair loop** before the result is accepted. `evidence` kinds include `tests-added`, `commands-run`, `validation-output`; `verify` runs shell commands. | **Unused.** The orchestrator hand-rolls test gates with manual polling. This is exactly the "all functions work reliably + autonomous" mechanism the user wants. |
| `chain` mode (`{previous}`, `{chain_dir}`) | Sequential pipeline in one call; each step's output threads to the next. | **Unused.** The visual loop is 4–5 separate manual dispatches with hand-passed reports. |
| `worktree: true` | Isolated git worktrees per parallel task → safe parallelism. | **Unused.** Workstreams are strictly sequential. |
| `async: true` + `action: status/interrupt/resume` + `intercom` channel | True background runs with polling, resume, and async clarification. | **Mentioned, not used.** The pipeline blocks on interactive `ask_user`. |
| `output` / `outputMode: "file-only"` / `reads` | Precise per-dispatch context control (report → file, pre-load only needed files). | **Unused.** Agents read freely → context bloat. |
| `progress: true` | `progress.md` per task for deterministic resume. | **Unused.** Resume "infers from commit messages." |
| per-task `model` override | Orchestrator sets `model: "provider/id:thinking"` per dispatch → dynamic routing per `MODEL_STRATEGY`. | **Unused.** Routing relies on agent frontmatter only. |
| `control` + `notifyOn` + `notifyChannels: ["intercom"]` | Attention tracking + notifications for long autonomous runs. | **Unused.** |
| `config` create/update (`thinking`, `systemPromptMode`, `inheritSkills`, …) | Runtime agent definition; also the `subagents.agentOverrides` settings mechanism. | **Not documented.** The native way to set project-level model+thinking+fallbacks (`v3/.pi/settings.json` already uses it) is never mentioned in the harness. |

This is the biggest opportunity: the harness is building, by hand and unreliably, what the tool
already does natively and deterministically.

### GAP-4 — No deterministic functional verification for "all functions work reliably"  *(HIGH)*

The framework covers visual fidelity and unit/widget/golden tests thoroughly, but the user's
core goal — **every spec function works reliably** — is under-served:

- No **spec → test traceability matrix** (which spec requirement → which test(s)). The reviewer
  checks "implementation against acceptance criteria" qualitatively.
- No **per-feature integration/E2E gate**. E2E is a final-phase workstream and the device smoke
  gate is optional. "Function works" should be verified on an emulator **per feature**, not just
  at the end.
- No enforcement that every spec function has an integration journey.

### GAP-5 — Design-token extractor & stitch-html-parser are prose-only  *(HIGH)*

Both skills describe a process but ship **no executable parser**. Phase 0 dispatches
`flutter-dev.feature-agent` to improvise parsing of `<script id="tailwind-config">` every run →
non-deterministic tokens. For a "robust" framework, this must be a real deterministic script
shipped with the harness (e.g. `tools/extract_design_tokens.js` using `cheerio` /
`node-html-parser`) that reproducibly emits `design_tokens.json`. Same critique applies to the
architecture-consistency-checker: the grep commands are deterministic but should be a script
(`tools/arch_check.sh`) the architect runs, not re-derived each invocation.

### GAP-6 — Visual validation loop is fragile  *(MEDIUM)*

- **Render-size mismatch is inherent:** goldens render at a fixed test viewport; Stitch
  `screen.png` is at a different size. No viewport/scale normalization is specified.
- **No deterministic pixel-diff pre-filter.** Flutter goldens already auto-generate `_isolated`
  diff PNGs on failure; adding `pixelmatch` (or a threshold on the Flutter diff) gives a
  deterministic PASS/FAIL before the non-deterministic vision comparison. Vision should only do
  *semantic* diff (wrong icon, wrong component), not pixel parity.
- **Font/icon parity in goldens not addressed** (`FontLoader`, `ahem`/Roboto, platform icons) →
  goldens flake across machines/CI.
- **Network images in mockups** → goldens cannot fetch; the stub convention is a coupling
  between feature-agent and golden-test-generator that is not enforced.
- **Tool enforcement is prompt-only.** `visual-validator.md` lists `tools: read, write, edit,
  bash, ...` then says "never modify production code" in prose. `pi-subagents` honors the
  `tools:` frontmatter field — so **remove `edit`/`write`** and the rule becomes physically
  unbreakable. Same for `architect` (read/grep only).
- **"Delete throwaway golden, re-run real golden"** is confusing and error-prone. Simplify to a
  single golden test; during iteration `--update-goldens` regenerates locally; on parity the
  golden PNG is committed as the baseline.

### GAP-7 — Interactivity breaks autonomy  *(MEDIUM)*

The pipeline leans on `ask_user` (interactive, blocking) for missing info and recovery. For
"complete all tasks autonomously," add an **autonomy mode**: pre-resolve all decisions in the
plan/approval phase; missing runtime info → structured default + logged assumption (not a
blocking question); recovery → bounded auto-retry with model escalation before asking. Use the
`intercom` async channel for non-blocking clarifications during background runs.

### GAP-8 — Resume/recovery is weak  *(MEDIUM)*

"Infer last completed workstream from commit messages" is fragile — and v3 isn't even git.
Use a `state.json` (workstream → status → runId → commit) as the source of truth, plus native
`action: "resume"` with `id`/`runId`/`dir`. Require `git init` in Phase 0 (currently "ask
whether to init" — for autonomy, auto-init).

### GAP-9 — No toolchain gate  *(MEDIUM)*

`flutter build apk`, goldens, and integration tests need Java + Android SDK/NDX + an emulator.
There is no `flutter doctor` gate in Phase 0. For autonomy, Phase 0 must run `flutter doctor`
and fail fast with remediation if the toolchain is missing — otherwise the build gate fails
late and un-autonomously.

### GAP-10 — Skill-name assumptions partially unverified  *(LOW–MEDIUM)*

Confirmed to exist in `flutter/skills` and `dart-lang/skills` (official): `flutter-fix-layout-
issues`, `flutter-use-http-package`, `flutter-implement-json-serialization`, `flutter-add-
integration-test`, `flutter-apply-architecture-best-practices`, `flutter-build-responsive-
layout`, `dart-add-unit-test`, `dart-collect-coverage`, `dart-fix-runtime-errors`. Others
referenced in `feature-agent.md` (e.g. `dart-generate-test-mocks`, `flutter-add-widget-test`,
`dart-run-static-analysis`, `dart-use-pattern-matching`) need a quick existence check.
`install.sh` only verifies 5 official skills post-install. Add a check that **every** skill
referenced in agent frontmatter exists, else warn.

### GAP-11 — Minor inconsistencies  *(LOW)*

- `planner.md` lists `design-token-extractor` and `ask-user` as skills, but the planner "does
  not implement"; the orchestrator dispatches the extractor as `feature-agent`, not planner —
  ownership is ambiguous.
- `ask-user` is provided by the `pi-ask-user` package skill; listing it as a project skill may
  double-load.
- Reviewer is `gpt-5.4` with no validation the ID resolves (see GAP-2).
- `flutter-add-widget-test` is referenced by `feature-agent` and by `install.sh`
  `OFFICIAL_REQUIRED` — verify it exists (the Flutter skills README shows `flutter-add-widget-
  test` is not in the public list I saw; the closest is `flutter-add-integration-test` and
  `dart-add-unit-test`).

---

## 3. Recommended improvements (prioritized roadmap)

### P0 — Unblocks everything

1. **Reconcile models.** Run `pi --list-models` on the target machine; map each agent role to
   a **real** model ID available there. Make the harness model-agnostic: define **capability
   tiers** (`planner-tier`, `ui-vision-tier`, `logic-tier`, `mechanical-tier`, `review-tier`)
   in `MODEL_STRATEGY.md` and resolve them to concrete IDs from the target project's
   `.pi/settings.json` `subagents.agentOverrides` (the native per-agent override mechanism) or
   `/models` at runtime. Encode thinking as a `:high` / `:xhigh` suffix on the model string.
   Replace hardcoded speculative IDs in agent frontmatter with either verified IDs or tier
   references the orchestrator resolves.
2. **Deploy and run one workstream end-to-end in a real target project.** Install the harness
   into a target project (outside the research workspace), run W01 through the orchestrator,
   and fix whatever breaks against `pi-subagents@0.28.0`. Capture `plan.md`,
   `design_tokens.json`, golden PNGs, `ARCHITECTURE_LOG.md`, and `review.md` as the first
   concrete evidence the pipeline works. Until this passes, the framework is a draft.

### P1 — Biggest reliability & autonomy wins

3. **Adopt native `acceptance` contracts.** The planner emits, per workstream, an `acceptance`
   object: `criteria` = spec acceptance criteria; `evidence` = `[tests-added, commands-run,
   validation-output, changed-files]`; `verify` = `[{id, command: "flutter test ..."},
   {command: "flutter analyze"}, {command: "flutter test test_goldens/..."},
   {command: "flutter test integration_test/..."}]`; `review` = `{agent: "flutter-dev.reviewer",
   required: true}`; `stopRules`; `maxFinalizationTurns`. The orchestrator passes `acceptance`
   in each `subagent()` dispatch. The child then runs a **bounded self-review/repair loop**
   before reporting success — tool-enforced, not prompt-enforced. This single change delivers
   the user's "all functions work reliably + autonomous" goal.
4. **Convert the UI-critical loop to a `chain`** (or tighten context): `architect` (pre) →
   `feature-agent` → `visual-validator` → `golden-test-generator`, with `{previous}` threading
   the discrepancy report and `{chain_dir}` for artifacts. Or keep separate dispatches but use
   `output: "file-only"` + `reads` to bound context.
5. **Enforce tool restrictions via frontmatter.** `visual-validator` and `architect`: drop
   `edit`/`write` (keep `read`, `bash`, `glob`, `ask_user`). "Never modify code" becomes
   physically enforced by `pi-subagents`.
6. **Add spec→test traceability.** Planner output includes a matrix (spec requirement →
   workstream → unit/widget/integration/E2E tests). Each feature workstream's `acceptance.
   verify` includes an integration test for its spec functions, run on an emulator.

### P2 — Robustness

7. **Ship deterministic scripts:** `tools/extract_design_tokens.js` (cheerio) and
   `tools/arch_check.sh`. Skills invoke the scripts instead of improvising.
8. **Harden visual validation:** deterministic pixel-diff pre-filter (Flutter golden `_isolated`
   diff + `pixelmatch` threshold) **then** vision semantic diff; specify golden viewport
   matching the mockup aspect ratio; document font/icon parity (`FontLoader`, `ahem`/Roboto,
   platform icons); enforce network-image stubs in goldens by convention.
9. **Autonomy mode:** pre-resolve decisions in the plan; missing info → default + log; bounded
   auto-retry with model escalation before `ask_user`; use `intercom` for non-blocking
   clarifications during `async` runs.
10. **Resume via `state.json`** (workstream → status → runId → commit) + native
    `action: "resume"`. Auto-init git in Phase 0.
11. **Phase 0 `flutter doctor` toolchain gate** + Android SDK/emulator readiness check before
    any build/integration gate.

### P3 — Polish

12. **`install.sh`:** verify every skill referenced in agent frontmatter exists post-install;
    verify model IDs resolve; document `subagents.agentOverrides` in `AGENTS.md` as the
    project-level model config mechanism.
13. **Resolve ownership:** planner should not list `design-token-extractor` as a skill; the
    orchestrator owns extraction dispatch. Dedupe `ask-user`.
14. **Document the pi-subagents native features the harness now uses** (`acceptance`, `chain`,
    `worktree`, `async/status/resume`, `intercom`) in `FRAMEWORK.md` so the design maps to the
    tool, not to hand-rolled equivalents.

---

## 4. One-line summary

The previous session produced a thorough, well-written redesign that faithfully implements its
own plan — but the plan was never validated against the real `pi-subagents@0.28.0` tool,
hard-codes model IDs that are not verified against any target machine, and hand-rolls
reliability mechanisms (acceptance gates, chains, worktrees, async resume, intercom) that the
installed tool already provides natively. (`the-little-library/v3` is a research sandbox and
is not evidence of harness failure.) The highest-leverage fixes are: (1) reconcile models to
real IDs, (2) adopt native `acceptance` contracts per workstream, (3) deploy and run one
workstream end-to-end in a real target project, and (4) enforce tool-level (not prompt-level)
boundaries on read-only agents.
