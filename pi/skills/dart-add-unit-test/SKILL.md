---
name: dart-add-unit-test
description: Write and organize unit tests for functions, methods, and classes using package:test for pure Dart logic or flutter_test for Flutter widget tests. Use when creating new logic or fixing bugs to ensure code remains correct and regression-free.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-05-30
---
# Testing Dart and Flutter Applications

## Contents
- [Choosing the Right Test Package](#choosing-the-right-test-package)
- [Structuring Test Files](#structuring-test-files)
- [Writing Unit Tests (package:test)](#writing-unit-tests-packagetest)
- [Writing Widget Tests (flutter_test)](#writing-widget-tests-flutter_test)
- [Executing Tests](#executing-tests)
- [Workflows](#workflows)
- [Examples](#examples)

## Choosing the Right Test Package

| Scenario | Use | Import |
|----------|-----|--------|
| Pure Dart logic (providers, repositories, DAOs, validators, utils) | `package:test` | `import 'package:test/test.dart';` |
| Flutter widgets (screens, custom widgets, interactions) | `flutter_test` | `import 'package:flutter_test/flutter_test.dart';` |
| Integration / E2E (full app on device) | `integration_test` + `flutter_test` | Both |

Both can coexist in the same project. Use `flutter test` to run all tests in a Flutter project.

## Structuring Test Files

- Place all test code within the `test/` directory at the root of the Flutter package.
- Mirror the `lib/` directory structure (e.g., `lib/data/repositories/book_repository.dart` → `test/data/repositories/book_repository_test.dart`).
- Append `_test.dart` to all test file names.
- Integration/E2E tests go in `integration_test/` (not `test/`).

## Writing Unit Tests (package:test)

Use `package:test` for testing providers, repositories, DAOs, validators, and utility functions — anything that doesn't import Flutter.

### Core API

```dart
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    late Calculator calc;

    setUp(() {
      calc = Calculator();
    });

    test('should add two numbers correctly', () {
      expect(calc.add(2, 3), equals(5));
    });

    test('should handle asynchronous operations', () async {
      final result = await calc.fetchRemoteValue();
      expect(result, isNotNull);
    });
  });
}
```

### Testing Riverpod Providers

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test('should return list of books when repository succeeds', () async {
    final container = ProviderContainer(
      overrides: [
        bookRepoProvider.overrideWith((ref) => FakeBookRepository()),
      ],
    );

    final books = await container.read(catalogNotifierProvider.future);

    expect(books, hasLength(3));
    expect(books.first.title, 'Test Book');
  });
}
```

For generated providers (`@riverpod`), the provider variable is auto-named (e.g., `catalogNotifierProvider`).

### Mocking with Mockito

Always use `@GenerateNiceMocks` (not `@GenerateMocks`) and `thenAnswer` for async stubs:

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<ApiClient>()])
import 'api_client_test.mocks.dart';

void main() {
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
  });

  test('should return data on successful API call', () async {
    // CRITICAL: Use thenAnswer for Future-returning methods
    when(mockClient.get(any)).thenAnswer((_) async => Response('{"id": 1}', 200));

    final result = await fetchData(mockClient);

    expect(result.id, equals(1));
    verify(mockClient.get(Uri.parse('https://api.example.com/data'))).called(1);
  });
}
```

## Writing Widget Tests (flutter_test)

Use `flutter_test` for testing widgets, screens, and UI interactions:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('should display book title and author', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookDetailNotifierProvider('1').overrideWith((ref) => fakeBook),
        ],
        child: const MaterialApp(home: BookDetailScreen(bookId: '1')),
      ),
    );

    expect(find.text('The Great Gatsby'), findsOneWidget);
    expect(find.text('F. Scott Fitzgerald'), findsOneWidget);
  });

  testWidgets('should show loading indicator while fetching', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookDetailNotifierProvider('1').overrideWith((ref) => const AsyncLoading()),
        ],
        child: const MaterialApp(home: BookDetailScreen(bookId: '1')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## Executing Tests

| Context | Command |
|---------|---------|
| All tests in a Flutter project | `flutter test` |
| Specific test file | `flutter test test/path/to/file_test.dart` |
| Integration/E2E tests | `flutter test integration_test/` |
| Pure Dart project | `dart test` |
| Pure Dart project, specific file | `dart test test/path/to/file_test.dart` |

**Always use `flutter test` for Flutter projects** — it handles both `package:test` and `flutter_test` files correctly.

## Workflows

### Workflow: Writing Unit Tests for a Provider

- [ ] 1. Create the test file in `test/` mirroring the provider's path in `lib/`.
- [ ] 2. Import `package:test/test.dart` and the target provider.
- [ ] 3. Create a `ProviderContainer` with overrides for dependencies.
- [ ] 4. Write `test()` cases grouped by functionality using `group()`.
- [ ] 5. Use `container.read(provider.future)` for async providers, `container.read(provider)` for sync.
- [ ] 6. Run: `flutter test test/path/to/file_test.dart`.
- [ ] 7. **Feedback Loop:** Run test → review stack trace → fix → re-run until passing.

### Workflow: Writing Widget Tests

- [ ] 1. Create the test file in `test/` mirroring the widget's path in `lib/`.
- [ ] 2. Import `package:flutter_test/flutter_test.dart` and the target widget.
- [ ] 3. Wrap in `ProviderScope(overrides: [...])` + `MaterialApp` for routing and theme.
- [ ] 4. Use `testWidgets()` with `WidgetTester`.
- [ ] 5. Cover all states: loading, empty, error, data.
- [ ] 6. Run: `flutter test test/path/to/file_test.dart`.
- [ ] 7. **Feedback Loop:** Run → review → fix → re-run.

## Examples

### Testing a Drift DAO with In-Memory Database

```dart
import 'package:test/test.dart';
import 'package:the_little_library/data/database/database.dart';

void main() {
  group('BookDao', () {
    late AppDatabase db;
    late BookDao dao;

    setUp(() async {
      db = AppDatabase.memory();
      dao = db.bookDao;
    });

    tearDown(() async {
      await db.close();
    });

    test('should return all books sorted by title', () async {
      await dao.insertBook(const BooksCompanion(title: Value('Zebra'), author: Value('Z')));
      await dao.insertBook(const BooksCompanion(title: Value('Apple'), author: Value('A')));

      final books = await dao.getAllBooks();

      expect(books, hasLength(2));
      expect(books.first.title, 'Apple');
      expect(books.last.title, 'Zebra');
    });
  });
}
```

### Testing an AsyncNotifier Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('CatalogNotifier', () {
    test('should load books on build', () async {
      final container = ProviderContainer(
        overrides: [
          bookRepoProvider.overrideWith((ref) => FakeBookRepository()),
        ],
      );

      final notifier = container.read(catalogNotifierProvider.notifier);
      final state = await container.read(catalogNotifierProvider.future);

      expect(state, hasLength(2));
    });
  });
}
```
