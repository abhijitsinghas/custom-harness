# The Little Library — Implementation Plan

> **References:** `docs/spec-v2.md` (16 Phase 1 features, 3 Phase 2), `docs/The-Little-Library---Proto-2/` (20 HTML mockups)
> **Target:** Flutter Android app, Material Design 3, drift/Riverpod stack
> **Strategy:** Phased delivery with parallel AI subagent workstreams

---

## Design System (from Mockups)

| Token | Value |
|-------|-------|
| Primary | `#5D4037` (warm brown) |
| On Primary | `#FFFFFF` |
| Primary Container | `#EADDCF` (cream) |
| Secondary | `#FFA000` (amber) |
| Surface | `#FFF8F0` (off-white) |
| Background | `#FAFAF5` (warm grey) |
| Dark theme | Full dark variant defined in mockups |
| Font | Roboto, 16sp body, 14sp secondary |
| Device target | 412×900dp frame, responsive |

---

## Phase 0: Foundation (Days 1–3)

**Goal:** Project scaffold, design system, data contracts, navigation shell. All subsequent phases depend on this.

### Workstream 0.1 — Project Scaffold & Theme
**Owner:** Subagent A | **Depends on:** Nothing | **Testable by:** Running the app with theme visible
- Flutter project creation (`flutter create little_library`)
- `pubspec.yaml` with all dependencies: drift, riverpod, google_mlkit_text_recognition, google_mlkit_barcode_scanning, googleapis, google_sign_in, image_picker, path_provider, share_plus, url_launcher, intl, uuid, speech_to_text
- `lib/core/theme.dart` — Material Design 3 theme from mockup CSS tokens (light + dark)
- `lib/core/constants.dart` — app strings, enum values, predefined genres/languages
- `lib/core/extensions.dart` — date formatting, string normalization, ISBN conversion utilities
- `lib/l10n/app_en.arb` — English strings (scaffold for future i18n)
- Font assets (Roboto)

### Workstream 0.2 — Data Model (drift Tables)
**Owner:** Subagent B | **Depends on:** 0.1 | **Testable by:** Running drift code generation + unit tests
- `lib/data/database/database.dart` — drift database class
- `lib/data/database/tables/` — all table definitions from spec-v2 Data Model:
  - `book_table.dart` — 21 fields, UUID primary key
  - `author_table.dart` — raw_name, normalized_name, disambiguation
  - `book_author_table.dart` — join table
  - `genre_table.dart` — name, is_custom
  - `book_genre_table.dart` — join table
  - `tag_table.dart`
  - `book_tag_table.dart`
  - `language_table.dart` — name, is_builtin
  - `book_loan_table.dart` — borrower_name, contact, dates, notes
  - `location_tables.dart` — Room, Cupboard, Shelf
  - `book_shelf_table.dart` — book-to-shelf assignment
  - `change_log_table.dart` — entity_type, entity_id, field_name, old/new values, timestamp, device_user, event_type
- All indices as per spec
- FTS5 virtual table for full-text search on title, isbn, publisher
- Database migrations (v1 schema)
- `build.yaml` for drift code generation

### Workstream 0.3 — Repository Interfaces & Contracts
**Owner:** Subagent C | **Depends on:** 0.2 | **Testable by:** Contract tests with mock implementations
- `lib/data/repositories/book_repository.dart` — CRUD + search + filter queries
- `lib/data/repositories/location_repository.dart` — hierarchical CRUD
- `lib/data/repositories/genre_repository.dart` — CRUD with built-in seed data
- `lib/data/repositories/tag_repository.dart` — CRUD
- `lib/data/repositories/language_repository.dart` — CRUD with built-in seed data
- `lib/data/repositories/loan_repository.dart` — CRUD + active loans query
- `lib/data/repositories/change_log_repository.dart` — append + query by timestamp
- All repositories expose Riverpod providers
- Seeded data: 20 predefined genres, 3 built-in languages

### Workstream 0.4 — Navigation Shell & Router
**Owner:** Subagent D | **Depends on:** 0.1 | **Testable by:** Navigating between placeholder screens
- `lib/app.dart` — MaterialApp with theme, router
- `lib/features/catalog/catalog_screen.dart` — placeholder with app bar + drawer
- Navigation drawer with all 9 items (Library, Locations, Recent Activity, Active Loans, Genres, Tags, Languages, Deleted Books, Settings)
- FAB speed dial (4 items, expand/collapse animation)
- Sync status bar component (green/amber/red states, hardcoded for now)
- GoRouter or Navigator 2.0 setup
- All route definitions (15+ routes)

**Phase 0 Integration Check:** All 4 subagents merge. App launches, shows themed catalog screen with working navigation drawer and empty catalog. Database tables created and verified. Repositories compile with generated drift code.

---

## Phase 1: Data & Sync Engine (Days 4–6)

**Goal:** Working database with all CRUD operations, Google Drive sync engine, Google Books API client.

### Workstream 1.1 — Database DAOs & Full CRUD
**Owner:** Subagent A | **Depends on:** Phase 0 | **Testable by:** Unit tests for all CRUD operations
- Implement all drift DAOs with typed queries
- Book CRUD with author/genre/tag/location join operations
- Location hierarchy CRUD with cascade (set books to None on delete)
- Genre/Tag/Language CRUD with built-in protection
- FTS5 search query (title, isbn, publisher) with trigram fallback for authors
- Filter queries: genre, language, location, status, format, condition, tags, date range
- Sort queries: title, author (multi-author duplicate rows), recently added, purchase date
- Pagination support (offset/limit)
- Soft delete queries (is_deleted filter)
- Duplicate detection queries (ISBN exact + Levenshtein fuzzy)
- Unit tests with in-memory SQLite

### Workstream 1.2 — Google Books API Client
**Owner:** Subagent B | **Depends on:** Phase 0 | **Testable by:** Mock API tests
- `lib/data/api/google_books_client.dart`
- Search by ISBN
- Search by title + author query
- Response parsing to Book model
- Multi-result handling (return list of matches)
- Local response cache (by ISBN, by title+author hash) — SQLite table or in-memory
- Quota tracking (count requests, detect 429 response)
- Custom API key support (from Settings)
- Unit tests with mocked HTTP responses

### Workstream 1.3 — Sync Engine
**Owner:** Subagent C | **Depends on:** 1.1 | **Testable by:** Sync unit tests with mock Drive
- `lib/data/sync/sync_engine.dart`
- Google Drive API client (`lib/data/api/google_drive_client.dart`):
  - Folder creation and discovery
  - File upload/download (catalog.db, change_log.db, version.txt)
  - Cover image upload/download (incremental — only new/changed)
  - Permissions management (share via email)
  - Folder existence check (404 → trigger recovery)
- Change log recording: every write operation also records to change_log table
- Pull logic: download remote change_log, identify new events, replay
- Push logic: optimistic locking (check version.txt), upload catalog.db, append change_log
- Merge logic: entity_type-aware field-level merge, conflict detection
- Snapshot creation (every 1000 events locally)
- Sync trigger: on app launch, after every save, pull-to-refresh
- Sync status Riverpod provider
- Unit tests with in-memory DB + mock Drive responses

### Workstream 1.4 — Google Sign-In & Auth
**Owner:** Subagent D | **Depends on:** Phase 0 | **Testable by:** Sign-in flow test
- `lib/data/auth/auth_service.dart`
- Google Sign-In integration
- Sign-in persistence (remember user)
- Sign-out
- Auth state Riverpod provider
- Google account display name retrieval
- Token refresh handling
- Skip sign-in flow (offline mode)

**Phase 1 Integration Check:** Books can be created, read, updated, soft-deleted via repositories. Google Books API returns results. Sync engine can push/pull to/from Drive mock. Auth works. Database searches return correct results.

---

## Phase 2: Core Screens (Days 7–11)

**Goal:** All primary user-facing screens implemented with real data. The app is usable for basic cataloging.

### Workstream 2.1 — Setup Wizard (F0)
**Owner:** Subagent A | **Depends on:** 1.4, 1.3 | **Mockup:** `setup-wizard.html`
- 3-step wizard: Sign-In → Connect Library → Sync & Go
- Google Sign-In button with skip link
- Link paste / QR scan for joining existing library
- Create new library + email sharing flow
- Progress indicator during sync
- Post-setup banner for skipped sign-in
- Delayed sign-in merge flow

### Workstream 2.2 — Catalog Screen (F5)
**Owner:** Subagent B | **Depends on:** 1.1 | **Mockup:** `catalog.html`
- App bar with drawer hamburger
- Sync status bar (connected to sync provider)
- Search bar with voice mic + ranking dropdown (3 modes)
- Filter chips (horizontal scrollable): Genre, Language, Location cascade, Status, Format, Condition, Tags, Purchase Date range, Show Deleted
- Sort dropdown: Title, Author, Recently Added, Purchase Date
- Grid/List toggle
- Book cards: cover thumbnail, title, author, status badge (priority logic), overdue indicator
- Multi-select mode (long-press): checkboxes, bottom bar with Delete/Change Location
- Empty states (no books, no search results, no filter results, no books on shelf)
- "None" location nudge banner
- "Checked Out by Me" quick-filter chip
- Pull-to-refresh triggers sync
- Lazy loading / pagination

### Workstream 2.3 — Book Detail Screen (F6)
**Owner:** Subagent C | **Depends on:** 1.1 | **Mockup:** `book-detail.html`
- Cover image full-width at top
- Status section with badge + context-sensitive action buttons
- Grouped info cards: Basic, Authors, Details, Classification, Location, Purchase, Notes
- Loan history list
- Bottom action bar: Edit, Share, Change History, Delete/Restore
- Deleted book variant: strikethrough title, muted cover, Restore button, "[Deleted]" loan labels
- Delete confirmation dialog
- Restore immediate action

### Workstream 2.4 — Add/Edit Book Form (F2) + Duplicate Detection (F7)
**Owner:** Subagent D | **Depends on:** 1.1, 1.2 | **Mockup:** `add-book.html`
- Scrollable sectioned form (Basic, Authors, Details, Classification, Location, Purchase, Cover, Notes)
- Author type-ahead with normalized dedup + disambiguation prompt
- Genre/Tag multi-select chips with inline "+ Add"
- Cascading location dropdowns (Room → Cupboard → Shelf), default "None"
- Date pickers (publication date, purchase date)
- Cover image picker (bottom sheet: camera/gallery/online)
- "Enrich Online" button + auto-enrich integration
- Multi-match display (horizontal cards) + per-field acceptance
- Duplicate check on save (ISBN + fuzzy title/author) with warning dialog
- Form validation (title required, ISBN format, date ranges)
- Edit mode (pre-fill from existing book)
- API quota exhausted state (disabled button)

**Phase 2 Integration Check:** User can complete setup wizard, browse catalog, view book details, add/edit books with enrichment. Duplicate detection works. Catalog filters and search are functional. This is the first "usable" milestone.

---

## Phase 3: Input Methods (Days 12–14)

**Goal:** Barcode scanning, photo OCR, and voice input. All flow into the Add Book form (2.4).

### Workstream 3.1 — Barcode Scanner (F3)
**Owner:** Subagent A | **Depends on:** 2.4, 1.2 | **Mockup:** `barcode-scanner.html`
- Camera viewfinder with ML Kit barcode detection
- Barcode overlay (corner brackets animation)
- Torch toggle
- On detection: ISBN lookup via Google Books API → pre-fill form (Screen 2.4)
- Offline: pre-fill ISBN only
- "Not an ISBN" handling → manual entry fallback
- Camera permission handling (rationale → settings)
- "Enter ISBN manually" text link

### Workstream 3.2 — Photo OCR (F4)
**Owner:** Subagent B | **Depends on:** 2.4, 1.2 | **Mockup:** `photo-ocr.html`
- Camera/gallery picker (bottom sheet)
- ML Kit text recognition (Latin script)
- Processing overlay: "Scanning text…"
- Result: photo with highlighted text regions (bounding boxes)
- Extracted text as tappable chips → assign to Title/Author
- Online: Google Books search with extracted text → pre-fill form
- Offline: manual assignment → pre-fill form
- Crop/rotate editor before OCR
- No text detected fallback
- Non-English fallback (Phase 1)

### Workstream 3.3 — Voice Input + LLM (F11)
**Owner:** Subagent C | **Depends on:** 2.4 | **Mockup:** `voice-input.html`
- Microphone UI: pulsing waveform animation
- Platform STT integration (speech_to_text package)
- Live transcription display
- LLM extraction pipeline:
  - Tier 1: on-device (Gemini Nano / MediaPipe) — scaffold/placeholder for Phase 1
  - Tier 2: cloud (Gemini API / OpenAI) with structured prompt
  - Tier 3: regex keyword fallback
- Extracted fields → pre-fill form (Screen 2.4)
- Processing state indicators (tier level shown)
- Error states: no speech, extraction failed, mic permission denied

**Phase 3 Integration Check:** All three input methods work end-to-end: scan barcode → pre-fill form, photo OCR → pre-fill form, voice input → pre-fill form. Each flows into the shared Add Book screen with enrichment available.

---

## Phase 4: Library Management (Days 15–17)

**Goal:** Location hierarchy, book lending, and management screens.

### Workstream 4.1 — Location Management (F1)
**Owner:** Subagent A | **Depends on:** 1.1 | **Mockup:** `locations.html`
- Nested expandable list (Room → Cupboard → Shelf)
- Per-shelf book count display
- FAB context-aware (add Room/Cupboard/Shelf based on selection)
- Swipe-to-delete with cascade warning
- Delete confirmation with book count
- "Assign Books" from shelf → book picker with checkboxes
- Bulk location assignment (P2-F3 alternate flow from catalog multi-select)

### Workstream 4.2 — Lending & Status Tracking (F12)
**Owner:** Subagent B | **Depends on:** 1.1 | **Mockup:** `checkout-loan.html`
- Checkout bottom sheet: family member dropdown + custom name
- Loan form: borrower name, contact, dates, notes
- Status transition validation (Available-only guard)
- Return dialog (3 options): previous shelf / new shelf / no location
- Overdue indicator on cards + catalog banner
- "Active Loans" drawer screen with Checked Out / Loaned sections
- Loan constraint enforcement (one active loan per book)
- Loan history on book detail

### Workstream 4.3 — Management Screens (F9, F10, F14)
**Owner:** Subagent C | **Depends on:** 1.1 | **Mockup:** `management.html`
- Unified management pattern for Genres, Tags, Languages
- List with visibility toggle
- Built-in items: lock icon, non-deletable
- Custom items: swipe-to-delete, edit
- FAB to add new
- Add/edit dialog
- Delete confirmation with usage count
- Seed 20 predefined genres + 3 built-in languages

**Phase 4 Integration Check:** Locations can be created, edited, deleted. Books can be checked out, loaned, returned. Overdue tracking works. Genres, tags, and languages can be managed.

---

## Phase 5: Activity & Administration (Days 18–20)

**Goal:** Activity feed, sync management, settings, export, sharing. App is feature-complete.

### Workstream 5.1 — Recent Activity Feed (F13)
**Owner:** Subagent A | **Depends on:** 1.3 (change log) | **Mockup:** `recent-activity.html`
- Chronological feed from change log
- Filter tabs: All, Added, Edited, Checked Out, Loaned, Returned
- Natural language event descriptions
- User avatars/initials, book thumbnails, relative timestamps
- Tap → Book Detail
- Pull-to-refresh, infinite scroll (paginated, 50 per page)
- Empty state

### Workstream 5.2 — Conflict Resolver + Sync Management (F8)
**Owner:** Subagent B | **Depends on:** 1.3 | **Mockup:** `conflict-resolver.html`
- Conflict resolver screen: per-conflict cards with both versions
- Inline editable field + tappable remote version chip
- Skip / Keep Mine / Keep Theirs / Custom value actions
- Remaining count indicator
- "All resolved" completion
- Sync status screen in Settings: last sync, pending count, manual sync button

### Workstream 5.3 — Settings, Export, Sharing
**Owner:** Subagent C | **Depends on:** 1.3, 1.4 | **Mockups:** `settings.html`, `export.html`, `share-library.html`
- Settings screen with all sections: Account, Sync, Sharing, Preferences, Data, About
- Account: email + display name, sign out
- Preferences: auto-enrich toggle, API key field, default sort
- Export dialog: JSON / CSV / Text format selector → share sheet
- Share Library screen: link copy, QR code display, email invitation
- About: version, rate link, privacy link

### Workstream 5.4 — Deleted Books & Edge Case Polish
**Owner:** Subagent D | **Depends on:** 1.1 | **Mockup:** `deleted-books.html`
- Deleted books screen: catalog variant with deleted filter
- Strikethrough/greyed-out card appearance
- Restore from detail
- Force Update blocking screen
- Change History screen (per-book event timeline)
- All empty states, error states, loading states across all screens
- Accessibility pass: semantic labels, sufficient contrast, tap targets ≥ 48dp
- Final integration testing

**Phase 5 Integration Check:** Full app is feature-complete. All 16 Phase 1 features work. Sync, sharing, export, settings all functional. Ready for testing.

---

## Phase 6: Phase 2 Features — Advanced (Days 21–25)

**Goal:** Bulk shelf scanner, Devanagari OCR, bulk location assignment. These build on stable Phase 1 foundations.

### Workstream 6.1 — Bulk Shelf Scanner (P2-F1)
**Owner:** Subagent A | **Depends on:** 3.2 (Photo OCR), 1.2 (Google Books), 2.4 (Add Book form) | **Mockup:** `bulk-scanner.html`
- **Capture Step:** Camera viewfinder with shelf guide overlay, gallery picker
- **Processing Step:** Spine detection visualization (numbered bounding boxes appearing progressively), progress bar with stage indicators ("Detecting book spines…" → "Reading spine N of M…" → "Matching titles online…"), cancel button
- **Adjustment Step:** Interactive bounding boxes with resize handles (8-point), long-press drag to reposition, merge tool (draw rectangle to combine boxes), split tool (tap to divide), delete box (false positive removal), reset to original ML detection, undo snackbars for all operations, "Done Adjusting" → advance
- **Results Step:** Cropped spine thumbnails, suggested titles with confidence badges (high/medium/low), Accept/Edit/Skip per book, "Fetch All" batch enrichment button, accepted counter ("5 of 12 accepted"), skip confirmation with undo snackbar
- **Review Step:** Accepted books flow into Add Book form (Screen 2.4) for final review with duplicate check, "Enrich Online" available per-book
- **FAB:** 5th Speed Dial item "Scan Shelf" added to catalog FAB
- **Offline:** OCR text only (no Google Books matching), offline banner shown
- **Performance:** 20–30 books processed in 5–15 seconds
- **Technical:** Custom TFLite model or ML Kit object detection for spine detection; horizontal vs vertical stacking handled via text orientation

### Workstream 6.2 — Devanagari OCR (P2-F2)
**Owner:** Subagent B | **Depends on:** 3.2 (Photo OCR screen) | **Mockup:** `photo-ocr.html`
- Enable ML Kit Devanagari text recognition model
- Script auto-detection per text block (Latin vs Devanagari)
- UI additions to existing Photo OCR screen:
  - Script badge per text block (`[A]` Latin / `[द]` Devanagari / `[?]` unknown)
  - Color-coded bounding boxes (blue = Latin, orange = Devanagari)
  - Script legend below photo
  - Language auto-suggest chip ("Detected: Hindi script — set language to Hindi?")
  - Mixed-script processing indicator ("Scanning text… (Latin + Devanagari)")
- Google Books API queries include language hint for better Devanagari results
- Apply to both single-book OCR (F4) and bulk shelf scanner (P2-F1)

### Workstream 6.3 — Bulk Location Assignment (P2-F3)
**Owner:** Subagent C | **Depends on:** 4.1 (Locations), 2.2 (Catalog multi-select) | **Mockup:** `locations.html`
- **From Shelf:** Shelf row expands to show actions → "Assign Books" opens book picker overlay
- **Book Picker:** Search bar + filter chips (Genre, Language, Status), scrollable book list with checkboxes, cover thumbnail + title + author per row, current location badge shown, "Already here" indicator for books on this shelf, pre-selected state
- **Selection Counter:** Sticky bottom bar showing "X books selected" + "Assign to [Shelf Name]" button (disabled when 0)
- **Confirmation Dialog:** "Move X books to [Shelf Name]? Y books will be moved from other locations. Z books currently have no location." [Cancel] [Assign]
- **Post-Assign:** Success snackbar "X books assigned to [Shelf Name]. [View]"
- **Alternate Flow:** Catalog multi-select → "Change Location" → pick target shelf (reuses same picker)

**Phase 6 Integration Check:** All 3 Phase 2 features work. Bulk scanner detects spines, adjusts, enriches. Devanagari OCR handles mixed scripts. Bulk location assignment works from both shelf and catalog. App is fully complete with all 19 features (16 Phase 1 + 3 Phase 2).

---

## Dependency Graph

```
Phase 0 (Foundation)
├── 0.1 Project Scaffold & Theme ─────────────────────────────┐
├── 0.2 Data Model (drift Tables) ───┐                        │
├── 0.3 Repository Interfaces ───────┤                        │
└── 0.4 Navigation Shell ────────────┼────────────────────────┘
                                      │
Phase 1 (Data & Sync)                 │
├── 1.1 Database DAOs ◄──────────────┤
├── 1.2 Google Books API ◄───────────┤
├── 1.3 Sync Engine ◄────────────────┤
└── 1.4 Google Sign-In ◄─────────────┘
                    │
Phase 2 (Core Screens)
├── 2.1 Setup Wizard ◄── 1.4, 1.3
├── 2.2 Catalog ◄──────── 1.1
├── 2.3 Book Detail ◄───── 1.1
└── 2.4 Add/Edit + Dup ◄── 1.1, 1.2
         │
Phase 3 (Input Methods)
├── 3.1 Barcode ◄── 2.4, 1.2
├── 3.2 Photo OCR ◄─ 2.4, 1.2
└── 3.3 Voice ◄───── 2.4
         │
Phase 4 (Library Management)
├── 4.1 Locations ◄── 1.1
├── 4.2 Lending ◄──── 1.1
└── 4.3 Management ◄── 1.1
         │
Phase 5 (Activity & Admin)
├── 5.1 Recent Activity ◄── 1.3
├── 5.2 Conflict Resolver ◄─ 1.3
├── 5.3 Settings/Export ◄─── 1.3, 1.4
└── 5.4 Deleted Books ◄───── 1.1
         │
Phase 6 (Advanced — Phase 2 Features)
├── 6.1 Bulk Scanner ◄── 3.2, 1.2, 2.4
├── 6.2 Devanagari OCR ◄─ 3.2
└── 6.3 Bulk Location ◄── 4.1, 2.2
```

---

## Parallel Subagent Assignment Map

### Phase 0 — All 4 agents run in parallel after kickoff
| Agent | Workstream | Files to create |
|-------|-----------|-----------------|
| A | 0.1 Theme + Scaffold | `pubspec.yaml`, `lib/core/`, `lib/l10n/`, `lib/main.dart` |
| B | 0.2 Data Model | `lib/data/database/` (all tables, indices, FTS) |
| C | 0.3 Repositories | `lib/data/repositories/` (6+ repository files) |
| D | 0.4 Navigation | `lib/app.dart`, `lib/features/*/` placeholder screens, router |

### Phase 1 — All 4 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 1.1 DAOs | `lib/data/database/dao/` (all DAO implementations) |
| B | 1.2 Books API | `lib/data/api/google_books_client.dart` |
| C | 1.3 Sync | `lib/data/sync/`, `lib/data/api/google_drive_client.dart` |
| D | 1.4 Auth | `lib/data/auth/` |

### Phase 2 — All 4 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 2.1 Setup | `lib/features/setup/` |
| B | 2.2 Catalog | `lib/features/catalog/` |
| C | 2.3 Book Detail | `lib/features/book_detail/` |
| D | 2.4 Add Book | `lib/features/add_book/` |

### Phase 3 — All 3 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 3.1 Barcode | `lib/features/scanner/barcode/` |
| B | 3.2 OCR | `lib/features/scanner/ocr/` |
| C | 3.3 Voice | `lib/features/voice_input/` |

### Phase 4 — All 3 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 4.1 Locations | `lib/features/locations/` |
| B | 4.2 Lending | `lib/features/lending/` |
| C | 4.3 Management | `lib/features/genres/`, `lib/features/settings/management/` |

### Phase 5 — All 4 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 5.1 Activity | `lib/features/activity/` |
| B | 5.2 Conflicts | `lib/features/sync_ui/` |
| C | 5.3 Settings | `lib/features/settings/` |
| D | 5.4 Polish | `lib/features/deleted/`, `lib/features/change_history/`, all error/empty/loading states |

### Phase 6 — All 3 agents run in parallel
| Agent | Workstream | Files |
|-------|-----------|-------|
| A | 6.1 Bulk Scanner | `lib/features/bulk_scan/`, FAB update |
| B | 6.2 Devanagari OCR | `lib/features/scanner/ocr/` (enhancement), ML Kit Devanagari model config |
| C | 6.3 Bulk Location | `lib/features/locations/` (enhancement), `lib/features/catalog/` (multi-select enhancement) |

---

## Shared Contracts (Must be agreed before Phase 0 ends)

### Riverpod Providers (all agents reference these)
```dart
// Database
final databaseProvider = Provider<AppDatabase>((ref) => ...);
// Repositories
final bookRepoProvider = Provider<BookRepository>((ref) => ...);
final locationRepoProvider = Provider<LocationRepository>((ref) => ...);
// etc.
// Auth
final authStateProvider = StateProvider<AuthState>((ref) => ...);
// Sync
final syncStateProvider = StateProvider<SyncState>((ref) => ...);
```

### Model Classes (generated by drift — all agents use typed drift classes)
```dart
// All models are drift DataClass types from 0.2
Book, Author, Genre, Tag, Language, BookLoan, Room, Cupboard, Shelf, ChangeLogEvent
```

### Route Names (defined in 0.4 — all agents use these)
```dart
'/catalog', '/book/:id', '/book/add', '/book/edit/:id',
'/scanner/barcode', '/scanner/ocr', '/voice-input',
'/locations', '/checkout/:bookId', '/loan/:bookId',
'/conflicts', '/activity', '/settings',
'/settings/genres', '/settings/tags', '/settings/languages',
'/deleted', '/active-loans', '/export',
'/share-library', '/change-history/:bookId',
'/setup', '/force-update',
'/bulk-scanner'
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Sync engine complexity delays Phase 1 | Build sync engine with comprehensive unit tests using in-memory mocks before integrating Drive |
| ML Kit models not available on all devices | Graceful fallback to manual entry for all OCR/barcode features |
| Google Books API quota exhaustion | Implement cache from day 1, custom API key support from day 1 |
| Drift code generation issues | Pin drift version, run build_runner early in Phase 0 to validate |
| Merge conflicts between parallel agents | Each agent works in isolated feature folders; shared code in `core/` and `data/` is contract-first |
| UI inconsistency across agents | Theme in `core/theme.dart` is the single source of truth; all agents use Material 3 widgets only |
| Spine detection accuracy (P2-F1) | Spine adjustment UI allows manual correction; falls back to manual entry if detection fails entirely |
| Devanagari OCR performance (P2-F2) | On-device model may be slower; show per-block progress and allow mixed-script fallback |

---

## Success Criteria (from spec-v2)

1. ✅ Scan a book in a bookstore → know if owned within 10 seconds
2. ✅ 2000+ books with responsive search
3. ✅ Changes on one device appear on another on next app launch
4. ✅ Duplicate detection catches ≥ 95% of genuine duplicates
5. ✅ Manual entry under 2 minutes
6. ✅ Voice entry under 30 seconds
7. ✅ No data loss — queued changes, reversible deletions
8. ✅ Bulk scan a shelf of 20-30 books in under 15 seconds (Phase 2)
9. ✅ OCR handles both Latin and Devanagari scripts with auto-detection (Phase 2)
10. ✅ Assign dozens of books to a new shelf in one operation (Phase 2)
