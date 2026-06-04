# Project-Agnostic Flutter/Dart Reliability Harness

> Planner → one-workstream implementer → fresh-context reviewer → quality gates.  
> Product-specific information is supplied at runtime through `AGENTS.md`, start prompts, and `ask_user` answers.

## Design goals

1. **Project-agnostic agents** — no product names, paths, package ids, or features are hardcoded in agents/skills.
2. **Reliability first** — plan approval, scoped workstreams, tests, review, and build gates are mandatory unless the user explicitly relaxes them.
3. **Runtime configuration** — each project provides specs, paths, stack, and rules through `AGENTS.md` or the orchestrator start prompt.
4. **Fresh-context review** — implementation and review are separated.
5. **Recoverable execution** — git state and workstream commits determine resume position.

---

## Installed agents

| Agent | Role | Default model | Thinking |
|---|---|---|---:|
| `planner` | Reads config/spec/artifacts/code and writes dependency-ordered workstreams | `openai-codex/gpt-5.5` | high |
| `feature-agent` | Implements exactly one Feature/IT/E2E workstream and commits when green | `openai-codex/gpt-5.3-codex` | high |
| `reviewer` | Reviews completed workstreams against spec/plan/tests/gates | `openai-codex/gpt-5.5` | high |

The orchestrator is a skill/procedure, not a coding agent. It dispatches these agents and asks the user for missing or high-stakes decisions.

Model choices are defaults. See `MODEL_STRATEGY.md` for runtime override guidance and supported thinking-level constraints. In particular, do not assign `xhigh` to `openai-codex/gpt-5.5`; use `high`.

---

## Runtime configuration

A target project should contain an `AGENTS.md` based on this harness template. Required values include:

- project name
- app type
- app directory
- spec path
- plan output path
- review output path
- package/application id for mobile build/install gates
- tech stack and architecture rules
- quality gates

If values are missing, the orchestrator/agents ask the user. They must not invent values.

---

## Pipeline

```text
0. Resolve runtime config and environment
1. Optional scaffold / dependency setup
2. Planner creates or validates plan
3. User approves plan
4. Feature-agent executes one workstream at a time
5. Gate after each workstream or configured phase
6. Reviewer verifies implementation and tests
7. Fix/re-review loop for blockers
8. Final quality gate and smoke test
```

---

## Workstream types

### Feature workstream — `W{N}`

Creates/modifies production code plus unit/widget tests. Examples:

- app scaffold
- theme/router setup
- repository + provider + screen slice
- database schema addition
- feature UI and behavior

### Integration test workstream — `IT{N}`

Creates integration tests only, usually after a layer or cross-feature boundary is complete. Examples:

- onboarding → catalog
- add item → list → detail
- checkout → return

### End-to-end test workstream — `E2E{N}`

Creates complete user journey tests only. Examples:

- new user creates account/library and adds first item
- duplicate prevention journey
- offline local-first journey

---

## Recommended gates for Flutter projects

```bash
cd [app_dir]
flutter pub get
# if code generation is configured
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
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

## Visual validation policy

When design screenshots/mockups are supplied:

- treat the source mockups as immutable references;
- do not overwrite them with `flutter test --update-goldens`;
- store Flutter-generated goldens separately;
- use visual discrepancy reports when exact pixel matching is unrealistic.

---

## Failure recovery

On workstream failure, the orchestrator does not debug. It asks the user to choose:

1. reset and retry with same model
2. reset and retry with upgraded model
3. retry in-place with same model
4. retry in-place with upgraded model
5. skip workstream
6. abort pipeline

Reliability-first default: reset/retry or upgraded retry; skipping requires explicit user approval.

---

## Hard boundaries

| Role | Must not do |
|---|---|
| Orchestrator | implement, review code deeply, decide architecture alone, debug failures itself |
| Planner | implement code or tests |
| Feature-agent | touch files outside assigned scope, make unapproved architecture decisions |
| Reviewer | modify production code or author missing tests |

---

## Start prompt pattern

```text
Orchestrator, begin Phase 0 for this project.
Runtime inputs:
- App type: Flutter Android app
- Spec: SPEC.md
- App directory: my_app/
- Mockups: design-assets/screenshots/
- Plan output: specs/plan.md
- Review output: specs/review.md
- Package id: com.example.myapp
- Priority: reliability/quality first
Ask me for any missing required information.
```

The concrete paths and features above are examples. Replace them for each project.
