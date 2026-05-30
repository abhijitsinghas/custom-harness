# Code Review — Phase 1, Round 1

**Round:** 1 of 3
**`dart analyze lib/`:** clean (0 issues)
**`flutter test test/data/`:** 60 passed, 442 failed

## Summary

The sync engine tests pass cleanly (60 tests), confirming the sync engine, state provider, and Google Drive client mocks are wired correctly. However, the DAO, API client, and auth tests are all **stub failures** (`fail('TODO(implementer): ...')`) — they do not exercise the actual implementation. This review therefore focuses on **static code inspection against the user stories** and the **sync-engine green tests** as the only validated behavior.

---

## BLOCKER — Must Fix

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 1 | `sync_engine.dart:160-163` | Optimistic locking is **completely broken**. `localKnownVersion` is set to `remoteVersion` when `_lastSyncTimestamp != null`, making `remoteVersion > localKnownVersion` always `false`. The pull-then-retry logic (US-1.3.5) never executes. | US-1.3.5 |
| 2 | `google_books_client.dart:260` | On custom API key 403 fallback, `_performGet(query: '', ...)` passes an **empty query string**, discarding the original search. The retry will return irrelevant results or an error. | US-1.2.6 |
| 3 | `book_dao.dart:1` (representative) | **No `@DriftAccessor` annotation** on any DAO (`BookDao`, `LocationDao`, `GenreDao`, `LanguageDao`, `TagDao`, `AuthorDao`, `ChangeLogDao`). AGENTS.md §Drift Conventions requires `@DriftAccessor` + code generation. This blocks typed drift query helpers and compile-time validation. | Architecture |
| 4 | `sync_engine.dart:62` | `ProviderContainer` is passed as a required parameter into data-layer methods (`syncNow`, `_push`, `_pull`, `_merge`). The **data layer depends on Riverpod/Flutter**, violating the layered architecture contract (AGENTS.md §Separation of Concerns). The engine should expose a `Stream<SyncState>` or accept a callback, and the UI layer should bridge to Riverpod. | Architecture |
| 5 | `book_dao.dart:321` | `updateBookWithRelations` only updates `BookShelf.shelfId` when `shelfId != null`. It is **impossible to move a book to "None"** (set `shelfId` to null). US-1.1.3 requires changing shelf; US-1.1.12 implies nullification on cascade delete. | US-1.1.3 |
| 6 | `book_dao.dart:21,33` | `BookFilters.locationRoomId` is declared but **never referenced** inside `listBooksPaginated`. The location cascade filter (US-1.1.9) is entirely unimplemented for both `listBooksPaginated` and `_listBooksWithAuthorSort`. | US-1.1.9 |
| 7 | `location_dao.dart:171` | `_nullifyBooksOnShelves` updates `Book.updatedAt` but **does not write `ChangeLogEvent` rows** for the affected books. US-1.1.12 requires "`updated_at` + change-log events are written for every affected book." | US-1.1.12 |
| 8 | `sync_engine.dart:841` | `syncEngineProvider` throws `UnimplementedError`. The provider is not wired to a real `SyncEngine` instance, so any widget that watches it will crash at runtime. | Integration |

---

## SHOULD FIX — Important

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 9 | `author_dao.dart:45` | `deleteAuthor` throws generic `Exception('Cannot delete author...')` instead of `ReferencedEntityException` as required by US-1.1.20. | US-1.1.20 |
| 10 | `book_dao.dart:456` | `listBooksPaginated` with `BookSort.purchaseDate` orders by `book.purchase_date DESC` without `NULLS LAST`. SQLite sorts NULLs first by default, violating US-1.1.10 spec. | US-1.1.10 |
| 11 | `book_dao.dart:283-345` | `updateBookWithRelations` writes change-log events for `title`, `authors`, `genres`, and `shelf_id`, but **omits** `isbn`, `languageId`, `format`, `condition`, and `status`. US-1.1.3 requires a ChangeLogEvent for "every changed field." | US-1.1.3 |
| 12 | `book_dao.dart:501` | `_listBooksWithAuthorSort` uses `SELECT DISTINCT book.* ... ORDER BY author.raw_name COLLATE NOCASE`. In SQLite, `DISTINCT` requires `ORDER BY` expressions to appear in the `SELECT` list; this is a **latent runtime error** waiting to happen on certain SQLite builds or strict settings. | US-1.1.10 |
| 13 | `sync_engine.dart:380` | `_merge` is essentially empty (only sets UI state). All merge logic is inlined into `_pull` via `_replayEvents`, making the architecture hard to follow and `_merge` unit-testable in isolation only via the sync engine internals. | Architecture |
| 14 | `sync_engine.dart:147-185` | `_push` has **no retry logic with exponential backoff** on network timeout. US-1.3.16 requires "retries up to 3 times with exponential backoff." | US-1.3.16 |
| 15 | `book_repository.dart` | `BookRepository` **bypasses `BookDao` entirely** and performs raw database queries directly (e.g., `_ftsSearch`, `_filteredSearch`, `findDuplicates`). AGENTS.md says repositories consume DAOs. This duplicates logic already present in `DuplicateDetector` and `BookDao`. | Architecture |
| 16 | `sync_engine.dart:305-330` | `_downloadRemoteEvents` downloads the **entire** remote `change_log.db` file and filters by timestamp locally. US-1.3.2 says "only those 15 events are downloaded (not the entire file)." | US-1.3.2 |
| 17 | `google_books_client.dart:227-231` | Offline detection only catches `SocketException` **after** the HTTP request fails. US-1.2.14 says "skips the HTTP attempt when offline." The cache check happens first, but on cache miss the request is still attempted. | US-1.2.14 |
| 18 | `language_dao.dart:1` | Imports `genre_dao.dart` solely to reuse `BuiltInEntityException`, creating an unnecessary coupling. Both `genre_dao.dart` and `language_dao.dart` define their own copy of `BuiltInEntityException` instead of importing the canonical one from `dao_exceptions.dart` (which exists but is unused). | Architecture |
| 19 | `test/data/database/dao/book_dao_test.dart:25` | Seed language ID `'lang-en-0000-0000-0000-000000000001'` is **35 characters**, but `language_table.dart` enforces `min: 36`. Any attempt to run this seed data will throw `InvalidDataException`. (Same issue may exist in other test files.) | Tests |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| 20 | `book_dao.dart:97-140` | `getBookWithDetails` executes 5 separate queries (book, authors, genres, tags, location path) instead of a single joined query. US-1.1.2 says "eagerly loaded (no N+1)" — for a single book this is acceptable, but a single query with joins would be cleaner. | US-1.1.2 |
| 21 | `location_dao.dart:155-168` | `listAllLocations()` does N+1 queries (one per room, then one per cupboard). A single hierarchical join or recursive CTE would be more efficient for large libraries. | US-1.1.11 |
| 22 | `google_books_cache.dart` | `GoogleBooksCache` table is created via raw SQL in `database.dart` migration rather than being registered in `@DriftDatabase`. Since `dart analyze` is now clean, add the table to `@DriftDatabase` and remove the manual `CREATE TABLE`. | Architecture |
| 23 | `sync_engine.dart:215,234,448` | `_uploadCatalog`, `_uploadCoverImages`, and `_createSnapshot` are stubs passing empty byte arrays (`[]`). Add TODO comments linking to the follow-up workstream so future reviewers don't mistake them for forgotten code. | US-1.3.1 |
| 24 | `auth_state_provider.dart:73` | `authServiceProvider` throws `UnimplementedError`, identical pattern to `syncEngineProvider`. Must be wired before the app can authenticate in production. | Integration |
| 25 | `sync_state_provider.dart:116` `auth_state_provider.dart:99` | `syncStateProvider` and `authStateProvider` are manually created with `NotifierProvider<...>(...)` instead of `@riverpod` + code generation. AGENTS.md §Riverpod Conventions recommends `@riverpod` for all stateful providers. | Architecture |

---

## Resolved from Round 0

*Round 0 was the foundation phase; no prior review round exists for Phase 1.*

---

## Verdict: NEEDS FIXES (8 blockers)

**Summary:**

- **Sync engine (1.3)** is the strongest area: 60 passing tests, state machine works, conflict detection and merge logic are structurally correct. The main blockers are the broken optimistic-lock math and the data-layer Riverpod leak.
- **Database DAOs (1.1)** have functional CRUD, search, and duplicate detection, but violate the `@DriftAccessor` convention, miss location filtering entirely, cannot clear a shelf to null, and fail to write change logs during cascade deletes.
- **Google Books client (1.2)** is mostly complete but has a critical bug in the custom-key fallback that drops the search query, and lacks proactive offline detection.
- **Auth (1.4)** uses valid `google_sign_in` 7.2.0 APIs, but the provider is unimplemented and the architecture coupling is minor.

**Required before next round:**
1. Fix optimistic-lock version math (`sync_engine.dart:160-163`).
2. Fix custom-key fallback to preserve the original query (`google_books_client.dart:260`).
3. Add `@DriftAccessor` to all DAOs or justify the deviation.
4. Remove `ProviderContainer` from the sync engine data layer; bridge at the provider level.
5. Allow `shelfId: null` in `updateBookWithRelations` to clear location.
6. Implement `locationRoomId` filtering in `listBooksPaginated`.
7. Write `ChangeLogEvent` rows in `_nullifyBooksOnShelves`.
8. Wire `syncEngineProvider` to a real instance (and `authServiceProvider`).

After fixes, re-run `flutter test test/data/` and verify that the stub tests are replaced with real assertions exercising the implementation.
