# AGENTS.md — Project Runtime Configuration Template

> This file is intentionally **project-agnostic**. Copy/edit it in the target project after installing the harness. The orchestrator and agents must treat this as runtime configuration, not hardcoded product knowledge.

## How agents should use this file

- Read this file first.
- If a required value is missing, ask the user exactly one focused question via `ask_user`.
- Do not assume product-specific paths, package names, features, tech stack, or design artifacts.
- Prefer values passed in the orchestrator start prompt over values in this template.
- Keep implementation constrained to the configured app directory.

---

## Project Identity

| Field | Value |
|---|---|
| Project name | `[REQUIRED: e.g. My App]` |
| App type | `[Flutter app / Dart package / other]` |
| Primary platform | `[Android / iOS / web / desktop / multi-platform]` |
| Package/application id | `[REQUIRED for mobile build/install, e.g. com.example.app]` |
| Organization for `flutter create --org` | `[e.g. com.example]` |

---

## Project Paths

All paths are relative to the project root unless absolute.

| Path | Value | Required? |
|---|---:|---:|
| Product spec | `[path/to/SPEC.md]` | Yes |
| User stories | `[optional path/to/user-stories.md]` | No |
| Design system | `[optional path/to/design.md]` | No |
| Mockups/screenshots | `[optional path — Stitch directory with */screen.png + */code.html subfolders]` | For visual validation |
| Design tokens (JSON) | `[path/to/design_tokens.json]` | Auto-generated from Stitch HTML |
| Stitch HTML mockups | `[same as mockups path]` | Parsed for design token extraction |
| Existing generated code/artifacts | `[optional path/to/generated/]` | No |
| Flutter app directory | `[app_dir/]` | Yes for Flutter |
| Plan output | `specs/plan.md` | Yes |
| Review output | `specs/review.md` | Yes |
| Integration test directory | `[app_dir]/integration_test/` | Yes for Flutter |
| Golden test source | `[app_dir]/test_goldens/` | For golden test dart files |
| Golden test images | `[app_dir]/test/goldens/` | Golden PNG baselines |
| Architecture decision log | `docs/ARCHITECTURE_LOG.md` | For consistency across workstreams |
| Build instructions | `[optional path/to/build-instructions.md]` | No |

---

## Runtime Decisions

| Decision | Value |
|---|---|
| Implementation priority | `Reliability/quality first` |
| Approval style | `Ask before architecture/scaffold/plan/recovery decisions` |
| Workstream style | `Gated workstreams with commits` |
| Test strategy | `Unit + widget + golden + integration/E2E where applicable` |
| Visual validation | `Use visual-validator agent to compare rendered goldens vs Stitch mockups` |
| Golden test policy | `Generate golden tests for all UI screens; store in test/goldens/; never overwrite source mockups` |
| Git policy | `Commit after each successful workstream` |

---

## UI / Visual Validation

| Decision | Value |
|---|---|
| Visual validation | `Enabled` (default when mockups are present) |
| Max visual iterations | `3` (max 5, configurable per screen) |
| Golden test framework | `flutter_test` (default), or `alchemist` |
| Visual comparison method | `vision` (GPT-5.5 compares rendered goldens vs mockups) |
| Design token source | `design_tokens.json` (extracted from Stitch HTML) |

---

## Technology Stack

Fill only what applies. Agents must not infer missing values without asking.

| Layer | Technology / Package | Notes |
|---|---|---|
| UI framework | `[Flutter version/channel]` |  |
| State management | `[e.g. Riverpod, Provider, Bloc]` |  |
| Routing | `[e.g. go_router]` |  |
| Local persistence | `[e.g. Drift, Isar, Hive, SQLite]` |  |
| Remote API | `[e.g. Supabase, REST, GraphQL]` |  |
| Auth | `[e.g. Supabase Auth, Firebase Auth]` |  |
| Code generation | `[e.g. build_runner, riverpod_generator, json_serializable]` |  |
| Testing | `[flutter_test, integration_test, mockito/mocktail, patrol, alchemist for golden tests]` |  |

---

## Architecture Rules

Replace this section with project-specific rules. The defaults below are safe for medium/large Flutter apps.

- UI widgets must not contain business logic or direct database/network access.
- State/controllers/view-models call repositories/services.
- Data repositories own persistence/API details and return typed domain/data models.
- Generated files must not be manually edited.
- **No hardcoded design tokens in feature UI.** Use `Theme.of(context).colorScheme.*`, `Theme.of(context).textTheme.*`, and named `AppSpacing` constants.
- If `design_tokens.json` exists, all color/typography/spacing values must reference it.
- Tests should verify behavior, not implementation details.
- Golden tests should exist for every UI screen.
- After each workstream, append architectural decisions to `ARCHITECTURE_LOG.md`.
- Accessibility: tappable targets ≥ 48dp, semantic labels for icon-only actions, sufficient contrast.

---

## Quality Gates

For Flutter projects, use these unless the runtime prompt overrides them:

```bash
cd [app_dir]
flutter pub get
# If code generation is configured:
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
# Golden tests (if configured):
flutter test test_goldens/
# If integration tests exist:
flutter test integration_test/
flutter build apk --debug
```

For Android device smoke test, if configured:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n [package_id]/.MainActivity
```

---

## Model Profile

This harness uses a four-model strategy. See `MODEL_STRATEGY.md` for full details.

| Role | Default model | Thinking |
|---|---:|---|
| Orchestrator | No fixed model | high |
| Planner | `openai-codex/gpt-5.5` | high |
| Feature agent (UI-critical) | `openai-codex/gpt-5.5` | high |
| Feature agent (logic) | `opencode-go/deepseek-v4-pro` | xhigh |
| Feature agent (simple) | `opencode-go/deepseek-v4-flash` | high |
| Visual validator | `openai-codex/gpt-5.5` | high |
| Architect | `opencode-go/deepseek-v4-flash` | high |
| Reviewer | `openai-codex/gpt-5.4` | high |
| Final review / critical escalation | `openai-codex/gpt-5.5` | high |

**Removed models:** GPT-5.3-Codex, GPT-5.4-Mini, Kimi K2.6, Qwen3.7 Plus, GLM-5.1.

Concrete model names depend on the local Pi/provider configuration. See `MODEL_STRATEGY.md` for thinking-level constraints.
