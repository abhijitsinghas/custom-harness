# The Little Library — App Specification v2

## Overview

A Flutter Android app for cataloging and tracking a home library (~10-12 cupboards/bookshelves). The primary goal is to prevent duplicate book purchases by maintaining a searchable, **auto-syncing** catalog shared across all household members via Google Drive.

Every family member can add, edit, and search books. Changes sync automatically. No one buys a duplicate again.

---

## Architecture

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Android primary, iOS-compatible) |
| State Management | Riverpod |
| Local Database | drift (SQLite) — type-safe, reactive, migrations |
| OCR | google_mlkit_text_recognition (Latin script; Devanagari in Phase 2) |
| Barcode | google_mlkit_barcode_scanning |
| Online Book Lookup | Google Books API |
| Voice / LLM | On-device (Gemini Nano / MediaPipe) → cloud LLM (Gemini API) → keyword extraction fallback |
| Google Drive Sync | googleapis + google_sign_in |
| Image Capture | image_picker (camera + gallery) |
| Speech-to-Text | Platform STT (Android SpeechRecognizer / iOS SFSpeechRecognizer) |
| UI Localization | English only (Phase 1), built with Flutter arb files for future i18n |

### Project Structure

```
lib/
├── core/              # Shared utilities, constants, theme, extensions, i18n
│   ├── theme.dart
│   ├── utils.dart
│   └── l10n/          # arb localization files (English, future languages)
├── data/              # Data layer
│   ├── database/      # drift tables, DAOs, database class
│   ├── api/           # Google Books API, Google Drive API, LLM API
│   ├── sync/          # Sync engine (change log, merge, conflict resolution)
│   └── repositories/  # BookRepository, LocationRepository, SyncRepository
├── features/
│   ├── setup/         # First-run wizard (F0)
│   ├── catalog/       # Browse, search, filter (F5)
│   ├── book_detail/   # View & edit a single book (F6)
│   ├── add_book/      # Manual entry wizard (F2)
│   ├── scanner/       # Barcode + single-book OCR (F3, F4)
│   ├── voice_input/   # Voice + LLM entry (F11)
│   ├── bulk_scan/     # Multi-book shelf scanning (Phase 2)
│   ├── locations/     # Room → Cupboard → Shelf CRUD (F1)
│   ├── genres/        # Genre management (F9)
│   ├── sync_ui/       # Sync status, conflict resolver, Drive sharing
│   └── settings/      # App preferences, auto-enrich toggle, Drive folder sharing
├── app.dart           # MaterialApp, router setup
└── main.dart          # Entry point, Riverpod ProviderScope
```

---

## Sync Architecture

The app uses a **Google Drive-backed, offline-first sync engine** with change-log-based conflict resolution.

### Principles

- **Offline-first:** All reads/writes go to local SQLite. Sync is a background process.
- **Everyone is a peer:** Any device can add, edit, or delete books.
- **No central authority:** Google Drive is the shared file store, not a database server.
- **Event-sourced:** Every change is recorded as an event in a change log.

### Sync File Layout on Google Drive

```
/The Little Library/
├── catalog.db          # Base state snapshot (used for initial sync & recovery)
├── change_log.db       # Append-only incremental event journal (day-to-day sync)
├── version.txt         # Monotonically increasing version number for optimistic locking
└── covers/             # Cover images named by book UUID
    ├── {uuid1}.jpg
    ├── {uuid2}.jpg
    └── ...
```

- `catalog.db` is the base state snapshot — downloaded only on first sync or recovery from corruption. Day-to-day sync uses `change_log.db`.
- `change_log.db` is the append-only incremental event journal. Only new events since last sync are downloaded and replayed.
- `version.txt` stores an integer version number for optimistic locking (prevents concurrent push overwrites).
- `covers/` contains cover images; only new/changed files are uploaded/downloaded.

### Sync Triggers

| Trigger | Direction | Behavior |
|---------|-----------|----------|
| App launch / foreground | Pull | Download latest events from `change_log.db` since last sync point. Replay events locally. Download any new cover images. |
| After every save (add/edit/delete) | Push | Check `version.txt` for optimistic locking. If version matches, upload updated `catalog.db`, append new events to `change_log.db`, increment version, upload new cover images. If version mismatch, pull first, merge, then retry push. |
| Pull-to-refresh on catalog | Pull | Same as app launch pull. |

### Change Log (Event Journal)

Every change to any shared entity is recorded as an event. A single unified table covers all entity types:

| Field | Type | Description |
|-------|------|-------------|
| `event_id` | UUID | Unique event identifier |
| `entity_type` | text | Type of entity: `book`, `location`, `genre`, `tag`, `author`, `loan`, `language` |
| `entity_id` | UUID | ID of the changed entity |
| `field_name` | text | Which field changed (e.g., "title", "name", "status", "returned_date"). For creates, set to `*`. |
| `old_value` | text | Previous value (nullable for creates) |
| `new_value` | text | New value (the full entity JSON for creates) |
| `timestamp` | ISO 8601 | When the change happened |
| `device_user` | text | Google account email of the person who made the change |
| `event_type` | text | `create`, `update`, `delete` (soft delete where applicable) |

**Snapshots:** To keep merge fast, the app creates a state snapshot after every 1000 events. Merges replay events only since the last snapshot.

### Merge Strategy (Pull)

1. Download latest events from remote `change_log.db` (only events with timestamp > local last_sync_timestamp).
2. For each new remote event, replay against local DB:
   - **Non-conflicting field:** Apply automatically.
   - **Same-field conflict:** Queue for manual resolution.
3. Show conflict resolver UI (see UX section) for queued conflicts.
4. After all conflicts resolved, update local DB and set last_sync_timestamp.
5. `catalog.db` is only downloaded on first sync (new device) or if local DB is corrupted and needs full recovery.

### Optimistic Locking (Push)

1. Before pushing, read `version.txt` from Drive.
2. If `remote_version == local_last_known_version`: safe to push. Upload new `catalog.db`, append events to `change_log.db`, write `version + 1` to `version.txt`.
3. If `remote_version != local_last_known_version`: another device pushed first. Pull new events, merge locally, then retry push with updated version.

### Conflict Resolution

When two devices edited the same field of the same book:

- **Detection:** Same `entity_type` + `entity_id` + `field_name` in both local and remote change logs, with different `new_value`.
- **UI:** Inline edit screen showing:
  - The conflicting field highlighted
  - Version A: "Mom changed Location to Study/Shelf 2 — 2 hours ago"
  - Version B: "You changed Location to Bedroom/Shelf 1 — 30 minutes ago"
  - An editable text field pre-filled with the local version
  - The remote version shown as a tappable chip to quickly adopt it
  - User can keep either version, combine them, or type a third value

### Deletion Model

- **Soft delete:** Deleted books get `is_deleted = true`. They are hidden from all UI (catalog, search, filters) by default.
- **View deleted:** A "Show Deleted" toggle in Settings reveals deleted books with a strikethrough or greyed-out appearance.
- **Restore:** Deleted books can be restored, which sets `is_deleted = false`. The book is restored to its exact previous state — same status, location, checked_out_to, and associated loan records remain intact. User can update as needed afterward.
- **Permanent:** Deleted books are never purged. The record stays forever.
- **Sync:** The delete event syncs as a soft-delete to all devices.

### Sync Version Compatibility

When the app is updated with schema changes, different devices may run different versions.

- `catalog.db` includes an `app_schema_version` field.
- On sync, the app compares the remote `app_schema_version` with its own.
- **If remote version is higher:** Force update. Show a blocking screen: "This library has been updated by another device. Please update The Little Library to continue." User cannot proceed until they update the app.
- **If local version is higher:** Push proceeds normally. Older devices will be forced to update on their next pull.
- This prevents data corruption from schema mismatches across app versions.

### Sync Error Handling

| Error | User Message | App Behavior |
|-------|-------------|--------------|
| No internet | Amber status bar: "Offline — 3 changes pending" | Queue changes, retry on next trigger |
| Drive storage full | Red status bar: "Drive storage full — free up space" with link to drive.google.com | Queue changes, retry on next trigger |
| Network timeout | Amber status bar: "Sync timed out — retrying" | Retry up to 3 times with exponential backoff; then show actionable message |
| Corrupted remote file | Red status bar: "Remote catalog appears corrupted. Restore from local backup?" | Offer to push local version as recovery |
| Auth expired | Red status bar: "Sign-in expired — tap to re-authenticate" | Show sign-in prompt |
| Drive folder deleted | Red status bar: "Library folder not found on Drive. Recreate from this device?" | If confirmed, recreate folder on Drive and push full local catalog. Other devices will pull from this restored copy on next sync. |

### API Quota Management

**Google Books API** has a free-tier daily quota (~1000 requests/day). To manage this:

1. **Local cache:** API responses are cached locally by ISBN and by title+author hash. Repeat lookups for the same book don't consume quota.
2. **Quota warning:** When the daily quota is exhausted, show a message: "Google Books daily limit reached. You can still add books manually. Enrichment will resume tomorrow." The "Enrich Online" button is disabled with this explanation.
3. **Custom API key:** Settings → Account → "Google Books API Key" allows power users to add their own API key for higher quotas. If a custom key is configured, it's used first; the default key is the fallback.

---

## Data Model

All primary keys and foreign keys use UUID v4 (text).

### Book (21 fields — 19 user-facing + 2 system)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | Primary key |
| 2 | `title` | text | ✓ | Full title including subtitle |
| 3 | `isbn` | text | | ISBN-13 (normalized from ISBN-10 on save). Nullable — some old/regional books lack ISBN |
| 4 | `language_id` | text (UUID) | ✓ | FK → Language. Default: English |
| 5 | `cover_image_path` | text | | Local file path to cover image |
| 6 | `cover_image_url` | text | | Remote URL if fetched online |
| 7 | `publisher` | text | | Publisher name |
| 8 | `edition` | text | | Edition description (e.g., "1st", "Revised") |
| 9 | `publication_date` | text | | Full date (YYYY-MM-DD) or just year (YYYY) |
| 10 | `format` | text | | Enum: Hardcover, Paperback, Other |
| 11 | `page_count` | int | | Number of pages |
| 12 | `description` | text | | Synopsis/blurb |
| 13 | `condition` | text | | Enum: New, Like New, Used, Worn, Damaged |
| 14 | `price_paid` | real | | Purchase price (in local currency) |
| 15 | `purchase_date` | text | | ISO date string (YYYY-MM-DD) |
| 16 | `notes` | text | | Free-form notes |
| 17 | `status` | text | ✓ | Enum: Available, CheckedOut, Loaned. Default: Available |
| 18 | `checked_out_to` | text | | Family member name when status = CheckedOut |
| 19 | `is_deleted` | boolean | ✓ | Default false. Soft delete flag |
| 20 | `created_at` | text | ✓ | ISO timestamp, auto-set |
| 21 | `updated_at` | text | ✓ | ISO timestamp, auto-updated |

### Author (many-to-many with Book)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | |
| 2 | `raw_name` | text | ✓ | Display name as entered (e.g., "J.K. Rowling") |
| 3 | `normalized_name` | text | ✓ | Lowercase, stripped spaces/punctuation for dedup ("jkrowling"). Unique constraint. |
| 4 | `disambiguation` | text | | Optional note to distinguish same-name authors (e.g., "historian, b.1965"). When creating an author whose normalized_name already exists, user is prompted: "Is this the same person?" If no, disambiguation is required. Normalized name becomes "jkrowling_historian". |

### BookAuthor (join table)

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓ |
| 2 | `author_id` | text (UUID) | ✓ |

### Genre (Book ↔ Genre, many-to-many)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | |
| 2 | `name` | text | ✓ | Unique |
| 3 | `is_custom` | boolean | ✓ | false = predefined, true = user-created |

### BookGenre (join table)

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓ |
| 2 | `genre_id` | text (UUID) | ✓ |

### Tag (Book ↔ Tag, many-to-many)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | |
| 2 | `name` | text | ✓ | Unique, user-defined (e.g., "unread", "lent to mom") |

### BookTag (join table)

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓ |
| 2 | `tag_id` | text (UUID) | ✓ |

### Language

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | |
| 2 | `name` | text | ✓ | Unique (e.g., "English", "Hindi", "Sanskrit", "Marathi") |
| 3 | `is_builtin` | boolean | ✓ | true = English/Hindi/Sanskrit; false = user-added |

### BookLoan (external loans — when book is loaned outside the household)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | |
| 2 | `book_id` | text (UUID) | ✓ | FK → Book |
| 3 | `borrower_name` | text | ✓ | Name of the person who borrowed the book |
| 4 | `borrower_contact` | text | | Phone number or email (optional) |
| 5 | `loaned_date` | text | ✓ | ISO date (YYYY-MM-DD) |
| 6 | `due_date` | text | | Expected return date (YYYY-MM-DD) |
| 7 | `returned_date` | text | | Actual return date; null if still out |
| 8 | `notes` | text | | Free-form notes about the loan |
| 9 | `created_at` | text | ✓ | ISO timestamp |
| 10 | `created_by` | text | ✓ | Google account email of who recorded the loan |

### Location (hierarchical: Room → Cupboard → Shelf)

#### Room

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `id` | text (UUID) | ✓ |
| 2 | `name` | text | ✓, unique |

#### Cupboard

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `id` | text (UUID) | ✓ |
| 2 | `name` | text | ✓ |
| 3 | `room_id` | text (UUID) | ✓, FK → Room |

#### Shelf

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `id` | text (UUID) | ✓ |
| 2 | `name` | text | ✓ |
| 3 | `cupboard_id` | text (UUID) | ✓, FK → Cupboard |

### Book ↔ Shelf (every book has a location; defaults to "None")

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓, unique (one location per book) |
| 2 | `shelf_id` | text (UUID) | FK → Shelf, nullable when location is "None" |

### Change Log Events

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `event_id` | text (UUID) | ✓ | |
| 2 | `entity_type` | text | ✓ | Type of entity: `book`, `location`, `genre`, `tag`, `author`, `loan`, `language` |
| 3 | `entity_id` | text (UUID) | ✓ | ID of the changed entity |
| 4 | `field_name` | text | ✓ | Which field changed. For creates, set to `*`. |
| 5 | `old_value` | text | | Null for creates |
| 6 | `new_value` | text | | The new value (full entity JSON for creates) |
| 7 | `timestamp` | text | ✓ | ISO 8601 |
| 8 | `device_user` | text | ✓ | Google account email |
| 9 | `event_type` | text | ✓ | create, update, delete |

### Database Indices

| Table | Index On | Purpose |
|-------|----------|---------|
| Book | `title` (COLLATE NOCASE) | Fast title search and sorting |
| Book | `isbn` | Exact ISBN lookup |
| Book | `language_id` | Filter by language |
| Book | `format` | Filter by format |
| Book | `condition` | Filter by condition |
| Book | `purchase_date` | Filter and sort by purchase date |
| Book | `created_at` | Sort by recently added |
| Book | `status` | Filter by status |
| Book | `checked_out_to` | Filter by who has the book |
| Author | `normalized_name` (COLLATE NOCASE) | Dedup and type-ahead |
| Author | `raw_name` (COLLATE NOCASE) | Display search |
| Genre | `name` (COLLATE NOCASE) | Genre lookup |
| Language | `name` (COLLATE NOCASE) | Language lookup |
| Room | `name` (COLLATE NOCASE) | Location filtering |
| Cupboard | `room_id` | Cascading location queries |
| Shelf | `cupboard_id` | Cascading location queries |
| BookAuthor | `book_id`, `author_id` | Join performance |
| BookGenre | `book_id`, `genre_id` | Join performance |
| BookTag | `book_id`, `tag_id` | Join performance |
| ChangeLog | `entity_type`, `timestamp` | Filter events by type, ordered replay |
| ChangeLog | `entity_type`, `entity_id`, `timestamp` | Event replay during merge |
| BookLoan | `book_id`, `returned_date` | Active loans lookup |
| BookLoan | `borrower_name` | Search loans by borrower |

**FTS (Full-Text Search):** An FTS5 virtual table on `Book` indexes `title`, `isbn`, and `publisher` for fast fuzzy full-text search. Author names are searched via Author table join with LIKE/trigram matching.

---

## Navigation Architecture

**Pattern:** Single-screen with navigation drawer (hamburger menu).

**Main screen:** Catalog (F5) — the default landing screen after setup.

**Navigation drawer items:**

| Item | Icon | Destination |
|------|------|-------------|
| Library | 📚 | Catalog (F5) — default screen |
| Locations | 📍 | Location management (F1) |
| Recent Activity | ⏱️ | Activity feed (F13) |
| Active Loans | 📖 | Currently loaned/checked-out books |
| Genres | 🏷️ | Genre management (F9) |
| Tags | # | Tag management (F10) |
| Languages | 🌐 | Language management (F14) |
| Deleted Books | 🗑️ | View/restore soft-deleted books |
| Settings | ⚙️ | Sync, Account, Auto-enrich, Share Library, About |

**FAB (Floating Action Button):** Material Speed Dial on the catalog screen.
- Tap the '+' FAB → it morphs to '✕' and 4 labeled mini-FABs fan out:
  1. 🎤 **Voice Input** (F11)
  2. 📷 **Scan Cover** (F4)
  3. 📱 **Scan Barcode** (F3)
  4. ✏️ **Add Manually** (F2)
- Tap again or tap away to collapse.
- **Phase 2:** A 5th option "Scan Shelf" (P2-F1) is added to the speed dial.

---

## Feature Specifications — Phase 1

### F0. Setup Wizard (First-Run Experience)

**Purpose:** Get a new family member connected to the shared library in under 2 minutes.

**Flow (3 steps):**

**Step 1 — Google Sign-In:**
- "Welcome to The Little Library" screen with app logo
- "Sign in with Google" button
- "Skip for now" link below (allows offline-only usage; sync can be enabled later from Settings)
- If sign-in fails: show retry with error reason

**Step 2 — Connect to Shared Library:**
- Two options presented:
  - **"I have a link or QR code"** — paste link or scan QR code shared by a family member
  - **"Create a new library"** — creates the `/The Little Library/` folder in the user's Drive
- On creating a new library, user is prompted: "Share with family?" → enter email addresses → app calls Google Drive API (`permissions.create`) to grant write access to each email. Google sends notification emails to recipients.
- On selecting an existing library, the app downloads and merges the catalog

**Step 3 — Sync & Go:**
- App pulls the latest catalog from Drive
- Shows progress: "Downloading catalog…" → "Synced 847 books, 12 locations"
- "Start Browsing" button → lands on catalog screen (F5)

**Post-setup:** If user skipped sign-in, a persistent banner appears: "Sign in to sync with family." They can sign in later from Settings → Account. On later sign-in, the app merges their local data with the Drive catalog using the standard merge flow.

**Drive sharing:** Settings → Share Library provides three sharing methods:
- **Share via link:** Copy a shareable Google Drive link
- **Share via QR code:** Generate and display a QR code others can scan
- **Share via email:** Enter email addresses → app grants Drive folder access via `permissions.create` API

Any family member can access sharing options at any time, not just during setup.

### F1. Location Management

**Purpose:** Users set up their physical storage hierarchy (Room → Cupboard → Shelf).

**Flow:**
1. Navigate to Locations section from the navigation drawer
2. Create Rooms (e.g., "Living Room", "Study", "Bedroom")
3. Under each Room, create Cupboards/Bookcases (e.g., "Main Bookshelf", "Corner Cupboard")
4. Under each Cupboard, create Shelves (e.g., "Top Shelf", "Shelf 2", "Bottom Shelf")
5. Full CRUD on all three levels
6. Deleting a Room/Cupboard/Shelf: affected books have their location set to **"None"** (not deleted). Confirmation dialog warns: "X books will have their location set to None. Continue?"

**UI:** Nested list with expand/collapse, add via FAB, swipe-to-delete with confirmation.

### F2. Add Book — Manual Entry

**Purpose:** Manually enter all book details via a form, with optional AI enrichment.

**Flow:**
1. Tap "+" FAB → choose "Add Manually"
2. Scrollable form with sections:
   - **Basic:** Title*, ISBN, Language* (dropdown from Language table), Format
   - **Authors:** Add one or more authors (type-ahead search existing or create new; author dedup via normalized name)
   - **Details:** Publisher, Edition, Publication Date (date picker), Page Count, Description
   - **Classification:** Genres (multi-select chips with inline "+ Add" to create new), Tags (multi-select chips with inline "+ Add")
   - **Location:** Room → Cupboard → Shelf picker (cascading dropdowns); defaults to "None"
   - **Purchase:** Purchase Date (date picker), Price Paid, Condition
   - **Cover:** Tap to add (camera / gallery / online search)
   - **Notes:** Free text

3. **Enrichment (applies to all add-book flows — F2, F3, F4, F11, P2-F1):**
   - **Manual Enrich:** An **"Enrich Online"** button is always visible. On tap, searches Google Books API using available fields (title + author). If multiple matches found, presents them as a scrollable list. User selects a match, then can accept/reject enriched fields **per-field** (e.g., take title from match 1, description from match 2).
   - **Auto-Enrich:** A setting toggle ("Auto-enrich from web") enables automatic lookup. When the user pauses typing the title, the app searches Google Books in the background and suggests completions for empty fields. User can accept or override. If multiple matches, they are presented for selection.

4. **Duplicate check:** Always runs both:
   - ISBN exact match
   - Fuzzy title+author match (Levenshtein distance ratio ≥ 80%)
5. If duplicate found → warning dialog with match reason and [Add Anyway] / [Cancel]
6. On save → local DB updated → change log event recorded → push to Drive triggered

**Validation:** Title is required. ISBN validated for format (10 or 13 digits); ISBN-10 is auto-converted to ISBN-13 on save. Publication date year range: 1000–current year.

### F3. Add Book — Barcode / ISBN Scan

**Purpose:** Scan a book's barcode, look up details online.

**Flow:**
1. Tap "+" FAB → choose "Scan Barcode"
2. Camera viewfinder opens with barcode detection overlay; torch toggle available
3. On detection:
   - **Online:** Query Google Books API → populate all available fields → pre-filled form for review
   - **Offline:** Pre-fill ISBN only → manual form
4. **Enrich Online** button at review stage: re-queries Google Books API for additional fields. Multi-match + per-field selection as described in F2.
5. User edits, then saves with duplicate check.

**Edge cases:**
- Barcode is not an ISBN → "Not a recognized ISBN" with option to enter manually
- Camera permission denied → show rationale and link to settings

### F4. Add Book — Single Photo OCR

**Purpose:** Take a photo of a book cover/spine; extract title and author via OCR.

**Flow:**
1. Tap "+" FAB → choose "Scan Book Cover"
2. Choose camera or gallery
3. Run ML Kit text recognition (Latin script in Phase 1)
4. **Online:** Send detected text to Google Books API → present top matches → user selects best match → pre-fill form
5. **Offline:** Present extracted text blocks → user taps to assign to "Title" or "Author" → pre-fill form
6. **Enrich Online** button at review stage (multi-match + per-field, as in F2)
7. User completes and saves with duplicate check

**UI:** Photo with detected text regions highlighted. Extracted text shown as tappable chips below.

**Edge cases:**
- No text detected → "Try a clearer photo or enter manually"
- Cluttered cover → option to crop/rotate before OCR
- Non-English text (Phase 1) → falls back to manual entry

### F5. Catalog Browsing & Search

**Purpose:** Browse all books with powerful filtering and search.

**Flow:**
1. Main screen shows book grid/list (toggle) sorted by title (default)
2. **Search bar** at top:
   - Text search across title, author names, ISBN, publisher, tags
   - **Voice search** via microphone icon (platform STT → fills search bar)
   - **Search ranking selector** (dropdown next to search bar): user chooses from:
     - **Relevance** (default): title matches > author matches > tag matches > publisher/ISBN; alpha within tier
     - **Recency-boosted**: same as relevance but recently added/viewed books boosted
     - **Alphabetical**: simple A-Z by title
3. **Filter drawer/chips:**
   - By Genre (multi-select)
   - By Language (single select)
   - By Location: Room → Cupboard → Shelf (cascading); includes "None" option for unplaced books
   - By Status (multi-select): Available, Checked Out, Loaned
   - By Format
   - By Condition
   - By Tags (multi-select)
   - By Purchase Date range
   - Show/Hide Deleted
4. **Sort options:** Title, Author, Recently Added, Purchase Date
   - **Author sort (multi-author):** Books with multiple authors appear under each author. E.g., "Good Omens" (Neil Gaiman, Terry Pratchett) appears under both G (Gaiman) and P (Pratchett) when sorted by author. In all other sort modes, the book appears once.
5. Each book card shows:
   - Cover thumbnail
   - Title
   - Primary author
   - **Status badge (takes priority):** If Checked Out → "With Mom" (blue). If Loaned → "Loaned to Arjun" (amber). If Available → location badge (e.g., "Study / Shelf 2") or "No location" (muted).
   - Overdue indicator (red) if applicable
6. Tap book → Book Detail (F6)
7. Long-press → multi-select mode for bulk actions (delete, change location)

**"None" location nudge:** If any books have location "None," a subtle banner shows on the catalog: "N books need a shelf — tap to assign." Tapping navigates to a filtered view of unplaced books.

**Performance:** Reactive drift queries. FTS5 for text search. Smooth scrolling with 2000+ books.

### F6. Book Detail & Edit

**Purpose:** View full details of a book and edit any field.

**Flow:**
1. Shows all fields in a structured layout
2. Cover image displayed prominently at top
3. **Status section:** Shows current status (Available / Checked Out to X / Loaned to Y). Action buttons: "Check Out", "Loan to Someone", "Return to Shelf" / "Mark Returned" based on current status.
4. **Loan history:** If the book has past loans, a "Loan History" section shows previous borrowers and dates.
5. Edit button → switches to edit mode (same form as F2, pre-filled). Not shown for deleted books.
6. Delete button → confirmation dialog → soft delete. If book is already deleted, shows "Restore" button instead → restores book to exact previous state.
7. Share button → share book details as text (via system share sheet)
8. Change history button → shows the change log for this book (who changed what, when)

### F7. Duplicate Detection

**Purpose:** Prevent adding a book that already exists in the catalog.

**Trigger points:** On save in F2, F3, F4, F11; on import/merge.

**Algorithm (both checks always run):**
1. **ISBN normalization:** On save, detect ISBN format. If ISBN-10 (10 digits/9 digits + X), convert to ISBN-13 using the standard algorithm. Store only ISBN-13.
2. **ISBN exact match:** Query `SELECT * FROM books WHERE isbn = ? AND isbn IS NOT NULL AND is_deleted = false`. If result exists → hard duplicate.
3. **Title + Author fuzzy match:** Use normalized strings. Levenshtein distance ratio. Flag if title similarity ≥ 80% AND at least one author similarity ≥ 80%. Only checks non-deleted books.
4. **User decision:** Dialog shows matched book(s) with match reason. User chooses "This is a duplicate — cancel" or "Different book — add anyway."

### F8. Sync Status & Management

**Purpose:** Users can see sync state, resolve conflicts, and manage the shared Drive folder.

**Sync Status Bar:** Persistent thin bar below the app bar (or bottom):
- **Green** + "Synced just now" — all changes pushed and pulled successfully
- **Amber** + "Offline — N changes pending" — changes queued locally, will sync when connected
- **Red** + specific error message — sync failed, actionable message (e.g., "Drive storage full")

**Pull-to-refresh** on catalog screen triggers an immediate pull sync.

**Settings → Sync:**
- Last sync timestamp
- Manual "Sync Now" button
- "Share Library" — shows link + QR code for family members to join
- "Resolve Conflicts" — if any unresolved conflicts exist, shows count and navigates to conflict resolver

### F9. Genre Management

**Predefined genres (shipped with app):**
Fiction, Non-Fiction, Science, Technology, History, Biography & Memoir, Poetry, Religion & Spirituality, Philosophy, Self-Help, Business & Economics, Art & Photography, Cooking, Travel, Health & Wellness, Comics & Graphic Novels, Children's, Young Adult, Reference, Textbooks

**Flow:**
1. Settings → Manage Genres
2. View predefined + custom genres
3. Add custom genre (name only)
4. Edit custom genre name
5. Delete custom genre (warn if books are tagged; orphaned genres disassociated)
6. Predefined genres cannot be deleted, only hidden from selection UI

### F10. Tag Management

1. Tags are fully user-defined
2. Created inline while adding/editing a book (type-ahead; "+ Add [new tag]" always visible)
3. Settings → Manage Tags (CRUD)

### F11. Voice Input with LLM

**Purpose:** Speak a natural language description; AI extracts structured book fields.

**Flow:**
1. Tap "+" FAB → choose "Voice Input"
2. Microphone activates (platform STT)
3. User speaks freely, e.g.:
   > "Add The Alchemist by Paulo Coelho, published in 1988 by HarperCollins, hardcover, I bought it last month for 350 rupees, it's in the living room main bookshelf, fiction."
4. Transcribed text → LLM extraction pipeline:
   - **Tier 1 (on-device):** Gemini Nano / MediaPipe LLM Inference with structured extraction prompt
   - **Tier 2 (cloud fallback):** Gemini API / OpenAI API with same prompt
   - **Tier 3 (keyword fallback):** Regex-based extraction ("by [Author]", "published in [Year]", "[Genre]")
5. Extracted fields pre-fill the add-book form for user review
6. **Enrich Online** button available (multi-match + per-field, as in F2)
7. User saves with duplicate check

**Voice search (F5):** Search bar microphone icon → speak query → STT fills search bar. No LLM extraction needed.

**Technical considerations:**
- STT uses platform APIs (no extra dependencies)
- On-device LLM limited to Android 14+ devices with sufficient RAM
- Extraction prompt designed for consistent JSON output
- Target: < 3 seconds from voice end to filled form

### F12. Book Lending & Status Tracking

**Purpose:** Track when books leave the shelf — either taken by a household member for reading, or loaned to someone outside the family.

**Book Statuses:**
- **Available:** On its assigned shelf, ready to read
- **Checked Out:** Taken by a household member for reading (still in the house, just not on shelf)
- **Loaned:** Loaned to someone outside the household

**Status Transition Rules:**
- All transitions must pass through Available — no direct CheckedOut ↔ Loaned jumps.
- Checkout: allowed only if status = Available. Validation: "This book is currently loaned to [Borrower]. Mark it as returned first."
- Loan: allowed only if status = Available. Validation: "This book is currently checked out by [Person]. Return it to the shelf first."
- Return: allowed from CheckedOut or Loaned.

#### Internal Checkout (Checked Out)

**Flow:**
1. From Book Detail → tap "Check Out"
2. Select family member name from dropdown (pulled from Google account names of synced devices, or type a custom name like "Mom", "Dad")
3. Book status changes to "Checked Out"; `checked_out_to` field records the name
4. Book card shows "With Mom" badge instead of location badge
5. To return: tap "Return to Shelf" → dialog appears with three options:
   - **"Return to [Previous Shelf]"** — status back to Available, location stays as before checkout
   - **"Return to a different shelf"** — opens location picker to assign a new shelf
   - **"Return without location"** — status back to Available, location set to None

**Catalog integration:**
- Filter includes "Checked Out" status
- "Checked Out by Me" quick-filter: matches `checked_out_to` against the signed-in Google account's display name (e.g., if Google account shows "Priya Sharma", it matches books checked out to "Priya Sharma").

#### External Loan (Loaned)

**Flow:**
1. From Book Detail → tap "Loan to Someone"
2. Form opens:
   - **Borrower Name***: who is borrowing the book
   - **Borrower Contact**: phone or email (optional, for follow-up)
   - **Loaned Date***: defaults to today
   - **Due Date**: expected return date (optional)
   - **Notes**: free text (e.g., "Needs it for her book club")
3. On save:
   - Book status → "Loaned"
   - New BookLoan record created
   - Change log event recorded
4. Book card shows "Loaned to [Borrower]" badge (amber/orange color to distinguish from Checked Out)

**Return flow:**
1. From Book Detail (Loaned state) → tap "Returned"
2. Populates `returned_date` on the active BookLoan record
3. Book status → "Available"
4. Loan history preserved — tapping "Loan History" on Book Detail shows all past loans for that book

**Overdue reminders:**
- If `due_date` has passed and `returned_date` is null, book card shows "Overdue — due [date]" in red
- A banner on the catalog: "N books overdue" if any books are past due
- Optional: push notification reminder (Phase 2)

**Loan constraint:** Only one active (unreturned) loan per book at a time. Attempting to create a second loan while one is active shows: "This book is already loaned to [Borrower]. Mark it as returned first."

**Catalog integration:**
- Filter includes "Loaned" status
- Search loans by borrower name
- "Active Loans" item in navigation drawer shows all currently loaned and checked-out books

### F13. Recent Activity

**Purpose:** A timeline showing what the family has been doing in the library — additions, edits, checkouts, loans, returns.

**Data source:** The unified change log, filtered for human-readable events.

**Flow:**
1. Access from navigation drawer → "Recent Activity"
2. Chronological feed (newest first) showing:
   - User avatar/initial (from Google account)
   - Action description in natural language:
     - "Mom added **The Alchemist** by Paulo Coelho"
     - "Dad checked out **Sapiens**"
     - "Rohan changed location of **1984** to Study / Shelf 2"
     - "You loaned **The Hobbit** to Arjun"
     - "Mom returned **Sapiens** to shelf"
   - Book cover thumbnail
   - Relative timestamp ("2 hours ago", "Yesterday", "3 days ago")
3. Tap any entry → navigates to Book Detail (F6)
4. Pull-to-refresh loads latest events
5. Infinite scroll for history

**Filter:** Tabs or chips at the top to filter by event type: All, Added, Edited, Checked Out, Loaned, Returned.

**Performance:** Paginated queries on the change log table. Load 50 events at a time.

### F14. Language Management

**Purpose:** Manage the list of languages available for books.

**Built-in languages (shipped with app):** English, Hindi, Sanskrit

**Flow:**
1. Settings → Manage Languages (also accessible from navigation drawer → Languages)
2. View built-in + custom languages list
3. Add custom language (name only, e.g., "Marathi", "Tamil", "Urdu")
4. Edit custom language name
5. Delete custom language (warn if books are tagged with it — affected books set to "English" as default)
6. Built-in languages cannot be deleted, only hidden from selection UI

**Book form integration:** The Language field in F2 becomes a dropdown of all visible languages (built-in + custom).

### F15. Export Catalog

**Purpose:** Export the catalog as a file for sharing, backup, or external use.

**Flow:**
1. Settings → Export Catalog
2. Choose format:
   - **JSON:** Full catalog including all book data, authors, genres, tags, locations, and loan history. Machine-readable.
   - **CSV:** Spreadsheet-friendly with one row per book. Columns: Title, Author(s), ISBN, Language, Publisher, Edition, Publication Date, Format, Pages, Condition, Price, Purchase Date, Location, Status, Tags, Genres.
   - **Share as Text:** Human-readable list of books with title and author. Suitable for messaging.
3. Cover images are NOT included (files would be too large).
4. File shared via system share sheet (Save to Drive, email, messaging apps).
5. File named: `little-library-export-YYYY-MM-DD.{json|csv|txt}`

---

## Phase 2 Features (Future)

### P2-F1. Bulk Shelf Scanning

**Purpose:** One photo of a shelf → detect multiple books → extract titles.

**Flow:**
1. Tap "+" FAB → "Scan Shelf"
2. Capture or select photo of a bookshelf
3. **Spine detection:** Object detection model identifies individual book spine regions
4. **OCR each spine:** Text recognition on each detected region
5. **Online matching:** Query Google Books API per OCR result → suggest best match
6. **Offline fallback:** Present raw OCR text per spine for manual assignment
7. Results as scrollable list with: cropped spine image, suggested title, Accept / Edit / Skip
8. Accepted books → pre-filled form for review and save (duplicate check each)
9. **Enrich Online** per-book + **"Fetch All"** batch button (same multi-match + per-field model)
10. User can merge adjacent regions if spine detection incorrectly split/merged books

**Technical:**
- Custom TFLite model or ML Kit object detection for spine detection
- Handle horizontal vs vertical stacking based on text orientation
- 20-30 books per photo: 5–15 seconds processing time

### P2-F2. Hindi / Sanskrit OCR (Devanagari Script)

- Enable `google_mlkit_text_recognition` Devanagari model
- Auto-detect script per text block, apply appropriate model
- Mixed-script shelves: handle Latin + Devanagari in same photo

### P2-F3. Bulk Location Assignment

**Purpose:** Select a shelf, then assign multiple books to it in one operation.

**Flow:**
1. Locations → tap target Shelf → "Assign Books"
2. Book picker with search/filter, multi-select with checkboxes
3. Current location shown as badge per book
4. "Assign X books to [Shelf]" → confirmation → all selected books updated

**Alternate flow:** Catalog multi-select mode → "Change Location" → pick target shelf.

---

## UX Specifications

### Permissions Strategy

All permissions requested **just-in-time** when the feature is first used:

| Permission | Trigger | Rationale Dialog |
|-----------|---------|------------------|
| Camera | First tap on "Scan Barcode" or "Scan Book Cover" | "The Little Library needs camera access to scan barcodes and book covers." |
| Microphone | First tap on "Voice Input" or voice search mic | "The Little Library needs microphone access to capture your voice for book entry and search." |
| Storage | First cover image save or catalog import | "The Little Library needs storage access to save cover images and import/export your catalog." |

Each denial shows the rationale again. Second denial shows a dialog with a "Open Settings" button.

### Offline UX

- **Status bar** (persistent, below app bar): color-coded sync indicator
- **Queued changes badge:** "3 pending" next to sync indicator
- **All features work offline:** add, edit, delete, search, browse — everything except online enrichment and sync
- **Graceful degradation:** Network-dependent features (Google Books lookup, Drive sync, cloud LLM) show "Offline — this feature requires internet" with a retry button

### Enrichment UX (All Flows)

1. **Manual trigger:** "Enrich Online" button visible whenever the add/edit form is shown
2. **Auto-enrich toggle:** Settings → "Auto-enrich from web" (default: off)
3. **Multi-match display:** When multiple Google Books results exist, show a horizontal scrollable card list. Each card shows: cover thumbnail, title, author, year. Tap to select.
4. **Per-field acceptance:** After selecting a match, enriched fields are shown with checkmarks. User can deselect individual fields. Can also select a different match for different fields.
5. **Loading state:** Skeleton cards while searching. "Searching Google Books…" indicator.

### Empty States

- **First launch (no catalog):** "Your library is empty. Add your first book!" with three quick-action buttons: Scan Barcode, Scan Cover, Add Manually
- **Search with no results:** "No books match '[query]'. Try different keywords or adjust filters."
- **No books on a shelf:** "This shelf is empty. Add books or assign existing ones."
- **No books in deleted view:** "No deleted books."
- **No active loans:** "No books are currently checked out or loaned. Everything is on the shelf!"
- **No recent activity:** "No activity yet. Start adding books to build your library!"

---

## Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Offline-first | All core features work without internet |
| Sync reliability | No data loss on failed sync; changes queued and retried |
| Performance | Book list renders smoothly with 2000+ books; search results < 300ms |
| Storage | Cover images optimized (max 800px wide, JPEG quality 80%, ~50–100KB each) |
| Sync bandwidth | Incremental: only changed DB + new images transferred. Full catalog DB < 5MB for 2000 books |
| Accessibility | Sufficient color contrast, tappable targets ≥ 48px, semantic labels for screen readers |
| Error handling | Graceful degradation — never crash on bad input, network failure, or missing permissions |
| Data integrity | Foreign key constraints, transactions for multi-table writes, soft deletes preserve referential integrity |
| Change log | Event journal with snapshots every 1000 events for merge performance |

---

## Edge Cases & Error States

- **Empty state:** Quick-action buttons for first book
- **Camera permission denied:** Rationale dialog → link to settings
- **Microphone permission denied:** Rationale dialog → link to settings
- **Storage permission denied:** Rationale dialog → link to settings
- **Network timeout:** 10s timeout on online lookups → fall back to offline flow
- **Drive storage full:** Actionable error with link to drive.google.com
- **Corrupted Drive file:** Offer to restore from local backup
- **Auth expired:** Prompt to re-authenticate
- **Multiple books on same shelf:** Allowed — no uniqueness constraint
- **Deleted author still referenced:** Join table handles cascade; orphan cleanup
- **Image storage full:** Warning banner when approaching device limits
- **First merge after delayed sign-in:** Full merge flow with conflict resolution
- **Very large import/merge:** Progress indicator for 100+ books
- **Book with no ISBN:** Duplicate detection via fuzzy title+author
- **Deleted book re-added:** Soft-deleted book with matching ISBN or fuzzy title/author triggers duplicate warning; user can restore the deleted book or add as new
- **Deleted book with active loan:** Soft-deleting a book with an active loan preserves the BookLoan record. The book shows as "[Deleted]" in loan history. The loan remains visible in Active Loans until returned.

---

## Success Criteria

1. A family member can scan a book in a bookstore and within 10 seconds know if it's already owned
2. The catalog can hold 2000+ books with responsive search
3. Changes made on one device appear on another device's next app launch without user intervention
4. Duplicate detection catches ≥ 95% of genuine duplicates
5. Manual entry of a book takes under 2 minutes for a complete record
6. Voice entry of a book takes under 30 seconds from speaking to filled form
7. No data is ever lost — failed syncs queue changes; deletions are reversible
