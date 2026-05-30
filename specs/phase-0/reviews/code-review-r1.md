# Code Review — Phase 0, Round 1

**Round:** 1 of 3
**`dart analyze`:** clean (0 issues)
**`flutter test`:** 0 passed, ~500 failed (all RED-phase placeholders — expected)

---

## BLOCKER — Must Fix

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 1 | `database_provider.dart:7` | `databaseProvider` unconditionally returns `AppDatabase.memory()`. Every app restart wipes the database. Must return `AppDatabase()` (file-backed) for production and override with `AppDatabase.memory()` only in tests. | US-0.E2E.2 |
| 2 | `book_repository.dart:89` | `search()` joins `bookGenres` with `innerJoin`, which excludes books that have **no genre** from search results. Should use `leftOuterJoin` so unclassified books remain searchable. | US-0.3.2 |
| 3 | `sync_status_bar.dart:96` | Green sync bar background is `#4CAF50` with white text, giving a contrast ratio of ~2.9:1. US-0.4.23 explicitly requires WCAG AA (≥4.5:1) and states the implementation must darken the bar if mockup tokens fail. Use e.g. `#2E7D32` (4.6:1). | US-0.4.23 |

---

## SHOULD FIX — Important

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 4 | `theme.dart:85` | `themeModeProvider` is manually created with `NotifierProvider`. AGENTS.md conventions require `@riverpod` annotation + `riverpod_generator` for all stateful providers. Same issue for `syncStatusProvider` at `sync_status_bar.dart:26`. | AGENTS.md |
| 5 | `theme.dart:72` | `ThemeModeNotifier` toggles theme in memory only. US-0.1.3 requires the choice to **persist across app restarts** (SharedPreferences or `hive`/`local_storage` missing). | US-0.1.3 |
| 6 | `app.dart:88` | `LittleLibraryApp.build()` calls `buildAppRouter()` on every rebuild, producing a new `GoRouter` instance. Navigation state (route stack, listeners) resets whenever the widget rebuilds. Router should be memoized once (e.g., via a lazy final or provider). | US-0.4.9 |
| 7 | `app.dart:97` | `MaterialApp.router` delegates do not include `AppLocalizations.delegate`. `lib/l10n/app_en.arb` exists and `generate: true` is set in pubspec, but the generated l10n class is never imported or wired into the widget tree. | US-0.1.10 |
| 8 | `analysis_options.yaml` | Missing `exclude: ["**/*.g.dart"]` for generated drift code. `dart analyze` currently passes, but strict-casts/inference/raw-types flags will flag generated files as the schema grows, breaking CI. | AGENTS.md |
| 9 | `book_table.dart:23` | `@TableIndex` annotations for text columns lack `COLLATE NOCASE` required by US-0.2.10 (`idx_book_title`, `idx_author_normalized_name`, `idx_author_raw_name`, `idx_genre_name`, `idx_language_name`, `idx_room_name`). Drift `@TableIndex` does not support collation directly; add `customConstraint` on the column or use drift's `text().collate(Collate.noCase)` in the table definition. | US-0.2.10 |
| 10 | `change_log_repository.dart:43` | `querySince` accepts `String timestamp` instead of `DateTime` per the US-0.3.8 contract. Repository interface should accept `DateTime` and convert internally to ISO-8601 string. | US-0.3.8 |
| 11 | `genre_repository.dart:32` | `_seeded` bool is set to `true` synchronously **before** `await _db.transaction(...)` completes. If a widget reads `listAll()` immediately after the repository is constructed, it may query an un-seeded database. | US-0.3.6 |
| 12 | `language_repository.dart:31` | Same premature `_seeded` flag as genre repository. | US-0.3.6 |
| 13 | `location_repository.dart:73` | `deleteRoom()` performs N+1 queries (loops over cupboards → shelves → per-shelf `UPDATE`). For a room with many cupboards this is inefficient and may jank the UI thread. Should use drift `batch()` or raw bulk SQL. | US-0.3.3 |
| 14 | `pubspec.yaml` (`hooks_runner`) | `dart run build_runner build --delete-conflicting-outputs` fails with "Failed to compile build script". The explicit `hooks_runner` dev dependency may be forcing build-hooks resolution that the installed Dart SDK AOT compiler cannot handle. Since US-0.2.11 requires clean generation, this must be resolved (remove unused dependency or downgrade conflicting packages). | US-0.2.11 |
| 15 | `change_log_table.dart:21` | `newValue` is defined as `text().withLength(min: 1)()` — required and non-empty. In Phase 1, `delete` events may not have a meaningful new value. Consider making it nullable (`text().nullable()`) to avoid constraint violations during change-logging. | US-0.2.8 |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| 16 | `app_metadata_table.dart` | Migration `onCreate` never inserts the singleton `AppMetadata` row, so the table remains empty on first open. Seed it with default `schemaVersion = 1` so force-update logic in later phases can read it. | US-0.2.9 |
| 17 | `extensions.dart:60` | `DateFormatting` extends `DateTime?`, but US-0.1.15 mentions an "unparsable date string" — there is no string-parsing entry point. The extension gracefully handles `null` DateTime, which partially satisfies the story. | US-0.1.15 |
| 18 | `genre_repository.dart:37` | Seed logic uses raw `customStatement('INSERT OR IGNORE ...')` instead of typed drift `into(_db.genres).insert(..., mode: InsertMode.insertOrIgnore)`. Raw SQL bypasses type safety and drift's validation. | US-0.3.4 |
| 19 | `book_repository.dart:116` | `findDuplicates` does exact case-insensitive matching (`lower().equals(...)`). US-0.3.2 calls for duplicate *detection*; Phase 1 will need Levenshtein fuzzy matching (≥80%). Consider renaming to `findExactDuplicates` or adding a fuzzy variant. | US-0.3.2 |
| 20 | `pubspec.yaml` | Every dependency uses `any` version constraint. This makes builds non-reproducible and risks automatic major-version breaks on `flutter pub get`. Pin minimum versions matching the packages actually tested. | US-0.1.4 |

---

## Resolved from Round 0

| # | Original Issue | Resolution |
|---|----------------|------------|
| — | — | — |

---

## Verdict: NEEDS FIXES (3 blockers)
