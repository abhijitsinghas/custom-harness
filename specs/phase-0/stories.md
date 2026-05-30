# User Stories — Phase 0: Foundation

> **Source:** `specs/plan.md` (Phase 0 section) + `docs/spec-v2.md` + `docs/The-Little-Library---Proto-2/` (mockups)
> **Workstreams:** 0.1 Project Scaffold & Theme | 0.2 Data Model | 0.3 Repository Interfaces | 0.4 Navigation Shell
> **Integration Gate:** App launches, shows themed catalog screen with working navigation drawer and empty catalog. Database tables created and verified. Repositories compile with generated drift code.

---

# Workstream 0.1 — Project Scaffold & Theme

## Happy Path

### US-0.1.1: App Launch with Material Design 3 Theme
**As a** family member
**I want to** open the app and see a warm, book-themed interface
**So that** the app feels inviting and consistent with the mockups

**Given** the app is installed on an Android device
**When** I launch the app
**Then** the app opens without crash, displays the catalog screen scaffold with the warm brown (`#5D4037`) primary color, cream surface (`#FFF8F0`), and amber (`#FFA000`) accent, matching the mockup CSS tokens.

### US-0.1.2: Theme Respects System Dark Mode
**As a** family member
**I want to** use the app in dark mode when my device is set to dark
**So that** the app is comfortable to use at night

**Given** my Android device is set to dark mode
**When** I launch the app
**Then** the app renders in dark mode with tokens: primary `#D4C4B5`, surface `#2B2930`, background `#1C1B1F`, per the mockup dark theme CSS.

### US-0.1.3: Manual Theme Toggle
**As a** family member
**I want to** toggle between light and dark themes manually
**So that** I can override the system preference

**Given** the app is running in light mode
**When** I tap the theme toggle button (as seen in mockup top-right corner of catalog.html and setup-wizard.html)
**Then** the app switches to dark mode immediately with smooth transition, and persists the choice across app restarts.

### US-0.1.4: pubspec.yaml Includes All Dependencies
**As a** developer
**I want to** have all required packages declared
**So that** the app compiles and subsequent phases have their dependencies ready

**Given** a fresh clone of the repository
**When** I run `flutter pub get`
**Then** all dependencies resolve successfully including: `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `google_mlkit_text_recognition`, `google_mlkit_barcode_scanning`, `googleapis`, `google_sign_in`, `image_picker`, `path_provider`, `share_plus`, `url_launcher`, `intl`, `uuid`, `speech_to_text`, `http`, `go_router`; plus dev dependencies: `build_runner`, `drift_dev`, `mockito`, `coverage`, `flutter_lints`.

### US-0.1.5: Constants and Enums Defined
**As a** developer
**I want to** reuse predefined constants throughout the app
**So that** the codebase is maintainable and consistent

**Given** the constants file exists at `lib/core/constants.dart`
**When** I inspect it
**Then** it defines: `BookFormat { hardcover, paperback, other }`, `BookCondition { new, likeNew, used, worn, damaged }`, `BookStatus { available, checkedOut, loaned }`, `EventType { create, update, delete }`, `EntityType { book, location, genre, tag, author, loan, language }`, plus app strings and 20 predefined genres + 3 built-in languages (English, Hindi, Sanskrit).

### US-0.1.6: Extension Utilities Work Correctly
**As a** developer
**I want to** use utility extensions for common operations
**So that** code is DRY and readable

**Given** the extensions file exists at `lib/core/extensions.dart`
**When** I use the ISBN conversion extension on `"0-06-231500-5"`
**Then** it returns the correct ISBN-13 `"978-0-06-231500-7"`. When I use date formatting with `intl`, it produces localized date strings. When I use string normalization, it strips spaces/punctuation and lowercases correctly.

### US-0.1.7: Levenshtein Distance Utility
**As a** developer
**I want to** compute string similarity for duplicate detection
**So that** fuzzy matching works in later phases

**Given** the utils file exists at `lib/core/utils.dart`
**When** I call Levenshtein distance on `"The Alchemist"` vs `"The Alchemists"`
**Then** it returns a ratio ≥ 80% (or exact distance value that maps to ≥ 80% for similar strings).

### US-0.1.8: Route Constants Defined
**As a** developer
**I want to** navigate using named route constants
**So that** route strings are centralized and typo-free

**Given** the routes file exists at `lib/core/routes.dart`
**When** I inspect it
**Then** it defines all 24 route constants: `kRouteCatalog`, `kRouteBookDetail`, `kRouteBookAdd`, `kRouteBookEdit`, `kRouteScannerBarcode`, `kRouteScannerOcr`, `kRouteVoiceInput`, `kRouteLocations`, `kRouteCheckout`, `kRouteLoan`, `kRouteConflicts`, `kRouteActivity`, `kRouteSettings`, `kRouteSettingsGenres`, `kRouteSettingsTags`, `kRouteSettingsLanguages`, `kRouteDeleted`, `kRouteActiveLoans`, `kRouteExport`, `kRouteShareLibrary`, `kRouteChangeHistory`, `kRouteSetup`, `kRouteForceUpdate`, `kRouteBulkScanner`.

### US-0.1.9: Strict Analysis Configuration
**As a** developer
**I want to** have strict static analysis enabled
**So that** type safety is enforced and bugs are caught early

**Given** `analysis_options.yaml` exists
**When** I run `dart analyze`
**Then** `strict-casts: true`, `strict-inference: true`, and `strict-raw-types: true` are all active with zero warnings/errors on the scaffold code.

### US-0.1.10: Localization Scaffold
**As a** developer
**I want to** have i18n infrastructure ready
**So that** future language support is straightforward

**Given** `lib/l10n/app_en.arb` exists
**When** I inspect it
**Then** it contains the base English app name and common UI strings scaffolded for Flutter `gen-l10n`.

### US-0.1.11: Entry Point with Riverpod ProviderScope
**As a** family member
**I want to** launch an app with proper state management wiring
**So that** all providers work correctly

**Given** `lib/main.dart` exists
**When** I inspect it
**Then** it wraps the app in `ProviderScope`, imports `app.dart`, and contains no direct business logic or UI code.

---

## Edge Cases

### US-0.1.12: Theme Switching During Animation
**Given** the app is animating a screen transition (e.g., drawer opening)
**When** the user toggles theme
**Then** the theme switches without jank, crashes, or unstyled widgets.

### US-0.1.13: Invalid ISBN Extension Input
**Given** the ISBN extension receives `"not-an-isbn"` or an empty string
**When** conversion is attempted
**Then** it returns `null` (or throws a documented exception) rather than producing garbage output.

### US-0.1.14: Levenshtein on Very Long Strings
**Given** two strings of 500+ characters each
**When** Levenshtein distance is computed
**Then** it completes in < 10ms and does not overflow stack or memory.

### US-0.1.15: Date Formatting with Null/Invalid Dates
**Given** a null or unparsable date string
**When** formatted via the date extension
**Then** it returns a fallback string (e.g., `"—"` or `"Unknown date"`) without crashing.

### US-0.1.19: Theme Toggle During Drawer Animation
**Given** the navigation drawer is animating open (50% through slide transition)
**When** the user toggles light/dark theme
**Then** the theme updates without jank, the drawer continues its animation to completion, and no widget rebuilds throw assertion errors.

### US-0.1.20: Theme Toggle During FAB Expansion
**Given** the FAB speed dial is animating its staggered expand (mini-FABs are mid-fan-out)
**When** the user toggles light/dark theme
**Then** the theme updates instantly, the FAB expansion continues smoothly, and labels remain styled correctly.

### US-0.1.21: Theme Toggle During Route Transition
**Given** a route transition (e.g., `/catalog` → `/settings`) is in progress with go_router slide animation
**When** the user toggles light/dark theme
**Then** the transition completes normally, the incoming screen renders with the new theme, and no black frames or flickering occur.

---

## Error States

### US-0.1.16: Missing pubspec Dependency
**Given** a dependency is accidentally omitted from `pubspec.yaml`
**When** `flutter pub get` runs in CI
**Then** the build fails with a clear `pub get` error, and `dart analyze` (if imports exist) fails with unresolved import errors.

### US-0.1.17: analysis_options.yaml Misconfiguration
**Given** `analysis_options.yaml` contains an invalid rule name
**When** `dart analyze` runs
**Then** it emits a diagnostic about the unknown rule rather than silently ignoring it.

---

## Accessibility

### US-0.1.18: Sufficient Color Contrast in Theme
**Given** the theme tokens are applied
**When** measured against WCAG AA standards
**Then** all text-on-background combinations (e.g., on-primary `#FFFFFF` on primary `#5D4037`, on-surface `#1C1B1F` on surface `#FFF8F0`) achieve a contrast ratio ≥ 4.5:1.

---

# Workstream 0.2 — Data Model (drift Tables)

## Happy Path

### US-0.2.1: Database Opens and Creates All Tables
**As a** developer
**I want to** instantiate the drift database
**So that** all tables exist for the app to function

**Given** `lib/data/database/database.dart` defines `AppDatabase`
**When** I open an in-memory database (`AppDatabase.memory()`)
**Then** all 14 tables are created: `Book`, `Author`, `BookAuthor`, `Genre`, `BookGenre`, `Tag`, `BookTag`, `Language`, `BookLoan`, `Room`, `Cupboard`, `Shelf`, `BookShelf`, `ChangeLogEvent`, plus `AppMetadata`.

### US-0.2.2: FTS5 Virtual Table Created
**As a** developer
**I want to** full-text search books by title, ISBN, and publisher
**So that** catalog search is fast

**Given** `lib/data/database/fts.dart` defines an FTS5 virtual table
**When** the database opens
**Then** the FTS5 table exists and indexes `title`, `isbn`, and `publisher` from the Book table.

### US-0.2.3: Book Table Has All 21 Fields
**As a** developer
**I want to** store complete book records
**So that** all user-facing and system fields are persisted

**Given** the Book table schema
**When** inspected
**Then** it contains all 21 fields: `id` (UUID text PK), `title`, `isbn`, `language_id`, `cover_image_path`, `cover_image_url`, `publisher`, `edition`, `publication_date`, `format`, `page_count`, `description`, `condition`, `price_paid`, `purchase_date`, `notes`, `status`, `checked_out_to`, `is_deleted`, `created_at`, `updated_at`.

### US-0.2.4: Author Normalized Name is Unique
**As a** developer
**I want to** prevent duplicate authors by normalized name
**So that** author deduplication works automatically

**Given** the Author table schema
**When** two authors with the same `normalized_name` are inserted
**Then** the second insert fails with a uniqueness constraint violation on `normalized_name` (COLLATE NOCASE).

### US-0.2.5: Composite Primary Keys on Join Tables
**As a** developer
**I want to** ensure referential integrity on many-to-many relationships
**So that** no duplicate associations exist

**Given** `BookAuthor`, `BookGenre`, and `BookTag` tables
**When** inspected
**Then** each has a composite primary key `(book_id, author_id)`, `(book_id, genre_id)`, `(book_id, tag_id)` respectively.

### US-0.2.6: BookShelf Has Unique book_id
**As a** developer
**I want to** enforce one-location-per-book
**So that** a book cannot be on two shelves simultaneously

**Given** the `BookShelf` table schema
**When** inspected
**Then** `book_id` has a unique constraint, ensuring a book maps to at most one shelf.

### US-0.2.7: Location Hierarchy with Foreign Keys
**As a** developer
**I want to** model Room → Cupboard → Shelf relationships
**So that** the physical library layout is represented

**Given** `Room`, `Cupboard`, `Shelf` tables
**When** inspected
**Then** `Cupboard.room_id` FK → `Room.id`, and `Shelf.cupboard_id` FK → `Cupboard.id`, with appropriate indices on `room_id` and `cupboard_id`.

### US-0.2.8: Change Log Event Table Captures All Fields
**As a** developer
**I want to** record every change for sync and audit
**So that** the event journal is complete

**Given** the `ChangeLogEvent` table schema
**When** inspected
**Then** it contains: `event_id`, `entity_type`, `entity_id`, `field_name`, `old_value`, `new_value`, `timestamp`, `device_user`, `event_type`.

### US-0.2.9: AppMetadata Singleton Table
**As a** developer
**I want to** store app-level metadata (e.g., schema version)
**So that** force-update logic can compare versions during sync

**Given** the `AppMetadata` table schema
**When** inspected
**Then** it contains a `schema_version` integer (and any other singleton fields), designed to hold exactly one row.

### US-0.2.10: All Indices Created
**As a** developer
**I want to** query the database efficiently
**So that** UI remains responsive with large catalogs

**Given** the database schema
**When** I list indices via `PRAGMA index_list`
**Then** indices exist on: `Book.title` (NOCASE), `Book.isbn`, `Book.language_id`, `Book.format`, `Book.condition`, `Book.purchase_date`, `Book.created_at`, `Book.status`, `Book.checked_out_to`, `Author.normalized_name` (NOCASE), `Author.raw_name` (NOCASE), `Genre.name` (NOCASE), `Language.name` (NOCASE), `Room.name` (NOCASE), `Cupboard.room_id`, `Shelf.cupboard_id`, `BookAuthor.(book_id, author_id)`, `BookGenre.(book_id, genre_id)`, `BookTag.(book_id, tag_id)`, `ChangeLog.(entity_type, timestamp)`, `ChangeLog.(entity_type, entity_id, timestamp)`, `BookLoan.(book_id, returned_date)`, `BookLoan.(borrower_name)`.

### US-0.2.11: build_runner Generates Clean drift Code
**As a** developer
**I want to** regenerate model classes after schema changes
**So that** the codebase stays in sync with the database

**Given** all table definitions are written
**When** I run `dart run build_runner build --delete-conflicting-outputs`
**Then** all `*.g.dart` files are generated without errors, and `dart analyze` passes on generated code.

### US-0.2.12: Migration v1 Applies Successfully
**As a** developer
**I want to** version the database schema
**So that** future migrations can be applied incrementally

**Given** a fresh app install
**When** the database is opened for the first time
**Then** migration v1 runs, creating all tables, indices, and the FTS5 virtual table, and sets the schema version to 1.

---

## Edge Cases

### US-0.2.13: UUID v4 Primary Key Generation
**Given** a new book is inserted with `uuid` package
**When** the `id` is generated
**Then** it is a valid UUID v4 (random), not sequential, and collision probability is negligible.

### US-0.2.14: Nullable Foreign Keys
**Given** `BookShelf.shelf_id` and `Book.isbn` are nullable
**When** a book is created without a location or ISBN
**Then** the insert succeeds and the nullable columns store `NULL`.

### US-0.2.15: ISBN-10 vs ISBN-13 Storage
**Given** the `isbn` field is plain text
**When** an ISBN-10 is saved (normalized to ISBN-13 by app logic in later phases)
**Then** the database stores the normalized 13-digit string. The schema itself does not enforce ISBN format (that is application-level validation).

### US-0.2.16: Soft Delete Flag Default
**Given** the `Book.is_deleted` boolean field
**When** a new book row is inserted without specifying `is_deleted`
**Then** it defaults to `false` (or is explicitly required in the insert).

### US-0.2.17: FTS5 with Special Characters in Title
**Given** a book title contains punctuation (`"The C++ Programming Language"`)
**When** the FTS5 tokenizer indexes it
**Then** it indexes without crash, and searching for `C++` or `Programming` returns the book.

### US-0.2.24: FTS5 with Emoji in Title
**Given** a book title contains emoji (`"The 🌈 Rainbow Book"`)
**When** the FTS5 tokenizer indexes it
**Then** it indexes without crash, and searching for `"Rainbow"` returns the book.

### US-0.2.25: FTS5 with Non-Latin Script in Title
**Given** a book title is in a non-Latin script (`"महाभारत"` or `"भगवद् गीता"`)
**When** the FTS5 tokenizer indexes it
**Then** it indexes without crash, and searching for the exact title or a substring returns the book.

### US-0.2.26: FTS5 with Quotes and Apostrophes in Title
**Given** a book title contains quotes or apostrophes (`"The Butler's Wife"`, `"\"Something\" Different"`)
**When** the FTS5 tokenizer indexes it
**Then** it indexes without crash or syntax error, and searching for `"Butler"` or `"Something"` returns the book.

---

## Error States

### US-0.2.18: Duplicate Genre Name Insertion
**Given** the `Genre` table has a unique constraint on `name` (COLLATE NOCASE)
**When** I attempt to insert `"Fiction"` twice
**Then** the second insert throws a drift `SqliteException` with code 2067 (unique constraint failed).

### US-0.2.19: Foreign Key Violation on BookAuthor
**Given** FK constraints are enabled
**When** I insert a `BookAuthor` row with a `book_id` that does not exist in `Book`
**Then** the insert throws a foreign key constraint violation.

### US-0.2.20: build_runner Failure on Syntax Error
**Given** a table definition has a Dart syntax error
**When** `build_runner` runs
**Then** it fails with a clear error pointing to the file and line number.

### US-0.2.21: Migration Conflict on Schema Mismatch
**Given** an existing database at version 1
**When** the app opens with an unchanged schema
**Then** no migration runs (idempotent open). If the schema changed without a new migration, drift throws a migration exception on open.

---

## Empty States

### US-0.2.22: Empty Database on First Open
**Given** the app is installed for the first time
**When** the database opens
**Then** all tables exist but contain zero rows. A unit test can verify `SELECT count(*) FROM book` returns 0.

---

## Accessibility

### US-0.2.23: Data Model Does Not Block Accessibility
**Given** the data layer has no UI
**When** N/A (data layer only)
**Then** ensure that no table names or field names use confusing abbreviations that would propagate to UI labels. All enum values in `lib/core/constants.dart` should have human-readable display names suitable for screen readers.

---

# Workstream 0.3 — Repository Interfaces & Contracts

## Happy Path

### US-0.3.1: Repository Providers Are Injectable
**As a** developer
**I want to** inject repositories via Riverpod providers
**So that** the architecture stays decoupled and testable

**Given** all repository provider definitions exist
**When** I create a `ProviderContainer` with overrides
**Then** I can override `bookRepoProvider`, `locationRepoProvider`, `genreRepoProvider`, `tagRepoProvider`, `languageRepoProvider`, `loanRepoProvider`, and `changeLogRepoProvider` with mock implementations.

### US-0.3.2: Book Repository Interface Defines CRUD + Search
**As a** developer
**I want to** know the contract for book operations
**So that** I can implement it in Phase 1

**Given** `lib/data/repositories/book_repository.dart`
**When** inspected
**Then** it declares methods for: create, read by id, update, soft-delete/restore, list all (with pagination), search (text + filters + sort), and duplicate detection query signatures. All return drift-generated `Book` type or `List<Book>`.

### US-0.3.3: Location Repository Interface Defines Hierarchy CRUD
**As a** developer
**I want to** manage the physical location hierarchy through a clean contract
**So that** Phase 1 can implement cascade delete behavior

**Given** `lib/data/repositories/location_repository.dart`
**When** inspected
**Then** it declares methods for: create Room, create Cupboard (under Room), create Shelf (under Cupboard), rename any level, delete Room/Cupboard/Shelf (with documented cascade behavior: affected books set to `shelf_id = null`), and query full hierarchy.

### US-0.3.4: Genre Repository Seeds 20 Predefined Genres on First Open
**As a** family member
**I want to** see common genres available immediately
**So that** I don't have to create them manually

**Given** a fresh database
**When** the `GenreRepository` is first instantiated (or `AppDatabase` is first opened)
**Then** 20 predefined genres are inserted: Fiction, Non-Fiction, Science, Technology, History, Biography & Memoir, Poetry, Religion & Spirituality, Philosophy, Self-Help, Business & Economics, Art & Photography, Cooking, Travel, Health & Wellness, Comics & Graphic Novels, Children's, Young Adult, Reference, Textbooks. All have `is_custom = false`.

### US-0.3.5: Language Repository Seeds 3 Built-in Languages
**As a** family member
**I want to** see English, Hindi, and Sanskrit as default language options
**So that** I can assign them to books immediately

**Given** a fresh database
**When** the `LanguageRepository` is first instantiated
**Then** three languages are inserted: English, Hindi, Sanskrit, all with `is_builtin = true`.

### US-0.3.6: Seeded Data Is Idempotent
**As a** family member
**I want to** relaunch the app without duplicate seed data
**So that** genres and languages don't multiply

**Given** the app has already seeded genres and languages
**When** the app launches again
**Then** no additional genre or language rows are created. The seed logic checks for existing rows before inserting.

### US-0.3.7: Repository Contract Tests Compile and Pass
**As a** developer
**I want to** verify repository interfaces with mock implementations
**So that** the contract is sound before real DAOs are written

**Given** contract tests in `test/data/repositories/`
**When** `flutter test` runs
**Then** all tests pass. Each test uses a mock implementation of the repository interface and verifies that the expected return types are correct (e.g., `getBookById` returns `Future<Book?>`, `listGenres` returns `Future<List<Genre>>`).

### US-0.3.8: Change Log Repository Interface
**As a** developer
**I want to** append and query change log events
**So that** the sync engine can replay events

**Given** `lib/data/repositories/change_log_repository.dart`
**When** inspected
**Then** it declares: `appendEvent(ChangeLogEvent)`, `querySince(DateTime timestamp)`, and `getEventsForEntity(String entityType, String entityId)`.

---

## Edge Cases

### US-0.3.9: Seed Data Race Condition
**Given** two isolates or rapid open/close cycles
**When** seed logic runs concurrently
**Then** SQLite transaction isolation prevents duplicate seed rows (insert-with-ignore or transaction guard).

### US-0.3.10: Repository Called Before Database Ready
**Given** a repository provider is accessed extremely early in app lifecycle
**When** the database is still initializing
**Then** the provider waits for `AppDatabase` to be ready (via Riverpod dependency chain) and does not crash with null database.

### US-0.3.11: Built-in Genre/Language Protection Contract
**Given** the contract tests for `GenreRepository` and `LanguageRepository`
**When** a test calls `deleteGenre` on a built-in genre
**Then** the contract specifies that the real implementation (in Phase 1) must throw an `UnsupportedError` or return a failure result, and built-in items must remain non-deletable.

### US-0.3.16: Language Repository Seed Data Race Condition
**Given** two isolates or rapid open/close cycles trigger `LanguageRepository` initialization concurrently
**When** seed logic for English, Hindi, and Sanskrit runs at the same time
**Then** SQLite transaction isolation prevents duplicate language rows (insert-with-ignore or transaction guard), matching the protection already verified for `GenreRepository`.

---

## Error States

### US-0.3.12: Mock Repository Returns Null for Missing Book
**Given** a mock `BookRepository` in a contract test
**When** `getBookById` is called with a non-existent UUID
**Then** it returns `null` (or `Future<Book?>` resolving to `null`), not throwing an unexpected exception.

### US-0.3.13: Provider Container Without Overrides Fails Gracefully
**Given** a test creates a `ProviderContainer` without overriding `databaseProvider`
**When** a repository provider is read
**Then** the container resolves `databaseProvider` to a real in-memory DB (per default), or the test is expected to provide overrides. No silent null provider behavior.

---

## Empty States

### US-0.3.14: Repository List Methods Return Empty List
**Given** the database is empty
**When** `listBooks()`, `listGenres()`, `listTags()`, `listLoans()` are called
**Then** each returns an empty list `[]` (or `Future<List<T>>` resolving to `[]`), not `null`.

---

## Accessibility

### US-0.3.15: Repository Error Messages Are Human-Readable
**Given** repository operations may fail in later phases
**When** errors are surfaced
**Then** error messages are suitable for display in UI (e.g., `"Genre 'Fiction' already exists"` rather than raw SQL error codes), ensuring screen readers can vocalize meaningful text.

---

# Workstream 0.4 — Navigation Shell & Router

## Happy Path

### US-0.4.1: App Launches to Catalog Screen
**As a** family member
**I want to** open the app and immediately see the catalog
**So that** I can start browsing my library

**Given** the app is installed
**When** I launch it
**Then** it navigates to `/catalog` and displays the catalog placeholder screen with app bar title "The Little Library" and the hamburger menu icon, matching `catalog.html` mockup.

### US-0.4.2: Navigation Drawer Opens and Shows 9 Items
**As a** family member
**I want to** access all major sections from a single drawer
**So that** navigation is organized and predictable

**Given** I am on the catalog screen
**When** I tap the hamburger icon in the app bar
**Then** the navigation drawer slides in from the left, displaying 9 items in order: Library (Catalog), Locations, Recent Activity, Active Loans, Genres, Tags, Languages, Deleted Books, Settings, with appropriate icons, matching the mockup.

### US-0.4.3: Drawer Items Navigate to Placeholder Screens
**As a** family member
**I want to** visit every section even if it's not fully built yet
**So that** I can see the app structure

**Given** the drawer is open
**When** I tap each of the 9 drawer items
**Then** the drawer closes and the app navigates to the corresponding route, showing a placeholder `Scaffold` with the route name in the app bar.

### US-0.4.4: FAB Speed Dial Expands with 4 Mini-FABs
**As a** family member
**I want to** quickly choose how to add a book
**So that** I can use my preferred input method

**Given** I am on the catalog screen
**When** I tap the large `+` FAB at bottom-right
**Then** the `+` icon rotates 45° to `×`, and 4 labeled mini-FABs fan out upward with staggered animation: Voice Input, Scan Cover, Scan Barcode, Add Manually, matching `catalog.html` mockup.

### US-0.4.5: FAB Speed Dial Collapses
**As a** family member
**I want to** dismiss the speed dial without selecting an option
**So that** I can continue browsing

**Given** the FAB speed dial is expanded
**When** I tap the main FAB again, or tap outside the speed dial area, or press the back button
**Then** the mini-FABs collapse with reverse animation and the icon rotates back to `+`.

### US-0.4.6: Sync Status Bar Shows Green State
**As a** family member
**I want to** see that my library is synced
**So that** I know everything is up to date

**Given** the app is on the catalog screen (mock data for Phase 0)
**When** I look below the app bar
**Then** a thin sync status bar is visible with green background, sync icon, and text "Synced just now", matching the mockup.

### US-0.4.7: Sync Status Bar Shows Amber Offline State
**As a** family member
**I want to** know when I'm offline and have pending changes
**So that** I understand why new books aren't appearing on other devices

**Given** the mock sync state is set to offline with 3 pending changes
**When** I view the catalog screen
**Then** the sync bar shows amber background with text "Offline — 3 changes pending".

### US-0.4.8: Sync Status Bar Shows Red Error State
**As a** family member
**I want to** see when a sync error occurs
**So that** I can take action

**Given** the mock sync state is set to error (e.g., "Drive storage full")
**When** I view the catalog screen
**Then** the sync bar shows red background with an actionable error message.

### US-0.4.9: go_router Registers All 24 Routes
**As a** developer
**I want to** have every screen reachable by URL
**So that** deep linking and navigation work consistently

**Given** `lib/app.dart` configures go_router
**When** I inspect the route list
**Then** all 24 routes are registered: `/catalog`, `/book/:id`, `/book/add`, `/book/edit/:id`, `/scanner/barcode`, `/scanner/ocr`, `/voice-input`, `/locations`, `/checkout/:bookId`, `/loan/:bookId`, `/conflicts`, `/activity`, `/settings`, `/settings/genres`, `/settings/tags`, `/settings/languages`, `/deleted`, `/active-loans`, `/export`, `/share-library`, `/change-history/:bookId`, `/setup`, `/force-update`, `/bulk-scanner`.

### US-0.4.10: Back Navigation Works from All Routes
**As a** family member
**I want to** use the system back button to return to previous screens
**So that** navigation feels natural

**Given** I navigated from `/catalog` → `/settings` → `/settings/genres`
**When** I press the system back button once
**Then** I return to `/settings`. When I press back again, I return to `/catalog`.

---

## Edge Cases

### US-0.4.11: Unknown Route Handling
**Given** the app receives a deep link to `/nonexistent-route`
**When** go_router processes it
**Then** it navigates to a 404-style placeholder screen (or redirects to `/catalog`) without crashing.

### US-0.4.12: Deep Link to Parameterized Route
**Given** a deep link `/book/550e8400-e29b-41d4-a716-446655440000`
**When** go_router processes it
**Then** it navigates to the Book Detail placeholder and the route parameter is accessible via `GoRouterState`.

### US-0.4.13: Drawer Open During FAB Expand
**Given** the navigation drawer is open
**When** I tap the FAB to expand the speed dial
**Then** the drawer closes first, then the FAB expands, preventing overlapping UI layers.

### US-0.4.14: Rapid Drawer Open/Close
**Given** I rapidly tap the hamburger icon multiple times
**When** the drawer animation is still running
**Then** the drawer does not glitch, stutter, or get stuck in a half-open state. It completes to the correct open/closed state.

### US-0.4.15: Sync Status Bar Color Transition
**Given** the sync bar is transitioning from green to amber
**When** the state changes
**Then** the color change animates smoothly over ~200ms, not flashing abruptly.

### US-0.4.26: FAB Collapse When Drawer Opens
**Given** the FAB speed dial is fully expanded with 4 visible mini-FABs
**When** the user opens the navigation drawer (swipe or hamburger tap)
**Then** the FAB collapses instantly (or within 50ms), the mini-FABs disappear, and the drawer begins its open animation without overlapping UI layers.

### US-0.4.27: Simultaneous Drawer/FAB Gesture Conflict
**Given** the user performs a simultaneous gesture: swiping from the left edge to open the drawer while tapping the FAB area
**When** both gestures are recognized in the same frame
**Then** the drawer open gesture takes priority, the FAB does not expand, and no assertion error or gesture arena exception is thrown.

---

## Error States

### US-0.4.16: go_router Misconfiguration
**Given** a route is registered with a malformed path pattern
**When** the app starts
**Then** go_router throws a clear assertion error during debug build, not a runtime crash on navigation.

### US-0.4.17: Placeholder Screen Route Parameter Missing
**Given** I navigate to `/book/` without an `:id`
**When** go_router matches
**Then** it either does not match the `/book/:id` route (falls to 404) or the placeholder screen handles the null parameter gracefully.

---

## Empty States

### US-0.4.18: Catalog Placeholder Shows Empty Catalog State
**As a** family member
**I want to** see a friendly message when my library is empty
**So that** I know how to add my first book

**Given** the catalog screen is displayed with zero books
**When** I look at the content area
**Then** an empty state illustration appears with: icon (book outline), title "Your library is empty", subtitle "Add your first book to get started.", and three quick-action buttons: "Add Manually", "Scan Barcode", "Scan Cover", matching `catalog.html` mockup empty state.

---

## Accessibility

### US-0.4.19: Drawer Items Have Semantic Labels
**As a** family member using a screen reader
**I want to** hear what each drawer item does
**So that** I can navigate without seeing the screen

**Given** TalkBack is enabled
**When** I swipe through the navigation drawer items
**Then** each item is announced with its label (e.g., "Recent Activity, button") and the icon has a semantic label.

### US-0.4.20: FAB Speed Dial Labels Are Accessible
**As a** family member using a screen reader
**I want to** know what each mini-FAB does
**So that** I can choose the right input method

**Given** TalkBack is enabled and the speed dial is expanded
**When** I swipe to each mini-FAB
**Then** each is announced with its text label: "Voice Input, button", "Scan Cover, button", "Scan Barcode, button", "Add Manually, button". The main FAB is announced as "Add book, button".

### US-0.4.21: Sync Status Bar Announces State Changes
**As a** family member using a screen reader
**I want to** be notified when sync status changes
**So that** I know if my library is up to date

**Given** TalkBack is enabled
**When** the sync bar changes from green "Synced just now" to amber "Offline — 3 changes pending"
**Then** the new state is announced via `SemanticsService.announce` (or equivalent) with the full message.

### US-0.4.22: Tappable Targets Meet Minimum Size
**As a** family member with motor difficulties
**I want to** tap navigation elements easily
**So that** I don't miss small targets

**Given** the catalog screen is displayed
**When** I measure all interactive elements: hamburger icon, drawer items, FAB, mini-FABs, sort icon, grid/list toggle icons
**Then** each has a tappable area of at least 48×48dp (Material Design 3 minimum). The mini-FABs (44×44dp in mockup) should have padding or hit-test expansion to meet 48dp.

### US-0.4.23: Sufficient Contrast on Sync Bar Text
**As a** family member with low vision
**I want to** read the sync status clearly
**So that** I know the current sync state

**Given** the sync bar is rendered in green (`#4CAF50`) with white text, amber (`#FF9800`) with dark brown text (`#3E2B23`), and red (`#F44336`) with white text
**When** contrast is measured
**Then** all combinations meet WCAG AA (≥ 4.5:1). Green `#4CAF50` on white `#FFFFFF` = ~3.0:1; ensure the *text-on-bar-background* is measured: white `#FFFFFF` on green `#4CAF50` = ~2.9:1 — **this may need adjustment** (e.g., darker green `#2E7D32` for 4.6:1, or bold text at 3:1). The spec requires sufficient contrast; if the mockup tokens fail, the implementation must darken the bar backgrounds slightly to pass WCAG AA.

### US-0.4.24: Theme Contrast in Dark Mode
**As a** family member using dark mode with low vision
**I want to** see all text clearly
**So that** the app remains usable

**Given** dark mode is active
**When** I inspect common text backgrounds: surface `#2B2930` with on-surface `#E6E1E5`, primary container `#5D4037` with on-primary-container `#EADDCF`
**Then** all combinations achieve WCAG AA contrast ≥ 4.5:1. (Verify: `#E6E1E5` on `#2B2930` = ~11.7:1 ✓; `#EADDCF` on `#5D4037` = ~4.7:1 ✓.)

### US-0.4.25: Reduced Motion Respect
**As a** family member who prefers reduced motion
**I want to** minimize animations
**So that** I don't experience dizziness

**Given** the device's accessibility "Remove animations" setting is enabled
**When** I open/close the drawer or expand/collapse the FAB speed dial
**Then** animations are either disabled or significantly shortened (e.g., 50ms or instant), per `MediaQuery.of(context).disableAnimations` or `AnimationBehavior`.

### US-0.4.28: Reduced Motion on Sync Bar Color Transition
**Given** the device's accessibility "Remove animations" setting is enabled
**When** the sync status bar transitions from green to amber (or amber to red) due to a state change
**Then** the color change is instantaneous (0ms) or uses a 50ms micro-fade, not the default 200ms animated transition.

### US-0.4.29: Reduced Motion on Route Transitions
**Given** the device's accessibility "Remove animations" setting is enabled
**When** I navigate between routes (e.g., `/catalog` → `/settings`) via drawer tap or deep link
**Then** the route transition is either a simple cross-fade ≤ 50ms or an instant replacement, not the default slide/scale animation.

---

# Cross-Cutting Phase 0 Stories

## Integration / E2E

### US-0.E2E.1: Phase 0 Integration — App Launch
**Given** the app is built from Phase 0 code
**When** I install and launch it on an Android device
**Then** it opens to `/catalog`, the navigation drawer works, the FAB speed dial expands/collapses, the sync status bar is visible, `dart analyze` returns zero warnings/errors, and `dart run build_runner build` completes successfully.

### US-0.E2E.2: Phase 0 Integration — Database Verification
**Given** the app is built from Phase 0 code
**When** I run the unit test that opens an in-memory DB
**Then** the test confirms all 14 tables + FTS5 virtual table exist, all indices are present, and `PRAGMA foreign_keys` returns `1`.

### US-0.E2E.3: Phase 0 Integration — Theme Toggle on Device
**Given** the app is running on a device
**When** I tap the theme toggle and switch between light/dark
**Then** all screens (catalog, drawer, setup placeholder) update their colors immediately without requiring a restart.

### US-0.E2E.4: Phase 0 Integration — All Routes Reachable
**Given** the app is running
**When** I navigate through all 24 routes via drawer items, FAB mini-FABs, and direct deep links
**Then** every route displays its placeholder screen without crash or assertion error.
