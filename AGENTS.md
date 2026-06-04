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
| Mockups/screenshots | `[optional path/to/mockups/]` | No |
| Existing generated code/artifacts | `[optional path/to/generated/]` | No |
| Flutter app directory | `[app_dir/]` | Yes for Flutter |
| Plan output | `specs/plan.md` | Yes |
| Review output | `specs/review.md` | Yes |
| Integration test directory | `[app_dir]/integration_test/` | Yes for Flutter |
| Build instructions | `[optional path/to/build-instructions.md]` | No |

---

## Runtime Decisions

| Decision | Value |
|---|---|
| Implementation priority | `Reliability/quality first` |
| Approval style | `Ask before architecture/scaffold/plan/recovery decisions` |
| Workstream style | `Gated workstreams with commits` |
| Test strategy | `Unit + widget + integration/E2E where applicable` |
| Visual validation | `Use mockups as immutable references; avoid overwriting source-of-truth screenshots` |
| Git policy | `Commit after each successful workstream` |

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
| Testing | `[flutter_test, integration_test, mockito/mocktail, patrol]` |  |

---

## Architecture Rules

Replace this section with project-specific rules. The defaults below are safe for medium/large Flutter apps.

- UI widgets must not contain business logic or direct database/network access.
- State/controllers/view-models call repositories/services.
- Data repositories own persistence/API details and return typed domain/data models.
- Generated files must not be manually edited.
- No hardcoded design tokens in feature UI if a theme/design system exists.
- Tests should verify behavior, not implementation details.
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

Default recommendation: `reliability-first`.

| Role | Recommended capability | Thinking |
|---|---|---|
| Orchestrator | Fast/reliable coordinator | high |
| Planner | Huge-context reasoning/planning model | highest supported; usually `xhigh` for DeepSeek |
| Feature agent — foundation/complex | Strongest coding model | highest supported; `high` for GPT-5.5 |
| Feature agent — medium | Strong coding model | high |
| Feature agent — simple | Fast coding model | high |
| Reviewer | Strongest code-review model | highest supported; `high` for GPT-5.5 |

Concrete model names depend on the local Pi/provider configuration. See `MODEL_STRATEGY.md` in this harness for suggested mappings and thinking-level constraints.
