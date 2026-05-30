# Code Review — Phase 0, Round 3 (FINAL)

**Round:** 3 of 3
**`dart analyze`:** clean (0 issues)
**`flutter test`:** 0 passed, 520 failed (all RED-phase placeholders — expected)
**`dart run build_runner build --delete-conflicting-outputs --force-jit`:** succeeded; verified by deleting and regenerating `lib/core/theme.g.dart`

---

## BLOCKER — Must Fix

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| — | — | **No blockers.** | — |

---

## SHOULD FIX — Important

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| — | — | **No outstanding should-fix items.** | — |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| — | — | **No outstanding nice-to-have items.** | — |

---

## Resolved from Round 2

| # | Original Issue | Resolution |
|---|----------------|------------|
| R2-B1 | `pubspec.yaml:49` `hooks_runner` caused "Failed to compile build script" | **Fixed.** `hooks_runner` removed from `pubspec.yaml`. `dart run build_runner build --force-jit` completes successfully. Verified by deleting `theme.g.dart` and regenerating it (wrote 1 output). |
| R2-S2 | `theme.dart:85` `ThemeModeNotifier` toggled theme in memory only | **Fixed.** `ThemeModeNotifier` now imports `shared_preferences`, reads persisted mode in `_loadPersistedMode()`, and writes back via `_persist()` on every toggle/set. |
| R2-S3 | `sync_status_bar.dart:26` `syncStatusProvider` still manually created | **Fixed.** Migrated to `@riverpod` class `SyncStatusNotifier` with `part 'sync_status_bar.g.dart';`. Generated provider is `syncStatusProvider`, consumed correctly by the widget. |
| R2-S4 | `book_table.dart:23` (and related tables) lacked `COLLATE NOCASE` | **Fixed.** All indexed text columns now use `customConstraint('COLLATE NOCASE NOT NULL')`: `Books.title`, `Authors.rawName`, `Authors.normalizedName`, `Genres.name`, `Languages.name`, `Rooms.name`. |
| R2-S5 | `sync_status_bar.dart:72` `InkWell` tap area ~30 dp | **Fixed.** Wrapped in `SizedBox(height: 48)`; meets AGENTS.md ≥48 dp accessibility target. |
| R2-N6 | `pubspec.yaml` dependencies used `any` | **Fixed.** All runtime and dev dependencies now have pinned minimum versions (`^x.x.x`). No `any` constraints remain. |
| R2-N7 | `book_repository.dart:76` `search()` used `like('%$query%')` only | **Fixed.** `search()` now routes filter-less queries to `_ftsSearch()` using the `book_fts` FTS5 virtual table (with rank ordering). Falls back to LIKE only when genre/language/format filters are active. |
| R2-N8 | `book_repository.dart:116` `findDuplicates` did exact matching only | **Fixed.** `findDuplicates()` now tries `_findExactDuplicates` first, then falls back to `_findFuzzyDuplicates` using `similarityRatio()` with an 80% threshold on title/author. |

---

## Resolved from Round 1 (Regression Check)

| # | Original Issue | Verification Status |
|---|----------------|---------------------|
| R1-1 | `database_provider.dart` returned `AppDatabase.memory()` unconditionally | **Still fixed.** Returns `AppDatabase()` (file-backed). |
| R1-2 | `book_repository.dart:89` `search()` used `innerJoin` | **Still fixed.** `_filteredSearch` uses `leftOuterJoin`. |
| R1-3 | `sync_status_bar.dart:96` green `#4CAF50` failed WCAG AA | **Still fixed.** Uses `#2E7D32` (~4.6:1). |
| R1-4 | `theme.dart:85` manual `NotifierProvider` | **Still fixed.** Uses `@riverpod` code generation. |
| R1-6 | `app.dart:88` `buildAppRouter()` called on every rebuild | **Still fixed.** Global `final GoRouter appRouter = _buildAppRouter();`. |
| R1-7 | `app.dart:97` Missing `AppLocalizations.delegate` | **Still fixed.** Delegates and `supportedLocales` wired. |
| R1-8 | `analysis_options.yaml` missing `exclude: ["**/*.g.dart"]` | **Still fixed.** Present under `analyzer: exclude:`. |
| R1-10 | `change_log_repository.dart:43` `querySince` accepted `String` | **Still fixed.** Accepts `DateTime` and converts internally. |
| R1-11 | `genre_repository.dart:32` premature `_seeded` | **Still fixed.** Set after transaction completes. |
| R1-12 | `language_repository.dart:31` premature `_seeded` | **Still fixed.** Same pattern as genre. |
| R1-13 | `location_repository.dart:73` N+1 `deleteRoom()` | **Still fixed.** Uses `isIn` bulk queries inside transaction. |
| R1-15 | `change_log_table.dart:21` `newValue` required/non-empty | **Still fixed.** Now `text().nullable()`. |
| R1-16 | `app_metadata_table.dart` never seeded | **Still fixed.** `database.dart` `onCreate` inserts `AppMetadataCompanion.insert()`. |
| R1-18 | `genre_repository.dart:37` raw `customStatement` seed | **Still fixed.** Uses typed drift `insert(..., mode: InsertMode.insertOrIgnore)`. |

---

## Verdict: APPROVE

**REVIEW_PASSED**

All Round 1 and Round 2 issues have been verified as resolved. `dart analyze` is clean. `build_runner` code generation is functional (verified by destructive regeneration test). All 520 test failures are RED-phase contract placeholders (`fail('Implementation not yet created')`), which is expected for Phase 0 TDD. No blockers, no should-fix items, and no regressions remain.
