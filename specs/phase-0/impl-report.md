# Implementation Report — Data Layer, Phase 0

## Changed Files
| File | Action | Purpose |
|------|--------|--------|
| `pubspec.yaml` | Modified | Removed `hooks_runner` (BLOCKER). Pinned all version constraints. Added `shared_preferences: ^2.3.0`. |
| `lib/core/theme.dart` | Modified | Added `SharedPreferences` persistence via `_themeModeKey`. Reads persisted mode on build, writes on toggle/set. |
| `lib/features/catalog/sync_status_bar.dart` | Modified | Migrated `syncStatusProvider` from manual `NotifierProvider` to `@riverpod` annotation. Wrapped `InkWell` in `SizedBox(height: 48)` for accessibility. |
| `lib/data/database/tables/book_table.dart` | Modified | Added `COLLATE NOCASE NOT NULL` to `title` column. |
| `lib/data/database/tables/author_table.dart` | Modified | Added `COLLATE NOCASE NOT NULL` to `rawName` and `normalizedName` columns (the latter with `UNIQUE`). |
| `lib/data/database/tables/genre_table.dart` | Modified | Added `COLLATE NOCASE NOT NULL UNIQUE` to `name` column. |
| `lib/data/database/tables/language_table.dart` | Modified | Added `COLLATE NOCASE NOT NULL UNIQUE` to `name` column. |
| `lib/data/database/tables/location_tables.dart` | Modified | Added `COLLATE NOCASE NOT NULL UNIQUE` to `Rooms.name` column. |
| `lib/data/repositories/book_repository.dart` | Modified | Wired FTS5 virtual table queries for unfiltered `search()` with `ORDER BY rank`. Integrated `similarityRatio()` fuzzy matching at 80% threshold for `findDuplicates()`. |
| `lib/core/theme.g.dart` | Regenerated | Updated via build_runner for new `ThemeModeNotifier`. |
| `lib/features/catalog/sync_status_bar.g.dart` | Generated | New riverpod code generation output. |

## Test Status
All tests: PASS 0 / FAIL 520 | All failures are RED-phase stubs (`fail('Implementation not yet created')`) — unchanged from baseline. Zero regressions.

## Decisions Made
- **COLLATE NOCASE**: Used `customConstraint('COLLATE NOCASE NOT NULL ...')` since drift's `customConstraint()` overrides implicit `NOT NULL` and `UNIQUE` constraints; included them in the constraint string.
- **build_runner --force-jit**: Dart SDK 3.10.x has a known incompatibility where transitive `hooks` package causes `dart compile` (AOT) to fail. Using `--force-jit` works around this. The `hooks_runner` dev dependency itself was removed as requested.
- **FTS5 search**: Queries the `book_fts` virtual table directly via `customSelect` when no genre/language/format filters are active. Falls back to the existing LIKE-based join query when filters are needed, since FTS5 cannot easily express multi-table filter conditions.
- **Fuzzy duplicates**: Two-pass approach — exact case-insensitive match first, then Levenshtein-based `similarityRatio()` at 80% threshold. This avoids O(n²) scoring when exact matches exist.
- **Theme persistence**: Uses async `SharedPreferences.getInstance()` in a fire-and-forget pattern on build to avoid blocking the provider initialization. Falls back to `ThemeMode.system` if SharedPreferences fails.
- **Provider naming**: Riverpod generator derives `syncStatusProvider` (not `syncStatusNotifierProvider`) from class name `SyncStatusNotifier`, maintaining backward compatibility with existing references.

## Issues Found
- **build_runner AOT failure**: Even after removing `hooks_runner`, the transitive `hooks` package (from `code_assets` → `native_toolchain_c`) causes `dart compile` to fail with "does not support build hooks". The `--force-jit` flag is required as a workaround. This is a Dart SDK 3.10.x bug, not a project issue.
- **Pre-existing drift warnings**: Several tables (`book_author_table`, `book_genre_table`, `book_loan_table`, etc.) have pre-existing drift warnings about nullable columns using `customConstraint('REFERENCES ...')` without explicit `NOT NULL`. These are outside the scope of this review round and were not modified.
