# Project-Agnostic Flutter/Dart Reliability Harness

> Planner → one-workstream implementer → visual validator → fresh-context reviewer → quality gates.  
> Product-specific information is supplied at runtime through `AGENTS.md`, start prompts, and `ask_user` answers.  
> Design tokens are extracted from Stitch HTML mockups into machine-readable `design_tokens.json`.

## Design goals

1. **Project-agnostic agents** — no product names, paths, package ids, or features are hardcoded in agents/skills.
2. **Reliability first** — plan approval, scoped workstreams, tests, visual validation, review, and build gates are mandatory unless the user explicitly relaxes them.
3. **Visual fidelity** — every UI screen is validated against its Stitch mockup using the visual-validator agent's iterative comparison loop.
4. **Runtime configuration** — each project provides specs, paths, stack, design tokens, and rules through `AGENTS.md` or the orchestrator start prompt.
5. **Fresh-context review** — implementation, visual validation, and review are separated.
6. **Machine-readable design** — Stitch HTML mockups are parsed into `design_tokens.json` — the single source of truth for colors, typography, spacing, and components.
7. **Recoverable execution** — git state, workstream commits, and architecture log determine resume position.

---

## Installed agents

| Agent | Role | Capability tier | Thinking |
|---|---|---|---|
| `planner` | Reads config/spec/design-tokens/artifacts/code and writes dependency-ordered workstreams with UI-critical annotations and acceptance contracts | `planner-tier` | high |
| `feature-agent` | Implements exactly one workstream; for UI-critical: reads design tokens, generates golden tests, participates in visual iteration | `logic-tier` default / `ui-vision-tier` for UI-critical | xhigh / high |
| `visual-validator` | Semantic vision diff between rendered UI/golden diffs and Stitch mockup; produces discrepancy reports; never edits code | `ui-vision-tier` | high |
| `architect` | Fast deterministic pattern scanning before and after workstreams; read-only guard | `mechanical-tier` | high |
| `reviewer` | Deep review of completed workstreams against spec/plan/design-tokens/golden-tests/architecture-log/gates | `review-tier` | high |

The orchestrator is a skill/procedure, not a coding agent. It dispatches these agents and asks the user for missing or high-stakes decisions.

Concrete model choices are resolved per target machine. See `MODEL_STRATEGY.md` for capability tiers, `subagents.agentOverrides`, and thinking-level constraints.

---

## Runtime configuration

A target project should contain an `AGENTS.md` based on this harness template. Required values include:

- project name
- app type
- app directory
- spec path
- plan output path
- review output path
- design tokens path
- Stitch mockups path
- golden test paths
- architecture decision log path
- package/application id for mobile build/install gates
- tech stack and architecture rules
- quality gates

If values are missing, the orchestrator/agents ask the user. They must not invent values.

---

## Pipeline (Updated)

```text
Phase 0: Resolve config + scaffold + extract design tokens from Stitch HTML
         ↓ user approval
Phase 1: Planner creates plan with UI-critical annotations and design token references
         ↓ user approval
Phase 2: For each workstream in dependency order:
          2a. arch_check.sh: deterministic pre-workstream consistency check
          2b. Feature-agent: implement one workstream with native pi-subagents acceptance contract
          2c. Acceptance verify gates: analyze + unit/widget + integration + golden as planned
          2d. [IF UI-critical] golden_check.sh deterministic pre-filter → visual-validator semantic diff → fix loop
          2e. [IF UI-critical] Golden-test-generator: establish visual baseline
          2f. Feature-agent: append architecture log
          2g. arch_check.sh: deterministic post-workstream consistency check
          2h. Update state.json + commit
         ↓
Phase 3: Reviewer: deep review against spec/plan/tokens/goldens/log
         ↓ fixes/re-review if needed
Phase 4: Final quality gate: analyze + test + goldens + integration + build + smoke
```

---

## Workstream types

### Feature workstream — `W{N}`

Creates/modifies production code plus unit/widget tests. Examples:

- app scaffold
- theme/router setup
- repository + provider + screen slice
- database schema addition

### Feature workstream (UI-critical) — `W{N} [UI-critical]`

Creates/modifies visual screens or widgets. Triggered by planner annotation. Includes:

- Design token reading requirement
- Golden test generation
- Visual validation loop (render → compare against mockup → iterate fixes)
- Must validate against a specific Stitch mockup screen

### Integration test workstream — `IT{N}`

Creates integration tests only, usually after a layer or cross-feature boundary is complete.

### End-to-end test workstream — `E2E{N}`

Creates complete user journey tests only.

---

## Design token pipeline (New)

```
Stitch Mockups (code.html + screen.png)
        │
        ▼
design-token-extractor skill
  • Parses all tailwind.config blocks
  • Merges and resolves conflicts
  • Infers component patterns
        │
        ▼
design_tokens.json
  • Colors (light + dark)
  • Typography (families, sizes, weights)
  • Spacing (named scale)
  • Components (inferred structure)
  • Screen catalog
        │
        ▼
All agents reference this single file:
  • Planner: references tokens by name in workstream specs
  • Feature-agent: reads tokens before UI code; uses theme constants
  • Visual-validator: uses token values as expected benchmark
  • Reviewer: verifies token compliance (no hardcoded values)
  • Architect: scans for hardcoded color violations
```

See `STITCH_PIPELINE.md` for full documentation.

---

## Visual validation loop (New)

```
┌──────────────────────────────────────────────────────┐
│  For each UI-critical workstream:                    │
│                                                      │
│  1. Feature-agent implements screen                  │
│  2. Feature-agent generates golden test              │
│  3. Visual-validator renders golden → captures PNG   │
│  4. Visual-validator compares PNG vs Stitch mockup:  │
│     • Layout proportions      • Colors vs tokens     │
│     • Typography              • Spacing              │
│     • Corner radii            • Shadows              │
│     • Icons                   • Component hierarchy  │
│  5. If MISMATCH: discrepancy report → feature-agent  │
│     → apply fixes → re-render → re-compare           │
│  6. If MATCH: establish permanent golden baseline    │
│                                                      │
│  Max iterations: 3 (configurable)                    │
│  Model: ui-vision-tier (vision-capable)              │
└──────────────────────────────────────────────────────┘
```

---

## Architecture consistency (New)

The deterministic `arch_check.sh` tool runs before and after each workstream; the architect agent explains results when needed:

| Check | What it scans |
|---|---|
| print() in production | `grep -rn "print(" lib/` |
| Bare `!` operators | `grep -rn "\.!\b" lib/` |
| setState overreach | `grep -rn "setState" lib/` |
| dispose() pairing | StatefulWidget count vs dispose() count |
| dynamic type misuse | `grep -rn "dynamic" lib/` outside JSON boundaries |
| Generated file edits | `git diff --name-only` on `.g.dart` files |
| Design token compliance | `grep -rn "Color(0x" lib/` in feature files |
| Golden test coverage | Screen count vs golden test count |
| Architecture log | Freshness and completeness |

Results: PASS (no issues), WARN (minor), FAIL (significant — autonomy-mode recovery before asking user).

---

## Recommended gates for Flutter projects

```bash
cd [app_dir]
flutter pub get
# if code generation is configured
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
# golden tests (if golden test source exists)
flutter test test_goldens/
# if integration tests exist
flutter test integration_test/
# if Android build is configured
flutter build apk --debug
```

Optional device smoke gate:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n [package_id]/.MainActivity
```

---

## Visual validation policy (Updated)

When Stitch mockups are supplied:

- **Phase 0:** Run `design-token-extractor` to parse Stitch HTML → `design_tokens.json`
- **Phase 1:** Planner references design tokens by name in workstream descriptions
- **Phase 2:** Feature-agent generates golden test alongside the widget
- **Phase 2 (visual):** Visual-validator compares rendered golden against Stitch `screen.png`
- **Phase 2 (baseline):** Golden-test-generator establishes permanent visual baseline
- **Policy:**
  - Stitch `screen.png` and `code.html` are **IMMUTABLE** references — never overwrite
  - Golden PNGs in `test/goldens/` are generated artifacts — regenerated at intentional rebaseline
  - `design_tokens.json` is the single machine-readable source of truth
  - CI runs `flutter test test_goldens/` without `--update-goldens` to detect visual regressions
  - Visual validator runs `--update-goldens` during iteration only

---

## Native acceptance contracts (New)

Every workstream carries a native `pi-subagents` `acceptance` contract emitted by the planner and passed by the orchestrator. It includes:

- `criteria`: observable acceptance criteria from the spec
- `evidence`: required proof (`changed-files`, `tests-added`, `commands-run`, `validation-output`)
- `verify`: shell commands (`flutter analyze`, targeted tests, goldens, integration tests)
- `review`: optional reviewer gate
- `stopRules` and `maxFinalizationTurns`: bounded self-review/repair loop

This is the primary mechanism for autonomous reliability: a feature-agent cannot claim success until the acceptance contract is satisfied or residual risk is reported.

## Resume and autonomy

- `docs/state.json` is the source of truth for resume (`workstream → status → runId → commit`).
- The orchestrator uses native `subagent({ action: "status" })` and `subagent({ action: "resume", id })` for async runs.
- Autonomy mode performs bounded automatic retries and tier escalation before asking the user.
- Non-blocking clarifications should use intercom/async channels where available.

## Failure recovery

On workstream failure, the orchestrator does not debug. It first applies autonomy-mode recovery. If recovery is exhausted, it asks the user to choose:

1. reset and retry with same model
2. reset and retry with upgraded model
3. retry in-place with same model
4. retry in-place with upgraded model
5. skip workstream
6. abort pipeline

Additional options for visual validation failure:

7. continue with visual discrepancies (reduce tolerance)
8. skip visual validation for this screen
9. accept current visual state as baseline

Reliability-first default: reset/retry or upgraded retry; skipping requires explicit user approval.

---

## Hard boundaries

| Role | Must not do |
|---|---|
| Orchestrator | implement, review code deeply, decide architecture alone, debug failures itself |
| Planner | implement code or tests |
| Feature-agent | touch files outside assigned scope, make unapproved architecture decisions, hardcode design values |
| Visual-validator | modify production code directly (produces reports only) |
| Architect | modify code (read-only scan) |
| Reviewer | modify production code or author missing tests |

---

## Start prompt pattern

```text
Orchestrator, begin Phase 0 for this project.
Runtime inputs:
- App type: Flutter Android app
- Spec: [SPEC.md]
- App directory: my_app/
- Mockups: design-assets/Stitch-Mockup/ (contains screen.png + code.html per screen)
- Design tokens: docs/design_tokens.json (will auto-extract from Stitch HTML)
- Plan output: specs/plan.md
- Review output: specs/review.md
- Golden test source: my_app/test_goldens/
- Architecture log: docs/ARCHITECTURE_LOG.md
- Package id: com.example.myapp
- Priority: reliability/quality first
- Visual validation: enabled (max 3 iterations per screen)
Ask me for any missing required information.
```

The concrete paths and features above are examples. Replace them for each project.
