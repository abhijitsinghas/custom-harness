---
name: flutter-apply-architecture-best-practices
description: Architects a Flutter application using Riverpod with the MVVM + Repository layered approach. Use when structuring a new project or refactoring for scalability.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-05-30
---
# Architecting Flutter Applications with Riverpod

## Contents
- [Architectural Layers](#architectural-layers)
- [Project Structure](#project-structure)
- [Riverpod Patterns](#riverpod-patterns)
- [Workflow: Implementing a New Feature](#workflow-implementing-a-new-feature)
- [Examples](#examples)

## Architectural Layers

Enforce strict Separation of Concerns by dividing the application into distinct layers. Never mix UI rendering with business logic or data fetching. Use Riverpod for all state management and dependency injection.

### UI Layer (Presentation)
- **Views:** Reusable, lean widgets. Only UI-specific logic (animations, layout, simple routing). Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod integration.
- **State access:** Use `ref.watch(provider)` in `build()` for reactive reads, `ref.read(provider.notifier)` in callbacks for one-shot actions.
- **No business logic, no direct database access.** Delegate everything to providers.
- **Local ephemeral state:** Only for truly local concerns (text field focus, animation controller, scroll position). Use `StatefulWidget` + `setState` for these only.

### Logic Layer (Providers)
- **Providers are the ViewModel layer.** Use `@riverpod` annotation + `riverpod_generator` for code generation.
- **Notifier:** `Notifier<T>` or `AsyncNotifier<T>` for mutable state. Expose immutable state via the `state` property.
- **Async state:** Use `AsyncNotifier<T>` returning `AsyncValue<T>`. Consumers render with `AsyncValue.when(data:, loading:, error:)`.
- **Providers must NOT import `package:flutter/material.dart`.** Keep providers pure Dart — importable by tests without Flutter.

### Data Layer
- **DAOs/Services:** Raw database access (drift DAOs), API clients (http). Stateless utility classes.
- **Repositories:** Consume DAOs/Services. Transform raw data to canonical drift models. Handle caching, offline, retry. Expose `Stream` or `Future`.
- **Dependency injection:** Repositories are Riverpod providers (`Provider<BookRepository>`). DAOs are injected into repositories via constructors or provider refs.

## Project Structure

Organize by feature for UI, by type for data:

```
lib/
├── core/                  # Theme, constants, extensions, l10n/
│   ├── theme.dart
│   └── utils.dart
├── data/                  # Data layer (by type)
│   ├── database/          # drift tables, DAOs, AppDatabase
│   ├── api/               # REST API clients, DTOs
│   ├── sync/              # Sync engine
│   └── repositories/      # Repository implementations
├── features/              # UI layer (by feature)
│   ├── catalog/
│   │   ├── catalog_screen.dart
│   │   └── catalog_provider.dart
│   ├── book_detail/
│   │   ├── book_detail_screen.dart
│   │   └── book_detail_provider.dart
│   └── add_book/
│       ├── add_book_screen.dart
│       └── add_book_provider.dart
├── app.dart               # MaterialApp.router, ProviderScope
└── main.dart              # Entry point
```

## Riverpod Patterns

### Provider Definitions

```dart
// Database (singleton)
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

// Repository (depends on database)
@Riverpod(keepAlive: true)
BookRepository bookRepo(BookRepoRef ref) {
  return BookRepository(db: ref.watch(databaseProvider));
}

// Async state for a feature screen (auto-dispose when screen leaves)
@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  @override
  Future<List<Book>> build() async {
    final repo = ref.watch(bookRepoProvider);
    return repo.getAllBooks();
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(bookRepoProvider);
      return repo.search(query);
    });
  }
}
```

### Consuming Providers in Widgets

```dart
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(catalogNotifierProvider);

    return catalogState.when(
      data: (books) => BookListView(books: books),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(catalogNotifierProvider),
      ),
    );
  }
}
```

### Handling user actions

```dart
// In a widget callback (NOT in build):
ref.read(catalogNotifierProvider.notifier).search(query);

// Or for simple state:
ref.read(someNotifierProvider.notifier).update(value);
```

## Workflow: Implementing a New Feature

- [ ] **Step 1: Define drift table / API DTO.** Create or update table definitions in `data/database/`. Run `build_runner`.
- [ ] **Step 2: Implement DAO methods.** Add queries to the DAO for the new feature's data access patterns.
- [ ] **Step 3: Implement Repository.** Create/update repository with methods that consume DAOs. Expose `Future` or `Stream`.
- [ ] **Step 4: Create Riverpod providers.** Repository provider + feature-specific `AsyncNotifier` provider.
- [ ] **Step 5: Implement the Screen widget.** `ConsumerWidget` that watches the provider and renders all states.
- [ ] **Step 6: Write unit tests.** Test providers with `ProviderContainer(overrides: [...])` and `AppDatabase.memory()`.
- [ ] **Step 7: Write widget tests.** Test screens with `ProviderScope(overrides: [...])` wrapping `MaterialApp`.
- [ ] **Step 8: Run validator.** `dart analyze` + `flutter test` + `flutter test integration_test/`.

## Examples

### Data Layer: Repository with Provider

```dart
// data/database/tables.dart
class Books extends Table {
  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
}

// data/database/dao.dart
@DriftAccessor(tables: [Books])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(AppDatabase db) : super(db);

  Future<List<Book>> getAllBooks() => select(books).get();
  Future<Book?> getBook(String id) => (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
}
```

### Logic Layer: Riverpod AsyncNotifier

```dart
// features/book_detail/book_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'book_detail_provider.g.dart';

@riverpod
class BookDetailNotifier extends _$BookDetailNotifier {
  @override
  Future<Book> build(String bookId) async {
    final repo = ref.watch(bookRepoProvider);
    final book = await repo.getBook(bookId);
    if (book == null) throw Exception('Book not found');
    return book;
  }

  Future<void> updateTitle(String newTitle) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(bookRepoProvider);
      return repo.updateTitle(bookId, newTitle);
    });
  }
}
```

### UI Layer: ConsumerWidget with All States

```dart
// features/book_detail/book_detail_screen.dart
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailNotifierProvider(bookId));

    return state.when(
      data: (book) => Scaffold(
        appBar: AppBar(title: Text(book.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
              if (book.author != null) Text('by ${book.author}'),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load book: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookDetailNotifierProvider(bookId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
