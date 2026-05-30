# User Stories — Phase 1: Data & Sync Engine

> **Source:** `specs/plan.md` (Phase 1), `docs/spec-v2.md` (Architecture, Data Model, Sync Architecture), mockups (`setup-wizard.html`, `settings.html`, `add-book.html`, `conflict-resolver.html`)
> **Pipeline references:** FULL TDD (1.1, 1.3), LIGHT TDD (1.2, 1.4)

---

# Workstream 1.1 — Database DAOs & Full CRUD

## Happy Path

### US-1.1.1: Create a book with all related entities in a single transaction
**As a** library owner  
**I want to** insert a book together with its authors, genres, tags, and shelf location in one atomic operation  
**So that** the catalog stays consistent and I never see a book without its authors  

**Given** an in-memory drift database seeded with languages, genres, and a location hierarchy  
**When** I call `BookDao.insertBookWithRelations(Book, List<Author>, List<Genre>, List<Tag>, Shelf?)`  
**Then** a single drift transaction inserts the `Book`, all `BookAuthor`/`BookGenre`/`BookTag` join rows, the `BookShelf` row (or sets `shelf_id` to null for "None"), and the `ChangeLogEvent` record; rollback on any exception.

### US-1.1.2: Read a book with all joined data
**As a** library owner  
**I want to** fetch a single book with its authors, genres, tags, language, and physical location  
**So that** I can view every detail on the Book Detail screen (F6)  

**Given** a book exists with 2 authors, 1 genre, 2 tags, and a shelf assigned  
**When** I call `BookDao.getBookWithDetails(bookId)`  
**Then** the query returns the book with all related entities eagerly loaded (no N+1), including the full location path (Room → Cupboard → Shelf).

### US-1.1.3: Update a book and its relationships
**As a** library owner  
**I want to** change a book’s title, swap an author, add a genre, remove a tag, and move it to a different shelf  
**So that** the catalog always reflects the current state of my physical library  

**Given** an existing book with authors/genres/tags/location  
**When** I call `BookDao.updateBookWithRelations(...)` with a new title, a replaced author list, an added genre, and a new shelf  
**Then** drift replaces the join-table rows to match the new lists, updates the `BookShelf` row, updates `Book.updated_at`, and writes a `ChangeLogEvent` for every changed field (title, author list delta, genre list delta, shelf_id) inside the same transaction.

### US-1.1.4: Soft-delete a book
**As a** library owner  
**I want to** delete a book without permanently destroying its record  
**So that** I can restore it later if needed  

**Given** a non-deleted book with an active loan  
**When** I call `BookDao.softDeleteBook(bookId)`  
**Then** `Book.is_deleted` becomes `true`, `updated_at` is refreshed, a `delete` change-log event is written, but the `BookLoan` records remain intact (per spec §Edge Cases).

### US-1.1.5: Restore a soft-deleted book
**As a** library owner  
**I want to** restore a deleted book to its exact previous state  
**So that** I do not lose location, status, or loan history  

**Given** a soft-deleted book whose previous `status` was `loaned` and whose `shelf_id` was non-null  
**When** I call `BookDao.restoreBook(bookId)`  
**Then** `is_deleted` becomes `false`, `status` remains `loaned`, `shelf_id` is unchanged, and an `update` change-log event is written.

### US-1.1.6: Paginated catalog list with default sort
**As a** library owner  
**I want to** browse the catalog page-by-page, newest first  
**So that** scrolling stays smooth with 2000+ books  

**Given** the database contains 2000 books  
**When** I call `BookDao.listBooksPaginated(limit: 50, offset: 0, sort: recentlyAdded)`  
**Then** the query returns 50 books ordered by `created_at DESC`, and `offset: 50` returns the next 50.

### US-1.1.7: FTS5 search on title, ISBN, and publisher
**As a** library owner  
**I want to** search for books by typing a keyword  
**So that** results appear in <300 ms even with a large library  

**Given** the FTS5 virtual table is populated with book data  
**When** I call `BookDao.searchBooksByFts(query: "alchemist")`  
**Then** the query returns books where the FTS5 `title`, `isbn`, or `publisher` columns match, ranked by FTS5 relevance.

### US-1.1.8: Trigram fallback search on author names
**As a** library owner  
**I want to** search by author when I only remember part of the name  
**So that** I still find the book even if the title is fuzzy  

**Given** an author named "Paulo Coelho" exists  
**When** I call `BookDao.searchBooksByAuthor(query: "paul")`  
**Then** the query uses a `LIKE '%paul%'` join against the `Author` table (trigram-style) and returns all books linked to matching authors.

### US-1.1.9: Filter catalog by genre, language, status, format, condition, tags, and location cascade
**As a** library owner  
**I want to** narrow the catalog with multiple filter criteria  
**So that** I quickly find the subset I need  

**Given** books with varying genres, languages, statuses, formats, conditions, tags, and locations  
**When** I call `BookDao.listBooksPaginated(...)` with filters `{genre: [Fiction], language: English, status: Available, format: Hardcover, condition: New, tags: [unread], location: roomId, showDeleted: false}`  
**Then** the query returns only books matching every active filter, and the location cascade matches the specified Room and all its child Cupboards/Shelves.

### US-1.1.10: Sort by title, author, recently added, and purchase date
**As a** library owner  
**I want to** choose how the catalog is ordered  
**So that** I can browse alphabetically or by recency  

**Given** books with titles, authors, creation dates, and purchase dates  
**When** I call `BookDao.listBooksPaginated(..., sort: title|author|recentlyAdded|purchaseDate)`  
**Then**:
- `title`: A–Z by `title COLLATE NOCASE`
- `author`: one duplicate row per distinct author for multi-author books (per spec §F5)
- `recentlyAdded`: `created_at DESC`
- `purchaseDate`: `purchase_date DESC` (nulls last)

### US-1.1.11: Location hierarchy CRUD — create Room, Cupboard, Shelf
**As a** library owner  
**I want to** model my physical space as Room → Cupboard → Shelf  
**So that** I can assign books to precise locations  

**Given** a clean database with no locations  
**When** I call `LocationDao.createRoom(...)`, then `LocationDao.createCupboard(..., roomId)`, then `LocationDao.createShelf(..., cupboardId)`  
**Then** each entity is inserted with a UUID, FK constraints are enforced, and cascading queries return the full tree.

### US-1.1.12: Delete a Room/Cupboard and cascade books to "None"
**As a** library owner  
**I want to** remove a cupboard when I discard old furniture  
**So that** books formerly on that cupboard are not accidentally deleted  

**Given** a Cupboard with 3 Shelves and 12 books assigned  
**When** I call `LocationDao.deleteCupboard(cupboardId)`  
**Then** the Cupboard and its Shelves are removed, all affected `BookShelf.shelf_id` values are set to null (books show "None" location), and `updated_at` + change-log events are written for every affected book.

### US-1.1.13: Seed built-in genres and languages on first open
**As a** new user  
**I want to** see 20 predefined genres and 3 built-in languages immediately  
**So that** I do not have to create common values from scratch  

**Given** a freshly opened in-memory database  
**When** the repository layer initializes  
**Then** `Genre` table contains 20 rows with `is_custom = false`, and `Language` table contains English, Hindi, Sanskrit with `is_builtin = true`.

### US-1.1.14: Built-in genre/language protection
**As a** library owner  
**I want to** prevent accidental deletion of built-in reference data  
**So that** the app remains stable  

**Given** a built-in genre "Fiction" (`is_custom = false`)  
**When** I attempt `GenreDao.deleteGenre(genreId)`  
**Then** the DAO throws `BuiltInEntityException` and no row is deleted.

### US-1.1.15: Duplicate detection — ISBN exact match
**As a** library owner  
**I want to** be warned when I am about to add a book whose ISBN already exists  
**So that** I do not buy duplicates  

**Given** a book with ISBN-13 `9780062315007` already in the catalog  
**When** `DuplicateDetector.check(book)` is called with the same normalized ISBN  
**Then** the method returns `DuplicateResult.exactMatch(bookId)`.

### US-1.1.16: Duplicate detection — fuzzy title + author
**As a** library owner  
**I want to** catch near-duplicate entries even when the ISBN is missing  
**So that** two editions of the same book do not slip through  

**Given** a catalog containing "The Alchemist" by "Paulo Coelho"  
**When** `DuplicateDetector.check(book)` is called with title "The Alchemist" and author "Paulo Coelho" (normalized)  
**Then** the Levenshtein distance ratio between both title and at least one author is ≥ 80%, and `DuplicateResult.fuzzyMatch(bookId)` is returned.

## Edge Cases

### US-1.1.17: ISBN-10 to ISBN-13 conversion on save
**Given** a user enters an ISBN-10 `0062315005`  
**When** the book is saved  
**Then** the stored ISBN is `9780062315007` (standard conversion), and duplicate detection normalizes against the 13-digit form.

### US-1.1.18: Book with no ISBN
**Given** a book where `isbn` is null (e.g., an old regional book)  
**When** duplicate detection runs  
**Then** the ISBN exact-match step is skipped, and only the fuzzy title+author check is performed.

### US-1.1.19: Multi-author sort produces duplicate rows
**Given** a book with authors "Neil Gaiman" and "Terry Pratchett"  
**When** the catalog is sorted by author  
**Then** the book appears twice in the result set—once under Gaiman and once under Pratchett. In all other sort modes it appears once.

### US-1.1.20: Deleting an author that is still referenced
**Given** an author linked to one or more books  
**When** `AuthorDao.deleteAuthor(authorId)` is called  
**Then** the DAO rejects the deletion with `ReferencedEntityException` (FK constraint), preserving referential integrity.

### US-1.1.21: Empty tag or genre list
**Given** a book with zero tags and zero genres  
**When** `getBookWithDetails(bookId)` is called  
**Then** the returned model contains empty lists, not nulls, and the query does not crash on the missing joins.

### US-1.1.22: Max-length title and description
**Given** a title of 1000 characters and a description of 5000 characters  
**When** the book is inserted  
**Then** drift stores the full text (SQLite text is unbounded), pagination still works, and FTS5 still indexes correctly.

### US-1.1.23: Concurrent writes on the same book
**Given** two drift transactions attempt to update the same book simultaneously  
**When** both execute  
**Then** SQLite serializes them; one completes first, the second retries and succeeds, and the change log contains both events.

## Error States

### US-1.1.24: Transaction rollback on mid-operation failure
**Given** a multi-table insert where the third join-table insert would violate a FK  
**When** `insertBookWithRelations` is called  
**Then** the entire transaction is rolled back, no partial data remains, and a `DriftWrappedException` is propagated with a clear message.

### US-1.1.25: Invalid UUID format in query
**Given** a malformed UUID string is passed to a DAO method  
**When** the query is prepared  
**Then** drift returns zero rows (no crash), and the repository layer logs a warning.

## Empty States

### US-1.1.26: Query catalog with zero books
**Given** a fresh database with no books  
**When** `listBooksPaginated(...)` is called  
**Then** the query returns an empty list (not null), count is 0, and the UI (Phase 2) will show the first-launch empty state per mockup `catalog.html`.

### US-1.1.27: Search with no matches
**Given** the database contains 50 books  
**When** `searchBooksByFts("xyznonexistent")` is called  
**Then** the result list is empty, ranked relevance is empty, and the UI will show the "No books match" empty state.

### US-1.1.28: No locations defined
**Given** no Room/Cupboard/Shelf rows exist  
**When** `LocationDao.listAllLocations()` is called  
**Then** an empty tree list is returned, and any book location defaults to "None" (null `shelf_id`).

## Accessibility

### US-1.1.29: Tappable targets ≥ 48 dp on DAO-related UI scaffolding
**Given** the Phase 0 placeholder catalog screen exists  
**When** the catalog is rendered (tested via widget test in Phase 2)  
**Then** all touch targets (FAB, filter chips, book cards) are ≥ 48×48 dp. DAO queries themselves have no UI, but the repository contracts they back must support data needed for semantic labels.

---

# Workstream 1.2 — Google Books API Client

## Happy Path

### US-1.2.1: Enrich a book by ISBN
**As a** library owner  
**I want to** look up a book by its ISBN and receive structured metadata  
**So that** I can auto-fill the Add Book form (F2)  

**Given** the device has internet and the API quota is available  
**When** `GoogleBooksClient.searchByIsbn("9780062315007")` is called  
**Then** an HTTP GET is issued to Google Books API with `q=isbn:9780062315007`, and a `List<BookEnrichment>` is returned containing title, authors, publisher, description, pageCount, and coverUrl. The first item is the strongest match.

### US-1.2.2: Enrich a book by title and author
**As a** library owner  
**I want to** search by title (and optionally author) when no ISBN is available  
**So that** I still get online metadata  

**Given** the device has internet  
**When** `GoogleBooksClient.searchByTitleAuthor("The Alchemist", "Paulo Coelho")` is called  
**Then** the query string `intitle:The Alchemist inauthor:Paulo Coelho` is sent, and a ranked list of up to 5 `BookEnrichment` results is returned.

### US-1.2.3: Multi-result display support
**As a** library owner  
**I want to** choose from multiple matches when the search is ambiguous  
**So that** I select the correct edition  

**Given** a title+author search returns 3 results  
**When** the client parses the response  
**Then** the list preserves the API order (best match first), each item has a non-null `title` and `authors` list, and the Add Book enrichment overlay (mockup `add-book.html`) can render a horizontal scrollable card for each.

### US-1.2.4: Local SQLite cache hit bypasses network
**As a** library owner  
**I want to** repeat lookups instantly without consuming quota  
**So that** I stay within the daily limit  

**Given** a previous `searchByIsbn("9780062315007")` was cached within 7 days  
**When** the same search is called again  
**Then** no HTTP request is made; the result is deserialized from the `google_books_cache` table and returned in < 50 ms.

### US-1.2.5: Cache keyed by title+author hash
**As a** library owner  
**I want to** cache lookups by content, not just ISBN  
**So that** enrichment works for books without ISBNs  

**Given** a previous `searchByTitleAuthor("Sapiens", "Yuval Noah Harari")` was cached  
**When** the same call is made again  
**Then** the cache key (SHA-256 of normalized title+author) matches, and the cached result is returned immediately.

### US-1.2.6: Custom API key overrides default key
**As a** power user  
**I want to** use my own Google Books API key for higher quota  
**So that** I am not blocked by the shared app quota  

**Given** a custom key is stored in local settings  
**When** `GoogleBooksClient.searchByIsbn(...)` is called  
**Then** the custom key is appended as `&key=`; if the custom key returns 403/invalid-key, the client falls back to the default app key once.

### US-1.2.7: Quota tracking and daily request counting
**As a** library owner  
**I want to** know how many API requests I have left today  
**So that** I can plan enrichment usage  

**Given** 12 requests have been made today  
**When** the next successful request completes  
**Then** the daily counter increments to 13, and `isQuotaExceeded` stream emits `false`.

## Edge Cases

### US-1.2.8: 10-second timeout on lookup
**Given** the network is very slow  
**When** a lookup exceeds 10 seconds  
**Then** the HTTP request is cancelled, a `TimeoutException` is thrown, and the UI falls back to offline/manual entry (mockup `add-book.html` shows manual form).

### US-1.2.9: Cache expired after 7 days
**Given** a cached entry was written 8 days ago  
**When** `searchByIsbn(...)` hits the cache key  
**Then** the entry is treated as a miss, the stale row is deleted, and a fresh network request is issued.

### US-1.2.10: Empty API response (no books found)
**Given** the API returns HTTP 200 with `totalItems: 0`  
**When** the client parses the response  
**Then** an empty list is returned (not null), and the UI enrichment overlay shows "No results found" (mockup `add-book.html`).

### US-1.2.11: Null author in API response
**Given** the API returns an item with `volumeInfo.authors` missing  
**When** the DTO is parsed  
**Then** `BookEnrichment.authors` is an empty list, not null, and the rest of the fields populate normally.

### US-1.2.12: Partial cover URL
**Given** the API returns a thumbnail URL without the `zoom=1` suffix  
**When** the DTO is parsed  
**Then** `coverUrl` is stored exactly as provided; no URL rewriting occurs in the client.

## Error States

### US-1.2.13: 429 Too Many Requests triggers quota exceeded
**Given** the daily quota is exhausted  
**When** the API returns HTTP 429 or 403 with quota message  
**Then** `isQuotaExceeded` stream emits `true`, the daily counter stops incrementing, and subsequent calls short-circuit with `QuotaExceededException` without hitting the network.

### US-1.2.14: Network unreachable
**Given** the device has no internet  
**When** any lookup method is called  
**Then** the client detects offline state, skips the HTTP attempt, and throws `OfflineException`. The cache is still queried; if a prior cache entry exists, it is returned (stale-but-useful fallback).

### US-1.2.15: Corrupted JSON response
**Given** the API returns malformed JSON  
**When** parsing runs  
**Then** a `FormatException` is caught, an empty list is returned, and the error is logged without crashing.

## Empty States

### US-1.2.16: Cache table is empty
**Given** a fresh install with no cached lookups  
**When** the first enrichment is triggered  
**Then** every lookup is a cache miss, the network is used, and the first result populates the cache table.

## Accessibility

### US-1.2.17: Enrichment loading state announced to screen reader
**Given** the enrichment overlay is open (mockup `add-book.html`)  
**When** skeleton loaders are visible  
**Then** the overlay container has `semanticsLabel: "Searching Google Books, please wait"` so TalkBack announces the loading state.

---

# Workstream 1.3 — Sync Engine

## Happy Path

### US-1.3.1: Push local changes to Google Drive
**As a** signed-in user  
**I want to** upload my local catalog and change log to Google Drive after every save  
**So that** other family members receive my changes  

**Given** the user is signed in, internet is available, and `version.txt` on Drive reads `42` matching local last-known version  
**When** the sync engine triggers a push after a book edit  
**Then** `catalog.db` is uploaded, new events are appended to `change_log.db`, `version.txt` is overwritten with `43`, new cover images are uploaded to `covers/`, and `SyncState` emits `pushing` → `idle`.

### US-1.3.2: Pull remote changes on app launch
**As a** family member on a second device  
**I want to** download new changes when I open the app  
**So that** I see books added by others  

**Given** remote `change_log.db` contains 15 events with `timestamp > local_last_sync_timestamp`  
**When** the app launches and the sync engine starts a pull  
**Then** only those 15 events are downloaded (not the entire file), replayed locally, new cover images are fetched, and `local_last_sync_timestamp` is updated to the newest event timestamp.

### US-1.3.3: Merge non-conflicting remote updates automatically
**As a** family member  
**I want to** see remote edits applied silently when they do not clash with my local edits  
**So that** I am not interrupted by trivial merges  

**Given** remote event: book A title changed to "New Title"; local book A has no uncommitted title change  
**When** the merge logic replays the remote event  
**Then** the local DB title is updated to "New Title" without user interaction, and no conflict is queued.

### US-1.3.4: Detect and queue same-field conflicts
**As a** family member  
**I want to** be notified when two devices edited the same field of the same book  
**So that** I can choose the correct value  

**Given** remote event: book B title changed to "Mom's Version"; local change log already has an un-synced title update for book B to "My Version"  
**When** merge replay reaches book B title  
**Then** the conflict is queued, `SyncState` emits `error` with conflict count, and the Conflict Resolver screen (mockup `conflict-resolver.html`) receives the queued item.

### US-1.3.5: Optimistic locking prevents concurrent overwrites
**As a** family member  
**I want to** avoid overwriting another device’s push  
**So that** no data is lost  

**Given** local last-known version is `42`, but remote `version.txt` now reads `43` (another device pushed)  
**When** the local device attempts a push  
**Then** the push is aborted, a pull is triggered first, merge runs, and the push retries with the updated version.

### US-1.3.6: Snapshot creation every 1000 events
**As a** user with a large library  
**I want to** compact the change log periodically  
**So that** future merges stay fast  

**Given** the local change log has reached exactly 1000 events  
**When** the next write operation completes  
**Then** the sync engine serializes a compact state snapshot (not a full DB dump) and resets the event counter, so the next pull replays from the snapshot point.

### US-1.3.7: Merge duplicate guard during replayed create events
**As a** family member joining late  
**I want to** be warned if a remote create event matches a soft-deleted local book  
**So that** I can restore the old record instead of creating a duplicate  

**Given** a soft-deleted local book has ISBN `9780062315007`; a remote `create` event arrives for the same ISBN  
**When** the merge replay runs  
**Then** duplicate detection fires, the engine surfaces a warning (restore vs. add-as-new), and the standard sync merge flow handles the choice.

### US-1.3.8: Sync status provider exposes state machine
**As a** user  
**I want to** see a color-coded sync indicator at all times  
**So that** I know whether my changes are safe  

**Given** the sync engine is running  
**When** I watch `syncStateProvider`  
**Then** it emits one of:
- `idle` — green bar, "Synced just now"
- `pulling` — amber bar, "Downloading changes…"
- `pushing` — amber bar, "Uploading changes…"
- `offline` — amber bar, "Offline — N changes pending"
- `error` — red bar, specific message (Drive full, auth expired, etc.)

### US-1.3.9: Large merge progress (100+ books)
**As a** new family member setting up the app  
**I want to** see progress during a big initial sync  
**So that** I know the app has not frozen  

**Given** the initial pull contains 847 books (per mockup `setup-wizard.html`)  
**When** the merge runs  
**Then** `SyncState` includes a progress fraction (`0.0` → `1.0`) and stage messages ("Downloading catalog…", "Organizing shelves…", "Fetching covers…").

## Edge Cases

### US-1.3.10: No new remote events since last sync
**Given** remote `change_log.db` has no events newer than `local_last_sync_timestamp`  
**When** a pull is triggered  
**Then** nothing is downloaded, nothing is replayed, `SyncState` briefly emits `pulling` then `idle`, and `last_sync_timestamp` is unchanged.

### US-1.3.11: Push with zero pending local changes
**Given** no writes have occurred since the last successful push  
**When** a push is triggered (e.g., after every save)  
**Then** the engine skips the upload, does not increment version, and emits `idle` immediately.

### US-1.3.12: Replayed remote delete on a locally modified book
**Given** a remote `delete` event arrives for book C, but the local user edited book C’s notes after the remote delete timestamp  
**When** merge replay runs  
**Then** the conflict resolver queues a "delete vs. update" conflict, and the book remains visible until the user resolves it.

### US-1.3.13: Snapshot already exists at exact 1000 boundary
**Given** a snapshot was created at event 1000  
**When** the next pull replays events 1001–1015  
**Then** only 15 events are replayed, the snapshot is reused, and no new snapshot is created until event 2000.

## Error States

### US-1.3.14: No internet during sync
**Given** the device is offline  
**When** any sync trigger fires  
**Then** `SyncState` emits `offline` with pending change count, no Drive API calls are attempted, and the engine retries on the next foreground event or manual "Sync Now" tap (mockup `settings.html`).

### US-1.3.15: Google Drive storage full
**Given** the user’s Drive quota is exhausted  
**When** a push attempts to upload `catalog.db`  
**Then** Drive returns a storage-full error, `SyncState` emits `error` with message "Drive storage full — free up space" and a link to drive.google.com, and changes remain queued locally.

### US-1.3.16: Network timeout during pull
**Given** the network is flaky  
**When** downloading `change_log.db` exceeds the timeout  
**Then** the engine retries up to 3 times with exponential backoff; after the third failure, `SyncState` emits `error` with "Sync timed out — retrying" and the engine schedules the next retry on the next app foreground.

### US-1.3.17: Corrupted remote catalog.db
**Given** the downloaded `catalog.db` fails SQLite integrity check  
**When** the engine detects corruption  
**Then** `SyncState` emits `error` with "Remote catalog appears corrupted. Restore from local backup?" and offers a recovery flow to push the local DB as the new canonical state.

### US-1.3.18: Auth token expired mid-sync
**Given** the Google Sign-In token expires while a push is in progress  
**When** the Drive API returns 401  
**Then** the engine attempts silent token refresh once; if that fails, `SyncState` emits `error` with "Sign-in expired — tap to re-authenticate" (mockup `settings.html`), and the push is queued.

### US-1.3.19: Shared Drive folder deleted by another user
**Given** the `/The Little Library/` folder is missing from Drive (404)  
**When** a pull or push runs  
**Then** `SyncState` emits `error` with "Library folder not found on Drive. Recreate from this device?" If the user confirms, the folder is recreated, `catalog.db` and `change_log.db` are seeded from local state, version resets to 1, and other devices will pull this restored copy on next sync.

### US-1.3.20: Schema version mismatch — remote newer
**Given** remote `app_schema_version` is `3` and local is `2`  
**When** a pull runs  
**Then** sync is aborted, a force-update screen is shown (mockup `force-update.html`), and the user cannot proceed until the app is updated.

### US-1.3.21: Schema version mismatch — local newer
**Given** local `app_schema_version` is `3` and remote is `2`  
**When** a push runs  
**Then** the push proceeds normally, updating remote `app_schema_version` to `3`. Older devices will be forced to update on their next pull.

## Empty States

### US-1.3.22: First-device setup — no remote files exist
**Given** the user creates a new library (mockup `setup-wizard.html` Step 2)  
**When** the sync engine looks for `/The Little Library/`  
**Then** the folder and all files are created from scratch with local data, `version.txt` starts at `1`, and `SyncState` shows "Library created on Drive".

### US-1.3.23: No conflicts to resolve
**Given** the conflict queue is empty  
**When** the user navigates to Resolve Conflicts (mockup `settings.html`)  
**Then** the Conflict Resolver screen shows the "All conflicts resolved" completion state with checkmark + summary.

## Accessibility

### US-1.3.24: Sync status bar color + text for color-blind users
**Given** the sync status bar is visible (mockup `catalog.html`)  
**When** `SyncState` is `error`  
**Then** the bar is red AND contains explicit text (e.g., "Drive storage full") so color-blind users understand the state without relying on color alone.

### US-1.3.25: Conflict resolver screen reader support
**Given** a queued conflict is displayed (mockup `conflict-resolver.html`)  
**When** TalkBack focuses the version card  
**Then** it reads: "Mom changed Title to The Alchemist, 25th Anniversary Edition, two hours ago. Double-tap to select this version." The editable field announces "Edit the resolved value."

---

# Workstream 1.4 — Google Sign-In & Auth

## Happy Path

### US-1.4.1: Sign in with Google
**As a** new user  
**I want to** authenticate with my Google account  
**So that** my library can sync via Google Drive  

**Given** the device has Google Play Services and internet  
**When** I tap "Sign in with Google" on the Setup Wizard (mockup `setup-wizard.html` Step 1)  
**Then** `google_sign_in` initiates the OAuth flow, the account object is returned, and `AuthState` emits `signedIn(account)`.

### US-1.4.2: Automatic sign-in on app restart
**As a** returning user  
**I want to** stay signed in across app sessions  
**So that** I do not re-enter credentials every time  

**Given** I previously signed in successfully  
**When** the app launches  
**Then** `AuthService` reads the stored account from `SharedPreferences`, attempts silent sign-in, and `AuthState` emits `signedIn(account)` without showing the wizard.

### US-1.4.3: Sign out keeps local data
**As a** user  
**I want to** disconnect my Google account without losing my catalog  
**So that** I can switch accounts or go offline-only safely  

**Given** I am signed in with 500 local books  
**When** I tap "Sign Out" in Settings (mockup `settings.html` Account section)  
**Then** `google_sign_in.signOut()` is called, `SharedPreferences` auth state is cleared, `AuthState` emits `signedOut`, and the local SQLite database is untouched.

### US-1.4.4: Silent token refresh before Drive API calls
**As a** signed-in user  
**I want to** have my token refreshed automatically when it nears expiry  
**So that** sync never fails silently due to an expired token  

**Given** the access token is 5 minutes from expiry  
**When** the sync engine prepares a Drive API call  
**Then** `AuthService` calls `google_sign_in.signInSilently()`, receives a fresh token, and the Drive call proceeds with the new credentials.

### US-1.4.5: Auth state Riverpod provider emits correct states
**As a** any screen/widget in the app  
**I want to** react to authentication changes via a central provider  
**So that** UI state stays consistent  

**Given** `authStateProvider` is watched by the Setup Wizard and Settings screens  
**When** the user signs in, signs out, or skips  
**Then** the provider emits:
- `AuthState.signedIn(account)` — display name and email available
- `AuthState.signedOut` — no account
- `AuthState.skipped` — user chose offline-only mode

### US-1.4.6: Display name retrieval for activity feed
**As a** family member  
**I want to** see who made each change in the activity feed  
**So that** I know which family member added or edited a book  

**Given** the signed-in Google account has `displayName` "Priya Sharma" and `email` "priya@gmail.com"  
**When** any write operation records a change log event  
**Then** `device_user` is set to `"priya@gmail.com"`, and the UI (Phase 5) renders "Priya" from `displayName` for the activity feed.

### US-1.4.7: Skip sign-in for offline mode
**As a** user without a Google account or with privacy concerns  
**I want to** use the app entirely offline  
**So that** I can still catalog my personal library  

**Given** the Setup Wizard is on Step 1 (mockup `setup-wizard.html`)  
**When** I tap "Skip for now"  
**Then** `AuthState` emits `skipped`, the app proceeds to the catalog, and a persistent banner (scaffolded in Phase 2) offers later sign-in from Settings. All local CRUD works normally; sync features are disabled.

### US-1.4.8: Delayed sign-in triggers merge flow
**As a** user who skipped sign-in initially  
**I want to** sign in later and merge my local data with the shared Drive catalog  
**So that** nothing is lost when I finally join the family library  

**Given** the user has 30 local books and later signs in from Settings  
**When** the sign-in succeeds  
**Then** the sync engine runs the standard merge flow: pull remote catalog, compare timestamps, apply non-conflicting remote events, queue conflicts, and push local changes. The Setup Wizard merge logic from mockup `setup-wizard.html` Step 3 is reused.

## Edge Cases

### US-1.4.9: Google Play Services not available
**Given** the device lacks Google Play Services (e.g., some custom ROMs)  
**When** sign-in is attempted  
**Then** `google_sign_in` returns a `PlatformException`, `AuthState` emits `signedOut`, and the UI shows an error: "Google Sign-In is not available on this device. Use offline mode."

### US-1.4.10: User cancels the OAuth consent screen
**Given** the Google sign-in web flow is open  
**When** the user presses back or cancels  
**Then** the account is null, `AuthState` stays `signedOut`, and the Setup Wizard remains on Step 1 with a non-blocking message "Sign-in cancelled."

### US-1.4.11: Silent sign-in fails on app launch
**Given** the stored token is invalid and silent refresh fails  
**When** the app launches  
**Then** `AuthState` emits `signedOut`, the catalog screen opens (since local data is independent), and the sync status bar shows "Sign in to sync" (amber). The user can re-initiate sign-in from Settings.

### US-1.4.12: Multiple account switching
**Given** the device has two Google accounts in the system picker  
**When** the user signs out and signs in with a different account  
**Then** the new account replaces the old in `SharedPreferences`, `AuthState` emits `signedIn(newAccount)`, and the next sync pull treats the new account’s Drive as the source (merge flow applies).

## Error States

### US-1.4.13: Network error during sign-in
**Given** the device has no internet during the OAuth handshake  
**When** sign-in is attempted  
**Then** a `SocketException` is caught, `AuthState` stays `signedOut`, and the Setup Wizard shows "Sign-in failed. Check your connection and try again." (per mockup `setup-wizard.html` error state).

### US-1.4.14: `google_sign_in` returns null account without exception
**Given** an internal Google Sign-In error (rare)  
**When** `signIn()` completes  
**Then** the result is treated as failure, `AuthState` stays `signedOut`, and the error is logged for diagnostics.

## Empty States

### US-1.4.15: No prior sign-in on first launch
**Given** a fresh install  
**When** the app launches  
**Then** `SharedPreferences` has no stored account, `AuthState` emits `signedOut`, and the Setup Wizard Step 1 is shown.

## Accessibility

### US-1.4.16: Sign-in button minimum touch target
**Given** the Setup Wizard Step 1 (mockup `setup-wizard.html`)  
**When** rendered  
**Then** the "Sign in with Google" button is ≥ 48 dp tall, has `semanticsLabel: "Sign in with Google"`, and the "Skip for now" link is ≥ 48 dp tall with `semanticsLabel: "Skip sign-in and use offline mode"`.

### US-1.4.17: Auth state changes announced
**Given** the user is using TalkBack  
**When** `AuthState` transitions to `signedIn` from the Settings screen  
**Then** a `SnackBar` with `semanticsLabel` announces "Signed in as Priya Sharma. Sync enabled."

---

# Cross-Workstream Integration Stories (Phase 1 Gate)

### US-1.5.1: End-to-end write → change log → push
**Given** the user is signed in, auth token is valid, and sync is idle  
**When** a book is created via `BookDao.insertBookWithRelations`  
**Then**:
1. The book appears in the local DB.
2. `ChangeLogDao` contains a `create` event for the book.
3. The sync engine detects pending changes, reads `version.txt`, pushes `catalog.db` + change log, increments version.
4. `syncStateProvider` emits `pushing` → `idle`.
5. A second device pulling sees the new event and replays it.

### US-1.5.2: Enrichment → save → duplicate check → sync
**Given** the user scans a barcode (Phase 3), gets an ISBN, and the Google Books client returns metadata  
**When** the Add Book form (mockup `add-book.html`) is pre-filled and the user taps Save  
**Then**:
1. `DuplicateDetector` runs ISBN exact + fuzzy title/author checks.
2. If no duplicate, the book is inserted via DAO with full transaction.
3. Change log records the create.
4. Sync engine pushes to Drive.
5. If a duplicate IS found, a warning dialog is shown before any insert (per mockup `add-book.html`).

### US-1.5.3: Large library performance gate
**Given** the in-memory database is seeded with 2000 books, 50 locations, 20 genres, and 100 tags  
**When** `listBooksPaginated(limit: 50)` + `searchBooksByFts("a")` + `sort: author` are executed sequentially  
**Then** each query completes in < 300 ms on a mid-range Android emulator, and pagination offset 1950 returns the final 50 books without crash.

### US-1.5.4: Full TDD coverage gate
**Given** all Phase 1 unit tests are run  
**When** `flutter test` executes  
**Then** coverage is ≥ 85% for repositories, ≥ 90% for sync engine business logic, and zero analyzer warnings exist.
