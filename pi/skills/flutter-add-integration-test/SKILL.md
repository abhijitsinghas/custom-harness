---
name: flutter-add-integration-test
description: Write integration and E2E tests using the modern IntegrationTestWidgetsFlutterBinding approach. Covers setup, authoring, Riverpod provider overrides, and running with flutter test.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-05-30
---
# Implementing Flutter Integration & E2E Tests

## Contents
- [Core Concepts](#core-concepts)
- [Project Setup](#project-setup)
- [Test Authoring](#test-authoring)
- [Riverpod Integration](#riverpod-integration)
- [Execution](#execution)
- [Workflow: Writing an Integration Test](#workflow-writing-an-integration-test)
- [Examples](#examples)

## Core Concepts

Flutter's modern integration testing uses the `integration_test` package with `IntegrationTestWidgetsFlutterBinding`. This approach:

- Uses the same `WidgetTester` / `testWidgets()` API as widget tests — no new API to learn.
- Runs with `flutter test integration_test/` — no separate `flutter drive` needed (except web).
- Works on Android, iOS, macOS, Windows, and Linux.
- Supports Firebase Test Lab via native instrumentation format.

**Legacy note:** The `flutter_driver` + `enableFlutterDriverExtension()` approach is deprecated. Do NOT use it for new tests. The only remaining case for `flutter_driver` is web testing with Chrome (requires `test_driver/integration_test.dart` + `flutter drive`).

## Project Setup

1. Add dependencies:
   ```bash
   cd the_little_library_app
   flutter pub add 'dev:integration_test:{"sdk":"flutter"}'
   flutter pub add 'dev:flutter_test:{"sdk":"flutter"}'
   ```

2. Create the `integration_test/` directory at the project root (next to `lib/` and `test/`).

3. Assign `ValueKey` to critical widgets in production code for reliable targeting:
   ```dart
   FloatingActionButton(
     key: const ValueKey('add_book_fab'),
     onPressed: () { ... },
     child: const Icon(Icons.add),
   )
   ```

4. **No driver extension needed.** Unlike the legacy approach, you do NOT need `enableFlutterDriverExtension()` in `main.dart`. Just use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` in each test file.

## Test Authoring

### Test file structure

```
integration_test/
├── foundation_test.dart        # IT01: Foundation layer integration
├── catalog_detail_test.dart    # IT02: Catalog ↔ Book Detail
├── add_browse_e2e_test.dart    # E2E01: Complete Add & Browse user story
└── sync_e2e_test.dart          # E2E03: Sync user journey
```

### Test boilerplate

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_little_library/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration: Catalog → Book Detail', () {
    testWidgets('should navigate from catalog to book detail when book card is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: TheLittleLibraryApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on the catalog screen
      expect(find.text('My Library'), findsOneWidget);

      // Tap a book card
      await tester.tap(find.byKey(const ValueKey('book_card_123')));
      await tester.pumpAndSettle();

      // Verify book detail screen
      expect(find.text('The Great Gatsby'), findsOneWidget);
    });
  });
}
```

### Widget targeting strategies

| Finder | Use when |
|--------|----------|
| `find.byKey(ValueKey('name'))` | **Preferred.** Most reliable. Add keys to production widgets. |
| `find.text('Label')` | Good for verifying visible text. Fragile if text changes. |
| `find.byType(MyWidget)` | Use sparingly — ambiguous if multiple instances. |
| `find.byIcon(Icons.add)` | Good for icon buttons. |
| `find.byTooltip('Add book')` | Good for icon-only buttons with tooltips. |

### Interaction patterns

```dart
// Tap
await tester.tap(find.byKey(const ValueKey('submit_button')));
await tester.pumpAndSettle();

// Enter text
await tester.enterText(find.byKey(const ValueKey('title_field')), 'The Great Gatsby');
await tester.pumpAndSettle();

// Scroll to make a widget visible
await tester.scrollUntilVisible(
  find.byKey(const ValueKey('book_card_50')),
  200.0,
  scrollable: find.byType(Scrollable).first,
);

// Drag / swipe
await tester.drag(find.byKey(const ValueKey('dismissible_item')), const Offset(-500, 0));
await tester.pumpAndSettle();
```

## Riverpod Integration

Override providers to inject test data, mock services, or use in-memory databases:

```dart
import 'package:the_little_library/data/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should display books from database', (tester) async {
    // Create in-memory database
    final db = AppDatabase.memory();

    // Insert test data
    await db.into(db.books).insert(BooksCompanion(
      title: const Value('Test Book'),
      author: const Value('Test Author'),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
        ],
        child: const TheLittleLibraryApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Book'), findsOneWidget);
  });
}
```

For repositories:

```dart
// Mock repository
class FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> getAllBooks() async => [
    Book(id: '1', title: 'Test Book', author: 'Author'),
  ];
}

// Override in test
ProviderScope(
  overrides: [
    bookRepoProvider.overrideWith((ref) => FakeBookRepository()),
  ],
  child: const TheLittleLibraryApp(),
)
```

## Execution

### Desktop / Mobile (Android, iOS, macOS, Windows, Linux)

```bash
flutter test integration_test/
```

Or target a specific file:

```bash
flutter test integration_test/catalog_detail_test.dart
```

On Android with a connected device, this auto-builds and installs the APK, runs tests, and reports results.

### Web (Chrome) — if needed

Web requires the legacy `flutter_driver` bridge. Only use this for web-specific testing:

1. Create `test_driver/integration_test.dart`:
   ```dart
   import 'package:integration_test/integration_test_driver.dart';
   Future<void> main() => integrationDriver();
   ```

2. Run:
   ```bash
   chromedriver --port=4444 &
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
   ```

## Workflow: Writing an Integration Test

- [ ] **Task 1: Plan the journey.** Identify which screens and interactions the test covers. Write a 1-2 sentence description.
- [ ] **Task 2: Add ValueKeys.** Ensure all target widgets in production code have `ValueKey`. Add missing keys.
- [ ] **Task 3: Create test file.** In `integration_test/`, create a file named after the workstream (e.g., `it01_foundation_test.dart`).
- [ ] **Task 4: Write boilerplate.** Add `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, import `app.dart`, wrap in `ProviderScope`.
- [ ] **Task 5: Write test cases.** Use `testWidgets()`. Follow Arrange → Act → Assert pattern.
- [ ] **Task 6: Run tests.** `flutter test integration_test/` — fix any failures.
- [ ] **Task 7: Feedback Loop.** If `pumpAndSettle` times out → check for infinite animations. If widget not found → add `scrollUntilVisible`. Re-run until passing.

## Examples

### Integration Test: Catalog → Book Detail Navigation

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_little_library/app.dart';
import 'package:the_little_library/data/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IT: Catalog → Book Detail navigation', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.memory();
      await db.into(db.books).insertMultiple([
        const BooksCompanion(title: Value('1984'), author: Value('George Orwell')),
        const BooksCompanion(title: Value('Dune'), author: Value('Frank Herbert')),
      ]);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('should display book list and navigate to detail on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWith((ref) => db)],
          child: const TheLittleLibraryApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify catalog shows books
      expect(find.text('1984'), findsOneWidget);
      expect(find.text('Dune'), findsOneWidget);

      // Tap first book
      await tester.tap(find.text('1984'));
      await tester.pumpAndSettle();

      // Verify book detail screen
      expect(find.text('1984'), findsOneWidget);
      expect(find.text('George Orwell'), findsOneWidget);
    });
  });
}
```

### E2E Test: Full Add & Browse Book Story

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_little_library/app.dart';
import 'package:the_little_library/data/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Add book via manual entry → verify in catalog → view detail', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('complete user journey: add → browse → verify', (tester) async {
      // Launch app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWith((ref) => db)],
          child: const TheLittleLibraryApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Navigate to Add Book
      await tester.tap(find.byKey(const ValueKey('nav_add_book')));
      await tester.pumpAndSettle();

      // Step 2: Fill in book details
      await tester.enterText(find.byKey(const ValueKey('title_field')), 'The Hobbit');
      await tester.enterText(find.byKey(const ValueKey('author_field')), 'J.R.R. Tolkien');
      await tester.pumpAndSettle();

      // Step 3: Save the book
      await tester.tap(find.byKey(const ValueKey('save_book_button')));
      await tester.pumpAndSettle();

      // Step 4: Navigate to catalog
      await tester.tap(find.byKey(const ValueKey('nav_catalog')));
      await tester.pumpAndSettle();

      // Step 5: Verify book appears in catalog
      expect(find.text('The Hobbit'), findsOneWidget);

      // Step 6: Tap book to view detail
      await tester.tap(find.text('The Hobbit'));
      await tester.pumpAndSettle();

      // Step 7: Verify detail screen data
      expect(find.text('The Hobbit'), findsOneWidget);
      expect(find.text('J.R.R. Tolkien'), findsOneWidget);
    });
  });
}
```
