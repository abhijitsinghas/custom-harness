# Code Review — Phase 1, Round 2

**Round:** 2 of 3
**`dart analyze lib/`:** clean (0 issues)
**`flutter test test/data/`:** 60 passed, 442 failed

---

## Resolved from Round 1

| # | Original Issue | Resolution |
|---|----------------|------------|
| 1 | `sync_engine.dart:160-163` Optimistic locking broken — `localKnownVersion` set to `remoteVersion` unconditionally | FIXED. `_remoteVersionAtLastSync` is now compared correctly against `remoteVersion`; `_push` pulls/merges when remote is newer. |
| 2 | `google_books_client.dart:260` Custom API key 403 fallback dropped original query | FIXED. `_handleResponse` now passes the original `query` to `_performGet(query: query, ...)` on fallback. |
| 3 | Missing `@DriftAccessor` annotations on all DAOs | FIXED. `BookDao`, `LocationDao`, `GenreDao`, `LanguageDao`, `TagDao`, `AuthorDao`, `ChangeLogDao` all have `@DriftAccessor()`. |
| 5 | `book_dao.dart:321` `updateBookWithRelations` ignored `shelfId = null` | FIXED. Shelf update block now writes `Value(shelfId)` regardless of null, allowing books to be moved to "None". |
| 6 | `book_dao.dart:21,33` `BookFilters.locationRoomId` never referenced in queries | FIXED. Both `listBooksPaginated` and `_listBooksWithAuthorSort` now INNER JOIN the location hierarchy and filter on `cupboard.room_id = ?`. |
| 7 | `location_dao.dart:171` `_nullifyBooksOnShelves` wrote `updatedAt` but no `ChangeLogEvent` rows | FIXED. `_nullifyBooksOnShelves` now inserts a `ChangeLogEvent` (`fieldName: 'shelf_id'`) for every affected book. |
| 9 | `author_dao.dart:45` `deleteAuthor` threw generic `Exception` instead of `ReferencedEntityException` | FIXED. Now throws `ReferencedEntityException` per US-1.1.20. |
| 10 | `book_dao.dart:456` `purchaseDate` sort lacked `NULLS LAST` | FIXED. `BookSort.purchaseDate` now orders with `DESC NULLS LAST`. |
| 11 | `book_dao.dart:283-345` `updateBookWithRelations` omitted change-log events for several fields | FIXED. Now writes `ChangeLogEvent` for `isbn`, `languageId`, `format`, `condition`, `status`, `authors`, `genres`, `shelf_id`, and `title`. |
| 12 | `book_dao.dart:501` `_listBooksWithAuthorSort` used `DISTINCT ... ORDER BY author.raw_name` causing latent SQLite runtime error | FIXED. Both `listBooksPaginated` and `_listBooksWithAuthorSort` now wrap the `DISTINCT` query in a subquery and apply `ORDER BY` on the outer query. |
| 18 | `language_dao.dart:1` Imported `genre_dao.dart` to reuse `BuiltInEntityException` | FIXED. Now imports the canonical `dao_exceptions.dart` directly. |

---

## BLOCKER — Must Fix (remaining + new)

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 4 | `sync_engine.dart:62,73,78,100,104,108,etc.` | **ProviderContainer leak into data layer is NOT fixed.** The `syncNow`/`push`/`pull` methods still accept `ProviderContainer? ref` and the engine still `import`s `package:flutter_riverpod/flutter_riverpod.dart`. The added `onStateChange` callback is a step forward, but `ref` remains in the public API and is actively used in `_emitState` and `_updateProgress`. Data layer must not depend on Riverpod. Remove `ref` from all engine methods and bridge at the provider level only. | Architecture |
| 8 | `sync_engine.dart:841` | **`syncEngineProvider` still throws `UnimplementedError`.** No real `SyncEngine` instance is wired. Any widget that `ref.watch(syncEngineProvider)` will crash at runtime. Must provide a real factory or at minimum a lazily-initialized instance. | Integration |
| N1 | `sync_engine.dart:555-566` | **`_updateProgress` silently swallows progress updates when using the `onStateChange` callback.** The method returns early (`if (onStateChange != null) return;`) without emitting anything, so production wiring via callback never receives progress fractions or stage messages. This makes the "fixed" callback path functionally broken for sync progress (US-1.3.9). | US-1.3.9 |
| N2 | `test/data/database/dao/book_dao_test.dart:27,34,41` | **Test seed IDs violate `withLength(min:36, max:36)` constraints.** `lang-en00-0000-0000-0000-000000000001` (37 chars), `genre-fiction-0000-0000-000000000001` (41 chars), and `author-paulo-0000-0000-000000000001` (39 chars) all exceed the 36-character limit enforced by `Languages`, `Genres`, and `Authors` tables. `setUp` throws `InvalidDataException` before any test body runs, blocking any attempt to replace stub assertions with real tests. | Tests |

---

## SHOULD FIX — Important (remaining from R1)

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 13 | `sync_engine.dart:380` | **`_merge` is still essentially empty.** All actual merge/replay logic lives in `_pull` via `_replayEvents`. Architecture remains hard to follow and `_merge` is not unit-testable in isolation. Either move replay logic into `_merge` or rename/remove `_merge` to reflect its true purpose. | Architecture |
| 14 | `sync_engine.dart:100-165` | **`_push` has no retry logic with exponential backoff.** `GoogleDriveClient` has a `_withRetry` helper, but `uploadFile` does **not** use it. US-1.3.16 requires retries up to 3 times with exponential backoff. The sync engine itself should retry the whole push on transient network failures. | US-1.3.16 |
| 15 | `book_repository.dart:90-180` | **`BookRepository` still bypasses `BookDao` for filtered search and duplicate detection.** `_filteredSearch` and `findDuplicates` perform raw database queries directly instead of delegating to `BookDao`. AGENTS.md mandates repositories consume DAOs. | Architecture |
| 16 | `sync_engine.dart:305-330` | **`_downloadRemoteEvents` downloads the entire remote `change_log.db` file and filters by timestamp locally.** The comment admits the Drive API lacks server-side filtering, but the US-1.3.2 spec says "only those 15 events are downloaded (not the entire file)." Consider using a separate metadata/index file or appending to a chunked log to avoid downloading the full history on every pull. | US-1.3.2 |
| 17 | `google_books_client.dart:227-231` | **Offline detection is still reactive, not proactive.** `_performGet` attempts the HTTP request and only catches `SocketException` on failure. US-1.2.14 says "skips the HTTP attempt when offline." The cache check happens first, but on cache miss the request is still attempted. Use a pre-flight connectivity check (e.g., `InternetAddress.lookup` or connectivity_plus) before calling `_httpClient.get`. | US-1.2.14 |
| 19 | `test/data/database/dao/book_dao_test.dart:27,34,41` | **Seed UUIDs remain invalid after the R1 fix attempt.** The language ID was changed from 35 to 37 characters; the genre and author IDs are 41 and 39 characters respectively. All three violate `min:36, max:36`. This prevents any real test execution in this file. | Tests |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| 20 | `book_dao.dart:97-140` | `getBookWithDetails` still executes 5 separate queries (book, authors, genres, tags, location path). A single joined query would be cleaner and closer to the "eagerly loaded (no N+1)" spirit of US-1.1.2. | US-1.1.2 |
| 21 | `location_dao.dart:155-168` | `listAllLocations()` still does N+1 queries. Consider a single hierarchical join or batch fetch. | US-1.1.11 |
| 22 | `lib/data/database/database.dart:82-93` | `google_books_cache` is still created via raw SQL in `onCreate` rather than being registered in `@DriftDatabase(tables: [...])`. Register `GoogleBooksCache` as a drift table and remove the manual `CREATE TABLE`. | Architecture |
| 23 | `sync_engine.dart:215,234,448` | `_uploadCatalog`, `_uploadCoverImages`, and `_createSnapshot` still pass empty byte arrays (`[]`) with no TODO comments indicating they are intentional stubs for a future workstream. Add `// TODO(phase-X): implement ...` markers. | US-1.3.1 |
| 24 | `auth_state_provider.dart:73` | `authServiceProvider` still throws `UnimplementedError`, same pattern as `syncEngineProvider`. Must be wired before production auth flows can work. | Integration |
| 25 | `sync_state_provider.dart:116` / `auth_state_provider.dart:99` | `syncStateProvider` and `authStateProvider` are still manually created with `NotifierProvider<...>(...)` instead of `@riverpod` + code generation. AGENTS.md recommends `@riverpod` for all stateful providers. | Architecture |
| N3 | `book_dao.dart:319` | `updateBookWithRelations` contains an unnecessary `if (true)` block around the shelf-assignment logic. Remove the dead conditional wrapper. | — |

---

## Verdict: NEEDS FIXES (4 blockers)

**Summary:**

- **6 of 8 R1 BLOCKERS are resolved.** The optimistic-lock math, `@DriftAccessor` annotations, Google Books fallback query preservation, location cascade filtering, null shelf assignment, and cascade change-log writes are all correctly implemented.
- **2 R1 BLOCKERS remain open:**
  - The ProviderContainer leak persists because `ref` was made optional rather than removed. The added `onStateChange` callback is undermined by `_updateProgress` swallowing progress updates in callback mode (new blocker N1), meaning the "correct" production path is broken.
  - `syncEngineProvider` remains an `UnimplementedError` crash hazard.
- **6 of 10 R1 SHOULD_FIX items remain open**, most notably: `_merge` is still empty, `_push` lacks retry logic, filtered search/duplicate detection bypass `BookDao`, the entire remote change log is still downloaded, offline detection is still reactive, and test seed UUIDs are still invalid (and now multiple tables are affected).
- **Test infrastructure is degraded:** `book_dao_test.dart` seed data throws `InvalidDataException` in `setUp`, meaning no test in that file can execute even if stubs are replaced. This is a hard blocker for test-driven iteration.

**Required before Round 3:**
1. Remove `ProviderContainer? ref` from **all** `SyncEngine` methods; bridge to Riverpod exclusively in the provider layer. Fix `_updateProgress` to emit progress via the callback when `onStateChange` is set.
2. Wire `syncEngineProvider` to a real `SyncEngine` factory.
3. Fix all test seed UUIDs in `book_dao_test.dart` to exactly 36 characters.
4. Address at least the SHOULD_FIX items #13–#15 (merge logic, push retry, repository/DAO coupling) to demonstrate architectural discipline.

After fixes, re-run `flutter test test/data/` and verify that stub tests are replaced with real assertions exercising the implementation.
