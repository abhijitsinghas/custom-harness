# The Little Library — UI Specification

> Generated from `docs/spec-v2.md`. This document contains only UI/UX-relevant information organized by screens, flows, components, and states. Use this to generate design mocks.

---

## App Identity

- **Name:** The Little Library
- **Platform:** Android (Flutter)
- **UI Language:** English
- **Design System:** Material Design 3
- **Theme:** Warm, book-friendly — think library browns, cream, with accent colors for status indicators

---

## Navigation Architecture

**Pattern:** Single-screen with navigation drawer (hamburger menu).

**Main Screen:** Catalog (browse/search books) — the default landing screen.

**Navigation Drawer Items:**

| # | Label | Icon | Destination |
|---|-------|------|-------------|
| 1 | Library | 📚 | Catalog — default |
| 2 | Locations | 📍 | Room → Cupboard → Shelf management |
| 3 | Recent Activity | ⏱️ | Family activity timeline |
| 4 | Active Loans | 📖 | Currently loaned/checked-out books |
| 5 | Genres | 🏷️ | Genre management |
| 6 | Tags | # | Tag management |
| 7 | Languages | 🌐 | Language management |
| 8 | Deleted Books | 🗑️ | View/restore soft-deleted books |
| 9 | Settings | ⚙️ | Sync, Account, Auto-enrich, Share, Export, About |

**FAB (Floating Action Button):** Material Speed Dial on catalog screen.
- Default state: Blue '+' FAB (bottom-right)
- Expanded: Morphs to '✕', 4 labeled mini-FABs fan out upward:
  1. 🎤 Voice Input
  2. 📷 Scan Cover
  3. 📱 Scan Barcode
  4. ✏️ Add Manually
- (Phase 2 adds 5th: 📚 Scan Shelf)

---

## Screen Inventory

### 1. Setup Wizard (3 steps)
### 2. Catalog (Main Screen)
### 3. Book Detail
### 4. Add/Edit Book Form
### 5. Barcode Scanner
### 6. Photo OCR Screen
### 7. Voice Input Screen
### 8. Location Management
### 9. Checkout / Loan Forms
### 10. Conflict Resolver
### 11. Recent Activity Feed
### 12. Management Screens (Genres, Tags, Languages)
### 13. Deleted Books
### 14. Active Loans
### 15. Settings
### 16. Export Dialog
### 17. Share Library Screen
### 18. Bulk Shelf Scanner (Phase 2)
### 19. Change History
### 20. Force Update (Blocking)

---

## Screen Specifications

---

### Screen 1: Setup Wizard (First-Run)

**Purpose:** Onboard a new family member in under 2 minutes.

#### Step 1 — Welcome & Sign-In
- App logo centered at top
- "Welcome to The Little Library" heading
- Brief subtitle: "Catalog your family's books. Never buy a duplicate again."
- **Primary button:** "Sign in with Google" (Google-branded button)
- **Text link:** "Skip for now" (allows offline-only usage)
- Edge: Sign-in failure → inline error with retry button

#### Step 2 — Connect to Shared Library
- Heading: "Connect to your family library"
- **Option A card:** "I have a link or QR code" → paste link field / scan QR button
- **Option B card:** "Create a new library" → creates Drive folder
- After creating: "Share with family?" prompt → email input field + "Send Invites" button
- Edge: Invalid link → "This link doesn't work. Ask a family member for a new one."

#### Step 3 — Sync & Go
- Progress indicator: "Downloading catalog…"
- Completion: "Synced 847 books, 12 locations" with checkmark
- **Primary button:** "Start Browsing" → navigates to Catalog

#### Post-Setup Banner (if skipped sign-in)
- Persistent amber banner below app bar: "Sign in to sync with family" with "Sign In" button

---

### Screen 2: Catalog (Main Screen)

**Purpose:** Browse, search, and filter all books. Default landing screen.

#### Layout
- **Top:** App bar with hamburger menu icon + app title "The Little Library"
- **Sync Status Bar:** Thin colored bar below app bar (green/amber/red — see Status Bar component)
- **Search Bar:** Below status bar. Includes:
  - Text input field
  - Microphone icon (voice search)
  - Dropdown for search ranking mode (Relevance / Recency / Alphabetical)
- **Filter Chips:** Horizontal scrollable row of chips below search:
  - Genre (multi-select)
  - Language (single-select dropdown)
  - Location (cascading: Room → Cupboard → Shelf)
  - Status (multi-select: Available, Checked Out, Loaned)
  - Format (Hardcover, Paperback, Other)
  - Condition (New, Like New, Used, Worn, Damaged)
  - Tags (multi-select)
  - Purchase Date (date range picker)
  - Show/Hide Deleted toggle
- **Sort Dropdown:** Title / Author / Recently Added / Purchase Date
- **View Toggle:** Grid icon / List icon

#### Book Grid/List
- **Grid (default):** 2 or 3 columns of book cards
- **List:** Single column with larger thumbnails
- Each card shows:
  - Cover thumbnail (placeholder if no cover: book spine icon)
  - Title (bold, 2 lines max)
  - Primary author (subtitle)
  - **Status Badge (overrides location):**
    - Available → location badge (e.g., "Study / Shelf 2") or "No location" (muted)
    - Checked Out → "With Mom" (blue badge)
    - Loaned → "Loaned to Arjun" (amber badge)
    - Overdue → red "Overdue — due Jan 5" indicator
  - Tap → navigates to Book Detail
  - Long-press → multi-select mode

#### Multi-Select Mode (long-press)
- Checkboxes appear on cards
- Bottom bar: "X selected" + actions: Delete, Change Location
- Tap away to exit multi-select

#### Empty States
- **No books at all:** Large illustration + "Your library is empty. Add your first book!" + 3 quick-action buttons: Scan Barcode, Scan Cover, Add Manually
- **Search no results:** "No books match '[query]'. Try different keywords."
- **Filter no results:** "No books match these filters. Try adjusting."

- **No books on a shelf:** "This shelf is empty. Add books or assign existing ones."

#### "None" Location Nudge
- If books exist with no location: amber banner "N books need a shelf — tap to assign"
- Tapping navigates to filtered catalog showing only unplaced books

- **"Checked Out by Me" quick-filter:** A tappable chip/pill shown below the search bar when user is signed in. Filters to books where checked_out_to matches the Google display name.

#### Voice Search
- Tapping mic icon → microphone listening UI (pulsing waveform)
- Speech transcribed → fills search bar
- "Listening…" / "Speak now" states

---

### Screen 3: Book Detail

**Purpose:** View complete book information, manage status, edit, delete.

#### Layout (Scrollable)
1. **Cover Image:** Full-width at top (placeholder if missing)
2. **Status Section:**
   - Status badge (large): "Available" (green) / "Checked Out by Mom" (blue) / "Loaned to Arjun" (amber)
   - Action buttons (context-sensitive):
     - Available → "Check Out" + "Loan to Someone"
     - Checked Out → "Return to Shelf"
     - Loaned → "Mark Returned"
     - Deleted → "Restore"
3. **Book Info Sections (grouped cards):**
   - **Basic:** Title, ISBN, Language, Format
   - **Authors:** List of author names
   - **Details:** Publisher, Edition, Publication Date, Pages, Description
   - **Classification:** Genre chips, Tag chips
   - **Location:** Room → Cupboard → Shelf path
   - **Purchase:** Date, Price, Condition
   - **Notes:** Free text
4. **Loan History:** List of past loans with borrower, dates, status
5. **Action Bar (bottom):**
   - Edit button (pen icon)
   - Share button (share icon)
   - Change History button (clock icon)
   - Delete button (trash icon) — or "Restore" for deleted books

- **Deleted Book Detail Variant:** When viewing a deleted book, the detail screen shows:
  - Strikethrough on title
  - Greyed-out/muted cover image
  - No "Check Out" or "Loan" buttons
  - No Edit button
  - "Restore" button (primary action)
  - Loan history retains entries with "[Deleted]" label if book was deleted while on loan

#### Dialogs
- **Delete confirmation:** "Delete [Book Title]? It will be hidden but can be restored later." [Cancel] [Delete]
- **Restore:** Immediate action — no confirmation (undo via snackbar)

---

### Screen 4: Add/Edit Book Form

**Purpose:** Enter book details manually. Same form used for add (F2), edit (F6), and as the review screen after barcode/OCR/voice.

#### Layout (Scrollable, Sectioned)

**Section: Basic Info**
- Title* (text field, required indicator)
- ISBN (text field, auto-formats; shows ISBN-13 after conversion)
- Language* (dropdown from language list)
- Format (segmented buttons: Hardcover | Paperback | Other)

**Section: Authors**
- List of added authors with remove (✕) button each
- "Add Author" button → type-ahead search existing OR create new
- If new author matches existing normalized name: "An author named 'John Smith' already exists. Is this the same person?" [Yes] [No — different person] → if no, disambiguation field appears

**Section: Details**
- Publisher (text)
- Edition (text)
- Publication Date (date picker — supports year-only or full date)
- Page Count (number input)
- Description (multiline text)

**Section: Classification**
- Genres: multi-select chips, scrollable. "+ Add" chip at end → inline dialog to create new genre
- Tags: multi-select chips with type-ahead. "+ Add [new tag]" chip

**Section: Location**
- Cascading dropdowns: Room → Cupboard → Shelf
- Default: "None" (shown as muted placeholder)

**Section: Purchase**
- Purchase Date (date picker)
- Price Paid (number input with currency hint)
- Condition (segmented buttons: New | Like New | Used | Worn | Damaged)

**Section: Cover Image**
- Current cover display (or placeholder with camera icon)
- Tap → bottom sheet: "Take Photo" | "Choose from Gallery" | "Search Online"

**Section: Notes**
- Multiline text field

#### Enrichment UI (visible in all add flows)
- **"Enrich Online" button:** Always visible in the form header/toolbar
  - Tapping while online: "Searching Google Books…" with skeleton cards
  - Results: horizontal scrollable card list (cover + title + author + year per card)
  - Selecting a card → fields populate with checkmarks per field
  - User can accept/reject individual fields
  - Can select different match for different fields
- **Auto-Enrich (if enabled in Settings):** When user pauses typing title, auto-triggers lookup. Results appear as subtle suggestions below fields.
- **Quota exhausted:** "Enrich Online" button disabled with subtitle: "Google Books daily limit reached. Enrichment will resume tomorrow." (If custom API key configured, button remains enabled.) Auto-enrich silently pauses when quota is exhausted.
- **Post-setup merge (delayed sign-in):** Progress overlay: "Merging your local catalog with the family library…" → if conflicts → Conflict Resolver (Screen 10) → "Merge complete. X books synced, Y conflicts resolved."

#### Bottom Actions
- [Cancel] [Save]
- On Save → duplicate check → if duplicate found, warning dialog: "This may be a duplicate of [Book] by [Author]. Add anyway?" [Cancel] [Add Anyway]

#### Validation
- Title required → red outline + "Title is required"
- ISBN format → "Enter a valid 10 or 13 digit ISBN"
- Publication year → "Enter a year between 1000 and [current year]"

---

### Screen 5: Barcode Scanner

**Purpose:** Scan a book's barcode/ISBN.

#### Layout
- Full-screen camera viewfinder
- Barcode detection overlay (corner brackets animation)
- Torch toggle button (top-right)
- "Enter ISBN manually" text link (bottom)
- Camera permission denied → rationale dialog → "Open Settings" button

#### Flow
1. Scan detects barcode → haptic feedback + beep
2. Online: "Looking up book…" loading → pre-filled form (Screen 4)
3. Offline: Pre-fills ISBN only → form
4. Barcode not ISBN: "Not a recognized ISBN" → option to enter manually

---

### Screen 6: Photo OCR Screen

**Purpose:** Take/select photo of book cover, extract text via OCR.

#### Layout
- **Capture step:** Camera viewfinder or gallery picker (bottom sheet: "Take Photo" | "Choose from Gallery")
- **Processing:** Full-screen photo with progress overlay: "Scanning text…"
- **Result step:**
  - Photo displayed with detected text regions highlighted (bounding boxes)
  - Below photo: extracted text blocks as tappable chips
  - User taps chip → assigns to "Title" or "Author" field
  - **Online:** "Searching Google Books…" → match suggestions → pre-fill form
  - **Offline:** Manual assignment → pre-fill form
- **Review:** Screen 4 (Add Book Form) with Enrich Online button

#### Edge Cases
- No text detected: "No text found. Try a clearer photo or enter manually." [Take New Photo] [Enter Manually]
- Cluttered cover: "Crop & Rotate" button before OCR — opens basic image editor with crop handles (drag corners), rotate 90° buttons, "Done" / "Cancel"
- Non-English text (Phase 1): Falls back to manual entry

---

### Screen 7: Voice Input Screen

**Purpose:** Speak book details; LLM extracts structured data.

#### Layout
- Large microphone button (center) with pulsing waveform animation
- "Listening…" status text
- Live transcription text below: words appear as spoken
- "Done" button to stop recording
- "Cancel" to go back

#### Processing States
1. **Listening:** Waveform animation, transcription streaming
2. **Processing:** "Extracting book details…" with LLM tier indicator:
   - "Using on-device AI" (Tier 1)
   - "Using cloud AI" (Tier 2)
   - "Extracting keywords" (Tier 3)
3. **Result:** Pre-filled form (Screen 4) with Enrich Online button

#### Edge Cases
- Microphone permission denied → rationale → Settings
- No speech detected: "I didn't catch that. Try again?" [Retry] [Enter Manually]
- LLM extraction fails: "Couldn't extract book details. Try speaking more clearly or enter manually." [Retry] [Enter Manually]

---

### Screen 8: Location Management

**Purpose:** Manage Room → Cupboard → Shelf hierarchy.

#### Layout
- Nested expandable list
- Level 1: Rooms (expandable)
  - Level 2: Cupboards (expandable)
    - Level 3: Shelves (leaf nodes)
- Each shelf shows book count: "Shelf 2 (23 books)"
- **FAB:** "+" to add Room (when at root), Cupboard (when room expanded), Shelf (when cupboard expanded)
- Swipe-to-delete with confirmation

#### Delete Confirmation
- Room: "Delete 'Study'? 3 cupboards and X books will have their location set to None." [Cancel] [Delete]
- Cupboard: "Delete 'Main Bookshelf'? 4 shelves and X books will have their location set to None." [Cancel] [Delete]
- Shelf: "Delete 'Shelf 2'? 23 books will have their location set to None." [Cancel] [Delete]

#### "Assign Books" (from a shelf)
- Tapping a shelf → "Assign Books" action
- Opens book picker with checkboxes, search, filter
- Shows current location badge per book
- Bottom bar: "Assign X books to [Shelf Name]" [Assign]

---

### Screen 9: Checkout & Loan Forms

#### Internal Checkout
- From Book Detail (Available) → tap "Check Out"
- **Bottom sheet:**
  - "Who has this book?"
  - Dropdown: list of family members (from synced Google accounts) + "Someone else…" custom input
  - [Cancel] [Check Out]
- Result: status changes to "Checked Out by [Name]"

#### External Loan
- From Book Detail (Available) → tap "Loan to Someone"
- **Full-screen form:**
  - Borrower Name* (required)
  - Borrower Contact (phone/email, optional)
  - Loaned Date* (date picker, defaults to today)
  - Due Date (date picker, optional)
  - Notes (multiline)
  - [Cancel] [Loan Book]
- Validation: "This book is currently checked out by [Person]. Return it first."

#### Return Flow
- From Book Detail (Checked Out / Loaned) → tap "Return to Shelf" / "Mark Returned"
- **Dialog with 3 options:**
  1. "Return to [Previous Shelf]" — keeps location
  2. "Return to a different shelf" — opens location picker
  3. "Return without location" — sets location to None

---

### Screen 10: Conflict Resolver

**Purpose:** Resolve sync conflicts (same field edited on two devices).

#### Layout
- Header: "Resolve Conflicts (3 remaining)"
- Per-conflict card:
  - Book cover thumbnail + title
  - Conflicting field highlighted in amber
  - Version A: "[Person] changed [Field] to [Value] — [time]"
  - Version B: "You changed [Field] to [Value] — [time]"
  - Editable text field pre-filled with local version
  - Remote version as a tappable chip to quickly adopt
- Navigation: [Skip] [Keep Mine] [Keep Theirs] or edit custom value
- After all resolved: "All conflicts resolved" → dismiss

---

### Screen 11: Recent Activity Feed

**Purpose:** Timeline of family's library activity.

#### Layout
- Filter tabs/chips: All | Added | Edited | Checked Out | Loaned | Returned
- Chronological feed (newest first):
  - User avatar/initial (from Google account)
  - Natural language action:
    - "Mom added **The Alchemist** by Paulo Coelho"
    - "Dad checked out **Sapiens**"
    - "You loaned **The Hobbit** to Arjun"
  - Book cover thumbnail
  - Relative timestamp: "2 hours ago", "Yesterday"
- Tap → Book Detail
- Pull-to-refresh
- Infinite scroll (load 50 at a time)

#### Empty State
- "No activity yet. Start adding books to build your library!"

---

### Screen 12: Management Screens

**Genres / Tags / Languages** — identical pattern:

- List of items with toggle (visible/hidden)
- Built-in items: show lock icon, cannot delete
- Custom items: swipe-to-delete or edit
- **FAB:** "+" to add new
- Add dialog: name text field + [Cancel] [Add]
- Delete confirmation (if in use): "X books use this genre/tag/language."

---

### Screen 13: Deleted Books

**Purpose:** View and restore soft-deleted books.

#### Layout
- Same as Catalog but shows only deleted books
- Cards have strikethrough/greyed-out appearance
- Tapping → Book Detail with "Restore" button instead of status actions
- Empty: "No deleted books."

---

### Screen 14: Active Loans

**Purpose:** View all currently checked-out and loaned books.

#### Layout
- Two sections or tabs: "Checked Out" | "Loaned"
- Book cards with status badges
- Overdue books sorted to top with red indicator
- Tap → Book Detail
- Empty: "No books are currently checked out or loaned. Everything is on the shelf!"

---

### Screen 15: Settings

#### Sections

**Account**
- Signed in as: [email] + display name (e.g., "priya@gmail.com (Priya Sharma)")
- "Not signed in — Sign In" button (if skipped)
- Sign Out button

**Sync**
- Last sync timestamp
- Sync status indicator
- "Sync Now" button
- Pending changes count
- "Resolve Conflicts" (shows count, hidden if 0)

**Library Sharing**
- "Share Library" → opens Share Library screen
- Three sharing methods listed with icons

**Preferences**
- "Auto-enrich from web" toggle (default: off)
- "Google Books API Key" text field (for power users)
- "Default sort order" dropdown

**Data**
- "Export Catalog" → opens Export dialog (Screen 16)
- "Manage Genres" → Screen 12
- "Manage Tags" → Screen 12
- "Manage Languages" → Screen 12

**About**
- App version
- "Rate the app" link
- "Privacy Policy" link
- Credits

---

### Screen 16: Export Dialog

**Purpose:** Export catalog in various formats.

#### Layout (Bottom Sheet or Dialog)
- "Export your catalog"
- Format selector (radio buttons):
  - JSON (full data, machine-readable)
  - CSV (spreadsheet-friendly, opens in Excel/Sheets)
  - Share as Text (human-readable list for messaging)
- "Cover images are not included."
- [Cancel] [Export]
- After export: system share sheet opens

---

### Screen 17: Share Library Screen

**Purpose:** Share the Google Drive library folder with family.

#### Layout
- "Share The Little Library"
- **Tab/option 1 — Share Link:** "Copy link" button → copies Drive folder link
- **Tab/option 2 — QR Code:** Generated QR code image (full-width), scannable by other devices
- **Tab/option 3 — Email:** Input field(s) for email addresses + "Send Invites" button
  - Success: "Invitations sent! [emails] will receive a Google Drive notification."
  - Error: "Couldn't share with [email]. Check the address."

---

### Screen 18: Bulk Shelf Scanner (Phase 2)

**Purpose:** Take one photo of a bookshelf, detect individual books, extract titles.

#### Capture Step
- Camera viewfinder (or gallery picker via bottom sheet: "Take Photo" | "Choose from Gallery")
- Guide overlay: "Position the shelf within the frame. Ensure spines are visible."
- Capture button

#### Processing Step
- Full-screen photo with progress: "Detecting books…"
- Results overlay: detected spine regions highlighted with numbered bounding boxes
- User can adjust boxes (resize handles, drag to reposition)
- "Merge" mode: user can draw a rectangle to merge two incorrectly split regions
- Progress: "Reading 12 spines… 8 of 12 complete"

#### Results Step (Scrollable List)
- Per-book card showing:
  - Cropped spine thumbnail
  - Suggested title (from OCR + online matching, or raw OCR text offline)
  - Confidence indicator (high/medium/low)
  - Action buttons: **[✓ Accept]** **[✏ Edit]** **[⏭ Skip]**
- **"Fetch All" button** at top of list: batch-enriches all accepted books via Google Books API
- **Accepted books counter:** "5 of 12 accepted"

#### Review Step
- Accepted books proceed to the Add Book form (Screen 4) for final review
- Each book opens individually with pre-filled data
- Duplicate check runs per book
- "Enrich Online" available per-book (same as Screen 4)

#### Processing States
- Online: OCR → Google Books match → pre-fill
- Offline: OCR → raw text → manual confirmation
- Performance indicator: "Processing 20–30 books takes 5–15 seconds"

---

### Screen 19: Change History

**Purpose:** View the edit history of a single book (who changed what, when).

#### Layout
- Header: "Change History — [Book Title]"
- Chronological list (newest first):
  - User avatar/initial
  - Natural language description:
    - "Mom changed Title from 'The Alchemist' to 'The Alchemist (25th Anniversary Edition)'"
    - "You changed Location from None to Study / Shelf 2"
    - "Dad changed Status from Available to Checked Out (to Dad)"
  - Relative timestamp
- Empty: "No changes recorded yet."

---

### Screen 20: Force Update (Blocking)

**Purpose:** Block app usage when the remote catalog has been updated by a newer app version.

#### Layout (Full-Screen, Non-Dismissable)
- App logo centered
- Heading: "Update Required"
- Message: "This library has been updated by another device. Please update The Little Library to continue."
- **Primary button:** "Update" → opens Google Play Store listing
- Subtitle: "Your data is safe and will sync after the update."
- No back button, no navigation — this screen blocks all access

---

## Shared Components

### Sync Status Bar
- Height: ~4px thin bar below app bar, or 32px bar with text
- **Green:** "Synced just now" — all good
- **Amber:** "Offline — 3 changes pending" — queued
- **Red:** Specific error + action (e.g., "Drive storage full — free up space")
- Persistent, visible on all screens

### Status Badge (on Book Cards)
- **Available:** Neutral/grey chip showing location or "No location"
- **Checked Out:** Blue chip — "With [Name]"
- **Loaned:** Amber/orange chip — "Loaned to [Name]"
- **Overdue:** Red indicator text — "Overdue — due [date]"

### Cover Image
- Aspect ratio: ~3:4 (book cover proportions)
- Placeholder: Book spine illustration with title overlay when no cover
- Rounded corners (8dp)
- Drop shadow (2dp elevation)

### Empty State
- Illustration or large icon centered
- Friendly message
- 1-3 quick-action buttons below

### Permission Dialog
- Rationale text explaining why permission is needed
- [Deny] [Allow]
- On second denial: "Go to Settings to enable [permission]." [Open Settings] [Cancel]

### Loading States
- Skeleton cards for lists (pulsing grey rectangles matching card layout)
- "Searching Google Books…" indicator with skeleton result cards for enrichment
- Progress bar for sync/export operations

### Error States
- Inline error messages (red text below fields)
- Snackbar for transient errors (swipe to dismiss)
- Full-screen error with retry for critical failures (sync, Drive access)

---

## Color Palette (Suggested)

| Token | Use | Suggested |
|-------|-----|-----------|
| Primary | App bar, FAB, buttons, links | Deep teal (#00695C) or warm brown (#5D4037) |
| Secondary | Accents, selected states | Amber (#FFA000) |
| Surface | Cards, sheets, dialogs | Off-white (#FFF8F0) or cream |
| Background | Screen background | Warm grey (#FAFAF5) |
| Status-Available | Available badge | Green (#4CAF50) |
| Status-CheckedOut | Checked Out badge | Blue (#2196F3) |
| Status-Loaned | Loaned badge | Amber (#FF9800) |
| Status-Overdue | Overdue indicator | Red (#F44336) |
| Sync-Green | Sync success | Green (#4CAF50) |
| Sync-Amber | Sync pending | Amber (#FFC107) |
| Sync-Red | Sync error | Red (#F44336) |

---

## Typography

- **Headlines:** Roboto (or system default) — Regular
- **Body:** Roboto — Regular
- **Book Titles:** Medium weight, 16sp
- **Author Names:** Regular weight, 14sp
- **Badges/Chips:** Medium weight, 12sp
- **Section Headers:** Medium weight, 14sp, all-caps with letter spacing

---

## Screen Transition Map

```
Setup Wizard (F0)
    │
    ▼
Catalog (F5) ◄── Navigation Drawer
    │                ├── Locations (F1)
    │                ├── Recent Activity (F13)
    │                ├── Active Loans
    │                ├── Genres (F9)
    │                ├── Tags (F10)
    │                ├── Languages (F14)
    │                ├── Deleted Books
    │                └── Settings
    │                     ├── Export Catalog (F15)
    │                     ├── Share Library
    │                     └── Post-Setup Merge (delayed sign-in)
    │
    ├── Book Detail (F6)
    │       ├── Edit → Add/Edit Form (F2)
    │       ├── Check Out → Checkout Sheet
    │       ├── Loan → Loan Form
    │       ├── Return → Return Dialog
    │       └── Change History (Screen 19)
    │
    └── FAB Speed Dial
            ├── Voice Input (F11) → Add/Edit Form
            ├── Scan Cover (F4) → Add/Edit Form
            ├── Scan Barcode (F3) → Add/Edit Form
            ├── Add Manually (F2) → Add/Edit Form
            └── Scan Shelf (P2-F1) → Bulk Shelf Scanner (Phase 2)

Force Update (Screen 20) — blocks all navigation
```

---

## Key Interactions

1. **Pull-to-refresh:** Catalog, Recent Activity — triggers sync
2. **Swipe-to-delete:** Location items, Tags, Genres, Languages
3. **Long-press:** Catalog book cards → multi-select mode
4. **Tap:** Standard navigation
5. **Speed Dial:** FAB expand/collapse animation
6. **Type-ahead:** Author search, Tag search
7. **Cascading dropdowns:** Room → Cupboard → Shelf picker
8. **Voice:** Microphone listening with waveform animation
9. **Scan:** Camera viewfinder with barcode overlay and OCR highlight boxes
