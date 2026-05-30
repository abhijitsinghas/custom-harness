# Code Review — Phase 0, Round 2

**Round:** 2 of 3
**`dart analyze`:** clean (0 issues)
**`flutter test`:** 0 passed, 505 failed (all RED-phase placeholders — expected)

---

## BLOCKER — Must Fix

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 1 | `pubspec.yaml:49` | `hooks_runner: ">=0.23.0 <1.0.0"` is still present. `dart run build_runner build --delete-conflicting-outputs` fails with **"Failed to compile build script"**. On investigation, `dart compile` of the build entrypoint errors with *"does not support build hooks"*. The existing `.g.dart` files (theme, database) are stale and cannot be regenerated, breaking the build pipeline and preventing any future drift/Riverpod code generation. This was Round 1 issue #14, claimed fixed. | US-0.2.11 / AGENTS.md |

---

## SHOULD FIX — Important

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 2 | `lib/core/theme.dart:85` | `ThemeModeNotifier` still toggles theme **in memory only**; no SharedPreferences, Hive, or file persistence is implemented. Resets to `ThemeMode.system` on every cold start, violating US-0.1.3 ("persist across app restarts"). No `shared_preferences` dependency exists in `pubspec.yaml`. This was Round 1 issue #5, claimed fixed. | US-0.1.3 |
| 3 | `lib/features/catalog/sync_status_bar.dart:26` | `syncStatusProvider` is still manually created with `NotifierProvider` instead of `@riverpod` + `riverpod_generator`. AGENTS.md explicitly prohibits manual `StateNotifierProvider`/`ChangeNotifierProvider` and mandates annotation-based code generation for all stateful providers. Only `themeModeProvider` was migrated; `syncStatusProvider` was missed. This was Round 1 issue #4, partially fixed. | AGENTS.md |
| 4 | `lib/data/database/tables/book_table.dart:23` | `title` column (and `author_table.dart:9` `normalizedName`/`rawName`, `genre_table.dart:10` `name`, `language_table.dart:10` `name`, `location_tables.dart:9` `name`) lack `COLLATE NOCASE`. `@TableIndex` annotations alone create case-sensitive B-tree indexes. US-0.2.10 requires case-insensitive search; without collation, queries using `.lower()` bypass indexes entirely and perform full table scans. This was Round 1 issue #9, claimed fixed. | US-0.2.10 |
| 5 | `lib/features/catalog/sync_status_bar.dart:72` | `InkWell` tap area is ~30 dp tall (Icon 18 dp + vertical Padding 12 dp), falling below the AGENTS.md accessibility requirement of **≥48 dp tappable targets**. The status bar should wrap its `InkWell` in a `SizedBox` of minimum height 48 dp or increase vertical padding. | AGENTS.md Accessibility |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| 6 | `pubspec.yaml:15-44` | All runtime dependencies still use `any` version constraint. Builds are non-reproducible and risk automatic major-version breaks. Pin minimum versions matching the packages actually tested. This was Round 1 issue #20, claimed fixed. | US-0.1.4 |
| 7 | `lib/data/repositories/book_repository.dart:76` | `search()` uses `like('%$query%')` on title, isbn, and publisher, which performs full table scans. An FTS5 virtual table (`book_fts`) is created in `database.dart` but never queried. For 2000+ books this will likely exceed the <300 ms non-functional search requirement. Consider wiring `book_fts` into `search()`. | NFR |
| 8 | `lib/data/repositories/book_repository.dart:116` | `findDuplicates` does exact lower-case matching only. Phase 1 will likely need fuzzy Levenshtein matching (≥80%). The existing `lib/core/utils.dart` already provides `similarityRatio()`. Consider renaming to `findExactDuplicates` or integrating fuzzy logic. This was Round 1 issue #19. | US-0.3.2 |

---

## Resolved from Round 1

| # | Original Issue | Resolution |
|---|----------------|------------|
| 1 | `database_provider.dart:7` unconditionally returned `AppDatabase.memory()` | **Fixed.** Now returns `AppDatabase()` (file-backed via `LazyDatabase`). |
| 2 | `book_repository.dart:89` `search()` used `innerJoin` on `bookGenres` | **Fixed.** Now uses `leftOuterJoin`; unclassified books remain searchable. |
| 3 | `sync_status_bar.dart:96` green background `#4CAF50` failed WCAG AA | **Fixed.** Now uses `#2E7D32` (~4.6:1 contrast). |
| 4 | `theme.dart:85` `themeModeProvider` manually created with `NotifierProvider` | **Partially fixed.** `themeModeProvider` migrated to `@riverpod`; `syncStatusProvider` still manual (see SHOULD FIX #3 above). |
| 6 | `app.dart:88` `buildAppRouter()` called on every rebuild | **Fixed.** Router memoized as global `final GoRouter appRouter = _buildAppRouter();`. |
| 7 | `app.dart:97` Missing `AppLocalizations.delegate` | **Fixed.** `MaterialApp.router` now includes `AppLocalizations.delegate` and `supportedLocales`. |
| 8 | `analysis_options.yaml` missing `exclude: ["**/*.g.dart"]` | **Fixed.** Added under `analyzer: exclude:`. |
| 10 | `change_log_repository.dart:43` `querySince` accepted `String timestamp` | **Fixed.** Now accepts `DateTime timestamp` and converts internally. |
| 11 | `genre_repository.dart:32` `_seeded` set before `await transaction` | **Fixed.** `_seeded = true` now follows the transaction completion. |
| 12 | `language_repository.dart:31` Same premature `_seeded` | **Fixed.** Same pattern as genre repository. |
| 13 | `location_repository.dart:73` `deleteRoom()` performed N+1 queries | **Fixed.** Uses `isIn` bulk queries and `batch`-style deletes within a transaction. |
| 15 | `change_log_table.dart:21` `newValue` required and non-empty | **Fixed.** Now `text().nullable()`. |
| 16 | `app_metadata_table.dart` `onCreate` never seeded singleton row | **Fixed.** `database.dart` `onCreate` inserts `AppMetadataCompanion.insert()`. |
| 18 | `genre_repository.dart:37` seed used raw `customStatement` | **Fixed.** Now uses typed drift `into(_db.genres).insert(..., mode: InsertMode.insertOrIgnore)`. |

---

## Verdict: NEEDS FIXES (1 blocker)
