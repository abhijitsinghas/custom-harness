---
name: dart-add-unit-test
description: Write project-agnostic Dart and Flutter unit/widget tests for logic, repositories, providers/controllers, and widgets. Adapts to the configured test stack and avoids implementation-detail tests.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-04
---

# Dart and Flutter Unit/Widget Testing

Use this skill when adding logic, fixing bugs, creating repositories/controllers, or implementing widgets.

## First: read runtime config

Check:

- `AGENTS.md`
- workstream plan
- `pubspec.yaml`
- existing `test/` style
- configured mock library (`mockito`, `mocktail`, fakes, etc.)
- configured state management and persistence

Do not introduce a new test package without approval.

## Choosing the test type

| Target | Preferred test |
|---|---|
| Pure Dart functions/classes | `package:test` or `flutter_test` as project convention dictates |
| Repositories/services | unit tests with fakes/mocks/in-memory persistence |
| State/controllers/providers | unit tests with dependency overrides/test containers |
| Widgets/screens | `flutter_test` widget tests |
| Multi-screen journeys | integration/E2E tests, not unit tests |

For Flutter packages, `flutter test` can run both unit and widget tests.

## Test structure

Mirror `lib/` under `test/`:

```text
lib/features/catalog/catalog_screen.dart
→ test/features/catalog/catalog_screen_test.dart
```

Name tests by behavior:

```dart
test('should return empty list when repository has no items', () async { ... });

testWidgets('should show validation error when title is empty', (tester) async { ... });
```

## Unit test workflow

1. Create the test file first when practical.
2. Arrange deterministic inputs/fakes.
3. Act through the public API.
4. Assert observable behavior.
5. Cover happy path, edge cases, error cases, and empty cases.
6. Run the targeted test.
7. Fix implementation until it passes.
8. Run static analysis.

Commands:

```bash
cd [app_dir]
flutter test test/path/to/file_test.dart
flutter analyze
```

## Mocking/fakes

Prefer simple fakes when they are clearer than generated mocks.

If using Mockito for async methods:

```dart
when(mockClient.fetch()).thenAnswer((_) async => result);
```

Do not use `thenReturn` for `Future`/`Stream` methods.

If using Mocktail, register fallback values where needed and keep verifications behavior-oriented.

## Testing state management

Adapt to configured stack.

### Riverpod pattern

```dart
final container = ProviderContainer(
  overrides: [
    repositoryProvider.overrideWith((ref) => FakeRepository()),
  ],
);
addTearDown(container.dispose);

final state = await container.read(featureProvider.future);
expect(state.items, hasLength(1));
```

### Bloc/Cubit pattern

Use bloc test utilities if configured, otherwise instantiate the bloc/cubit with fakes and assert emitted states.

### ChangeNotifier pattern

Instantiate notifier with fake dependencies, call public methods, and assert state/listener behavior.

## Testing persistence

If the project uses a local database, prefer in-memory databases for tests when available:

```dart
final db = AppDatabase.memory(); // project-specific helper if configured
addTearDown(db.close);
```

If no in-memory helper exists and database tests are required, add one only if the workstream allows it or ask the orchestrator.

## Widget tests

Wrap widgets with required app context:

```dart
await tester.pumpWidget(
  TestAppWrapper(
    child: WidgetUnderTest(...),
  ),
);
```

If no test wrapper exists, build the minimal wrapper using project-configured providers/router/theme.

Cover:

- loading state
- empty state
- error state
- data state
- main user interactions
- accessibility labels for icon-only controls

Prefer stable keys only where they represent public test hooks or planned integration/E2E targets.

## Anti-patterns

- `expect(true, isTrue)`
- testing private implementation details
- sleeping with arbitrary delays instead of using pumps/fakes
- hitting real network services in unit/widget tests
- depending on test order
- adding broad golden tests for unstable UI before layout is approved
