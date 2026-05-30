# The Little Library — App Specification

## Overview

A Flutter Android app for cataloging and tracking a home library (~10-12 cupboards/bookshelves). The primary goal is to prevent duplicate book purchases by maintaining a searchable catalog accessible to all household members via Google Drive sync.

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
| Google Drive | googleapis + google_sign_in |
| Image Capture | image_picker (camera + gallery) |

### Project Structure

```
lib/
├── core/              # Shared utilities, constants, theme, extensions
│   ├── theme.dart
│   └── utils.dart
├── data/              # Data layer
│   ├── database/      # drift tables, DAOs, database class
│   ├── api/           # Google Books API, Google Drive API clients
│   └── repositories/  # BookRepository, LocationRepository, etc.
├── features/
│   ├── catalog/       # Browse, search, filter
│   ├── book_detail/   # View & edit a single book
│   ├── add_book/      # Manual entry wizard
│   ├── scanner/       # Barcode scanning + single-book OCR
│   ├── bulk_scan/     # Multi-book shelf scanning (Phase 2)
│   ├── locations/     # Room → Cupboard → Shelf CRUD
│   ├── genres/        # Genre management
│   ├── sync/          # Google Drive export/import
│   └── settings/      # App preferences
├── app.dart           # MaterialApp, router setup
└── main.dart          # Entry point, Riverpod ProviderScope
```

---

## Data Model

### Book (18 fields — 16 user-facing + 2 system)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | Primary key, UUID v4 |
| 2 | `title` | text | ✓ | Full title including subtitle |
| 3 | `isbn` | text | | ISBN-10 or ISBN-13 (nullable — some old/regional books lack ISBN) |
| 4 | `language` | text | ✓ | Enum: English, Hindi, Sanskrit, Other (expandable) |
| 5 | `cover_image_path` | text | | Local file path to cover image |
| 6 | `cover_image_url` | text | | Remote URL if fetched online |
| 7 | `publisher` | text | | Publisher name |
| 8 | `edition` | text | | Edition description (e.g., "1st", "Revised") |
| 9 | `publication_date` | text | | Full date (YYYY-MM-DD) or just year (YYYY) if month/day unknown |
| 10 | `format` | text | | Enum: Hardcover, Paperback, Other |
| 11 | `page_count` | int | | Number of pages |
| 12 | `description` | text | | Synopsis/blurb |
| 13 | `condition` | text | | Enum: New, Like New, Used, Worn, Damaged |
| 14 | `price_paid` | real | | Purchase price (in local currency) |
| 15 | `purchase_date` | text | | ISO date string (YYYY-MM-DD) |
| 16 | `notes` | text | | Free-form notes |
| 17 | `created_at` | text | ✓ | ISO timestamp, auto-set |
| 18 | `updated_at` | text | ✓ | ISO timestamp, auto-updated |

### Author (many-to-many with Book)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | UUID v4 |
| 2 | `name` | text | ✓ | Full author name, unique |

### BookAuthor (join table)

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓ |
| 2 | `author_id` | text (UUID) | ✓ |

### Genre (Book ↔ Genre, many-to-many)

| # | Field | Type | Required | Notes |
|---|-------|------|----------|-------|
| 1 | `id` | text (UUID) | ✓ | UUID v4 |
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
| 1 | `id` | text (UUID) | ✓ | UUID v4 |
| 2 | `name` | text | ✓ | Unique, user-defined (e.g., "unread", "lent to mom") |

### BookTag (join table)

| # | Field | Type | Required |
|---|-------|------|----------|
| 1 | `book_id` | text (UUID) | ✓ |
| 2 | `tag_id` | text (UUID) | ✓ |

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

### Database Indices

For performant search and filtering across 2000+ books, the following indices are defined:

| Table | Index On | Purpose |
|-------|----------|---------|
| Book | `title` (COLLATE NOCASE) | Fast title search and sorting |
| Book | `isbn` | Exact ISBN lookup for duplicate detection and barcode scan |
| Book | `language` | Filter by language |
| Book | `format` | Filter by format |
| Book | `condition` | Filter by condition |
| Book | `purchase_date` | Filter and sort by purchase date |
| Book | `created_at` | Sort by recently added |
| Author | `name` (COLLATE NOCASE) | Fast author search and type-ahead |
| Genre | `name` (COLLATE NOCASE) | Genre lookup |
| Tag | `name` (COLLATE NOCASE) | Tag lookup |
| Room | `name` (COLLATE NOCASE) | Location filtering |
| Cupboard | `room_id` | Cascading location queries |
| Shelf | `cupboard_id` | Cascading location queries |
| BookAuthor | `book_id`, `author_id` | Join performance |
| BookGenre | `book_id`, `genre_id` | Join performance |
| BookTag | `book_id`, `tag_id` | Join performance |

**FTS (Full-Text Search):** A separate FTS5 virtual table on `Book` indexes `title`, `isbn`, and `publisher` for fast fuzzy search. Author names are searched via the Author table join with LIKE/trigram matching.

---

## Feature Specifications

### F1. Location Management (Setup Prerequisite)

**Purpose:** Users set up their physical storage hierarchy before cataloging books.

**Flow:**
1. User navigates to Locations section
2. Creates Rooms (e.g., "Living Room", "Study", "Bedroom")
3. Under each Room, creates Cupboards/Bookcases (e.g., "Main Bookshelf", "Corner Cupboard")
4. Under each Cupboard, creates Shelves (e.g., "Top Shelf", "Shelf 2", "Bottom Shelf")
5. Full CRUD on all three levels
6. Deleting a Room cascades to delete its Cupboards and Shelves. Any books assigned to those shelves have their location set to **"None"** (not deleted). Confirmation dialog warns if books are assigned: "X books will have their location set to None. Continue?"

**UI:** Nested list with expand/collapse, add via FAB, swipe-to-delete with confirmation.

### F2. Add Book — Manual Entry

**Purpose:** User manually enters all book details via a form.

**Flow:**
1. Tap "+" FAB → choose "Add Manually"
2. Multi-step form or scrollable form with sections:
   - **Basic:** Title*, ISBN, Language*, Format
   - **Authors:** Add one or more authors (type-ahead search existing or create new)
   - **Details:** Publisher, Edition, Publication Date (date picker), Page Count, Description
   - **Classification:** Genres (multi-select chips with inline "+ Add" to create new genre), Tags (multi-select chips with inline "+ Add" to create new tag)
   - **Location:** Room → Cupboard → Shelf picker (cascading dropdowns)
   - **Purchase:** Purchase Date (date picker), Price Paid, Condition
   - **Cover:** Tap to add (camera / gallery / online search)
   - **Notes:** Free text
3. On save:
   - **Duplicate check:** Always run both checks — ISBN exact match AND fuzzy title+author match — regardless of whether ISBN is present.
   - If potential duplicate found → show warning dialog: "This may be a duplicate of [Book Title] by [Author]. Add anyway?" with [Add Anyway] and [Cancel] buttons.
   - If no duplicate → save and navigate to book detail.

**Validation:** Title is required. ISBN, if provided, validated for format (10 or 13 digits). Publication date year must be reasonable (1000–current year).

### F3. Add Book — Barcode / ISBN Scan

**Purpose:** User scans a book's barcode, app looks up details online.

**Flow:**
1. Tap "+" FAB → choose "Scan Barcode"
2. Camera viewfinder opens with barcode detection overlay
3. Upon detecting a barcode:
   - **Online:** Query Google Books API by ISBN
     - If found → populate all available fields (title, authors, cover, publisher, description, page count, etc.). Present pre-filled form for user review and completion of missing fields.
     - If not found → pre-fill ISBN only, user fills rest manually.
   - **Offline:** Pre-fill ISBN only, user fills rest manually.
4. User edits/corrects any field, then saves (with duplicate check).
5. At review stage, an **"Enrich Online"** button is available: re-queries Google Books API to fetch additional fields (description, page count, genres, cover). User can accept/reject each enriched field.

**Edge cases:**
- Barcode is not an ISBN (e.g., store-specific code) → show "Not a recognized ISBN" with option to enter manually.
- Camera permission denied → show rationale and link to settings.
- Poor lighting → torch toggle button.

### F4. Add Book — Single Photo OCR

**Purpose:** User takes a photo of a single book cover/spine, app extracts title and author text via OCR.

**Flow:**
1. Tap "+" FAB → choose "Scan Book Cover"
2. Choose camera or gallery
3. After image captured/selected:
   - Run ML Kit text recognition (Latin script)
   - Extract all detected text blocks
   - **Online:** Send detected text to Google Books API as a search query → present top matches as suggestions. User selects best match → pre-fill form.
   - **Offline:** Present extracted text blocks. User taps to assign text to "Title" or "Author" fields. Pre-fill form with assigned text.
4. User completes remaining fields and saves (with duplicate check).
5. At review stage, an **"Enrich Online"** button is available: searches Google Books API using extracted title/author to fetch additional fields.

**UI:** After OCR, show the photo with detected text regions highlighted. Below, show extracted text as tappable chips that feed into title/author fields.

**Edge cases:**
- No text detected → "No text found. Try a clearer photo or enter manually."
- Very cluttered cover → user can crop/rotate before OCR (basic image editor).
- Non-English text (Phase 1) → OCR will fail to read; user falls back to manual entry.

### F5. Catalog Browsing & Search

**Purpose:** Browse all books with powerful filtering.

**Flow:**
1. Main screen shows book grid/list (toggle) sorted by title (default)
2. Search bar at top — searches across title, author names, ISBN, publisher, tags. Voice search via microphone icon.
3. Filter chips/drawer:
   - By Genre (multi-select)
   - By Language (single select)
   - By Location: Room → Cupboard → Shelf (cascading)
   - By Format
   - By Condition
   - By Tags (multi-select)
   - By Purchase Date range
4. Sort options: Title, Author, Recently Added, Purchase Date
5. Each book card shows: cover thumbnail, title, primary author, location badge
6. Tap book → navigates to Book Detail (F6)
7. Long-press → multi-select mode for bulk actions (delete, export selection, change location)

**Performance:** Reactive queries via drift. Search uses SQL LIKE/trigram for fuzzy matching. Large catalogs (1000+ books) should remain responsive.

### F6. Book Detail & Edit

**Purpose:** View full details of a book and edit any field.

**Flow:**
1. Shows all 16 fields in a structured layout
2. Cover image displayed prominently at top
3. Edit button (pen icon) → switches to edit mode (same form as F2 but pre-filled)
4. Delete button → confirmation dialog → removes book and cascades join table entries
5. Share button → share book details as text (for messaging family members)

### F7. Duplicate Detection

**Purpose:** Prevent adding a book that already exists in the catalog.

**Trigger points:**
- On save in F2 (manual entry)
- On save in F3 (barcode scan)
- On save in F4 (OCR entry)
- On import (F8)

**Algorithm (both checks always run):**
1. **ISBN exact match:** Query `SELECT * FROM books WHERE isbn = ?` AND `isbn IS NOT NULL`. If result exists → hard duplicate, show immediately.
2. **Title + Author fuzzy match:** Always run regardless of ISBN result. Use normalized strings (lowercase, stripped punctuation, trimmed whitespace). Compute similarity using Levenshtein distance ratio. Flag as potential duplicate if title similarity ≥ 80% AND at least one author similarity ≥ 80%.
3. **User decision:** Dialog shows all matched book(s) with match reason ("ISBN match" or "Title/Author similarity: 92%"). User chooses "This is a duplicate — cancel" or "Different book — add anyway".

### F8. Google Drive Manual Export/Import

#### Export

1. User navigates to Settings → Export Catalog
2. App serializes entire database to a JSON file including:
   - All books with authors, genres, tags, location
   - Cover images encoded as base64 (or packaged in a zip with image files)
   - Locations hierarchy
   - Genres and tags definitions
3. User chooses destination: share sheet (Save to Drive, email, etc.) or save locally
4. File named: `little-library-export-YYYY-MM-DD.json` (or `.zip`)

#### Import

1. User navigates to Settings → Import Catalog
2. File picker opens (`.json` or `.zip`)
3. App validates file format
4. **Merge strategy:** Show summary of incoming data (N books, N new genres, N new locations). User chooses:
   - **Merge:** Add new books, skip duplicates (by ISBN). Add new locations/genres/tags.
   - **Replace:** Wipe existing data and replace with imported catalog (confirmation required).
5. After import, show summary: "Added X books, skipped Y duplicates, added Z new locations."

### F9. Genre Management

**Predefined genres (shipped with app):**
Fiction, Non-Fiction, Science, Technology, History, Biography & Memoir, Poetry, Religion & Spirituality, Philosophy, Self-Help, Business & Economics, Art & Photography, Cooking, Travel, Health & Wellness, Comics & Graphic Novels, Children's, Young Adult, Reference, Textbooks

**Flow:**
1. Navigate to Settings → Manage Genres
2. View predefined + custom genres list
3. Add custom genre (name only)
4. Edit custom genre name
5. Delete custom genre (warn if books are tagged with it — orphaned genres are disassociated)
6. Predefined genres cannot be deleted, only hidden from selection UI

### F10. Tag Management

1. Tags are fully user-defined
2. Created inline while adding/editing a book (type-ahead with existing tags; "+ Add [new tag]" option always visible)
3. Manage in Settings → Manage Tags (CRUD)

### F11. Voice Input with LLM

**Purpose:** User speaks a natural language description of a book; app uses AI to extract structured fields.

**Flow:**
1. Tap "+" FAB → choose "Voice Input"
2. Microphone activates with speech-to-text (platform STT: Android SpeechRecognizer / iOS SFSpeechRecognizer)
3. User speaks freely, e.g.:
   > "Add The Alchemist by Paulo Coelho, published in 1988 by HarperCollins, hardcover, I bought it last month for 350 rupees, it's in the living room main bookshelf, fiction."
4. Transcribed text is sent to the LLM extraction pipeline:
   - **Tier 1 (on-device):** Use on-device LLM (Gemini Nano via AI Edge / MediaPipe LLM Inference) with a structured extraction prompt to parse: title, author(s), publisher, publication date, format, price paid, purchase date, location, genre, condition.
   - **Tier 2 (cloud fallback):** If on-device LLM unavailable or returns low confidence, call Gemini API / OpenAI API with the same extraction prompt.
   - **Tier 3 (keyword fallback):** If offline and no on-device LLM, use regex/keyword-based extraction (e.g., "by [Author]", "published in [Year]", "[Genre]").
5. Extracted fields pre-fill the add-book form for user review and correction.
6. At review stage, an **"Enrich Online"** button is available: searches Google Books API using extracted title/author to fetch additional fields (description, page count, genres, cover, publisher). User can accept/reject each enriched field.
7. User then saves (with duplicate check).

**Voice search:** The catalog search bar also supports voice input. User taps microphone icon → speaks search query → speech-to-text fills the search bar. No LLM extraction needed for search.

**Technical considerations:**
- Speech-to-text uses platform APIs (no extra dependencies)
- On-device LLM limited to Android 14+ devices with sufficient RAM
- Extraction prompt must be carefully designed for consistent JSON output
- Processing time target: < 3 seconds for voice → filled form (excluding manual review)

---

## Phase 2 Features (Future)

### P2-F1. Bulk Shelf Scanning

**Purpose:** Take one photo of a shelf with multiple books; app detects individual books and extracts titles.

**Flow:**
1. Tap "+" FAB → "Scan Shelf"
2. Capture or select photo of a bookshelf
3. **Spine detection:** Use object detection model to identify individual book spine regions
4. **OCR each spine:** Run text recognition on each detected region
5. **Online matching:** For each OCR result, query Google Books API → present top match suggestion
6. **Offline fallback:** Present raw OCR text for each spine for manual assignment
7. Results displayed as a scrollable list with:
   - Cropped spine image
   - Suggested title
   - Accept / Edit / Skip buttons
8. Accepted books proceed to pre-filled form for review and save (with duplicate check each).
9. At review stage, an **"Enrich Online"** button is available per book: searches Google Books API to fetch additional fields. Can be triggered manually per-book or via a "Fetch All" batch button at the top of the review list.
10. User can merge adjacent regions if spine detection incorrectly split/merged books

**Technical considerations:**
- On-device ML model for spine detection (custom TFLite model or ML Kit object detection)
- Handling books stacked horizontally vs vertically based on text orientation
- Performance: processing a photo with 20-30 books may take 5-15 seconds

### P2-F2. Hindi / Sanskrit OCR (Devanagari Script)

- Enable `google_mlkit_text_recognition` Devanagari model
- OCR flow (F4 and P2-F1) detects script per text block and applies appropriate model
- Mixed-script shelves: handle both Latin and Devanagari in same photo

### P2-F3. Bulk Location Assignment

**Purpose:** Select a location, then assign multiple books to it in one operation. Useful when relocating books.

**Flow:**
1. Navigate to Locations → tap on a target Shelf → "Assign Books" button
2. A book picker opens showing all books (with search/filter support)
3. User multi-selects books (checkboxes)
4. Current location of each book shown as a badge — books already on this shelf are pre-selected
5. Tap "Assign X books to [Shelf Name]" → confirmation → all selected books' location updated

**UI:** Grid/list with checkboxes, search bar at top, location chip on each book card. Selected count shown in a floating bottom bar.

**Alternate flow:** From catalog multi-select mode (long-press), user can select multiple books → "Change Location" action → pick target shelf.

### P2-F4. Google Drive Auto-Sync

- Background sync to a designated shared Google Drive folder
- Conflict resolution: last-write-wins with manual conflict review option
- Sync status indicator
- Sync frequency: on app open, on save, and periodic background (if feasible)

---

## Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Offline-first | All core features work without internet |
| Performance | Book list renders smoothly with 2000+ books |
| Storage | Cover images stored locally, optimized (max 800px wide, JPEG quality 80%) |
| Accessibility | Sufficient color contrast, tappable targets ≥ 48px |
| Error handling | Graceful degradation — never crash on bad input, network failure, or missing permissions |
| Data integrity | Foreign key constraints, cascading deletes where appropriate, transactions for multi-table writes |

---

## Edge Cases & Error States

- **Empty state:** "Your library is empty. Add your first book!" with quick-action buttons
- **Permission denied (Camera):** Explain why camera is needed, link to app settings
- **Permission denied (Storage):** Explain why storage is needed for cover images/import
- **Network timeout:** Online lookup times out after 10s → fall back to offline flow
- **Corrupted import file:** Validate JSON schema before processing, show specific error
- **Very large import:** Show progress indicator for imports with >100 books
- **Duplicate ISBN from import:** Follow merge strategy (skip or warn)
- **Multiple books on same shelf:** Allowed — no uniqueness constraint on shelf assignment
- **Deleted author still referenced:** Cascade handled by join table; author record cleaned up if orphaned
- **Image storage full:** Warn user when approaching device storage limits (optional)

---

## Success Criteria

1. A family member can scan a book in a bookstore and within 10 seconds know if it's already owned
2. The catalog can hold 2000+ books with responsive search
3. Any household member can export the catalog, share via Google Drive, and another member can import it without data loss
4. Duplicate purchases are prevented — duplicate detection catches ≥ 95% of genuine duplicates
5. Manual entry of a book takes under 2 minutes for a complete record
