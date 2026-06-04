---
name: flutter-add-integration-test
description: Write project-agnostic Flutter integration and E2E tests using the modern integration_test + WidgetTester approach, adapted to runtime-configured app architecture and dependencies.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-04
---

# Flutter Integration and E2E Tests

Use this skill for multi-screen flows, data-layer-to-UI validation, and complete user journeys.

## First: read runtime config

Check:

- `AGENTS.md`
- workstream plan and journeys
- app entry widget
- provider/dependency override strategy
- configured integration test directory
- existing integration tests
- mock/fake/in-memory test utilities

Do not use project-specific package names or paths unless provided by the plan/config.

## Modern Flutter approach

Use:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should complete journey', (tester) async {
    // pump app, interact, assert
  });
}
```

Do **not** use legacy `flutter_driver` or `enableFlutterDriverExtension()` unless runtime config explicitly requires web-driver testing.

## Test planning

For each planned journey, identify:

1. app launch state
2. required seeded data or fakes
3. route/screen path
4. user interactions
5. observable assertions
6. cleanup/reset strategy

Prefer one file per integration workstream and 2–4 journeys per file unless the plan says otherwise.

## App bootstrapping

Pump the real app widget when possible:

```dart
await tester.pumpWidget(
  TestAppWrapper(
    overrides: [
      // configured dependency overrides
    ],
    child: const AppUnderTest(),
  ),
);
await tester.pumpAndSettle();
```

If a project-specific test app wrapper does not exist, create one only if the workstream permits test-support files. Otherwise ask the orchestrator.

## Dependency isolation

- Use in-memory databases when available.
- Use fake repositories/services for network, auth, camera, voice, sync, and platform plugins unless the test is explicitly a device/plugin test.
- Keep each test independent.
- Avoid real external services in CI-style integration tests.

## Widget targeting

Preferred finders:

| Finder | Use |
|---|---|
| `find.byKey(ValueKey(...))` | stable controls/cards/fields targeted by tests |
| `find.text(...)` | user-visible assertions |
| `find.byTooltip(...)` | icon-only buttons with tooltip |
| `find.byType(...)` | broad structural checks; avoid if ambiguous |

Production code should expose stable keys for important journeys when planned. Do not add arbitrary keys everywhere.

## Interaction patterns

```dart
await tester.tap(find.byKey(const ValueKey('submit_button')));
await tester.pumpAndSettle();

await tester.enterText(find.byKey(const ValueKey('title_field')), 'Example');
await tester.pumpAndSettle();

await tester.scrollUntilVisible(
  find.byKey(const ValueKey('target_item')),
  250,
);
```

## Assertions

Assert real user-observable outcomes:

- visible text or status
- navigation destination
- persisted data shown after reload
- validation or error message
- item count/status where meaningful

Avoid meaningless assertions such as `expect(true, isTrue)`.

## Commands

```bash
cd [app_dir]
flutter test integration_test/[file]_test.dart
flutter test integration_test/
flutter analyze
```

If the test is specifically device/plugin/E2E and configured:

```bash
flutter test integration_test/ -d [device]
```

## Visual/golden integration

If using screenshots/mockups:

- Keep design screenshots immutable.
- Do not overwrite Stitch/Figma/source mockups with `--update-goldens`.
- Store Flutter-generated goldens separately.
- Prefer discrepancy reports for cross-renderer differences unless exact pixel baselines are approved.

## Failure handling

If integration tests fail after two focused attempts:

- stop
- report failing test names
- summarize errors
- identify likely owner: test issue, production bug, environment issue, missing test hook
- do not broaden scope without orchestrator approval
