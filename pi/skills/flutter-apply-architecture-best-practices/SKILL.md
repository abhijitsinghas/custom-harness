---
name: flutter-apply-architecture-best-practices
description: Apply project-agnostic Flutter architecture best practices. Defaults to layered UI/logic/data separation and can adapt to the runtime-configured state management, routing, persistence, and code generation stack.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Flutter Architecture Best Practices

Use this skill when structuring a Flutter project, adding a feature, reviewing architecture, or refactoring for scalability.

## First: read runtime config

Before recommending or changing architecture, read:

- `AGENTS.md` if present
- the assigned plan/workstream
- `pubspec.yaml`
- existing `lib/` structure
- project-specific architecture rules in the runtime prompt

Do not force Riverpod, Drift, GoRouter, or any package unless the project config/spec already selected them or the user approves the decision.

## Default architecture model

For medium/large Flutter apps, prefer layered separation:

```text
UI / Presentation
  ↓ watches/calls
Logic / State / ViewModel layer
  ↓ calls
Data / Repository / Service layer
  ↓ owns
Persistence, API clients, platform plugins
```

### UI layer

- Widgets render state and collect user input.
- No direct database/network calls from widgets.
- No business rules in build methods.
- Local `setState` only for ephemeral UI state such as focus, animation, or temporary text editing.
- Render loading, empty, error, and data states for async screens.
- Use `Theme.of(context)` and configured design tokens.
- Add semantic labels and stable keys where tests need them.

### Logic/state layer

Adapt to configured state management:

- Riverpod: providers/notifiers own feature state; widgets use `ref.watch` and `ref.read`.
- Bloc/Cubit: blocs own state transitions; widgets dispatch events and render states.
- Provider/ChangeNotifier: keep notifiers focused and testable.
- Other: follow project conventions.

Rules:

- Keep state classes immutable where practical.
- Keep state layer free of `material.dart` unless project explicitly allows UI dependencies.
- Expose behavior-oriented methods, not raw persistence details.
- Inject dependencies for testability.

### Data layer

- Repositories expose use-case-oriented APIs.
- Services/DAOs/API clients own raw persistence and network details.
- Keep external services behind interfaces/adapters when they affect determinism or future swaps.
- Handle offline, retry, caching, and error translation in data/repository layers, not widgets.

## Suggested folder layouts

Use the layout already present in the project unless it is clearly broken. Safe default:

```text
lib/
  main.dart
  app.dart
  core/ or app/          # theme, router, constants
  data/                  # database, api, repositories, sync
  domain/                # pure business rules/use cases if useful
  features/              # feature UI + state
  shared/                # reusable widgets/utilities
```

If generated artifacts already exist in a root layout, preserve them initially to avoid import churn unless the user approves a migration.

## Adding a feature: reliability-first workflow

1. Read the feature workstream and allowed files.
2. Identify dependencies and existing patterns.
3. Add/adjust data model or API DTO only if in scope.
4. Implement repository/service methods.
5. Implement state/controller/view-model.
6. Implement UI with all states.
7. Add stable test keys for planned integration/E2E journeys.
8. Write unit/widget tests.
9. Run generators if configured.
10. Run targeted tests, static analysis, then broader tests.

## Code generation rules

- Never manually edit generated files (`*.g.dart`, `*.freezed.dart`, generated mocks, etc.).
- Run the configured generator, typically:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- If generator output changes unexpectedly outside the workstream, stop and report.

## Error handling

- Convert low-level errors into user-actionable states/messages.
- UI should gracefully handle permission denial, network failure, empty data, invalid input, and unavailable platform services.
- Avoid crashes from null data, disposed controllers, or async race conditions.

## Testing obligations

- Pure business logic: unit tests.
- Repositories/services: unit tests with fakes/in-memory persistence.
- Screens/widgets: widget tests covering loading/empty/error/data and key interactions.
- Multi-screen flows: integration/E2E tests using project-approved APIs.

## Design token compliance

When the project has a `design_tokens.json` file (extracted from Stitch HTML mockups), ALL UI code must reference theme constants, never hardcoded values.

### Colors

```dart
// CORRECT — referencing design tokens
Container(
  color: Theme.of(context).colorScheme.primary,
)

// WRONG — hardcoded value
Container(
  color: Color(0xFF0D7377),
)
```

Read `design_tokens.json` to understand the token → ColorScheme mapping. Common mappings:
- `colors.light.accent` → `colorScheme.primary`
- `colors.light.surface` → `colorScheme.surface`
- `colors.light.background` → `colorScheme.background`
- `colors.light.textPrimary` → `colorScheme.onBackground`
- `colors.light.textSecondary` → `colorScheme.onSurfaceVariant`
- `colors.light.error` → `colorScheme.error`

### Typography

```dart
// CORRECT — referencing design tokens
Text('Title', style: Theme.of(context).textTheme.headlineLarge)

// WRONG — hardcoded style
Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
```

Typography token → TextTheme mapping:
- `typography.h1` → `textTheme.headlineLarge`
- `typography.h2` → `textTheme.headlineMedium`
- `typography.body` → `textTheme.bodyLarge`
- `typography.label` → `textTheme.labelLarge`
- `typography.caption` → `textTheme.bodySmall`

### Spacing

```dart
// CORRECT — referencing design token constants
Padding(
  padding: const EdgeInsets.all(AppSpacing.lg),
)

// WRONG — magic number
Padding(
  padding: const EdgeInsets.all(16),
)
```

Spacing constants should be defined in `lib/core/app_spacing.dart`:

```dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // Screen edge padding
  static const double screenEdge = 16;
  
  // Card gap
  static const double cardGridGap = 12;
}
```

### Exception: theme definition files

Hardcoded values are allowed ONLY in:
- `lib/core/app_theme.dart` (theme definition)
- `lib/core/app_spacing.dart` (spacing constants)
- `lib/core/app_tokens.dart` (design token mapping)

Feature files MUST reference these definitions, never raw values.

## Golden tests for visual regression

For every UI screen or significant widget, generate a golden (visual snapshot) test.

### Golden test file location

```
test_goldens/
├── catalog_grid_screen_golden_test.dart
├── book_detail_screen_golden_test.dart
└── welcome_screen_golden_test.dart
```

### Golden test template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:[app_package]/core/app_theme.dart';
import 'package:[app_package]/features/[feature]/[screen].dart';

void main() {
  group('[ScreenName] golden tests', () {
    testWidgets('renders correctly in light mode', (tester) async) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const [ScreenName](...requiredParams),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType([ScreenName]),
        matchesGoldenFile('goldens/[screen_name]_light.png'),
      );
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const [ScreenName](...requiredParams),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType([ScreenName]),
        matchesGoldenFile('goldens/[screen_name]_dark.png'),
      );
    });
  });
}
```

### Golden test policy

- **Establish baseline:** Run `flutter test --update-goldens test_goldens/` once during initial implementation
- **During visual iteration:** Use `--update-goldens` freely (goldens are transient during validation)
- **After visual parity:** Re-run without `--update-goldens` to confirm baseline sticks
- **CI:** Runs `flutter test test_goldens/` WITHOUT `--update-goldens` to detect regressions
- **Source mockups:** NEVER overwrite Stitch `screen.png` or `code.html` — they are immutable
- **Golden PNGs:** Stored in `test/goldens/` — these ARE version-controlled as visual baselines

### Anti-patterns to avoid

- Do NOT use network images in golden tests (use test doubles)
- Do NOT use random content (use fixed test data)
- Do NOT use `DateTime.now()` (freeze time for deterministic rendering)
- Do NOT skip golden tests for UI-critical screens

## Architecture decision log

After completing each workstream, append architectural decisions to `docs/ARCHITECTURE_LOG.md`.

### Format

```markdown
## [WORKSTREAM_ID]: [Name] — [Date]

**Files created:** ...
**Files modified:** ...
**Patterns used:**
- State: [pattern used]
- Routing: [router pattern]
- Widget composition: [how widgets are composed]
**Design token usage:**
- Colors: [which token → which element]
- Spacing: [which scale → which context]
- Typography: [which style → which text]
**Decisions:**
- [Architecture/naming/pattern decisions]
```

### Purpose

- Maintains consistency across workstreams (fresh agent contexts need decision continuity)
- Enables reviewer to verify decisions match implementation
- Prevents architecture drift (W03 follows pattern from W01 that W02 ignored)

## Architecture decision gate

Ask the user before:

- introducing a new state-management package
- changing folder architecture
- changing persistence strategy
- altering code-generation strategy
- adding external services/auth/sync providers
- performing large migrations
- using hardcoded design values when `design_tokens.json` exists
- skipping golden tests for UI-critical screens
- modifying the golden test or architecture log file conventions
