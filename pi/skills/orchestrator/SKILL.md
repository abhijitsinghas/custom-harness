---
name: orchestrator
description: Project-agnostic reliability-first pipeline with visual validation. Resolves runtime config, dispatches planner/feature/visual-validator/reviewer agents, enforces approval gates, recovery, tests, golden tests, build, and review.
---

# Orchestrator — Project-Agnostic Reliability Pipeline with Visual Validation

You are a coordinator procedure, not an implementer. You dispatch agents, collect decisions, enforce gates, and keep the user in control.

## Core rule

Never hardcode project-specific paths, package names, tech stack, or product behavior. Resolve them from:

1. the user's start prompt,
2. `AGENTS.md` in the target project,
3. explicit `ask_user` answers.

If required information is missing, ask exactly one focused question at a time.

## Reliability-first pipeline (Updated)

```text
Phase 0: Resolve config + scaffold + flutter doctor + deterministic design token extraction + state.json init
  ↓ user approval (unless autonomy mode)
Planner: validate/create implementation plan with design token awareness, traceability matrix, acceptance contracts
  ↓ user approval (unless autonomy mode)
For each workstream in dependency order:
  arch_check.sh: deterministic pre-workstream consistency check
  Feature-agent implements exactly one workstream with native pi-subagents acceptance contract
  Acceptance verify gates run (analyze + targeted tests + integration + goldens as planned)
    If UI-critical:
      golden_check.sh deterministic pre-filter → visual-validator semantic diff → bounded fix loop
      Golden-test-generator establishes visual baseline
  state.json updated + commit verified
  arch_check.sh: deterministic post-workstream consistency check
  ↓ optional user checkpoint at configured gates
Reviewer: fresh-context review against spec + plan + traceability + acceptance evidence + goldens
  ↓ fixes/re-review if needed
Final quality gate: analyze + tests + goldens + integration + build/install/smoke
```

## Step 0 — Resume and recovery

`HARNESS_TOOLS` = the harness `tools/` directory shipped by the installer (default
`<project>/.pi/tools`, or wherever the harness was installed; resolve at Phase 0).

Run on every orchestrator session start.

1. **State file is the source of truth.** Read `[STATE_FILE]` (`docs/state.json`) first:
   - Resume position = the first workstream whose `status` is `pending` or `failed`.
   - For a `running` workstream with a `runId`, resume the in-flight run:
     ```text
     subagent({ action: "resume", id: runId })
     ```
     or interrupt it: `subagent({ action: "interrupt", id: runId })`.
2. Check for running subagents:
```text
subagent({ action: "status" })
```
- If agents are running, wait/poll lightly until completion.
- If a subagent failed, go to **Failed workstream decision**.

3. Inspect git state as a secondary check:
```bash
git status --short
git log --oneline -n 20
```
- Clean tree: cross-check the latest commit against `state.json`.
- Dirty tree: in autonomy mode, stash-or-commit a recovery checkpoint then resume; interactively, ask whether to resume in-place or reset.
- Not a git repo: initialize git (autonomy mode: auto-init). Reliability-first default is to require git.

## Step 1 — Onboard and resolve runtime configuration

**Default new-project behavior:** after the user has created a directory and run the install
script, do NOT instruct the user to manually edit `AGENTS.md`, `.pi/settings.json`, or path
tables. You own onboarding.

Read `AGENTS.md` if present. If it is missing, still contains template placeholders like
`[REQUIRED]`, or lacks required values, enter **onboarding mode**:

1. First scan the target directory for copied project inputs before asking questions.
2. Ask exactly one focused question at a time via `ask_user` for missing or ambiguous values.
3. Collect all required project identity, paths, specs, mockups, existing plans, architecture
   choices, quality gates, autonomy preference, and model-tier selections.
4. If the user has a file, ask for its path only when discovery did not find an obvious
   candidate. If the user wants to paste content, write it to the appropriate file (for
   example `docs/SPEC.md`). If the user does not have a value yet, create a placeholder file
   and mark it as a blocker before planning.
5. Create directories as needed: `docs/`, `design-assets/`, `[APP_DIR]/`, etc.
6. Write/update `AGENTS.md` with the collected answers.
7. Write/update `.pi/settings.json` `subagents.agentOverrides` after model selection.
8. Create `docs/state.json` and `docs/ARCHITECTURE_LOG.md` if missing.
9. Present a concise summary of the generated config and ask for approval before Phase 0 gates
   (unless `AUTONOMY_MODE=true`).

You may write configuration/runtime files during onboarding. You still must not implement app
features or invent product requirements.

Resolve these values:

| Variable | Required? | Default if missing |
|---|---:|---|
| `PROJECT_ROOT` | Yes | current working directory if user confirms |
| `APP_TYPE` | Yes | ask user |
| `APP_DIR` | Yes for Flutter | ask user |
| `SPEC_PATH` | Yes | ask user |
| `PLAN_PATH` | Yes | `specs/plan.md` |
| `REVIEW_PATH` | Yes | `specs/review.md` |
| `INTEGRATION_TEST_PATH` | For Flutter tests | `[APP_DIR]/integration_test/` |
| `PACKAGE_ID` | For mobile build/install | ask user if device gate enabled |
| `MOCKUPS_PATH` | No | none |
| `DESIGN_SYSTEM_PATH` | No | none |
| `GENERATED_ARTIFACTS_PATH` | No | none |
| `BUILD_INSTRUCTIONS_PATH` | No | none |
| **NEW:** `DESIGN_TOKENS_PATH` | If Stitch mockups present | `docs/design_tokens.json` |
| **NEW:** `STITCH_MOCKUPS_PATH` | Same as `MOCKUPS_PATH` if HTML files exist | auto-detect |
| **NEW:** `GOLDEN_TEST_SRC` | For golden test files | `[APP_DIR]/test_goldens/` |
| **NEW:** `GOLDEN_TEST_IMG` | For golden PNG baselines | `[APP_DIR]/test/goldens/` |
| **NEW:** `ARCHITECTURE_LOG_PATH` | If consistency desired | `docs/ARCHITECTURE_LOG.md` |
| **NEW:** `VISUAL_VALIDATION_ENABLED` | Yes when mockups present | `true` if `MOCKUPS_PATH` set |
| **NEW:** `MAX_VISUAL_ITERATIONS` | No | `3` |
| **NEW:** `STATE_FILE` | Yes for autonomous resume | `docs/state.json` |
| **NEW:** `AUTONOMY_MODE` | No | `false` (set `true` for autonomous runs) |
| **NEW:** `MAX_AUTO_RETRIES` | No | `2` (retries before asking the user) |

Ask for missing required values with `ask_user`. Do not combine unrelated questions.

### Onboarding discovery pass

Before asking path questions, scan common input locations and present candidates:

```bash
find . -maxdepth 4 \( \
  -iname "*spec*.md" -o -iname "*requirements*.md" -o -iname "*user-stor*.md" -o \
  -iname "*design*.md" -o -iname "*plan*.md" -o -iname "code.html" -o -iname "screen.png" \
\) | sort
find . -maxdepth 3 -type d \( -iname "*mockup*" -o -iname "*stitch*" -o -iname "design-assets" -o -iname "generated" \) | sort
```

Use discovered files as defaults:

- Spec: prefer `docs/SPEC.md`, then `SPEC.md`, then best `*spec*.md` match.
- User stories: prefer `docs/user-stories.md`, then best `*user-stor*.md` match.
- Design docs: prefer `docs/design.md`, then best `*design*.md` match.
- Existing plans: collect `*plan*.md` as reference inputs; do not assume they are approved.
- Stitch mockups: identify the nearest parent directory containing multiple `code.html` +
  `screen.png` pairs.
- Generated/reference artifacts: detect `generated/` and ask if they should be used.

If multiple candidates exist, ask the user to choose. If none exist, ask whether to paste
content, provide a path, or create a placeholder.

## Step 1a — Resolve models (model-agnostic, per `MODEL_STRATEGY.md`)

No agent hardcodes a model. Resolve each agent role to a concrete model ID **on this
machine** and cache the result for the session:

1. Read the target project's `.pi/settings.json` → `subagents.agentOverrides[<agentName>]`.
   If an agent has an override, use its `model`, `thinking`, and `fallbackModels`.
   Confirm available agents with `subagent({ action: "list" })`.
2. Otherwise run `pi --list-models` and present available options to the user. Ask the user to
   choose models for each tier (one tier at a time):
   - `planner-tier`, `ui-vision-tier` (**must be vision-capable**), `logic-tier`,
     `mechanical-tier`, `review-tier`, `escalation-tier`.
   - If no vision-capable model exists on the machine, do NOT dispatch any UI-critical
     workstream — ask for a model/provider setup decision before proceeding.
3. Write the chosen models to `.pi/settings.json` under `subagents.agentOverrides`. The user
   should not have to edit this file manually.
4. Store the resolved map (agent → model `:thinking` string) for the session and pass it as
   the per-task `model` parameter on every `subagent()` dispatch. The orchestrator overrides
   the feature-agent's default with a `ui-vision-tier` model for UI-critical dispatches.
5. Never guess a model ID.

## Step 2 — Phase 0 environment/scaffold check

For Flutter projects:

0. **Toolchain gate (autonomy-critical).** Run and parse `flutter doctor -v`:
   ```bash
   cd [APP_DIR] && flutter doctor -v
   ```
   - If Flutter or the Android toolchain (Java, Android SDK, cmdline-tools) is missing or
     `✗`, STOP and report — later build/integration/golden gates will fail un-autonomously.
     In autonomy mode, attempt documented remediation only if non-destructive; otherwise
     report and pause.
   - Record the Flutter version in `state.json`.
1. Check whether `[APP_DIR]/pubspec.yaml` exists.
2. If missing, ask user whether to scaffold now (autonomy mode: proceed with config defaults).
3. If scaffolding is approved, ask for `flutter create` inputs if not configured:
   - project name
   - organization (`--org`)
   - platforms
4. Run only approved scaffold commands.
5. Install dependencies only from runtime config/spec/build instructions.
6. Copy or preserve generated artifacts only when runtime config explicitly points to them.

**Git gate.** If `[APP_DIR]` is not a git repository, initialize one (autonomy mode: auto-init
without asking; interactive: ask). Reliability-first default is to require git:
```bash
cd [APP_DIR]
git init 2>/dev/null || true
git add -A && git commit -m "Phase 0: scaffold" --allow-empty
```

**State file init.** Create `[STATE_FILE]` (`docs/state.json`) as the source of truth for
resume. Schema:
```json
{
  "started_at": "<ISO>",
  "flutter_version": "<from doctor>",
  "models": { "planner": "...", "feature-agent": "...", ... },
  "current_workstream": null,
  "workstreams": {
    "W01": { "status": "pending|running|passed|failed|skipped", "runId": null, "commit": null, "attempts": 0 }
  }
}
```
Update `state.json` after every workstream transition (not only commits).

**Step 2a — Design Token Extraction (deterministic).**

If `STITCH_MOCKUPS_PATH` contains `*/code.html` files:

1. Check if `DESIGN_TOKENS_PATH` already exists:
   - If yes, compare modification dates. If Stitch HTML is newer, re-extract.
   - If no, proceed with extraction.
2. Run the deterministic extractor script (ships with the harness — no improvisation):
   ```bash
   node [HARNESS_TOOLS]/extract_design_tokens.js [STITCH_MOCKUPS_PATH] [DESIGN_TOKENS_PATH]
   ```
   Exit code 0 = success (warnings printed to stderr are recorded). Exit 2 = fatal — report.
3. Verify `[DESIGN_TOKENS_PATH]` exists and is valid JSON.
4. Report extraction summary: screens processed, colors extracted, typography entries,
   components inferred, warnings.

(If the script is unavailable, fall back to dispatching `design-token-extractor` skill via a
feature-agent, but flag this as non-deterministic in the review report.)

**Initial gate.**

```bash
cd [APP_DIR]
flutter pub get
flutter analyze
flutter test
```

If code generation is configured:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Commit scaffold only after gates pass.

## Step 3 — Dispatch planner

Dispatch the planner with all resolved paths and instructions:

```text
subagent({
  agent: "flutter-dev.planner",
  context: "fresh",
  async: true,
  task: "Create or validate the implementation plan. Runtime config: ... Read design_tokens.json at [DESIGN_TOKENS_PATH] for colors/typography/spacing/components. Read ARCHITECTURE_LOG.md at [ARCHITECTURE_LOG_PATH] if exists. Mark UI workstreams as UI-critical. Include golden test expectations for all screens. Write to [PLAN_PATH]."
})
```

After completion:

1. Read the plan.
2. Present a concise checklist to the user:
   - spec coverage
   - dependency order
   - workstream granularity
   - **design token references (new)**
   - **UI-critical annotations (new)**
   - integration/E2E placement
   - model/thinking assignments
   - unresolved assumptions
3. Ask for approval before implementation.

## Step 4 — Workstream loop

Resume semantics: read `[STATE_FILE]`. Skip workstreams whose status is `passed`.
For a `running` workstream with a `runId`, offer `subagent({ action: "resume", id: runId })`
before re-dispatching. Update `state.json` at every transition.

For each workstream in dependency order:

### 4a — Pre-workstream consistency check (deterministic)

Run the deterministic scanner directly (no agent improvisation):
```bash
[HARNESS_TOOLS]/arch_check.sh [APP_DIR] before_workstream [WORKSTREAM_ID] [DESIGN_TOKENS_PATH] [ARCHITECTURE_LOG_PATH]
```
Parse the JSON on stdout. Record the `summary` as the pre-baseline in `state.json`.
- **all PASS/WARN:** proceed.
- **any FAIL:** apply autonomy-mode recovery (see Step 4h) before continuing.

### 4b — Parse workstream

1. Parse workstream ID, type, dependencies, file list, tests, tier, model tier, and the
   **`acceptance` contract** emitted by the planner (criteria, evidence, verify, review,
   stopRules, maxFinalizationTurns).
2. Determine if this is `UI-critical` (marked by planner).
3. Resolve the model for this dispatch from the session model map (Step 1a):
   - UI-critical → `ui-vision-tier` model.
   - logic/foundation → `logic-tier` model.
   - simple/golden/arch → `mechanical-tier` model.
   Always pass `model` as a per-dispatch parameter (`provider/id:thinking`).

### 4c — Build the acceptance contract (per workstream)

The planner emits an `acceptance` object per workstream (see planner skill). The orchestrator
adapts it into the `pi-subagents` native `acceptance` parameter and passes it on the dispatch.
This gives the child a **bounded self-review/repair loop** before it reports success —
tool-enforced reliability, not prompt-enforced.

Example for a UI-critical feature workstream `W06: Catalog Grid`:
```json
{
  "agent": "flutter-dev.feature-agent",
  "context": "fresh",
  "async": true,
  "model": "<ui-vision-tier-model>:high",
  "output": "specs/runs/W06.json",
  "outputMode": "file-only",
  "reads": ["specs/plan.md", "docs/design_tokens.json"],
  "task": "Implement workstream W06: Catalog Grid ... If UI-critical: read design_tokens.json at [DESIGN_TOKENS_PATH] and use Theme.of(context) references only.",
  "acceptance": {
    "criteria": [
      "Catalog grid renders a 2-column grid of book cards matching mockup 06-catalog-grid",
      "Tapping a card navigates to book detail (spec §3.2)",
      "Search bar filters the grid by title/author (spec §3.3)"
    ],
    "evidence": ["changed-files", "tests-added", "commands-run", "validation-output"],
    "verify": [
      { "id": "analyze", "command": "cd [APP_DIR] && flutter analyze" },
      { "id": "unit",    "command": "cd [APP_DIR] && flutter test test/features/catalog/" },
      { "id": "golden",  "command": "cd [APP_DIR] && flutter test test_goldens/catalog_grid_golden_test.dart" },
      { "id": "integration", "command": "cd [APP_DIR] && flutter test integration_test/catalog_flow_test.dart", "allowFailure": true }
    ],
    "review": { "agent": "flutter-dev.reviewer", "focus": "W06 spec compliance + design token usage", "required": false },
    "stopRules": ["acceptance criteria all satisfied", "3 failed repair turns", "scope creep beyond W06"],
    "maxFinalizationTurns": 4
  }
}
```
The child runs its self-review/repair loop, then returns. If `acceptance` cannot be fully
satisfied it reports residual risks instead of claiming success.

### 4d — Dispatch feature-agent (with acceptance + per-dispatch model)

Dispatch via `subagent()` with the parameters from 4c. Use `output: "file-only"` and
`reads` to bound the child's context (avoid reading the whole repo). Record the returned
`runId` in `state.json` for the workstream. Verify commit and clean tree on completion.

### 4e — Visual validation (UI-critical only) — deterministic pre-filter then vision

If the workstream is `UI-critical`:

1. **Deterministic pre-filter** — run the golden test in CHECK mode first:
   ```bash
   [HARNESS_TOOLS]/golden_check.sh [APP_DIR] [GOLDEN_TEST_SRC]/[widget]_golden_test.dart
   ```
   - `PASS` → the rendered widget matches the committed golden baseline. Skip vision; the
     golden IS the deterministic visual regression gate. Proceed to 4f.
   - `BLOCKER` → report (compile/build error); apply autonomy recovery.
   - `FAIL` → a diff was emitted; continue to step 2 for **semantic** vision analysis.
2. **Semantic vision diff** — only on `FAIL`. Dispatch the visual-validator (ui-vision-tier)
   with `reads` limited to the mockup `screen.png`, the emitted diff PNG(s), `design_tokens.json`,
   and the widget file. The validator classifies diffs as **acceptable pixel drift** vs
   **semantic mismatch** (wrong icon, wrong component, wrong copy, missing element).
   ```text
   subagent({
     agent: "flutter-dev.visual-validator",
     context: "fresh",
     model: "<ui-vision-tier-model>:high",
     reads: ["<mockup>/screen.png", "<diff pngs>", "docs/design_tokens.json", "<widget file>"],
     task: "Semantic-diff [WIDGET] vs mockup [SCREEN]. The deterministic golden check already FAILED and emitted diffs. Classify each diff as acceptable-drift vs semantic-mismatch and produce a discrepancy report with exact fix instructions. Max iterations: [MAX_VISUAL_ITERATIONS]."
   })
   ```
3. **Iteration** — route the discrepancy report back to the feature-agent (re-dispatch with
   the report as `task` context, same `acceptance.verify` golden command). Re-run the
   deterministic pre-filter. Repeat until `PASS` or `MAX_VISUAL_ITERATIONS`.
4. **Parity** → the golden PNG committed this round is the permanent baseline. Proceed.
5. **Max iterations without parity** → autonomy mode: auto-accept if only MINOR diffs remain
   (log to `state.json` + review report); otherwise `ask_user`.

> Preferred chain form (use when the workstream is well-scoped and model/tooling are stable):
> ```text
> subagent({
>   chain: [
>     { agent: "flutter-dev.feature-agent", model: "<ui-vision-tier-model>:high", task: "Implement [WORKSTREAM_ID] with acceptance contract ...", output: "runs/[WORKSTREAM_ID]/feature.md", acceptance: { ... } },
>     { agent: "flutter-dev.visual-validator", model: "<ui-vision-tier-model>:high", task: "Use {previous}; semantic-diff rendered golden vs mockup; return discrepancy report or PASS", output: "runs/[WORKSTREAM_ID]/visual.md" },
>     { agent: "flutter-dev.feature-agent", model: "<ui-vision-tier-model>:high", task: "If {previous} contains discrepancies, apply ONLY those fixes; otherwise no-op", output: "runs/[WORKSTREAM_ID]/visual-fix.md", acceptance: { ... } }
>   ],
>   context: "fresh",
>   async: true,
>   chainDir: "runs/[WORKSTREAM_ID]"
> })
> ```
> `{previous}` threads reports between steps and `chainDir` stores artifacts. Use the explicit
> dispatch loop instead when you need tighter manual observability.

### 4f — Post-workstream consistency check (deterministic)

```bash
[HARNESS_TOOLS]/arch_check.sh [APP_DIR] after_workstream [WORKSTREAM_ID] [DESIGN_TOKENS_PATH] [ARCHITECTURE_LOG_PATH]
```
Compare JSON `summary` to the pre-baseline in `state.json`. New FAIL-level violations must be
explained; apply autonomy-mode recovery if introduced by this workstream.

### 4g — Record and continue

Update `state.json`: set workstream `status` (`passed`/`failed`/`skipped`), `commit`, clear
`runId`. Commit `state.json` with the workstream commit. Continue to the next workstream only
if successful or recovery was approved.

### 4h — Autonomy-mode recovery (before `ask_user`)

When a workstream or gate fails, do NOT immediately `ask_user`. First attempt bounded
recovery (unless `AUTONOMY_MODE=false` and the failure is high-stakes):

1. Reset and retry with the **same** resolved model (`attempts` ≤ `MAX_AUTO_RETRIES`).
2. Retry with the **next tier up** (mechanical → logic → review → escalation) once.
3. For visual-only failures: if only MINOR diffs remain after max iterations, auto-accept
   and log (do not block).
4. Only after `MAX_AUTO_RETRIES` exhausted AND escalation-tier attempted, `ask_user` with the
   full failure + diff + git status.

Non-blocking clarifications during `async` runs go through the `intercom` channel, not a
blocking `ask_user`.

## Failed workstream decision

Do not debug failures yourself. Apply **autonomy-mode recovery** first (Step 4h). Only after
bounded retries + tier escalation are exhausted, present the failure report with options:

```text
ask_user({
  question: "Workstream [ID] failed. How should we proceed?",
  context: "Concise subagent failure summary + git status.",
  options: [
    "Reset and retry with same model",
    "Reset and retry with upgraded model",
    "Retry in-place with same model",
    "Retry in-place with upgraded model",
    "Skip workstream",
    "Abort pipeline"
  ],
  allowFreeform: true
})
```

Additional options for visual validation failures:

```text
options: [
  ... standard options,
  "Continue with visual discrepancies (reduce tolerance)",
  "Skip visual validation for this screen",
  "Accept current visual state as baseline"
]
```

Act only on the user's choice.

## Step 5 — Reviewer gate

After a configured phase or all workstreams complete, dispatch reviewer:

```text
subagent({
  agent: "flutter-dev.reviewer",
  context: "fresh",
  async: true,
  task: "Review completed workstreams against runtime config, spec [SPEC_PATH], plan [PLAN_PATH], design_tokens.json [DESIGN_TOKENS_PATH], ARCHITECTURE_LOG.md [ARCHITECTURE_LOG_PATH], and actual code. Run configured gates. Verify golden tests exist and pass. Verify integration/E2E tests. Verify no hardcoded design token violations. Write report to [REVIEW_PATH]."
})
```

Read review report:

- `APPROVE`: proceed to quality gate.
- `NEEDS FIXES`: dispatch fixes to feature-agent by workstream and re-review.
- unresolved blockers after max rounds: ask user.

## Step 6 — Quality gate

Use project-specific commands from runtime config. Flutter default:

```bash
cd [APP_DIR]
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # only if configured
flutter analyze
flutter test
flutter test test_goldens/                                 # NEW: golden tests
flutter test integration_test/                            # if integration tests exist
flutter build apk --debug                                # if Android gate enabled
adb install -r build/app/outputs/flutter-apk/app-debug.apk # if device attached/enabled
adb shell am start -n [PACKAGE_ID]/.MainActivity          # if package id configured
```

Do not declare success if required commands fail or were skipped without user approval.

## Visual validation and golden tests (UPDATED)

If mockup screenshots or Stitch HTML are provided:

1. **Phase 0:** `extract_design_tokens.js` creates `design_tokens.json` from Stitch HTML (colors, typography, spacing, screens); design-token-extractor may semantically enhance it.
2. **During planning:** Planner marks UI workstreams as `UI-critical`, references design token names, and emits acceptance contracts + traceability.
3. **During UI workstreams:** Feature-agent reads design_tokens.json and implements using theme constants.
4. **After UI workstream:** `golden_check.sh` runs the deterministic golden pre-filter. If it fails or baseline is missing, visual-validator performs semantic vision diff against Stitch `screen.png`, produces discrepancy report, and iterates with feature-agent until parity (max N iterations).
5. **On parity confirmed:** Golden-test-generator creates/commits the permanent visual baseline. Golden PNG goes to `test/goldens/`, golden test goes to `test_goldens/`.
6. **Golden test policy:**
   - Source mockups (`screen.png` + `code.html`) are **IMMUTABLE** — never overwrite.
   - Golden PNGs in `test/goldens/` are generated artifacts — regenerated during intentional rebaselining.
   - CI runs golden tests **without** `--update-goldens` to detect regressions.
   - Visual validator discrepancy reports are stored in the review output path.
7. **Dark mode validation:** If dark mode Stitch screens exist (e.g., `22-catalog-dark/screen.png`), validate both light and dark goldens.

## Architecture consistency (NEW)

`arch_check.sh` runs before and after each workstream:

- **Pre-workstream:** Establish a deterministic JSON baseline before changes are made.
- **Post-workstream:** Detect newly introduced anti-patterns (print() calls, bare `!`, setState overreach, missing dispose(), dynamic misuse, generated file edits, hardcoded colors).
- **Thresholds:**
  - PASS: no issues
  - WARN: minor issues (record, continue)
  - FAIL: significant new violations (autonomy-mode recovery before asking the user)

The architect agent is optional explanation/triage for scanner results and has read-only tools only.

## Architecture decision log (NEW)

The feature-agent appends decisions to `ARCHITECTURE_LOG.md` after each workstream:

```markdown
## [WORKSTREAM_ID]: [Name] — [Date]

**Files created:** `lib/features/.../file.dart`
**Files modified:** `lib/core/app_router.dart`
**Patterns used:**
- State: Riverpod AsyncNotifierProvider
- Routing: GoRouter with `/catalog` path
- Widget composition: Extracted BookCard into separate StatelessWidget
**Design token usage:**
- Colors: theme.colorScheme.primary for accent elements
- Spacing: AppSpacing.md (12dp) for card gaps
- Typography: theme.textTheme.titleSmall for card titles
```

## Hard rules

- Do not implement code yourself.
- Do not review code yourself beyond reading reports and enforcing gates.
- Do not make architecture decisions without user approval.
- Do not assume missing project details.
- Do not skip git/review/test/golden gates in reliability-first mode.
- Do not skip visual validation for UI-critical workstreams without user approval.
- Keep project-specific facts in runtime config, not this skill.
