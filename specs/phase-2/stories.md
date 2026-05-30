# User Stories — Phase 2: Core Screens

> **Scope:** Setup Wizard (F0), Catalog Screen (F5), Book Detail Screen (F6), Add/Edit Book Form (F2) + Duplicate Detection (F7).
> **Mockup refs:** `setup-wizard.html`, `catalog.html`, `book-detail.html`, `add-book.html`.
> **Pipeline:** FAST_BUILD (2.1, 2.2, 2.3, 2.4 UI) + LIGHT TDD (2.4 duplicate logic).

---

# Workstream 2.1 — Setup Wizard (F0)

## Happy Path

### US-1: Complete 3-step setup wizard with Google Sign-In
**As a** new family member  
**I want to** sign in with Google, connect to my family's library, and sync  
**So that** I can start browsing the shared catalog immediately.

**Given** I launch the app for the first time  
**When** I tap "Sign in with Google" on `setup-wizard.html` Step 1 (the button with Google logo), complete OAuth, then choose "I have a link or QR code" on Step 2, paste a valid invite link, and tap "Join Library"  
**Then** Step 3 shows a progress bar with stage messages ("Downloading catalog…", "Organizing shelves…", "Fetching covers…"), completes with a green checkmark, synced stats (e.g., "Synced 847 books, 12 locations"), and a "Start Browsing" button that navigates to `/catalog`.

### US-2: Skip sign-in during setup and browse offline
**As a** user who wants to try the app before signing in  
**I want to** skip Google Sign-In during setup  
**So that** I can use the app offline and sign in later.

**Given** I am on Step 1 of `setup-wizard.html`  
**When** I tap the "Skip for now" link below the Google Sign-In button  
**Then** I advance to Step 2, can create a local library, complete Step 3 with 0 books, and land on the catalog. A persistent banner appears on the catalog: "Sign in to sync with family" with a Settings link.

### US-3: Create a new library and invite family by email
**As a** first user setting up the shared library  
**I want to** create a new Drive folder and invite family members  
**So that** others can join and collaborate.

**Given** I am on Step 2 of `setup-wizard.html` and signed in  
**When** I select the "Create a new library" card (with subtitle "Start fresh and invite your family later"), tap "Create Library", then enter email addresses in the "Share with family?" card's input field, and tap "Send Invites"  
**Then** the app calls `permissions.create` for each email, advances to Step 3 sync, and completes the wizard.

### US-4: Join an existing library via pasted invite link
**As a** new family member with an invite link  
**I want to** paste the link to join the shared library  
**So that** I can sync existing data.

**Given** I am on Step 2 of `setup-wizard.html`  
**When** I select the "I have a link or QR code" card, paste `https://littlelibrary.app/join/family-abc123` into the link input field, and tap "Join Library"  
**Then** the link validates, the wizard advances to Step 3, and sync begins.

### US-5: Join an existing library via QR code scan
**As a** new family member with a QR code  
**I want to** scan the QR code to join  
**So that** I don't have to type a long link.

**Given** I am on Step 2 and have selected the "I have a link or QR code" card  
**When** I tap the QR scan button (the square icon button to the right of the link input field) and scan a valid QR code  
**Then** the link input is auto-populated with the decoded URL, and tapping "Join Library" proceeds to sync.

## Edge Cases

### US-6: Skip family invites during library creation
**As a** user creating a new library who wants to invite later  
**I want to** skip the email invitation step  
**So that** I can start using the app immediately.

**Given** I have selected "Create a new library" and tapped "Create Library"  
**When** the "Share with family?" card appears and I tap "Skip for now"  
**Then** the wizard advances to Step 3 sync without sending any invites.

### US-7: Invalid invite link format
**As a** user who pastes a broken link  
**I want to** see a clear error  
**So that** I know the link is invalid.

**Given** I have selected "I have a link or QR code"  
**When** I paste "not-a-valid-link" into the link input and tap "Join Library"  
**Then** the error text below the input field becomes visible: "This link doesn't work. Ask a family member for a new one."

### US-8: Delayed sign-in from Settings merges local data
**As a** user who skipped sign-in initially  
**I want to** sign in later and merge my local books  
**So that** my data is preserved and synced.

**Given** I have a local catalog with books added while signed out  
**When** I go to Settings → Account → "Sign in with Google" and complete sign-in  
**Then** the sync engine performs a merge: local books are pushed, remote books are pulled, and conflict resolution is offered if any fields clash.

## Error States

### US-9: Google Sign-In failure
**As a** user whose sign-in fails  
**I want to** see why and retry  
**So that** I'm not stuck.

**Given** I am on Step 1  
**When** I tap "Sign in with Google" but the OAuth flow fails (network error, user cancellation, or Play Services issue)  
**Then** the error message below the button becomes visible (e.g., "Sign-in failed. Please try again."), and the button remains tappable for retry.

### US-10: Drive connection failure during sync
**As a** user joining an existing library  
**I want to** know if the Drive folder is unreachable  
**So that** I can troubleshoot.

**Given** I tapped "Join Library" with a valid link  
**When** the Google Drive API returns a 404 or permission denied on the `/The Little Library/` folder  
**Then** Step 3 shows a red error state: "Could not connect to the shared library. The link may have expired. Ask for a new one." with a "Try Again" button.

### US-11: No internet during setup
**As a** user with no connectivity  
**I want to** still complete setup and use the app offline  
**So that** I'm not blocked.

**Given** the device has no internet connection  
**When** I tap "Join Library" or "Create Library"  
**Then** Step 3 shows an amber offline indicator: "Offline — your library will sync when you're back online." The wizard completes, and the catalog opens with a persistent offline sync status bar.

### US-12: Large library sync shows detailed progress
**As a** user joining a family with 1000+ books  
**I want to** see meaningful progress during a long sync  
**So that** I know the app hasn't frozen.

**Given** I am syncing a remote library with 500+ books for the first time  
**When** Step 3 runs  
**Then** the progress bar advances smoothly, stage messages update ("Downloading catalog…", "Organizing shelves…", "Fetching covers…"), and a book count ("Synced 312 of 847 books") appears. If >100 books, the "Organizing shelves…" stage persists for >2 seconds.

## Empty States

### US-13: New library with zero books
**As a** user creating a brand new library  
**I want to** see a welcoming empty catalog  
**So that** I know how to add my first book.

**Given** I completed setup with "Create a new library" and skipped invites  
**When** I land on the catalog  
**Then** the empty state from `catalog.html` is visible: "Your library is empty" with three quick-action buttons — "Add Manually", "Scan Barcode", "Scan Cover".

## Accessibility

### US-14: Screen reader announces wizard steps
**As a** screen reader user  
**I want to** know which step I'm on  
**So that** I understand the flow.

**Given** TalkBack is enabled  
**When** I advance from Step 1 to Step 2  
**Then** the step dot indicator is announced: "Step 2 of 3, Connect to your family library."

### US-15: Semantic labels on all interactive elements
**As a** screen reader user  
**I want to** understand every tappable element  
**So that** I can navigate independently.

**Given** TalkBack is enabled on `setup-wizard.html`  
**When** I explore Step 1  
**Then** the Google Sign-In button is labeled "Sign in with Google", the "Skip for now" link is labeled "Skip sign-in for now", and the app logo is labeled "The Little Library app icon".

### US-16: Progress announcements during sync
**As a** user with a visual impairment  
**I want to** hear sync progress updates  
**So that** I know when the app is ready.

**Given** TalkBack is enabled and I am on Step 3 syncing  
**When** the progress bar advances past 25%, 50%, 75%  
**Then** each milestone is announced (e.g., "Syncing library, 50 percent complete."), and upon completion TalkBack announces: "Sync complete. 847 books synced. Start Browsing button."

---

# Workstream 2.2 — Catalog Screen (F5)

## Happy Path

### US-17: Browse catalog in grid view
**As a** user  
**I want to** see my books as a grid of cover thumbnails  
**So that** I can visually scan my collection.

**Given** the catalog has books and the grid view toggle is active (`catalog.html`, toolbar right side, grid icon at 100% opacity)  
**When** I open the catalog  
**Then** books render in a 2-column grid with cover thumbnails at 3:4 aspect ratio, title (2-line clamp), primary author, and status badge.

### US-18: Toggle between grid and list view
**As a** user  
**I want to** switch between grid and list layouts  
**So that** I can choose my preferred browsing mode.

**Given** I am on the catalog in grid view (`catalog.html`, toolbar right side)  
**When** I tap the list view icon (opacity 0.5 when inactive)  
**Then** the view animates to a list layout: horizontal cards with a 56×74dp cover thumbnail on the left, title/author on the right, and the list icon becomes fully opaque while the grid icon dims.

### US-19: Search books by title or author
**As a** user looking for a specific book  
**I want to** type in the search bar  
**So that** matching books appear instantly.

**Given** I am on `catalog.html` with 100+ books  
**When** I tap the search bar (rounded field with magnifying glass icon), type "Sapiens"  
**Then** the grid updates to show only books whose title, author, ISBN, publisher, or tags match, within <300ms. The voice mic icon and ranking dropdown remain visible.

### US-20: Voice search via microphone icon
**As a** user who prefers speaking  
**I want to** search by voice  
**So that** I don't have to type.

**Given** I am on `catalog.html`  
**When** I tap the microphone icon inside the search bar (right side, 32dp icon button)  
**Then** the platform STT dialog opens, I speak "books by Harari", and the search bar text is populated with the transcript, triggering a search.

### US-21: Apply filter chips
**As a** user browsing a large library  
**I want to** filter by genre, language, location, status, format, condition, tags, purchase date, or deleted state  
**So that** I can narrow results.

**Given** I am on `catalog.html` with the horizontal chips row visible  
**When** I tap the "Genre ▾" chip, select "Fiction", then tap "Status ▾" and select "Available"  
**Then** both chips show an active state (background changes to primary-container color), and the grid only shows available fiction books. The chips row remains horizontally scrollable.

### US-22: Sort catalog by different criteria
**As a** user  
**I want to** change the sort order  
**So that** I can find books alphabetically, by author, recency, or purchase date.

**Given** I am on `catalog.html`  
**When** I tap the sort dropdown in the toolbar (left side, labeled "Title" by default) and select "Recently Added"  
**Then** the grid re-sorts with the most recently created books first, and the dropdown label updates.

### US-23: Author sort duplicates multi-author books under each author
**As a** user sorting by author  
**I want to** see multi-author books listed under every author  
**So that** I find the book regardless of which author I look under.

**Given** "Good Omens" has authors Neil Gaiman and Terry Pratchett  
**When** I sort by Author  
**Then** the book appears once under "G" (Gaiman) and once under "P" (Pratchett). In all other sort modes, it appears exactly once.

### US-24: Tap a book card to open detail
**As a** user browsing the catalog  
**I want to** tap a book to see its full details  
**So that** I can view or edit it.

**Given** I am on `catalog.html` in grid view  
**When** I tap a book card (cover + title area)  
**Then** the app navigates to `/book/:id` (Book Detail screen, `book-detail.html`).

### US-25: Long-press to enter multi-select mode
**As a** user managing many books  
**I want to** select multiple books at once  
**So that** I can perform bulk actions.

**Given** I am on `catalog.html`  
**When** I long-press (500ms) a book card  
**Then** multi-select mode activates: all cards show circular checkbox overlays (top-left corner), the tapped card becomes checked, the FAB disappears, and a bottom bar rises with "N selected" and "Delete" / "Change Location" actions.

### US-26: Multi-select delete and change location
**As a** user in multi-select mode  
**I want to** delete or move the selected books  
**So that** I can manage my catalog efficiently.

**Given** I have 3 books selected (checkboxes checked, bottom bar showing "3 selected")  
**When** I tap "Delete" in the bottom bar  
**Then** a confirmation dialog appears; on confirm, all 3 books are soft-deleted. If I tap "Change Location", a location picker opens and all selected books are reassigned.

### US-27: Pull-to-refresh triggers sync
**As a** user  
**I want to** manually refresh/sync the catalog  
**So that** I get the latest data from the family library.

**Given** I am on `catalog.html` and the catalog is synced  
**When** I pull down on the book grid/list  
**Then** a refresh indicator appears, the sync engine triggers a pull, and the sync status bar updates.

### US-28: "None" location nudge banner
**As a** user with unplaced books  
**I want to** be reminded to assign shelves  
**So that** my physical library stays organized.

**Given** 12 books have `shelf_id = null`  
**When** I open `catalog.html`  
**Then** an amber banner appears below the toolbar: "12 books need a shelf — tap to assign" with an "Assign" button. Tapping the banner or button filters the catalog to show only unplaced books.

### US-29: "Checked Out by Me" quick-filter
**As a** user looking for books I checked out  
**I want to** quickly filter to my checked-out books  
**So that** I can see what I'm reading.

**Given** I am signed in with display name "Priya Sharma" and some books have `checked_out_to = "Priya Sharma"`  
**When** I tap the "Checked Out by Me" quick-filter chip  
**Then** the catalog filters to show only books checked out to me, and the chip shows an active state.

### US-30: Status badge priority on book cards
**As a** user scanning the catalog  
**I want to** see the most important status first  
**So that** I instantly know where a book is.

**Given** books with various statuses exist  
**When** I view the catalog  
**Then** each card's badge follows this priority:
1. Checked Out → blue badge "With [Name]"
2. Loaned → amber badge "Loaned to [Borrower]"
3. Available with location → location badge (e.g., "Study / Shelf 2")
4. Available with no location → muted "No location"
5. Overdue → red "Overdue — due [date]"

## Edge Cases

### US-31: Multi-select with zero selected exits mode
**As a** user in multi-select mode  
**I want to** exit by deselecting all  
**So that** I can cancel without action.

**Given** I am in multi-select mode with 1 book selected  
**When** I tap the checked checkbox to deselect it (now 0 selected)  
**Then** the multi-select bottom bar dismisses, the FAB reappears, and checkbox overlays hide.

### US-32: Multi-select across scrollable catalog
**As a** user selecting books across pages  
**I want to** scroll while keeping selections  
**So that** I can select books not currently visible.

**Given** I am in multi-select mode with 2 books selected, and I scroll down to load more books  
**When** I long-press another book below the fold  
**Then** it becomes selected (checked), the selection count updates, and previously selected books remain checked.

### US-33: Search with special characters and empty query
**As a** user searching  
**I want to** handle edge inputs gracefully  
**So that** the app doesn't crash.

**Given** I am on `catalog.html`  
**When** I type "'"; DROP TABLE" (SQL injection attempt) or "  " (only spaces)  
**Then** the search treats it as a literal string or empty query, returns no results safely, and shows the empty search state without errors.

### US-34: Clear all active filters
**As a** user with multiple filters applied  
**I want to** clear them all at once  
**So that** I can start fresh.

**Given** Genre and Status chips are active  
**When** I tap an "X" or "Clear all" action (if provided) or deselect each chip  
**Then** all chips return to inactive state and the full catalog is shown.

### US-35: Lazy loading with exactly page-boundary counts
**As a** user with a large library  
**I want to** scroll smoothly  
**So that** performance stays fast.

**Given** the catalog has exactly 50 books (a common page boundary)  
**When** I scroll to the bottom  
**Then** the 50th book renders, no extra blank row appears, and a loading indicator only shows if more pages exist.

## Error States

### US-36: Sync status bar shows green/amber/red states
**As a** user  
**I want to** know the sync state at a glance  
**So that** I understand if my data is current.

**Given** I am on `catalog.html`  
**When** the sync state changes  
**Then** the thin sync bar below the app bar updates:
- Green: "Synced just now"
- Amber: "Offline — 3 changes pending"
- Red: specific error (e.g., "Drive storage full — free up space")

### US-37: Offline search and browse still work
**As a** user without internet  
**I want to** still search and browse  
**So that** the app is fully usable offline.

**Given** the device is offline  
**When** I open the catalog, search, apply filters, and sort  
**Then** all operations work locally with drift queries. The sync bar shows amber. Online-dependent features (e.g., cover fetch from URL) show cached data or placeholders.

### US-38: Sync error with actionable message
**As a** user when sync fails  
**I want to** understand why and what to do  
**So that** I can fix it.

**Given** a push fails because `version.txt` mismatched and retry also fails  
**When** the catalog shows the red sync bar  
**Then** it displays a tappable message: "Sync failed — tap to retry" or "Drive storage full — free up space" with a link to drive.google.com where applicable.

## Empty States

### US-39: First launch empty catalog with quick actions
**As a** first-time user with no books  
**I want to** see helpful actions  
**So that** I know how to populate my library.

**Given** the catalog has 0 books  
**When** I land on `catalog.html`  
**Then** the empty state from the mockup is centered: icon, "Your library is empty", "Add your first book to get started.", with three buttons: "Add Manually" (primary), "Scan Barcode", "Scan Cover".

### US-40: No search results
**As a** user whose search finds nothing  
**I want to** know and be guided  
**So that** I can adjust my query.

**Given** I search for "xyznonexistent"  
**When** no books match  
**Then** the empty state shows: "No books match your search" with subtext "Try different keywords or adjust your filters."

### US-41: No filter results
**As a** user with an overly restrictive filter  
**I want to** see a contextual message  
**So that** I know why nothing appears.

**Given** I filter Genre = "Cooking" and Location = "Bedroom / Nightstand" but no books match both  
**When** the grid updates  
**Then** the empty state shows: "No books on this shelf" (or "No books match the selected filters") with a "Clear Filters" action.

### US-42: No deleted books with Show Deleted active
**As a** user viewing deleted books  
**I want to** know when there are none  
**So that** I'm not confused.

**Given** no books have `is_deleted = true`  
**When** I activate the "Show Deleted" filter chip  
**Then** the catalog shows: "No deleted books."

## Accessibility

### US-43: Hamburger drawer menu labeled
**As a** screen reader user  
**I want to** know what the menu button does  
**So that** I can navigate.

**Given** TalkBack is enabled on `catalog.html`  
**When** I focus the hamburger icon (top-left of app bar)  
**Then** it announces "Open navigation menu" and double-tap opens the drawer with all 9 items labeled.

### US-44: Book cards have semantic labels
**As a** screen reader user browsing the catalog  
**I want to** hear book title, author, and status  
**So that** I can choose without seeing.

**Given** TalkBack is enabled and I swipe through the grid  
**When** I focus a book card  
**Then** it announces: "The Alchemist, by Paulo Coelho, Available on Study Shelf 2, double-tap to view details."

### US-45: Filter chips accessible
**As a** screen reader user  
**I want to** know which filters are active  
**So that** I understand the current view.

**Given** TalkBack is enabled  
**When** I focus the "Genre ▾" chip  
**Then** it announces "Filter by Genre, collapsed" or if active: "Filter by Genre, Fiction selected, double-tap to change."

### US-46: Multi-select mode announced
**As a** screen reader user  
**I want to** know when multi-select mode activates  
**So that** I can select books.

**Given** TalkBack is enabled  
**When** I long-press a book card  
**Then** TalkBack announces "Multi-select mode activated. 1 book selected." When I tap additional cards, it announces the updated count.

### US-47: Touch targets meet minimum size
**As a** user with motor impairments  
**I want to** tap elements easily  
**So that** I don't mis-tap.

**Given** I am on `catalog.html`  
**When** I inspect the FAB (56dp), filter chips (32dp height + adequate padding), icon buttons (40dp), and book cards  
**Then** all interactive elements are ≥48dp in at least one dimension, per Material Design accessibility guidelines.

## Loading States

### US-48: Initial catalog load shimmer
**As a** user opening the app  
**I want to** see that data is loading  
**So that** I know the app is working.

**Given** the catalog screen opens and drift query is still executing  
**When** the first frame renders  
**Then** skeleton cards (shimmer placeholders matching the grid layout) appear until the first page of books loads.

### US-49: Pagination loading indicator
**As a** user scrolling a large library  
**I want to** know more books are loading  
**So that** I don't think I've reached the end.

**Given** I scroll near the bottom of a 2000-book catalog  
**When** the next page is fetching  
**Then** a circular progress indicator appears at the bottom of the list/grid and disappears when the next batch renders.

---

# Workstream 2.3 — Book Detail Screen (F6)

## Happy Path

### US-50: View full book details with all info cards
**As a** user  
**I want to** see all book information in one place  
**So that** I can review the complete record.

**Given** I navigated to a book detail from the catalog  
**When** `book-detail.html` opens  
**Then** I see the cover hero, status section, and grouped info cards: Basic (title, ISBN, language, format), Authors, Details (publisher, edition, published, pages, description), Classification (genre chips + tag chips), Location (room/cupboard/shelf), Purchase (date, price, condition), Notes, and Loan History.

### US-51: Cover image hero display
**As a** user  
**I want to** see the book cover prominently  
**So that** I can identify the book visually.

**Given** the book has a `cover_image_path` or `cover_image_url`  
**When** `book-detail.html` renders  
**Then** the cover displays full-width at the top, maintaining aspect ratio, with max height capped at 320dp. If the image is loading, a placeholder with the book icon appears.

### US-52: Context-sensitive status actions
**As a** user managing a book's availability  
**I want to** see relevant action buttons based on status  
**So that** I can change status quickly.

**Given** I am on `book-detail.html`  
**When** the book status is:
- "Available" → I see "Check Out" (primary) and "Loan to Someone" (secondary) buttons.
- "Checked Out" → I see "Return to Shelf" button.
- "Loaned" → I see "Returned" button.

### US-53: View loan history
**As a** user tracking who has borrowed a book  
**I want to** see past loans  
**So that** I have a complete record.

**Given** a book has past `BookLoan` records  
**When** I scroll to the "Loan History" info card  
**Then** I see a vertical list of loan items: avatar circle with borrower initial, borrower name, and meta line (e.g., "Checked out · Jan 5 – Feb 12, 2023" or "Loaned · Aug 1 – Sep 15, 2023 · Returned").

### US-54: Edit book navigates to pre-filled form
**As a** user correcting a book's details  
**I want to** edit any field  
**So that** the record stays accurate.

**Given** I am on `book-detail.html`  
**When** I tap "Edit" in the bottom action bar  
**Then** the app navigates to `/book/edit/:id` (`add-book.html` in edit mode) with all 21 fields pre-filled from the existing book.

### US-55: Share book via system share sheet
**As a** user telling someone about a book  
**I want to** share the book details  
**So that** I can send it via messaging apps.

**Given** I am on `book-detail.html`  
**When** I tap "Share" in the bottom action bar  
**Then** the system share sheet opens with a text summary: "The Alchemist by Paulo Coelho (Paperback) — Available on Study / Shelf 2".

### US-56: View per-book change history
**As a** user curious about edits  
**I want to** see who changed what and when  
**So that** I can audit the record.

**Given** I am on `book-detail.html`  
**When** I tap "History" in the bottom action bar  
**Then** the app navigates to `/change-history/:bookId` showing a timeline of all `ChangeLogEvent` records for this book with human-readable descriptions.

### US-57: Soft-delete a book with confirmation
**As a** user removing a book from the active catalog  
**I want to** delete it with confirmation  
**So that** I don't accidentally lose data.

**Given** I am on `book-detail.html` for a non-deleted book  
**When** I tap "Delete" in the bottom action bar  
**Then** a confirmation dialog opens: "[Title] will be hidden but can be restored later from Deleted Books." with "Cancel" and "Delete" actions. On confirm, the book is soft-deleted (`is_deleted = true`), a change log event is recorded, and I return to the catalog.

### US-58: Restore a deleted book to exact previous state
**As a** user who accidentally deleted a book  
**I want to** restore it  
**So that** the record comes back exactly as it was.

**Given** I am viewing a deleted book (from the Deleted Books screen or via direct navigation)  
**When** I tap "Restore" (replacing Delete in the bottom action bar)  
**Then** the book's `is_deleted` becomes false, its status, location, `checked_out_to`, and loan records remain intact, and it reappears in the catalog.

## Edge Cases

### US-59: Book with no cover shows placeholder
**As a** user viewing a book without a cover image  
**I want to** see a clean placeholder  
**So that** the UI doesn't look broken.

**Given** a book has no `cover_image_path` and no `cover_image_url`  
**When** `book-detail.html` renders  
**Then** the cover hero shows the default book icon (from mockup CSS: `filter: grayscale(0.7) opacity(0.6)` for deleted; plain placeholder for non-deleted).

### US-60: Deleted book variant appearance
**As a** user viewing a deleted book  
**I want to** clearly see it's deleted  
**So that** I don't confuse it with active books.

**Given** a book has `is_deleted = true`  
**When** `book-detail.html` renders  
**Then** the cover image has `filter: grayscale(0.7) opacity(0.6)`, the title has a strikethrough decoration, the overall appearance is muted, and a "[Deleted]" label appears in the status section.

### US-61: Book with no location displays "None"
**As a** user viewing an unplaced book  
**I want to** see that it has no location  
**So that** I know to assign it.

**Given** a book has `shelf_id = null`  
**When** I view the Location info card  
**Then** all three rows (Room, Cupboard, Shelf) show "None" or "—".

### US-62: Book with multiple authors lists all
**As a** user viewing a multi-author book  
**I want to** see every author  
**So that** the record is complete.

**Given** a book is linked to 3 authors via `BookAuthor` join table  
**When** I view the Authors info card  
**Then** all 3 names are listed, each on its own row.

### US-63: Book with no ISBN still shows detail
**As a** user viewing an old book without an ISBN  
**I want to** see all other fields  
**So that** the record is useful.

**Given** a book has `isbn = null`  
**When** I view the Basic info card  
**Then** the ISBN row shows "—" or is hidden, and all other fields display normally.

### US-64: Deleted book with active loan preserves loan record
**As a** user  
**I want to** keep loan history even for deleted books  
**So that** I don't lose tracking data.

**Given** a book has an active `BookLoan` (not returned) and I soft-delete it  
**When** I view the deleted book's detail  
**Then** the Loan History still shows the active loan, and the Active Loans screen continues to list it until returned.

## Error States

### US-65: Cover image fails to load
**As a** user when a remote cover is unreachable  
**I want to** see a fallback  
**So that** the UI isn't broken.

**Given** a book has a `cover_image_url` but the network is offline or the URL is dead  
**When** `book-detail.html` attempts to load the image  
**Then** the placeholder book icon appears after the image load fails, with no crash or infinite spinner.

### US-66: Share sheet fails gracefully
**As a** user when sharing fails  
**I want to** see a message  
**So that** I know what happened.

**Given** I tap "Share" but no share-capable apps are installed or the system sheet crashes  
**When** the share intent fails  
**Then** a snackbar appears: "Unable to share. Please try again."

## Empty States

### US-67: No loan history
**As a** user viewing a never-loaned book  
**I want to** see a clear empty state  
**So that** I know there's no history.

**Given** a book has zero `BookLoan` records  
**When** I scroll to the Loan History card  
**Then** it shows: "No loan history. This book has never been checked out or loaned."

### US-68: No notes
**As a** user viewing a book with no notes  
**I want to** see a prompt or empty state  
**So that** I know I can add notes.

**Given** a book has `notes = null` or empty string  
**When** I scroll to the Notes card  
**Then** it shows a subtle placeholder: "No notes yet. Tap Edit to add some."

### US-69: No genres or tags
**As a** user viewing an unclassified book  
**I want to** see that classification is empty  
**So that** I know to add genres/tags.

**Given** a book has no `BookGenre` or `BookTag` associations  
**When** I scroll to the Classification card  
**Then** the Genres row shows "None" and the Tags row shows "None".

## Accessibility

### US-70: Cover image semantic label
**As a** screen reader user  
**I want to** know what the cover represents  
**So that** I understand the page context.

**Given** TalkBack is enabled on `book-detail.html`  
**When** I focus the cover hero image  
**Then** it announces: "Cover image for [Title] by [Primary Author]."

### US-71: Status badge and actions labeled
**As a** screen reader user  
**I want to** hear the book status and available actions  
**So that** I can interact correctly.

**Given** TalkBack is enabled  
**When** I focus the status badge  
**Then** it announces: "Status: Available on Study Shelf 2." When I focus the "Check Out" button, it announces: "Check Out, button."

### US-72: Bottom action bar labels
**As a** screen reader user  
**I want to** understand the bottom actions  
**So that** I can edit, share, view history, or delete.

**Given** TalkBack is enabled  
**When** I explore the bottom action bar (`book-detail.html`, 4 icon buttons: Edit, Share, History, Delete)  
**Then** each button is labeled with its action name and announces its icon description.

### US-73: Delete confirmation focus management
**As a** screen reader user  
**I want to** be guided through the delete dialog  
**So that** I don't accidentally confirm.

**Given** TalkBack is enabled and I tapped "Delete"  
**When** the confirmation dialog appears  
**Then** focus moves to the dialog title, and the "Cancel" button is the default action. TalkBack reads the full warning message.

---

# Workstream 2.4 — Add/Edit Book Form (F2) + Duplicate Detection (F7)

## Happy Path

### US-74: Add a new book with all sections
**As a** user cataloging a new book  
**I want to** fill all fields across sections  
**So that** the record is complete.

**Given** I navigated to `/book/add` (`add-book.html`)  
**When** I fill Basic Info (title "The Alchemist", ISBN, language English, format Paperback), add author "Paulo Coelho", fill Details (publisher, edition, publication date 1988, page count 208, description), select Genres "Fiction" and "Philosophy", add Tags "#classic" and "#spiritual", set Location to Study → Main Bookshelf → Shelf 2, set Purchase (date Mar 15 2022, price $12.99, condition Like New), pick a cover image, add notes, and tap "Save"  
**Then** the book is inserted into drift, a `create` change log event is recorded, sync push triggers, and the catalog shows the new book.

### US-75: Edit an existing book with pre-filled form
**As a** user correcting a book record  
**I want to** see existing values pre-filled  
**So that** I only change what needs fixing.

**Given** I navigated to `/book/edit/:id` from Book Detail  
**When** `add-book.html` opens in edit mode  
**Then** all fields match the existing book: title in title input, ISBN in ISBN input, authors listed in the Authors section, genres as active chips, location dropdowns set to current values, cover preview showing existing image, and the app bar title reads "Edit Book".

### US-76: Author type-ahead selects existing author
**As a** user adding a book by a known author  
**I want to** pick the existing author quickly  
**So that** I avoid duplicates.

**Given** "Paulo Coelho" already exists in `author_table` with `normalized_name = "paulocoelho"`  
**When** I tap "+ Add Author", type "Paulo" in the author input  
**Then** a dropdown appears with matching existing authors. Tapping "Paulo Coelho" adds him to the authors list without creating a new row.

### US-77: Author type-ahead creates new author with disambiguation
**As a** user adding a book by an author with a shared name  
**I want to** distinguish between two people with the same name  
**So that** the catalog stays accurate.

**Given** "John Smith" already exists (historian, b.1965)  
**When** I type "John Smith" as a new author  
**Then** a disambiguation prompt appears: "An author named 'John Smith' already exists. Is this the same person?" If I tap "No, this is a different person", I must enter a `disambiguation` note (e.g., "novelist, b.1972"); the new author's `normalized_name` becomes `"johnsmith_novelistb1972"`.

### US-78: Genre/Tag multi-select with inline "+ Add"
**As a** user classifying a book  
**I want to** select multiple genres/tags and create new ones inline  
**So that** classification is flexible.

**Given** I am in the Classification section of `add-book.html`  
**When** I tap the "+ Add" chip next to Genres, type "Regional Literature", and confirm  
**Then** a new Genre is created in `genre_table` (`is_custom = true`), it appears as an active input-chip in the Genres row, and the book is linked via `BookGenre`. Same flow applies to Tags.

### US-79: Cascading location dropdowns
**As a** user assigning a physical location  
**I want to** pick Room, then Cupboard, then Shelf  
**So that** the hierarchy is respected.

**Given** Rooms "Study", "Living Room" exist with associated cupboards and shelves  
**When** I select "Study" from the Room dropdown (`add-book.html`, Location section, 3 dropdowns in a row)  
**Then** the Cupboard dropdown populates with cupboards belonging to "Study", and selecting a cupboard populates the Shelf dropdown with its shelves.

### US-80: Select "None" for location
**As a** user who doesn't know the location yet  
**I want to** leave location unset  
**So that** I can assign it later.

**Given** I am in the Location section  
**When** I leave any or all dropdowns as "None"  
**Then** on save, `shelf_id` is set to null, the book shows "No location" in the catalog, and the "None" location nudge banner may appear.

### US-81: Date pickers for publication and purchase dates
**As a** user entering dates  
**I want to** use native date pickers  
**So that** input is easy and valid.

**Given** I am in the Details or Purchase section of `add-book.html`  
**When** I tap the "Publication Date" or "Purchase Date" field  
**Then** a Material date picker opens. For Publication Date, I can select year-only (e.g., just "1988"). For Purchase Date, I select a full calendar date.

### US-82: Cover image picker bottom sheet
**As a** user adding a cover  
**I want to** choose the source  
**So that** I can use camera, gallery, or search online.

**Given** I am in the Cover Image section (`add-book.html`, cover preview + 3 buttons)  
**When** I tap "Take Photo", "Choose from Gallery", or "Search Online"  
**Then** a bottom sheet appears with those three options. Selecting "Take Photo" opens the camera; "Choose from Gallery" opens the image picker; "Search Online" queries Google Books cover images based on title/ISBN.

### US-83: Image optimization on save
**As a** user with limited storage  
**I want** cover images optimized  
**So that** they don't consume too much space.

**Given** I selected a 4MB 3000×4000px cover image from gallery  
**When** I save the book  
**Then** the image is resized to max 800px width, compressed to JPEG quality 80%, saved to the app's documents directory, and the `cover_image_path` points to the optimized file (~50–100KB).

### US-84: Manual "Enrich Online" triggers Google Books search
**As a** user who wants to auto-fill book details  
**I want to** search Google Books from the form  
**So that** I don't type everything.

**Given** I have entered "The Alchemist" and "Paulo Coelho" in the form  
**When** I tap the "Enrich Online" button (magnifying glass icon in the app bar of `add-book.html`)  
**Then** an enrichment bottom sheet slides up showing skeleton loaders (3 `skeleton-row` placeholders), then after results load, horizontal scrollable result cards appear (cover thumbnail, title, author, year). I tap a card to select it.

### US-85: Per-field acceptance of enriched data
**As a** user who found a Google Books match  
**I want to** choose which fields to apply  
**So that** I keep my own data where needed.

**Given** the enrichment bottom sheet is showing results and I selected a match  
**When** I tap "Apply Selected"  
**Then** the form fields are filled with enriched data, each populated field shows a green checkmark (section-check icon) next to its section header, and I can manually override any field before saving.

### US-86: Auto-enrich suggests fields after typing pause
**As a** user with auto-enrich enabled  
**I want to** get suggestions without tapping a button  
**So that** entry is faster.

**Given** Settings → "Auto-enrich from web" is ON  
**When** I pause typing the title for 1.5 seconds  
**Then** a background Google Books search fires. If results are found and form fields are empty, suggestions appear as inline chips or pre-filled values that I can accept or dismiss.

### US-87: Save book and see it in catalog
**As a** user adding a book  
**I want to** confirm the save worked  
**So that** I know the record exists.

**Given** I filled the form and tapped "Save"  
**When** the transaction commits successfully  
**Then** a success snackbar appears: "'The Alchemist' added to your library." I am navigated back to `/catalog`, and the new book appears in the grid within 1 second.

## Duplicate Detection

### US-88: ISBN exact match warns of duplicate
**As a** user accidentally adding a book I already own  
**I want to** be warned before saving  
**So that** I don't create duplicates.

**Given** a book with ISBN-13 `9780062315007` already exists and is not deleted  
**When** I enter the same ISBN in the Add Book form and tap "Save"  
**Then** a duplicate warning dialog opens: "Possible Duplicate. This may be a duplicate of The Alchemist by Paulo Coelho already in your library." with matched book cover thumbnail, "Add Anyway" and "Cancel" buttons.

### US-89: Fuzzy title/author match warns of duplicate
**As a** user adding a book with a slightly different title spelling  
**I want to** be warned if it's probably the same book  
**So that** I don't create near-duplicates.

**Given** "The Alchemist" by "Paulo Coelho" exists  
**When** I enter title "The Alchmist" (typo) and author "Paulo Coelho"  
**Then** Levenshtein distance ratio is ≥80% for title and ≥80% for author → the duplicate warning dialog opens with match reason: "Similar title and author."

### US-90: "Add Anyway" bypasses duplicate and saves
**As a** user intentionally adding a second copy  
**I want to** confirm it's not a mistake  
**So that** I can add multiple copies.

**Given** the duplicate warning dialog is open  
**When** I tap "Add Anyway"  
**Then** the dialog closes, the book is inserted with a new UUID, and the catalog shows both entries.

### US-91: Duplicate match against deleted book offers restore
**As a** user re-adding a previously deleted book  
**I want to** restore the old record instead of creating a new one  
**So that** I preserve history.

**Given** a soft-deleted book with matching ISBN exists  
**When** I enter the same ISBN and save  
**Then** the duplicate dialog shows: "This book was previously deleted." with two options: "Restore Existing" (restores the soft-deleted book) and "Add as New" (creates a fresh record).

## Edge Cases

### US-92: Auto-enrich debounce cancels stale requests
**As a** user typing quickly  
**I want to** avoid redundant API calls  
**So that** quota isn't wasted.

**Given** auto-enrich is enabled  
**When** I type "The", pause 1.4s, then type " Alchemist"  
**Then** the first debounced search for "The" is cancelled before executing; only the search for "The Alchemist" (after the second pause) fires.

### US-93: Enrich with no internet shows offline message
**As a** user without connectivity  
**I want to** know enrichment isn't available  
**So that** I can enter manually.

**Given** the device is offline  
**When** I tap "Enrich Online"  
**Then** the bottom sheet shows: "Offline — enrichment requires internet. Tap to retry." with no skeleton loaders or infinite spinners.

### US-94: No Google Books results for enrichment
**As a** user adding a rare book  
**I want to** know when no matches are found  
**So that** I can enter manually.

**Given** I tap "Enrich Online" for a book not in Google Books  
**When** the API returns zero results  
**Then** the bottom sheet shows: "No matches found on Google Books. Try a different title or enter details manually." with a "Close" button.

### US-95: Storage permission rationale on first cover save
**As a** user saving a cover for the first time  
**I want to** understand why storage permission is needed  
**So that** I can grant it confidently.

**Given** this is the first time I attempt to save a cover image  
**When** the app needs to write to storage  
**Then** a rationale dialog appears: "The Little Library needs storage access to save cover images." with "Allow" and "Deny".

### US-96: Storage permission second denial opens Settings
**As a** user who previously denied storage  
**I want to** be directed to system settings  
**So that** I can enable permission manually.

**Given** I previously denied storage permission and selected "Don't ask again"  
**When** I attempt to save a cover again  
**Then** a dialog appears: "Storage permission is required to save cover images." with an "Open Settings" button that launches the app's system settings page.

### US-97: Create genre/tag with same name as existing dedupes
**As a** user typing a genre that already exists  
**I want to** select the existing one  
**So that** no duplicates are created.

**Given** "Fiction" already exists in `genre_table`  
**When** I tap "+ Add" and type "fiction" (case-insensitive)  
**Then** the existing "Fiction" genre is shown in the type-ahead; selecting it adds the existing genre chip rather than creating a new row.

### US-98: Publication year-only input (YYYY)
**As a** user who only knows the publication year  
**I want to** enter just the year  
**So that** I don't have to guess a full date.

**Given** I am entering the Publication Date  
**When** I select only a year (no month/day) in the date picker or type "1988"  
**Then** the field stores "1988" (text), validation accepts it (year between 1000 and current year), and the detail screen displays "1988".

### US-99: ISBN-10 auto-converted to ISBN-13 on save
**As a** user entering an ISBN-10  
**I want to** it stored as ISBN-13  
**So that** normalization is consistent.

**Given** I enter `0062315005` (ISBN-10 for The Alchemist)  
**When** I save the book  
**Then** the stored `isbn` value is `9780062315007` (converted via standard ISBN-10→13 algorithm), and duplicate detection matches against the normalized ISBN-13.

### US-100: Book with no ISBN passes validation
**As a** user adding a book without an ISBN  
**I want to** leave the field empty  
**So that** I'm not blocked.

**Given** I leave the ISBN field blank  
**When** I tap "Save"  
**Then** validation passes (ISBN is optional), the book is saved with `isbn = null`, and duplicate detection relies solely on fuzzy title+author matching.

### US-101: ISBN validation rejects invalid formats
**As a** user mistyping an ISBN  
**I want to** see a validation error  
**So that** I fix it before saving.

**Given** I enter "978-0-06-231500" (12 digits, invalid) or "abc" (non-numeric)  
**When** the field loses focus or I tap "Save"  
**Then** the field shows a red error: "Enter a valid 10 or 13 digit ISBN" and save is blocked.

### US-102: Publication year out of range rejected
**As a** user entering an implausible year  
**I want to** be corrected  
**So that** data stays realistic.

**Given** I enter publication year "999" or "3000"  
**When** I attempt to save  
**Then** validation shows: "Publication year must be between 1000 and [current year]."

### US-103: Required title validation
**As a** user who forgets the title  
**I want to** be reminded  
**So that** I don't save an incomplete record.

**Given** I leave the Title field blank  
**When** I tap "Save"  
**Then** the Title field gains focus, shows a red error "Title is required", and the save transaction does not execute.

## Error States

### US-104: API quota exhausted disables "Enrich Online"
**As a** user when the daily Google Books quota is reached  
**I want to** know why enrichment is unavailable  
**So that** I can add manually and try tomorrow.

**Given** the quota tracker shows `isQuotaExceeded = true`  
**When** I am on `add-book.html`  
**Then** the "Enrich Online" button (app bar magnifying glass) is disabled/greyed out. Long-pressing or focusing it shows a tooltip: "Google Books daily limit reached. You can still add books manually. Enrichment will resume tomorrow."

### US-105: Network timeout on enrichment falls back gracefully
**As a** user on a slow network  
**I want to** know the search timed out  
**So that** I can retry or proceed manually.

**Given** I tapped "Enrich Online" but the network is very slow  
**When** 10 seconds pass without a response  
**Then** the bottom sheet shows: "Search timed out. Check your connection and try again." with a "Retry" button. The skeleton loaders are replaced by this message.

### US-106: Image optimization or storage failure
**As a** user when cover processing fails  
**I want to** still save the book  
**So that** I'm not blocked.

**Given** I selected a cover image but the device storage is full or image processing crashes  
**When** I tap "Save"  
**Then** a warning appears: "Could not save cover image. Save book without cover?" with "Save Without Cover" and "Cancel" options.

## Empty States

### US-107: Empty add book form
**As a** user opening the add form  
**I want to** see a clean starting state  
**So that** I know what to fill.

**Given** I navigate to `/book/add`  
**When** `add-book.html` renders  
**Then** all fields are empty/default, no section-check icons are visible, cover preview shows the book placeholder icon, and the "Save" button is present but will validate on tap.

### US-108: No authors added yet
**As a** user in the Authors section  
**I want to** see that no authors are listed  
**So that** I know to add one.

**Given** I haven't added any authors  
**When** I view the Authors section  
**Then** the list area is empty, and only the "+ Add Author" chip is visible.

### US-109: No genres or tags selected
**As a** user in the Classification section  
**I want to** see empty genre/tag rows  
**So that** I know I can add them.

**Given** no genres or tags are selected  
**When** I view the Classification section  
**Then** the Genres row shows only the "+ Add" chip, and the Tags row shows only the "+ Add" chip.

### US-110: No cover image selected
**As a** user before picking a cover  
**I want to** see a clear placeholder  
**So that** I know where to tap.

**Given** no cover has been chosen  
**When** I view the Cover Image section  
**Then** the preview box shows the book icon placeholder, and the three action buttons (Take Photo, Choose from Gallery, Search Online) are visible below.

## Accessibility

### US-111: All form fields have associated labels
**As a** screen reader user  
**I want to** hear what each field is for  
**So that** I can fill the form accurately.

**Given** TalkBack is enabled on `add-book.html`  
**When** I focus any text input, dropdown, or segmented control  
**Then** it announces the field label (e.g., "Title, required, edit box" or "Format, Hardcover selected, segmented control").

### US-112: Section headers announced for navigation
**As a** screen reader user  
**I want to** know which section I'm in  
**So that** I can navigate the long form.

**Given** TalkBack is enabled  
**When** I swipe through the form  
**Then** each section header ("Basic Info", "Authors", "Details", "Classification", "Location", "Purchase", "Cover Image", "Notes") is announced as a heading, allowing heading-based navigation.

### US-113: Enrichment result cards labeled
**As a** screen reader user  
**I want to** choose the correct Google Books match  
**So that** I enrich accurately.

**Given** TalkBack is enabled and the enrichment bottom sheet is open with results  
**When** I focus a result card  
**Then** it announces: "The Alchemist, by Paulo Coelho, published 1988. Double-tap to select."

### US-114: Duplicate warning dialog focus trap
**As a** screen reader user  
**I want to** be guided through the duplicate decision  
**So that** I don't bypass the warning.

**Given** TalkBack is enabled and the duplicate dialog is open  
**When** the dialog appears  
**Then** focus moves to the dialog title, the matched book cover is described, and both "Cancel" and "Add Anyway" buttons are labeled. Tapping outside the dialog does not dismiss it.

### US-115: Date picker accessible
**As a** screen reader user  
**I want to** select dates without sight  
**So that** I can enter publication and purchase dates.

**Given** TalkBack is enabled  
**When** I open the Material date picker for Publication Date or Purchase Date  
**Then** the calendar grid is navigable by swipe, each day is announced with day-of-week and month, and the "OK" / "Cancel" actions are labeled.

### US-116: Cover picker bottom sheet labeled
**As a** screen reader user  
**I want to** choose a cover source  
**So that** I can add images.

**Given** TalkBack is enabled  
**When** the cover picker bottom sheet opens (Camera / Gallery / Search Online)  
**Then** each option is announced with its icon description: "Take Photo, button", "Choose from Gallery, button", "Search Online, button".

### US-117: Sufficient color contrast on validation errors
**As a** user with low vision  
**I want to** clearly see error messages  
**So that** I know what to fix.

**Given** I am on `add-book.html` in light or dark mode  
**When** a validation error appears (e.g., red error text below Title)  
**Then** the error text color (`#B3261E` light / `#F2B8B5` dark) maintains a contrast ratio ≥ 4.5:1 against the surface background, per WCAG AA.

---

# Cross-Cutting Stories

## Offline Behavior

### US-118: Core catalog features work without internet
**As a** user in airplane mode  
**I want to** browse, search, filter, add, edit, and delete books  
**So that** the app is fully functional offline.

**Given** the device has no network connectivity  
**When** I perform any catalog, book detail, or add/edit action  
**Then** all local DB operations succeed, the sync bar shows amber, and queued changes are marked for next sync. No action crashes or blocks on network absence.

## Performance

### US-119: Smooth scrolling with 2000+ books
**As a** user with a large library  
**I want to** scroll without jank  
**So that** the app feels responsive.

**Given** the catalog contains 2000 books  
**When** I scroll rapidly through the grid  
**Then** frame times remain <16ms, images load lazily, and no UI thread blocking occurs. Pagination fetches in chunks (e.g., 50 per page) via `ListView.builder`.

### US-120: Search returns results in under 300ms
**As a** user searching  
**I want to** see results instantly  
**So that** I stay in flow.

**Given** 2000 books with FTS5 index built  
**When** I type a 3-character query in the search bar  
**Then** results appear within 300ms on a mid-range Android device.
