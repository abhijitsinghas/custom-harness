# The Little Library — Build Instructions with Custom Harness

This document is project-specific. Keep it separate from the generic agents/skills so the harness remains project-agnostic.

Use these steps when you create the **actual implementation directory** for The Little Library. Do not implement in the research-only v3 directory unless you intentionally choose it as the target project.

---

## Source research artifacts

Current research source directory:

```text
/Users/abhijitsingh/Development/Projects/pi-workspace/research/the-little-library/v3/
```

Important artifacts:

```text
SPEC.md
01-user-stories.md
01-design.md
01-stitch-prompts.md
06-implementation-plan.md
PLAYBOOK.md
lib/                              # generated theme/router/widgets/database artifacts
TheLittleLibrary-Stitch-Mockup/    # Stitch screenshots + HTML/code exports
```

Recommended actual app directory name inside the target implementation repo:

```text
the_little_library/
```

Recommended package/application id:

```text
com.abhijits.thelittlelibrary
```

If you prefer a different package id, decide before scaffold and keep it consistent.

---

## Step 1 — Create a clean implementation workspace

Example:

```bash
mkdir -p /Users/abhijitsingh/Development/Projects/pi-workspace/apps/the-little-library
cd /Users/abhijitsingh/Development/Projects/pi-workspace/apps/the-little-library
git init
```

**Copy** research artifacts into this workspace, preserving a clear docs/artifacts layout. Do **not** move, rename, or delete the source files in the research directory.

Recommended target layout:

```text
[target]/
├── docs/
│   ├── SPEC.md
│   ├── 01-user-stories.md
│   ├── 01-design.md
│   ├── 01-stitch-prompts.md
│   ├── 06-implementation-plan.md
│   └── PLAYBOOK.md
├── generated/
│   └── lib/                         # copied from research v3/lib
└── design-assets/
    └── TheLittleLibrary-Stitch-Mockup/ # copied from research mockup folder
```

Manual copy is fine. If using shell commands, use `cp`/`rsync`, not `mv`. Example:

```bash
RESEARCH=/Users/abhijitsingh/Development/Projects/pi-workspace/research/the-little-library/v3
TARGET=/Users/abhijitsingh/Development/Projects/pi-workspace/apps/the-little-library

mkdir -p "$TARGET/docs" "$TARGET/generated" "$TARGET/design-assets"

cp "$RESEARCH/SPEC.md" "$TARGET/docs/SPEC.md"
cp "$RESEARCH/01-user-stories.md" "$TARGET/docs/01-user-stories.md"
cp "$RESEARCH/01-design.md" "$TARGET/docs/01-design.md"
cp "$RESEARCH/01-stitch-prompts.md" "$TARGET/docs/01-stitch-prompts.md"
cp "$RESEARCH/06-implementation-plan.md" "$TARGET/docs/06-implementation-plan.md"
cp "$RESEARCH/PLAYBOOK.md" "$TARGET/docs/PLAYBOOK.md"

rsync -a "$RESEARCH/lib/" "$TARGET/generated/lib/"
rsync -a "$RESEARCH/TheLittleLibrary-Stitch-Mockup/" \
  "$TARGET/design-assets/TheLittleLibrary-Stitch-Mockup/"
```

After copying, the original research directory should remain unchanged.

---

## Step 2 — Install the custom harness

From the target implementation workspace:

```bash
/path/to/research/custom-harness/install.sh
```

Example:

```bash
/Users/abhijitsingh/Development/Projects/pi-workspace/research/custom-harness/install.sh
```

Then verify:

```text
.pi/agents/planner.md
.pi/agents/feature-agent.md
.pi/agents/reviewer.md
.pi/skills/orchestrator/SKILL.md
AGENTS.md
FRAMEWORK.md
MODEL_STRATEGY.md
```

---

## Step 3 — Fill target `AGENTS.md`

Use this project-specific runtime config:

```markdown
# AGENTS.md — The Little Library Runtime Configuration

## Project Identity

| Field | Value |
|---|---|
| Project name | The Little Library |
| App type | Flutter app |
| Primary platform | Android first; iOS-compatible later |
| Package/application id | com.abhijits.thelittlelibrary |
| Organization for `flutter create --org` | com.abhijits |

## Project Paths

| Path | Value | Required? |
|---|---:|---:|
| Product spec | `docs/SPEC.md` | Yes |
| User stories | `docs/01-user-stories.md` | Yes |
| Design system | `docs/01-design.md` | Yes |
| Mockups/screenshots | `design-assets/TheLittleLibrary-Stitch-Mockup/` | Yes |
| Existing generated code/artifacts | `generated/lib/` | Yes |
| Flutter app directory | `the_little_library/` | Yes |
| Plan output | `specs/plan.md` | Yes |
| Review output | `specs/review.md` | Yes |
| Integration test directory | `the_little_library/integration_test/` | Yes |
| Build instructions | `docs/PLAYBOOK.md` | No |

## Runtime Decisions

| Decision | Value |
|---|---|
| Implementation priority | Reliability/quality first |
| Approval style | Ask before architecture/scaffold/plan/recovery decisions |
| Workstream style | Gated workstreams with commits |
| Test strategy | Unit + widget + integration/E2E |
| Visual validation | Stitch screenshots are immutable references |
| Git policy | Commit after each successful workstream |

## Technology Stack

| Layer | Technology / Package | Notes |
|---|---|---|
| UI framework | Flutter 3.x | Android first |
| State management | flutter_riverpod + riverpod_annotation/generator | Use generated providers where practical |
| Routing | go_router | Preserve generated route map initially |
| Local persistence | Drift + SQLite + FTS5 | Offline-first |
| Remote API/Auth | Supabase, Google Books/Open Library where specified | Keep behind abstractions |
| Camera/OCR/Voice | camera/image_picker, ML Kit, speech_to_text | Use fakes in tests |
| Code generation | build_runner, drift_dev, riverpod_generator, json_serializable/freezed as needed | Do not manually edit generated files |
| Testing | flutter_test, integration_test, mockito/mocktail, patrol if needed | Modern integration_test approach |

## Architecture Rules

- Preserve generated root layout initially: `lib/app_theme.dart`, `lib/app_router.dart`, `lib/widgets/*`, `lib/database/*`.
- Copy generated `lib/` from `generated/lib/` into `the_little_library/lib/` during scaffold/foundation.
- Do not move generated files into a new app/core hierarchy unless approved.
- UI widgets must not contain business logic or direct DB/API access.
- Use repository/service abstractions for data, sync, APIs, OCR, barcode, voice, and auth.
- Prefer Riverpod-generated providers where practical.
- Generated Drift/Riverpod/freezed/json files must not be manually edited.
- Use UUID v4 for primary ids.
- Preserve offline-first behavior; cloud/sync must not block local CRUD.
- Treat Stitch screenshots as visual references; do not overwrite them with `--update-goldens`.

## Quality Gates

```bash
cd the_little_library
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test integration_test/
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.abhijits.thelittlelibrary/.MainActivity
```
```

Commit this config:

```bash
git add AGENTS.md FRAMEWORK.md MODEL_STRATEGY.md .pi package.json package-lock.json
git commit -m "Install project harness and runtime config"
```

Adjust files in the commit command based on what exists.

---

## Step 4 — Start Pi orchestrator

In Pi:

```text
/name orchestrator
```

Then use this prompt:

```text
Orchestrator, begin Phase 0 for The Little Library.

Reliability/quality first. Do not implement in any research directory.
Use this target project root only.

Runtime inputs:
- App type: Flutter app
- Spec: docs/SPEC.md
- User stories: docs/01-user-stories.md
- Design system: docs/01-design.md
- Mockups/screenshots: design-assets/TheLittleLibrary-Stitch-Mockup/
- Existing generated artifacts: generated/lib/
- Existing implementation plan to validate: docs/06-implementation-plan.md
- App directory: the_little_library/
- Plan output: specs/plan.md
- Review output: specs/review.md
- Integration test directory: the_little_library/integration_test/
- Package/application id: com.abhijits.thelittlelibrary
- Flutter org: com.abhijits

Required behavior:
1. Resolve runtime config from AGENTS.md and this prompt.
2. Check git status and require clean/recoverable state.
3. If the Flutter project is missing, ask for approval before running flutter create.
4. Preserve the generated root lib layout from generated/lib/ by copying files into the Flutter app; do not move files out of `generated/lib/` or the research directory.
5. Ask for approval before the planner writes/replaces specs/plan.md.
6. Ask for approval before implementation starts.
7. Use gated workstreams, commits, reviewer verification, and quality gates.
8. Treat Stitch screenshots as immutable visual references.
Ask me one focused question if any required value is missing.
```

---

## Step 5 — Expected Phase 0 actions

The orchestrator should verify/ask before doing these:

```bash
flutter create --org com.abhijits --project-name the_little_library the_little_library
```

Add dependencies from `SPEC.md` and current plan. Expected baseline includes:

```text
flutter_riverpod
riverpod_annotation
riverpod_generator
drift
sqlite3_flutter_libs
sqlite3
path
path_provider
supabase_flutter
camera
image_picker
google_mlkit_text_recognition
google_mlkit_barcode_scanning
speech_to_text
go_router
dio
google_fonts
shimmer
uuid
intl
freezed_annotation
json_annotation
build_runner
drift_dev
freezed
json_serializable
mockito
mocktail
integration_test
patrol
```

Copy generated artifacts into the Flutter app package. This is a copy operation only; keep `generated/lib/` intact as the source snapshot:

```bash
rm -rf the_little_library/lib/widgets the_little_library/lib/database
cp generated/lib/app_theme.dart the_little_library/lib/app_theme.dart
cp generated/lib/app_router.dart the_little_library/lib/app_router.dart
cp -R generated/lib/widgets the_little_library/lib/widgets
cp -R generated/lib/database the_little_library/lib/database
```

Then run:

```bash
cd the_little_library
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

## Step 6 — Planner prompt if running manually

If you choose to run the planner directly instead of orchestrator:

```text
Planner, create a reliability-first implementation plan for The Little Library.

Inputs:
- Runtime config: AGENTS.md
- Spec: docs/SPEC.md
- User stories: docs/01-user-stories.md
- Design system: docs/01-design.md
- Mockups/screenshots: design-assets/TheLittleLibrary-Stitch-Mockup/
- Existing generated code: generated/lib/
- Existing implementation plan to validate/improve: docs/06-implementation-plan.md
- App directory: the_little_library/
- Plan output: specs/plan.md

Requirements:
- Preserve generated root layout initially.
- Convert the existing docs/06-implementation-plan.md into orchestrator-ready workstreams.
- Include Feature, Integration Test, and E2E workstreams.
- Include exact files, dependencies, acceptance criteria, test files, and gate commands.
- Insert IT/E2E workstreams after meaningful layer/story completion points.
- Assign reliability-first model/thinking guidance per workstream.
- Treat Stitch screenshots as immutable references for visual validation.
- Ask one focused question if any required information is missing.
```

---

## Step 7 — Recommended gated execution groups

Use the planner output as canonical, but expected groups are:

### Gate 1 — Foundation

```text
W01 → W02 → W03
```

Expected result:

- Flutter app exists
- generated theme/router/widgets/database copied
- app shell composes
- database opens for app/tests
- router guard behavior testable

### Gate 2 — Core MVP

```text
W04 → W05 → W06 → W07 → W08
IT01 → IT02 → IT03
E2E01 → E2E02
```

Expected result:

- onboarding/library creation
- manual/preview add book
- catalog/search
- book detail
- duplicate warning

### Gate 3 — Circulation and locations

```text
W09 → W10
IT04 → IT05
E2E03
```

### Gate 4 — Advanced input

```text
W11 → W12
IT06
```

### Gate 5 — Admin/sync/polish

```text
W13 → W14 → W15
E2E04
```

---

## Step 8 — Golden/visual validation prompt

Use after a screen exists:

```text
For the implemented [screen name] screen, compare it against the corresponding Stitch screenshot under design-assets/TheLittleLibrary-Stitch-Mockup/.

Rules:
- Do not overwrite the Stitch screenshot.
- Render Flutter at the same logical device size where practical.
- If creating goldens, store Flutter baselines separately from source mockups.
- Produce a prioritized visual discrepancy report: layout, typography, colors, spacing, icons, states, dark mode, accessibility.
- Only update Flutter goldens after I approve the visual baseline.
```

---

## Step 9 — Reviewer prompt if running manually

```text
Reviewer, review completed workstreams for The Little Library.

Inputs:
- Runtime config: AGENTS.md
- Spec: docs/SPEC.md
- Plan: specs/plan.md
- App directory: the_little_library/
- Review output: specs/review.md

Run configured quality gates where possible:
- flutter pub get
- dart run build_runner build --delete-conflicting-outputs
- flutter analyze
- flutter test
- flutter test integration_test/
- flutter build apk --debug

Verify:
- implementation matches plan/spec
- generated files were not manually edited
- integration/E2E tests exist and cover planned journeys
- no legacy flutter_driver usage
- UI uses theme/design tokens
- offline-first behavior is preserved
- Stitch screenshots are not overwritten

Write blockers, should-fix items, nice-to-have items, test verification, and final verdict to specs/review.md.
```

---

## Step 10 — Final quality checklist

Before calling the app implementation complete:

- [ ] `flutter analyze` clean
- [ ] `flutter test` passes
- [ ] `flutter test integration_test/` passes or skipped only with explicit approval
- [ ] `dart run build_runner build --delete-conflicting-outputs` clean
- [ ] `flutter build apk --debug` succeeds
- [ ] APK installs and launches on Android device
- [ ] key MVP flows manually smoke-tested
- [ ] visual discrepancy report reviewed for critical screens
- [ ] no generated files manually edited
- [ ] no source mockup/golden screenshots overwritten
- [ ] review report verdict is `APPROVE`
