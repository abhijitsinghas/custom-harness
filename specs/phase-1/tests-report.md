# Test Report — Phase 1: Data & Sync Engine

> **Generated:** 2026-05-29  
> **Pipeline:** FULL TDD (1.1, 1.3) + LIGHT TDD (1.2, 1.4)  
> **Expected:** ALL tests FAIL — no implementation exists yet

---

## Coverage Map

### Workstream 1.1 — Database DAOs & Full CRUD (FULL TDD)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1.1.1 | `test/data/database/dao/book_dao_test.dart` | should insert book, authors, genres, tags, shelf in one transaction | Unit |
| US-1.1.1 | `test/data/database/dao/book_dao_test.dart` | should rollback entire transaction on any insert failure | Unit |
| US-1.1.1 | `test/data/database/dao/book_dao_test.dart` | should write ChangeLogEvent for the create operation | Unit |
| US-1.1.1 | `test/data/database/dao/book_dao_test.dart` | should allow null shelfId for "None" location | Unit |
| US-1.1.2 | `test/data/database/dao/book_dao_test.dart` | should return book with all authors, genres, tags, language, location eagerly loaded | Unit |
| US-1.1.2 | `test/data/database/dao/book_dao_test.dart` | should include full location path Room → Cupboard → Shelf | Unit |
| US-1.1.2 | `test/data/database/dao/book_dao_test.dart` | should return null for non-existent bookId | Unit |
| US-1.1.3 | `test/data/database/dao/book_dao_test.dart` | should update title, replace authors, add genre, remove tag, change shelf in one transaction | Unit |
| US-1.1.3 | `test/data/database/dao/book_dao_test.dart` | should replace join-table rows to match new lists | Unit |
| US-1.1.3 | `test/data/database/dao/book_dao_test.dart` | should update Book.updatedAt on modification | Unit |
| US-1.1.3 | `test/data/database/dao/book_dao_test.dart` | should write ChangeLogEvent per changed field | Unit |
| US-1.1.4 | `test/data/database/dao/book_dao_test.dart` | should set isDeleted=true without removing the row | Unit |
| US-1.1.4 | `test/data/database/dao/book_dao_test.dart` | should refresh updatedAt on soft delete | Unit |
| US-1.1.4 | `test/data/database/dao/book_dao_test.dart` | should write a delete change-log event | Unit |
| US-1.1.4 | `test/data/database/dao/book_dao_test.dart` | should keep BookLoan records intact for deleted book | Unit |
| US-1.1.5 | `test/data/database/dao/book_dao_test.dart` | should set isDeleted=false and keep previous status | Unit |
| US-1.1.5 | `test/data/database/dao/book_dao_test.dart` | should preserve shelfId after restore | Unit |
| US-1.1.5 | `test/data/database/dao/book_dao_test.dart` | should write an update change-log event on restore | Unit |
| US-1.1.6 | `test/data/database/dao/book_dao_test.dart` | should return 50 books ordered by createdAt DESC for offset 0 | Unit |
| US-1.1.6 | `test/data/database/dao/book_dao_test.dart` | should return next 50 books at offset 50 | Unit |
| US-1.1.6 | `test/data/database/dao/book_dao_test.dart` | should handle offset beyond total count (empty list, not crash) | Unit |
| US-1.1.6 | `test/data/database/dao/book_dao_test.dart` | should exclude soft-deleted books by default | Unit |
| US-1.1.7 | `test/data/database/dao/book_dao_test.dart` | should return books matching FTS5 query on title, isbn, or publisher | Unit |
| US-1.1.7 | `test/data/database/dao/book_dao_test.dart` | should rank results by FTS5 relevance | Unit |
| US-1.1.7 | `test/data/database/dao/book_dao_test.dart` | should search isbn field via FTS5 | Unit |
| US-1.1.7 | `test/data/database/dao/book_dao_test.dart` | should search publisher field via FTS5 | Unit |
| US-1.1.8 | `test/data/database/dao/book_dao_test.dart` | should return books linked to authors matching LIKE query | Unit |
| US-1.1.8 | `test/data/database/dao/book_dao_test.dart` | should match partial author name (trigram-style LIKE) | Unit |
| US-1.1.8 | `test/data/database/dao/book_dao_test.dart` | should return empty list when no author matches | Unit |
| US-1.1.9 | `test/data/database/dao/book_dao_test.dart` | should return books matching genre, language, status, format, condition, tags, location | Unit |
| US-1.1.9 | `test/data/database/dao/book_dao_test.dart` | should cascade location filter Room → Cupboard → Shelf | Unit |
| US-1.1.9 | `test/data/database/dao/book_dao_test.dart` | should exclude soft-deleted books when showDeleted=false | Unit |
| US-1.1.9 | `test/data/database/dao/book_dao_test.dart` | should include soft-deleted books when showDeleted=true | Unit |
| US-1.1.9 | `test/data/database/dao/book_dao_test.dart` | should return empty list when no book matches all active filters | Unit |
| US-1.1.10 | `test/data/database/dao/book_dao_test.dart` | should sort A-Z by title COLLATE NOCASE | Unit |
| US-1.1.10 | `test/data/database/dao/book_dao_test.dart` | should produce duplicate rows per distinct author for author sort | Unit |
| US-1.1.10 | `test/data/database/dao/book_dao_test.dart` | should sort by createdAt DESC for recentlyAdded | Unit |
| US-1.1.10 | `test/data/database/dao/book_dao_test.dart` | should sort by purchaseDate DESC with nulls last | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should create a Room with UUID and enforce FK constraints | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should create a Cupboard linked to a Room | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should create a Shelf linked to a Cupboard | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should return full tree via cascading query (Room → Cupboards → Shelves) | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should enforce FK constraint: cannot create Cupboard for non-existent Room | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should enforce FK constraint: cannot create Shelf for non-existent Cupboard | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should allow renaming a Room | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should allow renaming a Cupboard | Unit |
| US-1.1.11 | `test/data/database/dao/location_dao_test.dart` | should allow renaming a Shelf | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should delete Cupboard and its Shelves in a transaction | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should set affected BookShelf.shelfId to null for books on deleted shelves | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should update updatedAt for every affected book | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should write ChangeLogEvent for every affected book | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should delete a Room and cascades through Cupboards → Shelves | Unit |
| US-1.1.12 | `test/data/database/dao/location_dao_test.dart` | should delete a Shelf and set its books to null shelfId | Unit |
| US-1.1.13 | `test/data/database/dao/genre_dao_test.dart` | should seed 20 predefined genres with isCustom=false on first open | Unit |
| US-1.1.13 | `test/data/database/dao/genre_dao_test.dart` | should be idempotent: reopening DB does not duplicate genres | Unit |
| US-1.1.13 | `test/data/database/dao/genre_dao_test.dart` | should include genres: Fiction, Non-Fiction, Science, Technology, History, etc. | Unit |
| US-1.1.13 | `test/data/database/dao/language_dao_test.dart` | should seed English, Hindi, Sanskrit with isBuiltin=true on first open | Unit |
| US-1.1.13 | `test/data/database/dao/language_dao_test.dart` | should be idempotent: reopening DB does not duplicate languages | Unit |
| US-1.1.13 | `test/data/database/dao/language_dao_test.dart` | should seed English language | Unit |
| US-1.1.13 | `test/data/database/dao/language_dao_test.dart` | should seed Hindi language | Unit |
| US-1.1.13 | `test/data/database/dao/language_dao_test.dart` | should seed Sanskrit language | Unit |
| US-1.1.14 | `test/data/database/dao/genre_dao_test.dart` | should throw BuiltInEntityException when deleting built-in genre | Unit |
| US-1.1.14 | `test/data/database/dao/genre_dao_test.dart` | should allow deleting custom genre (isCustom=true) | Unit |
| US-1.1.14 | `test/data/database/dao/genre_dao_test.dart` | should not physically delete the built-in genre row | Unit |
| US-1.1.14 | `test/data/database/dao/language_dao_test.dart` | should throw BuiltInEntityException when deleting built-in language | Unit |
| US-1.1.14 | `test/data/database/dao/language_dao_test.dart` | should allow deleting custom language (isBuiltin=false) | Unit |
| US-1.1.14 | `test/data/database/dao/language_dao_test.dart` | should not physically delete the built-in language row | Unit |
| US-1.1.15 | `test/data/database/duplicate_detector_test.dart` | should return DuplicateResult.exactMatch when same ISBN-13 exists | Unit |
| US-1.1.15 | `test/data/database/duplicate_detector_test.dart` | should normalize ISBNs before comparison (strip hyphens, spaces) | Unit |
| US-1.1.15 | `test/data/database/duplicate_detector_test.dart` | should return null when ISBN does not match any existing book | Unit |
| US-1.1.15 | `test/data/database/duplicate_detector_test.dart` | should only check non-deleted books for ISBN match | Unit |
| US-1.1.16 | `test/data/database/duplicate_detector_test.dart` | should return DuplicateResult.fuzzyMatch when Levenshtein ratio ≥ 80% | Unit |
| US-1.1.16 | `test/data/database/duplicate_detector_test.dart` | should compute similarity on normalized title and author | Unit |
| US-1.1.16 | `test/data/database/duplicate_detector_test.dart` | should return null when similarity below 80% threshold | Unit |
| US-1.1.16 | `test/data/database/duplicate_detector_test.dart` | should fuzzy match on at least one author of multi-author books | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should convert known ISBN-10 0062315005 → 9780062315007 | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should return unmodified ISBN-13 when already 13 digits | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should strip hyphens and spaces before conversion | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should validate ISBN-10 checksum before conversion | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should compute correct ISBN-13 checksum digit | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should handle ISBN-10 ending in X (10 as checksum) | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should normalize ISBN by stripping all non-digit characters except X | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should return null or throw for invalid-length input | Unit |
| US-1.1.17 | `test/data/database/isbn_utils_test.dart` | should detect ISBN-10 vs ISBN-13 format correctly | Unit |
| US-1.1.17 | `test/data/database/duplicate_detector_test.dart` | should convert ISBN-10 to ISBN-13 on save | Unit |
| US-1.1.17 | `test/data/database/duplicate_detector_test.dart` | should normalize duplicate detection against converted 13-digit form | Unit |
| US-1.1.17 | `test/data/database/duplicate_detector_test.dart` | should store the converted ISBN-13 in the database | Unit |
| US-1.1.18 | `test/data/database/duplicate_detector_test.dart` | should skip ISBN exact-match step when isbn is null | Unit |
| US-1.1.18 | `test/data/database/duplicate_detector_test.dart` | should still perform fuzzy title+author check when ISBN is null | Unit |
| US-1.1.18 | `test/data/database/duplicate_detector_test.dart` | should detect fuzzy duplicate even without ISBN | Unit |
| US-1.1.19 | `test/data/database/dao/book_dao_test.dart` | should show book twice when sorted by author and book has two authors | Unit |
| US-1.1.19 | `test/data/database/dao/book_dao_test.dart` | should show book once when sorted by title (non-author sorts) | Unit |
| US-1.1.20 | `test/data/database/dao/book_dao_test.dart` | should reject deletion when author is linked to books | Unit |
| US-1.1.20 | `test/data/database/dao/author_dao_test.dart` | should throw ReferencedEntityException when deleting author linked to books | Unit |
| US-1.1.20 | `test/data/database/dao/author_dao_test.dart` | should allow deleting author not linked to any books | Unit |
| US-1.1.20 | `test/data/database/dao/author_dao_test.dart` | should preserve referential integrity after reject | Unit |
| US-1.1.21 | `test/data/database/dao/book_dao_test.dart` | should return empty lists (not null) for tags and genres | Unit |
| US-1.1.21 | `test/data/database/dao/book_dao_test.dart` | should not crash on missing joins with zero tags/genres | Unit |
| US-1.1.22 | `test/data/database/dao/book_dao_test.dart` | should store 1000-char title without truncation | Unit |
| US-1.1.22 | `test/data/database/dao/book_dao_test.dart` | should store 5000-char description without truncation | Unit |
| US-1.1.22 | `test/data/database/dao/book_dao_test.dart` | should index long title in FTS5 correctly | Unit |
| US-1.1.23 | `test/data/database/dao/book_dao_test.dart` | should serialize concurrent transactions on same book | Unit |
| US-1.1.23 | `test/data/database/dao/book_dao_test.dart` | should produce two distinct change log events for concurrent writes | Unit |
| US-1.1.24 | `test/data/database/dao/book_dao_test.dart` | should rollback entire multi-table insert on FK violation | Unit |
| US-1.1.24 | `test/data/database/dao/book_dao_test.dart` | should leave no partial data after rollback | Unit |
| US-1.1.24 | `test/data/database/dao/book_dao_test.dart` | should throw DriftWrappedException with clear message | Unit |
| US-1.1.25 | `test/data/database/dao/book_dao_test.dart` | should return zero rows for malformed UUID (no crash) | Unit |
| US-1.1.26 | `test/data/database/dao/book_dao_test.dart` | should return empty list (not null) from listBooksPaginated | Unit |
| US-1.1.26 | `test/data/database/dao/book_dao_test.dart` | should return count 0 for empty catalog | Unit |
| US-1.1.27 | `test/data/database/dao/book_dao_test.dart` | should return empty list from searchBooksByFts for nonexistent term | Unit |
| US-1.1.27 | `test/data/database/dao/book_dao_test.dart` | should return empty list from searchBooksByAuthor for nonexistent author | Unit |
| US-1.1.28 | `test/data/database/dao/location_dao_test.dart` | should return empty tree from listAllLocations when no locations exist | Unit |
| US-1.1.28 | `test/data/database/dao/location_dao_test.dart` | should default book location to "None" (null shelfId) when no locations | Unit |
| US-1.1.29 | `test/data/database/dao/book_dao_test.dart` | should expose data models supporting semantic labels for UI | Unit |

### Workstream 1.2 — Google Books API Client (LIGHT TDD)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1.2.1 | `test/data/api/google_books_client_test.dart` | should issue GET with q=isbn:<isbn> and return List<BookEnrichment> | Unit |
| US-1.2.1 | `test/data/api/google_books_client_test.dart` | should return first item as strongest match | Unit |
| US-1.2.1 | `test/data/api/google_books_client_test.dart` | should populate title, authors, publisher, description, pageCount, coverUrl | Unit |
| US-1.2.1 | `test/data/api/google_books_client_test.dart` | should use default API key when no custom key set | Unit |
| US-1.2.2 | `test/data/api/google_books_client_test.dart` | should send intitle: and inauthor: query parameters | Unit |
| US-1.2.2 | `test/data/api/google_books_client_test.dart` | should return up to 5 BookEnrichment results | Unit |
| US-1.2.2 | `test/data/api/google_books_client_test.dart` | should handle empty author (title-only search) | Unit |
| US-1.2.3 | `test/data/api/google_books_client_test.dart` | should preserve API order (best match first) | Unit |
| US-1.2.3 | `test/data/api/google_books_client_test.dart` | should ensure every item has non-null title and authors list | Unit |
| US-1.2.4 | `test/data/api/google_books_client_test.dart` | should return cached result without HTTP request when cache is valid | Unit |
| US-1.2.4 | `test/data/api/google_books_client_test.dart` | should return cached result in < 50ms | Unit |
| US-1.2.4 | `test/data/api/google_books_client_test.dart` | should deserialize from google_books_cache table | Unit |
| US-1.2.5 | `test/data/api/google_books_client_test.dart` | should match cache key using SHA-256 of normalized title+author | Unit |
| US-1.2.5 | `test/data/api/google_books_client_test.dart` | should case-normalize title and author before hashing | Unit |
| US-1.2.5 | `test/data/api/google_books_client_test.dart` | should return cached result for identical title+author lookup | Unit |
| US-1.2.6 | `test/data/api/google_books_client_test.dart` | should append custom key as &key= when stored in local settings | Unit |
| US-1.2.6 | `test/data/api/google_books_client_test.dart` | should fall back to default app key once on 403/invalid-key | Unit |
| US-1.2.7 | `test/data/api/google_books_client_test.dart` | should increment daily counter on successful request | Unit |
| US-1.2.7 | `test/data/api/google_books_client_test.dart` | should emit isQuotaExceeded=false after successful request | Unit |
| US-1.2.7 | `test/data/api/google_books_client_test.dart` | should persist daily counter across app restarts | Unit |
| US-1.2.8 | `test/data/api/google_books_client_test.dart` | should cancel HTTP request and throw TimeoutException after 10 seconds | Unit |
| US-1.2.9 | `test/data/api/google_books_client_test.dart` | should treat cache as miss when entry is older than 7 days | Unit |
| US-1.2.9 | `test/data/api/google_books_client_test.dart` | should delete stale cache row and issue fresh network request | Unit |
| US-1.2.10 | `test/data/api/google_books_client_test.dart` | should return empty list (not null) when totalItems is 0 | Unit |
| US-1.2.11 | `test/data/api/google_books_client_test.dart` | should set authors to empty list when volumeInfo.authors is missing | Unit |
| US-1.2.11 | `test/data/api/google_books_client_test.dart` | should populate remaining fields normally even with null authors | Unit |
| US-1.2.12 | `test/data/api/google_books_client_test.dart` | should store coverUrl exactly as provided without rewriting | Unit |
| US-1.2.13 | `test/data/api/google_books_client_test.dart` | should emit isQuotaExceeded=true on HTTP 429 | Unit |
| US-1.2.13 | `test/data/api/google_books_client_test.dart` | should emit isQuotaExceeded=true on HTTP 403 with quota message | Unit |
| US-1.2.13 | `test/data/api/google_books_client_test.dart` | should stop incrementing daily counter when quota exceeded | Unit |
| US-1.2.13 | `test/data/api/google_books_client_test.dart` | should short-circuit subsequent calls with QuotaExceededException | Unit |
| US-1.2.14 | `test/data/api/google_books_client_test.dart` | should throw OfflineException when device has no internet | Unit |
| US-1.2.14 | `test/data/api/google_books_client_test.dart` | should skip HTTP attempt when offline | Unit |
| US-1.2.14 | `test/data/api/google_books_client_test.dart` | should return stale cached result when offline (fallback) | Unit |
| US-1.2.15 | `test/data/api/google_books_client_test.dart` | should catch FormatException and return empty list | Unit |
| US-1.2.15 | `test/data/api/google_books_client_test.dart` | should log the error without crashing | Unit |
| US-1.2.16 | `test/data/api/google_books_client_test.dart` | should trigger cache miss and use network on first lookup | Unit |
| US-1.2.16 | `test/data/api/google_books_client_test.dart` | should populate cache table with first result | Unit |
| US-1.2.17 | `test/data/api/google_books_client_test.dart` | should expose loading state for screen reader announcement | Unit |

### Workstream 1.3 — Sync Engine (FULL TDD)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1.3.1 | `test/data/sync/sync_engine_test.dart` | should upload catalog.db when version matches remote | Unit |
| US-1.3.1 | `test/data/sync/sync_engine_test.dart` | should append new events to remote change_log.db | Unit |
| US-1.3.1 | `test/data/sync/sync_engine_test.dart` | should overwrite version.txt with incremented version | Unit |
| US-1.3.1 | `test/data/sync/sync_engine_test.dart` | should upload new cover images to covers/ | Unit |
| US-1.3.1 | `test/data/sync/sync_engine_test.dart` | should emit pushing → idle in SyncState | Unit |
| US-1.3.2 | `test/data/sync/sync_engine_test.dart` | should download only events newer than local_last_sync_timestamp | Unit |
| US-1.3.2 | `test/data/sync/sync_engine_test.dart` | should replay downloaded events locally | Unit |
| US-1.3.2 | `test/data/sync/sync_engine_test.dart` | should download new cover images referenced in remote events | Unit |
| US-1.3.2 | `test/data/sync/sync_engine_test.dart` | should update local_last_sync_timestamp to newest event timestamp | Unit |
| US-1.3.3 | `test/data/sync/sync_engine_test.dart` | should apply remote title change when no local uncommitted title change | Unit |
| US-1.3.3 | `test/data/sync/sync_engine_test.dart` | should not queue conflict for non-overlapping field changes | Unit |
| US-1.3.3 | `test/data/sync/sync_engine_test.dart` | should update local DB without user interaction | Unit |
| US-1.3.4 | `test/data/sync/sync_engine_test.dart` | should queue conflict when remote changes same field with un-synced local change | Unit |
| US-1.3.4 | `test/data/sync/sync_engine_test.dart` | should emit SyncState error with conflict count | Unit |
| US-1.3.4 | `test/data/sync/sync_engine_test.dart` | should not apply remote value when conflict queued | Unit |
| US-1.3.5 | `test/data/sync/sync_engine_test.dart` | should abort push when remote version is newer than local last-known | Unit |
| US-1.3.5 | `test/data/sync/sync_engine_test.dart` | should trigger pull-first, merge, then retry push | Unit |
| US-1.3.5 | `test/data/sync/sync_engine_test.dart` | should complete push after merge with updated version | Unit |
| US-1.3.6 | `test/data/sync/sync_engine_test.dart` | should create compact state snapshot at exactly 1000 events | Unit |
| US-1.3.6 | `test/data/sync/sync_engine_test.dart` | should reset event counter after snapshot | Unit |
| US-1.3.6 | `test/data/sync/sync_engine_test.dart` | should replay from snapshot point on next pull | Unit |
| US-1.3.7 | `test/data/sync/sync_engine_test.dart` | should detect when remote create matches soft-deleted local book by ISBN | Unit |
| US-1.3.7 | `test/data/sync/sync_engine_test.dart` | should surface warning (restore vs add-as-new) instead of creating duplicate | Unit |
| US-1.3.8 | `test/data/sync/sync_engine_test.dart` | should emit idle when no sync activity | Unit |
| US-1.3.8 | `test/data/sync/sync_engine_test.dart` | should emit pulling when downloading changes | Unit |
| US-1.3.8 | `test/data/sync/sync_engine_test.dart` | should emit pushing when uploading changes | Unit |
| US-1.3.8 | `test/data/sync/sync_engine_test.dart` | should emit offline when no internet | Unit |
| US-1.3.8 | `test/data/sync/sync_engine_test.dart` | should emit error with specific message for each error type | Unit |
| US-1.3.8 | `test/data/sync/sync_state_provider_test.dart` | should emit idle as initial state | Unit |
| US-1.3.8 | `test/data/sync/sync_state_provider_test.dart` | should emit pulling during pull operation | Unit |
| US-1.3.8 | `test/data/sync/sync_state_provider_test.dart` | should emit pushing during push operation | Unit |
| US-1.3.8 | `test/data/sync/sync_state_provider_test.dart` | should emit offline when no internet available | Unit |
| US-1.3.8 | `test/data/sync/sync_state_provider_test.dart` | should emit error with message for each error type | Unit |
| US-1.3.9 | `test/data/sync/sync_engine_test.dart` | should emit progress fraction (0.0 → 1.0) during large merge | Unit |
| US-1.3.9 | `test/data/sync/sync_engine_test.dart` | should emit stage messages during merge phases | Unit |
| US-1.3.9 | `test/data/sync/sync_state_provider_test.dart` | should emit progress fraction during large sync | Unit |
| US-1.3.9 | `test/data/sync/sync_state_provider_test.dart` | should emit stage messages during merge phases | Unit |
| US-1.3.10 | `test/data/sync/sync_engine_test.dart` | should download nothing when no events newer than last_sync_timestamp | Unit |
| US-1.3.10 | `test/data/sync/sync_engine_test.dart` | should emit pulling → idle with no changes | Unit |
| US-1.3.10 | `test/data/sync/sync_engine_test.dart` | should not change last_sync_timestamp | Unit |
| US-1.3.11 | `test/data/sync/sync_engine_test.dart` | should skip upload when no writes since last push | Unit |
| US-1.3.11 | `test/data/sync/sync_engine_test.dart` | should not increment version | Unit |
| US-1.3.11 | `test/data/sync/sync_engine_test.dart` | should emit idle immediately | Unit |
| US-1.3.12 | `test/data/sync/sync_engine_test.dart` | should queue "delete vs update" conflict when remote delete arrives for locally modified book | Unit |
| US-1.3.12 | `test/data/sync/sync_engine_test.dart` | should keep book visible until user resolves the conflict | Unit |
| US-1.3.13 | `test/data/sync/sync_engine_test.dart` | should replay only events after snapshot boundary | Unit |
| US-1.3.13 | `test/data/sync/sync_engine_test.dart` | should not create new snapshot until event 2000 | Unit |
| US-1.3.14 | `test/data/sync/sync_engine_test.dart` | should emit offline with pending change count | Unit |
| US-1.3.14 | `test/data/sync/sync_engine_test.dart` | should skip all Drive API calls when offline | Unit |
| US-1.3.14 | `test/data/sync/sync_engine_test.dart` | should retry on next foreground event | Unit |
| US-1.3.15 | `test/data/sync/sync_engine_test.dart` | should emit error with "Drive storage full" message | Unit |
| US-1.3.15 | `test/data/sync/sync_engine_test.dart` | should keep changes queued locally | Unit |
| US-1.3.16 | `test/data/sync/sync_engine_test.dart` | should retry up to 3 times with exponential backoff | Unit |
| US-1.3.16 | `test/data/sync/sync_engine_test.dart` | should emit error with "Sync timed out" after third failure | Unit |
| US-1.3.16 | `test/data/sync/sync_engine_test.dart` | should schedule next retry on app foreground | Unit |
| US-1.3.17 | `test/data/sync/sync_engine_test.dart` | should detect SQLite integrity check failure on downloaded catalog.db | Unit |
| US-1.3.17 | `test/data/sync/sync_engine_test.dart` | should emit error with restore-from-local option | Unit |
| US-1.3.18 | `test/data/sync/sync_engine_test.dart` | should attempt silent token refresh on 401 | Unit |
| US-1.3.18 | `test/data/sync/sync_engine_test.dart` | should emit error with re-authenticate message on refresh failure | Unit |
| US-1.3.18 | `test/data/sync/sync_engine_test.dart` | should queue push for retry after auth recovery | Unit |
| US-1.3.19 | `test/data/sync/sync_engine_test.dart` | should emit error with "Library folder not found" on 404 | Unit |
| US-1.3.19 | `test/data/sync/sync_engine_test.dart` | should recreate folder and seed from local state on user confirmation | Unit |
| US-1.3.19 | `test/data/sync/sync_engine_test.dart` | should reset version to 1 after recreation | Unit |
| US-1.3.20 | `test/data/sync/sync_engine_test.dart` | should abort sync when remote schema version > local | Unit |
| US-1.3.20 | `test/data/sync/sync_engine_test.dart` | should signal force-update required | Unit |
| US-1.3.21 | `test/data/sync/sync_engine_test.dart` | should allow push when local schema version > remote | Unit |
| US-1.3.21 | `test/data/sync/sync_engine_test.dart` | should update remote app_schema_version on push | Unit |
| US-1.3.22 | `test/data/sync/sync_engine_test.dart` | should create folder and all files from scratch when no remote exists | Unit |
| US-1.3.22 | `test/data/sync/sync_engine_test.dart` | should start version.txt at 1 | Unit |
| US-1.3.22 | `test/data/sync/sync_engine_test.dart` | should emit "Library created on Drive" message | Unit |
| US-1.3.23 | `test/data/sync/sync_engine_test.dart` | should return empty conflict queue when no conflicts exist | Unit |
| US-1.3.24 | `test/data/sync/sync_engine_test.dart` | should include explicit text with error color for color-blind users | Unit |
| US-1.3.24 | `test/data/sync/sync_state_provider_test.dart` | should expose text labels for sync states suitable for TalkBack | Unit |
| US-1.3.24 | `test/data/sync/sync_state_provider_test.dart` | should combine color + text for error states | Unit |
| US-1.3.25 | `test/data/sync/sync_engine_test.dart` | should expose conflict details for TalkBack announcements | Unit |

### Workstream 1.4 — Google Sign-In & Auth (LIGHT TDD)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1.4.1 | `test/data/auth/auth_service_test.dart` | should initiate OAuth flow via google_sign_in | Unit |
| US-1.4.1 | `test/data/auth/auth_service_test.dart` | should return GoogleSignInAccount on success | Unit |
| US-1.4.1 | `test/data/auth/auth_service_test.dart` | should emit signedIn(account) in AuthState | Unit |
| US-1.4.2 | `test/data/auth/auth_service_test.dart` | should read stored account from SharedPreferences on launch | Unit |
| US-1.4.2 | `test/data/auth/auth_service_test.dart` | should attempt silent sign-in with stored account | Unit |
| US-1.4.2 | `test/data/auth/auth_service_test.dart` | should emit signedIn without showing wizard on success | Unit |
| US-1.4.3 | `test/data/auth/auth_service_test.dart` | should call google_sign_in.signOut() | Unit |
| US-1.4.3 | `test/data/auth/auth_service_test.dart` | should clear SharedPreferences auth state | Unit |
| US-1.4.3 | `test/data/auth/auth_service_test.dart` | should emit signedOut in AuthState | Unit |
| US-1.4.3 | `test/data/auth/auth_service_test.dart` | should not touch local SQLite database | Unit |
| US-1.4.4 | `test/data/auth/auth_service_test.dart` | should call google_sign_in.signInSilently() before Drive API calls | Unit |
| US-1.4.4 | `test/data/auth/auth_service_test.dart` | should receive fresh token and proceed with Drive call | Unit |
| US-1.4.5 | `test/data/auth/auth_service_test.dart` | should emit AuthState.signedIn(account) with displayName and email | Unit |
| US-1.4.5 | `test/data/auth/auth_service_test.dart` | should emit AuthState.signedOut with no account | Unit |
| US-1.4.5 | `test/data/auth/auth_service_test.dart` | should emit AuthState.skipped for offline-only mode | Unit |
| US-1.4.5 | `test/data/auth/auth_state_provider_test.dart` | should emit signedOut as initial state | Unit |
| US-1.4.5 | `test/data/auth/auth_state_provider_test.dart` | should emit signedIn(account) on successful sign-in | Unit |
| US-1.4.5 | `test/data/auth/auth_state_provider_test.dart` | should emit signedOut on explicit sign-out | Unit |
| US-1.4.5 | `test/data/auth/auth_state_provider_test.dart` | should emit skipped when user chooses offline mode | Unit |
| US-1.4.5 | `test/data/auth/auth_state_provider_test.dart` | should include displayName and email in signedIn state | Unit |
| US-1.4.6 | `test/data/auth/auth_service_test.dart` | should set deviceUser to email on write operations | Unit |
| US-1.4.6 | `test/data/auth/auth_service_test.dart` | should expose displayName for UI rendering | Unit |
| US-1.4.7 | `test/data/auth/auth_service_test.dart` | should emit AuthState.skipped when user skips | Unit |
| US-1.4.7 | `test/data/auth/auth_service_test.dart` | should allow all local CRUD operations in skipped mode | Unit |
| US-1.4.7 | `test/data/auth/auth_service_test.dart` | should disable sync features in skipped mode | Unit |
| US-1.4.8 | `test/data/auth/auth_service_test.dart` | should pull remote catalog and merge when signing in after skip | Unit |
| US-1.4.8 | `test/data/auth/auth_service_test.dart` | should compare timestamps and apply non-conflicting remote events | Unit |
| US-1.4.8 | `test/data/auth/auth_service_test.dart` | should queue conflicts if local and remote changes clash | Unit |
| US-1.4.8 | `test/data/auth/auth_service_test.dart` | should push local changes after merge | Unit |
| US-1.4.9 | `test/data/auth/auth_service_test.dart` | should catch PlatformException and emit signedOut | Unit |
| US-1.4.9 | `test/data/auth/auth_service_test.dart` | should show error: "Google Sign-In is not available on this device" | Unit |
| US-1.4.10 | `test/data/auth/auth_service_test.dart` | should return null account and stay signedOut on cancel | Unit |
| US-1.4.10 | `test/data/auth/auth_service_test.dart` | should show non-blocking "Sign-in cancelled" message | Unit |
| US-1.4.11 | `test/data/auth/auth_service_test.dart` | should emit signedOut when stored token is invalid | Unit |
| US-1.4.11 | `test/data/auth/auth_service_test.dart` | should open catalog screen with local data | Unit |
| US-1.4.11 | `test/data/auth/auth_service_test.dart` | should show "Sign in to sync" status | Unit |
| US-1.4.12 | `test/data/auth/auth_service_test.dart` | should replace old account in SharedPreferences on new sign-in | Unit |
| US-1.4.12 | `test/data/auth/auth_service_test.dart` | should emit signedIn(newAccount) with new credentials | Unit |
| US-1.4.12 | `test/data/auth/auth_service_test.dart` | should treat new account Drive as source on next sync | Unit |
| US-1.4.13 | `test/data/auth/auth_service_test.dart` | should catch SocketException and stay signedOut | Unit |
| US-1.4.13 | `test/data/auth/auth_service_test.dart` | should show "Sign-in failed. Check your connection" message | Unit |
| US-1.4.14 | `test/data/auth/auth_service_test.dart` | should treat null account as sign-in failure | Unit |
| US-1.4.14 | `test/data/auth/auth_service_test.dart` | should stay signedOut and log error | Unit |
| US-1.4.15 | `test/data/auth/auth_service_test.dart` | should have no stored account in SharedPreferences | Unit |
| US-1.4.15 | `test/data/auth/auth_service_test.dart` | should emit signedOut on first launch | Unit |
| US-1.4.15 | `test/data/auth/auth_service_test.dart` | should show Setup Wizard Step 1 | Unit |
| US-1.4.16 | `test/data/auth/auth_service_test.dart` | should render "Sign in with Google" button ≥ 48dp tall | Unit |
| US-1.4.16 | `test/data/auth/auth_service_test.dart` | should have semanticsLabel "Sign in with Google" | Unit |
| US-1.4.16 | `test/data/auth/auth_service_test.dart` | should render "Skip for now" link ≥ 48dp tall | Unit |
| US-1.4.16 | `test/data/auth/auth_service_test.dart` | should have semanticsLabel "Skip sign-in and use offline mode" | Unit |
| US-1.4.17 | `test/data/auth/auth_service_test.dart` | should announce "Signed in as [name]. Sync enabled." on sign-in | Unit |
| US-1.4.17 | `test/data/auth/auth_state_provider_test.dart` | should provide semantic labels for auth state transitions | Unit |

### Cross-Workstream Integration (Phase 1 Gate)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1.5.1 | `integration_test/phase1_e2e_test.dart` | should create book, log change event, and trigger sync push | Integration |
| US-1.5.1 | `integration_test/phase1_e2e_test.dart` | should produce correct change log entry for book creation | Integration |
| US-1.5.1 | `integration_test/phase1_e2e_test.dart` | should include deviceUser in change log event | Integration |
| US-1.5.2 | `integration_test/phase1_e2e_test.dart` | should run duplicate detection before insert | Integration |
| US-1.5.2 | `integration_test/phase1_e2e_test.dart` | should warn on exact ISBN duplicate before save | Integration |
| US-1.5.2 | `integration_test/phase1_e2e_test.dart` | should proceed with save when no duplicate detected | Integration |
| US-1.5.3 | `integration_test/phase1_e2e_test.dart` | should seed 2000 books, 50 locations, 20 genres, 100 tags without timeout | Integration |
| US-1.5.3 | `integration_test/phase1_e2e_test.dart` | should paginate to offset 1950 and return final 50 books | Integration |
| US-1.5.3 | `integration_test/phase1_e2e_test.dart` | should search FTS5 in < 300ms with 2000 books | Integration |
| US-1.5.3 | `integration_test/phase1_e2e_test.dart` | should sort by author in < 300ms with 2000 books | Integration |
| US-1.5.4 | `integration_test/phase1_e2e_test.dart` | should achieve ≥ 85% repository coverage | Integration |
| US-1.5.4 | `integration_test/phase1_e2e_test.dart` | should achieve ≥ 90% sync engine business logic coverage | Integration |
| US-1.5.4 | `integration_test/phase1_e2e_test.dart` | should have zero analyzer warnings | Integration |

### Supporting DAOs (no story ID — infrastructure)

| Test File | Test Name | Type |
|-----------|-----------|------|
| `test/data/database/dao/tag_dao_test.dart` | should create a new tag with UUID | Unit |
| `test/data/database/dao/tag_dao_test.dart` | should list all tags | Unit |
| `test/data/database/dao/tag_dao_test.dart` | should delete a tag by id | Unit |
| `test/data/database/dao/tag_dao_test.dart` | should rename a tag | Unit |
| `test/data/database/dao/tag_dao_test.dart` | should enforce unique tag name | Unit |
| `test/data/database/dao/tag_dao_test.dart` | should cascade remove BookTag join rows when tag deleted | Unit |
| `test/data/database/dao/author_dao_test.dart` | should create an author with rawName and normalizedName | Unit |
| `test/data/database/dao/author_dao_test.dart` | should list all authors | Unit |
| `test/data/database/dao/author_dao_test.dart` | should enforce unique normalizedName (NOCASE) | Unit |
| `test/data/database/dao/author_dao_test.dart` | should normalize author name for storage | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should append a change log event with all fields | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should query events since a given timestamp sorted desc | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should query events for a specific entity type and id | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should support pagination on querySince (limit + offset) | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should return empty list when no events since timestamp | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should record deviceUser on every event | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should record correct entityType for each operation | Unit |
| `test/data/database/dao/change_log_dao_test.dart` | should record correct eventType (create/update/delete) for each operation | Unit |
| `test/data/database/dao/genre_dao_test.dart` | should create a new custom genre with isCustom=true | Unit |
| `test/data/database/dao/genre_dao_test.dart` | should list all genres (built-in + custom) | Unit |
| `test/data/database/dao/genre_dao_test.dart` | should rename an existing genre | Unit |
| `test/data/database/dao/genre_dao_test.dart` | should enforce unique genre name (NOCASE) | Unit |
| `test/data/database/dao/language_dao_test.dart` | should create a new custom language with isBuiltin=false | Unit |
| `test/data/database/dao/language_dao_test.dart` | should list all languages (built-in + custom) | Unit |
| `test/data/database/dao/language_dao_test.dart` | should enforce unique language name (NOCASE) | Unit |
| `test/data/sync/google_drive_client_test.dart` | should find or create "/The Little Library/" folder on Drive | Unit |
| `test/data/sync/google_drive_client_test.dart` | should return folder ID for existing "The Little Library" folder | Unit |
| `test/data/sync/google_drive_client_test.dart` | should create folder when it does not exist (first-device setup) | Unit |
| `test/data/sync/google_drive_client_test.dart` | should upload catalog.db to Drive folder | Unit |
| `test/data/sync/google_drive_client_test.dart` | should upload change_log.db to Drive folder | Unit |
| `test/data/sync/google_drive_client_test.dart` | should upload cover images to covers/ subfolder | Unit |
| `test/data/sync/google_drive_client_test.dart` | should download a file from Drive | Unit |
| `test/data/sync/google_drive_client_test.dart` | should read version.txt to get current version | Unit |
| `test/data/sync/google_drive_client_test.dart` | should overwrite version.txt with new version | Unit |
| `test/data/sync/google_drive_client_test.dart` | should set file permissions for sharing | Unit |
| `test/data/sync/google_drive_client_test.dart` | should handle 404 when folder not found | Unit |
| `test/data/sync/google_drive_client_test.dart` | should handle storage quota exceeded error | Unit |
| `test/data/sync/google_drive_client_test.dart` | should handle 401 unauthorized (expired token) | Unit |
| `test/data/sync/google_drive_client_test.dart` | should handle network timeout during upload/download | Unit |
| `test/data/auth/auth_state_provider_test.dart` | should persist auth state across app restarts | Unit |
| `test/data/auth/auth_state_provider_test.dart` | should restore signedIn on relaunch without re-auth | Unit |
| `test/data/auth/auth_state_provider_test.dart` | should clear persisted state on sign-out | Unit |

---

## Uncovered Stories

**None.** Every user story from `specs/phase-1/stories.md` (US-1.1.1 through US-1.5.4) maps to at least one test case.

---

## Test Execution

### Expected Result

**All tests: FAIL** (expected — no implementation exists yet).

All test files use `fail('TODO(implementer): ...')` as placeholders. This means:
- Tests compile and run
- Every test immediately fails with a descriptive message
- No false positives / accidentally passing tests
- Implementer replaces each `fail()` with actual test logic

### Test File Inventory

| # | Test File | Stories Covered | Type |
|---|-----------|-----------------|------|
| 1 | `test/data/database/dao/book_dao_test.dart` | 1.1.1–1.1.10, 1.1.19–1.1.27, 1.1.29 | Unit |
| 2 | `test/data/database/dao/location_dao_test.dart` | 1.1.11–1.1.12, 1.1.28 | Unit |
| 3 | `test/data/database/dao/genre_dao_test.dart` | 1.1.13–1.1.14 | Unit |
| 4 | `test/data/database/dao/language_dao_test.dart` | 1.1.13–1.1.14 | Unit |
| 5 | `test/data/database/dao/tag_dao_test.dart` | (tag CRUD) | Unit |
| 6 | `test/data/database/dao/author_dao_test.dart` | 1.1.20 | Unit |
| 7 | `test/data/database/dao/change_log_dao_test.dart` | (change log CRUD) | Unit |
| 8 | `test/data/database/duplicate_detector_test.dart` | 1.1.15–1.1.18 | Unit |
| 9 | `test/data/database/isbn_utils_test.dart` | 1.1.17 | Unit |
| 10 | `test/data/api/google_books_client_test.dart` | 1.2.1–1.2.17 | Unit |
| 11 | `test/data/sync/google_drive_client_test.dart` | (Drive ops) | Unit |
| 12 | `test/data/sync/sync_engine_test.dart` | 1.3.1–1.3.25 | Unit |
| 13 | `test/data/sync/sync_state_provider_test.dart` | 1.3.8–1.3.9, 1.3.24 | Unit |
| 14 | `test/data/auth/auth_service_test.dart` | 1.4.1–1.4.17 | Unit |
| 15 | `test/data/auth/auth_state_provider_test.dart` | 1.4.5, 1.4.17 | Unit |
| 16 | `integration_test/phase1_e2e_test.dart` | 1.5.1–1.5.4 | Integration |

---

## Instructions for Implementer

1. Read `specs/phase-1/stories.md` for acceptance criteria.
2. Read `specs/phase-1/tests-report.md` (this file) for test map.
3. Create implementation files referenced by these tests:
   - `lib/data/database/dao/book_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/location_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/genre_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/language_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/tag_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/author_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/dao/change_log_dao.dart` (`@DriftAccessor`)
   - `lib/data/database/duplicate_detector.dart`
   - `lib/core/isbn_utils.dart`
   - `lib/data/api/google_books_client.dart`
   - `lib/data/api/book_enrichment.dart`
   - `lib/data/api/google_books_cache.dart`
   - `lib/data/sync/google_drive_client.dart`
   - `lib/data/sync/sync_engine.dart`
   - `lib/data/sync/sync_state_provider.dart`
   - `lib/data/auth/auth_service.dart`
   - `lib/data/auth/auth_state_provider.dart`
4. Replace each `fail('TODO(implementer): ...')` with actual test assertions.
5. Run `flutter test` — all tests should eventually pass.
6. Run `flutter test --coverage` — verify ≥ 85% repo coverage, ≥ 90% sync engine coverage.
7. Run `dart analyze` — verify zero warnings.
8. Run `flutter test integration_test/` — verify integration tests pass.
