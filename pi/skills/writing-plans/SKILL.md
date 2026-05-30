---
name: writing-plans
description: Creates detailed, bite-sized implementation plans from approved specs. Supports Feature, Integration Test, and E2E Test workstream types. Use when you have a spec or requirements for a multi-step task, before touching code.
---

# Writing Plans

Write comprehensive implementation plans with bite-sized tasks (2-5 minutes each). Supports three workstream types: **Feature (W{N})**, **Integration Test (IT{N})**, and **End-to-End Test (E2E{N})**.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** Ask the user for their preferred plan location, or use a sensible default.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. Each file should have one clear responsibility.

## Task Structure — Feature Workstream (W{N})

Each step is one action (2-5 minutes):
- Write the failing test
- Run it to verify it fails
- Write minimal implementation
- Run tests to verify they pass
- Commit (if user wants commits in the plan)

### Feature task format

```markdown
### Task N: {Component Name}

**Files:**
- Create: `exact/path/to/file.dart`
- Modify: `exact/path/to/existing.dart:123-145`
- Test: `test/exact/path/to/test.dart`

**Step 1: Write the failing test**

```dart
void main() {
  testWidgets('should display book title', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: BookDetailScreen(bookId: '1'))));
    expect(find.text('Test Book'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/path/to/test.dart`
Expected: FAIL (widget not implemented yet)

**Step 3: Write minimal implementation**

```dart
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: Text('Test Book'));
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `flutter test test/path/to/test.dart`
Expected: PASS
```

## Task Structure — Integration Test Workstream (IT{N})

Integration test workstreams validate cross-workstream interactions. They create files only in `integration_test/`.

### Integration test task format

```markdown
### IT01: {Name}

**Type:** Integration Test
**Depends on:** W04 (Catalog Screen), W05 (Book Detail Screen)
**Files to create:**
- `integration_test/catalog_detail_test.dart`

**Journeys covered:**
1. Browse catalog → tap book card → verify detail screen displays correct book data
2. Search for a book → verify filtered results → tap result → verify detail screen
3. Empty catalog → verify empty state message displayed

**Test scaffold:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_little_library/app.dart';
import 'package:the_little_library/data/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IT: Catalog → Book Detail', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.memory();
      await db.into(db.books).insertMultiple([...]);
    });

    tearDown(() async => db.close());

    testWidgets('should navigate from catalog to detail on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWith((ref) => db)],
          child: const TheLittleLibraryApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Journey 1: Browse → tap → verify
      await tester.tap(find.text('Test Book'));
      await tester.pumpAndSettle();
      expect(find.text('Test Book'), findsOneWidget);
    });
  });
}
```
```

## Task Structure — End-to-End Test Workstream (E2E{N})

E2E test workstreams validate complete user stories. They create files only in `integration_test/`.

### E2E test task format

```markdown
### E2E01: {Name}

**Type:** End-to-End Test
**User story:** "As a user, I want to add a book via manual entry, see it in my catalog, and view its details"
**Depends on:** W03 (Add Book), W04 (Catalog), W05 (Book Detail), IT01 (Catalog-Detail Integration)
**Files to create:**
- `integration_test/add_browse_e2e_test.dart`

**Journeys covered:**
1. **Happy path:** Launch app → tap Add Book → fill title + author → save → navigate to catalog → verify book appears → tap book → verify detail screen
2. **Empty fields error:** Tap Add Book → tap save with empty title → verify validation error shown
3. **Search within catalog:** Add multiple books → navigate to catalog → search by title → verify only matching books shown

**Test scaffold:**

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Add Book → Browse → View Detail', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.memory();
    });

    tearDown(() async => db.close());

    testWidgets('complete happy path: add book → verify in catalog → view detail', (tester) async {
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

      // Step 2: Fill in details → save
      await tester.enterText(find.byKey(const ValueKey('title_field')), 'The Hobbit');
      await tester.tap(find.byKey(const ValueKey('save_book_button')));
      await tester.pumpAndSettle();

      // Step 3: Navigate to catalog → verify
      await tester.tap(find.byKey(const ValueKey('nav_catalog')));
      await tester.pumpAndSettle();
      expect(find.text('The Hobbit'), findsOneWidget);

      // Step 4: View detail
      await tester.tap(find.text('The Hobbit'));
      await tester.pumpAndSettle();
      expect(find.text('The Hobbit'), findsOneWidget);
    });
  });
}
```
```

## No Placeholders

Never write these in a plan:
- TBD, TODO, "implement later"
- "Add validation" without showing the validation code
- "Write tests" without showing the test code
- "Similar to Task N" — repeat the code
- References to types/functions not defined in any task
- For test workstreams: "Write integration tests" without listing the journeys

## Quality Checklist (Self-Review)

After writing the plan, check:

### General
1. **Spec coverage** — Can you point to a task for each requirement? Fix gaps.
2. **Placeholder scan** — Any TBD, vague steps, or missing code? Fix them.
3. **Consistency** — Do method signatures and types match across tasks? Fix mismatches.
4. **Completeness** — Are file paths exact? Are test commands specific with expected output?

### Test-Specific
5. **Test placement** — Are IT workstreams after layer completions? E2E after story completions?
6. **Test dependencies** — Do test workstreams list the correct feature workstream dependencies?
7. **Journey clarity** — Can you picture each journey as a real user flow? Add detail if vague.
8. **Test isolation** — Are integration/E2E tests using `AppDatabase.memory()` and provider overrides?

## Execution Handoff

After saving the plan, offer the user a choice:
> "Plan complete at `<path>`. Want me to start implementation, or would you like to review the plan first?"
