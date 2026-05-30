# Test Report — Phase 2: Core Screens

> **Date:** 2026-05-30
> **Status:** RED — All 213 new tests FAIL (expected, no implementation exists)
> **Pipeline:** FAST_BUILD (UI screens) + LIGHT TDD (duplicate detection, validation)

---

## Coverage Map

### Workstream 2.1 — Setup Wizard (F0)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1 | `test/features/setup/setup_wizard_test.dart` | should render Step 1 with Google Sign-In button and skip link | Widget |
| US-1 | `test/features/setup/setup_wizard_test.dart` | should advance to Step 2 after successful Google Sign-In on Step 1 | Widget |
| US-1 | `test/features/setup/setup_wizard_test.dart` | should show "I have a link or QR code" and "Create a new library" cards on Step 2 | Widget |
| US-1 | `test/features/setup/setup_wizard_test.dart` | should validate invite link on Step 2 and advance to Step 3 sync | Widget |
| US-1 | `test/features/setup/setup_wizard_test.dart` | should display progress bar with stage messages on Step 3 | Widget |
| US-1 | `test/features/setup/setup_wizard_test.dart` | should complete sync with green checkmark, synced stats, and "Start Browsing" button | Widget |
| US-2 | `test/features/setup/setup_wizard_test.dart` | should advance to Step 2 when "Skip for now" is tapped | Widget |
| US-2 | `test/features/setup/setup_wizard_test.dart` | should allow creating a local library and complete setup with 0 books | Widget |
| US-2 | `test/features/setup/setup_wizard_test.dart` | should show persistent banner "Sign in to sync with family" on catalog after skip | Widget |
| US-3 | `test/features/setup/setup_wizard_test.dart` | should show "Create a new library" card with subtitle on Step 2 | Widget |
| US-3 | `test/features/setup/setup_wizard_test.dart` | should show "Share with family?" card with email input after "Create Library" tap | Widget |
| US-3 | `test/features/setup/setup_wizard_test.dart` | should call permissions.create for each email and advance to Step 3 | Widget |
| US-4 | `test/features/setup/setup_wizard_test.dart` | should show link input field on Step 2 when "I have a link or QR code" is selected | Widget |
| US-4 | `test/features/setup/setup_wizard_test.dart` | should validate the link and advance to Step 3 sync when valid link pasted | Widget |
| US-5 | `test/features/setup/setup_wizard_test.dart` | should show QR scan button next to link input on Step 2 | Widget |
| US-5 | `test/features/setup/setup_wizard_test.dart` | should auto-populate link input after scanning a valid QR code | Widget |
| US-6 | `test/features/setup/setup_wizard_test.dart` | should advance to Step 3 sync when "Skip for now" is tapped on Share card | Widget |
| US-6 | `test/features/setup/setup_wizard_test.dart` | should not send any invites when family invite step is skipped | Widget |
| US-7 | `test/features/setup/setup_wizard_test.dart` | should show visible error text below input for invalid link | Widget |
| US-8 | `test/features/setup/setup_wizard_test.dart` | should merge local books with remote when signing in later from Settings | Widget |
| US-9 | `test/features/setup/setup_wizard_test.dart` | should show visible error message when Google Sign-In fails | Widget |
| US-9 | `test/features/setup/setup_wizard_test.dart` | should keep "Sign in with Google" button tappable for retry after failure | Widget |
| US-10 | `test/features/setup/setup_wizard_test.dart` | should show red error state on Step 3 when Drive folder unreachable | Widget |
| US-11 | `test/features/setup/setup_wizard_test.dart` | should show amber offline indicator on Step 3 with offline message | Widget |
| US-11 | `test/features/setup/setup_wizard_test.dart` | should complete wizard and open catalog with offline sync status bar | Widget |
| US-12 | `test/features/setup/setup_wizard_test.dart` | should show book count during sync for 500+ books | Widget |
| US-12 | `test/features/setup/setup_wizard_test.dart` | should persist "Organizing shelves…" stage for >2 seconds for >100 books | Widget |
| US-13 | `test/features/setup/setup_wizard_test.dart` | should show welcoming empty catalog with three quick-action buttons after setup | Widget |
| US-14 | `test/features/setup/setup_wizard_test.dart` | should announce step dot indicator when advancing steps | Widget |
| US-15 | `test/features/setup/setup_wizard_test.dart` | should label Google Sign-In button "Sign in with Google" | Widget |
| US-15 | `test/features/setup/setup_wizard_test.dart` | should label "Skip for now" link "Skip sign-in for now" | Widget |
| US-15 | `test/features/setup/setup_wizard_test.dart` | should label app logo "The Little Library app icon" | Widget |
| US-16 | `test/features/setup/setup_wizard_test.dart` | should announce progress milestones at 25%, 50%, 75% | Widget |
| US-16 | `test/features/setup/setup_wizard_test.dart` | should announce completion with book count and "Start Browsing" button | Widget |

### Workstream 2.2 — Catalog Screen (F5)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-17 | `test/features/catalog/catalog_grid_list_test.dart` | should render books in a 2-column grid with cover thumbnails | Widget |
| US-17 | `test/features/catalog/catalog_grid_list_test.dart` | should display cover thumbnail at 3:4 aspect ratio in grid | Widget |
| US-17 | `test/features/catalog/catalog_grid_list_test.dart` | should clamp title to 2 lines in grid view | Widget |
| US-17 | `test/features/catalog/catalog_grid_list_test.dart` | should display primary author below title in grid view | Widget |
| US-17 | `test/features/catalog/catalog_grid_list_test.dart` | should display status badge on each book card in grid | Widget |
| US-18 | `test/features/catalog/catalog_grid_list_test.dart` | should show grid icon at full opacity and list icon at 0.5 opacity when grid is active | Widget |
| US-18 | `test/features/catalog/catalog_grid_list_test.dart` | should animate to list layout when list view icon is tapped | Widget |
| US-18 | `test/features/catalog/catalog_grid_list_test.dart` | should make list icon fully opaque and grid icon dimmed after toggle to list | Widget |
| US-19 | `test/features/catalog/catalog_grid_list_test.dart` | should show search bar with magnifying glass icon on catalog | Widget |
| US-19 | `test/features/catalog/catalog_grid_list_test.dart` | should filter grid to matching books when text is typed in search bar | Widget |
| US-19 | `test/features/catalog/catalog_grid_list_test.dart` | should show voice mic icon and ranking dropdown alongside search bar | Widget |
| US-20 | `test/features/catalog/catalog_grid_list_test.dart` | should open platform STT dialog when microphone icon is tapped | Widget |
| US-20 | `test/features/catalog/catalog_grid_list_test.dart` | should populate search bar with STT transcript and trigger search | Widget |
| US-21 | `test/features/catalog/catalog_grid_list_test.dart` | should show horizontally scrollable chips row below toolbar | Widget |
| US-21 | `test/features/catalog/catalog_grid_list_test.dart` | should activate chip with primary-container color background when selected | Widget |
| US-21 | `test/features/catalog/catalog_grid_list_test.dart` | should show only books matching multiple active filter chips | Widget |
| US-22 | `test/features/catalog/catalog_grid_list_test.dart` | should show sort dropdown in toolbar labeled "Title" by default | Widget |
| US-22 | `test/features/catalog/catalog_grid_list_test.dart` | should re-sort grid with most recently created books first when "Recently Added" selected | Widget |
| US-23 | `test/features/catalog/catalog_grid_list_test.dart` | should list multi-author book under each author when sorted by Author | Widget |
| US-24 | `test/features/catalog/catalog_grid_list_test.dart` | should navigate to /book/:id when a book card is tapped | Widget |
| US-25 | `test/features/catalog/catalog_grid_list_test.dart` | should activate multi-select mode on long-press (500ms) of a book card | Widget |
| US-26 | `test/features/catalog/catalog_grid_list_test.dart` | should show confirmation dialog and soft-delete selected books on "Delete" tap | Widget |
| US-26 | `test/features/catalog/catalog_grid_list_test.dart` | should open location picker and reassign all selected books on "Change Location" tap | Widget |
| US-27 | `test/features/catalog/catalog_grid_list_test.dart` | should show refresh indicator and trigger sync on pull down | Widget |
| US-28 | `test/features/catalog/catalog_grid_list_test.dart` | should show amber banner when 12 books have shelf_id = null | Widget |
| US-28 | `test/features/catalog/catalog_grid_list_test.dart` | should filter catalog to unplaced books when banner or "Assign" is tapped | Widget |
| US-29 | `test/features/catalog/catalog_grid_list_test.dart` | should filter catalog to books checked out to signed-in user | Widget |
| US-29 | `test/features/catalog/catalog_grid_list_test.dart` | should show active state on chip when "Checked Out by Me" is selected | Widget |
| US-30 | `test/features/catalog/catalog_grid_list_test.dart` | should show blue "With [Name]" badge for checked-out books | Widget |
| US-30 | `test/features/catalog/catalog_grid_list_test.dart` | should show amber "Loaned to [Borrower]" badge for loaned books | Widget |
| US-30 | `test/features/catalog/catalog_grid_list_test.dart` | should show location badge for available books with location | Widget |
| US-30 | `test/features/catalog/catalog_grid_list_test.dart` | should show muted "No location" badge for available books without location | Widget |
| US-30 | `test/features/catalog/catalog_grid_list_test.dart` | should show red "Overdue — due [date]" badge for overdue books | Widget |
| US-31 | `test/features/catalog/catalog_edge_cases_test.dart` | should dismiss bottom bar, show FAB, and hide checkbox overlays when all deselected | Widget |
| US-32 | `test/features/catalog/catalog_edge_cases_test.dart` | should preserve selections and update count when scrolling and selecting below the fold | Widget |
| US-33 | `test/features/catalog/catalog_edge_cases_test.dart` | should treat SQL injection attempt as literal string and return no results safely | Widget |
| US-33 | `test/features/catalog/catalog_edge_cases_test.dart` | should handle spaces-only query gracefully without crash | Widget |
| US-34 | `test/features/catalog/catalog_edge_cases_test.dart` | should return all chips to inactive state and show full catalog when cleared | Widget |
| US-35 | `test/features/catalog/catalog_edge_cases_test.dart` | should render the 50th book with no extra blank row and no loading indicator | Widget |
| US-36 | `test/features/catalog/catalog_edge_cases_test.dart` | should show green "Synced just now" when in sync | Widget |
| US-36 | `test/features/catalog/catalog_edge_cases_test.dart` | should show amber "Offline — 3 changes pending" when offline with pending changes | Widget |
| US-36 | `test/features/catalog/catalog_edge_cases_test.dart` | should show red error with specific message when sync fails | Widget |
| US-37 | `test/features/catalog/catalog_edge_cases_test.dart` | should allow search, filter, and sort operations while offline | Widget |
| US-38 | `test/features/catalog/catalog_edge_cases_test.dart` | should show tappable message on red sync bar with actionable text | Widget |
| US-39 | `test/features/catalog/catalog_edge_cases_test.dart` | should show icon, title, subtitle, and three quick-action buttons when 0 books | Widget |
| US-40 | `test/features/catalog/catalog_edge_cases_test.dart` | should show "No books match your search" with subtext when search yields nothing | Widget |
| US-41 | `test/features/catalog/catalog_edge_cases_test.dart` | should show "No books on this shelf" with "Clear Filters" action when filters yield nothing | Widget |
| US-42 | `test/features/catalog/catalog_edge_cases_test.dart` | should show "No deleted books." when Show Deleted filter active and no deleted books | Widget |
| US-43 | `test/features/catalog/catalog_edge_cases_test.dart` | should announce "Open navigation menu" for TalkBack on hamburger icon | Widget |
| US-44 | `test/features/catalog/catalog_edge_cases_test.dart` | should announce book title, author, and status when TalkBack focuses a card | Widget |
| US-45 | `test/features/catalog/catalog_edge_cases_test.dart` | should announce filter chip state (collapsed or active with selection) | Widget |
| US-46 | `test/features/catalog/catalog_edge_cases_test.dart` | should announce activation of multi-select mode and selection count | Widget |
| US-47 | `test/features/catalog/catalog_edge_cases_test.dart` | should have FAB at 56dp, filter chips at ≥48dp in one dimension | Widget |
| US-48 | `test/features/catalog/catalog_edge_cases_test.dart` | should show skeleton cards matching grid layout while initial data loads | Widget |
| US-49 | `test/features/catalog/catalog_edge_cases_test.dart` | should show circular progress indicator at bottom when next page is loading | Widget |

### Workstream 2.3 — Book Detail Screen (F6)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display cover hero, status section, and all grouped info cards | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display title in Basic info card matching book record | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display ISBN, language, and format in Basic info card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should list all authors in Authors info card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display publisher, edition, publication date, page count, and description in Details card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display genre chips and tag chips in Classification card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display room/cupboard/shelf in Location card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display purchase date, price, and condition in Purchase card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display notes in Notes card | Widget |
| US-50 | `test/features/book_detail/book_detail_screen_test.dart` | should display Loan History card | Widget |
| US-51 | `test/features/book_detail/book_detail_screen_test.dart` | should display cover image full-width at top with max height 320dp | Widget |
| US-51 | `test/features/book_detail/book_detail_screen_test.dart` | should show book icon placeholder while cover image is loading | Widget |
| US-52 | `test/features/book_detail/book_detail_screen_test.dart` | should show "Check Out" (primary) and "Loan to Someone" (secondary) buttons when Available | Widget |
| US-52 | `test/features/book_detail/book_detail_screen_test.dart` | should show "Return to Shelf" button when Checked Out | Widget |
| US-52 | `test/features/book_detail/book_detail_screen_test.dart` | should show "Returned" button when Loaned | Widget |
| US-53 | `test/features/book_detail/book_detail_screen_test.dart` | should show vertical list of loan items with avatar, borrower name, and meta line | Widget |
| US-54 | `test/features/book_detail/book_detail_screen_test.dart` | should navigate to /book/edit/:id with all 21 fields pre-filled | Widget |
| US-55 | `test/features/book_detail/book_detail_screen_test.dart` | should open system share sheet with formatted text summary on "Share" tap | Widget |
| US-56 | `test/features/book_detail/book_detail_screen_test.dart` | should navigate to /change-history/:bookId when "History" is tapped | Widget |
| US-57 | `test/features/book_detail/book_detail_screen_test.dart` | should show confirmation dialog with book title and Cancel/Delete actions | Widget |
| US-57 | `test/features/book_detail/book_detail_screen_test.dart` | should soft-delete book and navigate back to catalog on confirm | Widget |
| US-58 | `test/features/book_detail/book_detail_screen_test.dart` | should show "Restore" button instead of Delete for deleted books | Widget |
| US-58 | `test/features/book_detail/book_detail_screen_test.dart` | should restore book with all previous state intact on "Restore" tap | Widget |
| US-59 | `test/features/book_detail/book_detail_screen_test.dart` | should render cover hero with default book icon when no cover exists | Widget |
| US-60 | `test/features/book_detail/book_detail_screen_test.dart` | should show grayscale muted cover, strikethrough title, and "[Deleted]" label for deleted books | Widget |
| US-61 | `test/features/book_detail/book_detail_screen_test.dart` | should show "None" or "—" for Room, Cupboard, Shelf when shelf_id is null | Widget |
| US-62 | `test/features/book_detail/book_detail_screen_test.dart` | should list all 3 authors each on their own row in Authors card | Widget |
| US-63 | `test/features/book_detail/book_detail_screen_test.dart` | should show "—" or hide ISBN row when isbn is null | Widget |
| US-64 | `test/features/book_detail/book_detail_screen_test.dart` | should still show active loan in Loan History after book is soft-deleted | Widget |
| US-65 | `test/features/book_detail/book_detail_screen_test.dart` | should show placeholder book icon when remote cover URL fails to load | Widget |
| US-66 | `test/features/book_detail/book_detail_screen_test.dart` | should show snackbar "Unable to share. Please try again." when share fails | Widget |
| US-67 | `test/features/book_detail/book_detail_screen_test.dart` | should show "No loan history." message when zero BookLoan records | Widget |
| US-68 | `test/features/book_detail/book_detail_screen_test.dart` | should show placeholder "No notes yet. Tap Edit to add some." when notes empty | Widget |
| US-69 | `test/features/book_detail/book_detail_screen_test.dart` | should show "None" for Genres and Tags rows when no associations exist | Widget |
| US-70 | `test/features/book_detail/book_detail_screen_test.dart` | should announce "Cover image for [Title] by [Primary Author]" on cover focus | Widget |
| US-71 | `test/features/book_detail/book_detail_screen_test.dart` | should announce status badge with location and button labels | Widget |
| US-72 | `test/features/book_detail/book_detail_screen_test.dart` | should label all 4 bottom action bar buttons (Edit, Share, History, Delete) | Widget |
| US-73 | `test/features/book_detail/book_detail_screen_test.dart` | should move focus to dialog title with Cancel as default action on delete dialog | Widget |

### Workstream 2.4 — Add/Edit Book Form (F2) + Duplicate Detection (F7)

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-74 | `test/features/add_book/add_book_form_test.dart` | should render all form sections: Basic Info, Authors, Details, Classification, Location, Purchase, Cover Image, Notes | Widget |
| US-74 | `test/features/add_book/add_book_form_test.dart` | should fill all fields, insert into drift, record change log, and navigate to catalog on save | Widget |
| US-75 | `test/features/add_book/add_book_form_test.dart` | should pre-fill all form fields with existing book values on /book/edit/:id | Widget |
| US-76 | `test/features/add_book/add_book_form_test.dart` | should show dropdown with matching existing authors when typing in author input | Widget |
| US-77 | `test/features/add_book/add_book_form_test.dart` | should show disambiguation prompt when adding author with same name as existing | Widget |
| US-77 | `test/features/add_book/add_book_form_test.dart` | should require disambiguation note and create new author with modified normalized_name when "different person" selected | Widget |
| US-78 | `test/features/add_book/add_book_form_test.dart` | should create new custom genre and show it as active input-chip when created inline | Widget |
| US-79 | `test/features/add_book/add_book_form_test.dart` | should populate Cupboard dropdown with cupboards of selected Room | Widget |
| US-80 | `test/features/add_book/add_book_form_test.dart` | should set shelf_id to null when any or all location dropdowns are "None" | Widget |
| US-81 | `test/features/add_book/add_book_form_test.dart` | should open Material date picker when Publication Date field is tapped | Widget |
| US-81 | `test/features/add_book/add_book_form_test.dart` | should open Material date picker with full calendar for Purchase Date | Widget |
| US-82 | `test/features/add_book/add_book_form_test.dart` | should show bottom sheet with Take Photo, Choose from Gallery, and Search Online options | Widget |
| US-82 | `test/features/add_book/add_book_form_test.dart` | should open camera when "Take Photo" is selected | Widget |
| US-82 | `test/features/add_book/add_book_form_test.dart` | should open image picker when "Choose from Gallery" is selected | Widget |
| US-82 | `test/features/add_book/add_book_form_test.dart` | should query Google Books cover images when "Search Online" is selected | Widget |
| US-83 | `test/features/add_book/add_book_form_test.dart` | should resize cover to max 800px width and compress to JPEG quality 80% on save | Widget |
| US-84 | `test/features/add_book/add_book_form_test.dart` | should show enrichment bottom sheet with skeleton loaders then result cards | Widget |
| US-84 | `test/features/add_book/add_book_form_test.dart` | should pre-fill form when a result card is tapped and accepted | Widget |
| US-85 | `test/features/add_book/add_book_form_test.dart` | should show green checkmark on each section header for populated enriched fields | Widget |
| US-86 | `test/features/add_book/add_book_form_test.dart` | should fire background Google Books search after 1.5s typing pause when auto-enrich is ON | Widget |
| US-87 | `test/features/add_book/add_book_form_test.dart` | should show success snackbar and navigate to /catalog with new book visible | Widget |
| US-88 | `test/features/add_book/add_book_form_test.dart` | should show duplicate warning dialog with matched book cover and name when same ISBN entered | Widget |
| US-88 | `test/features/add_book/add_book_form_test.dart` | should not trigger duplicate warning when ISBN does not match any non-deleted book | Widget |
| US-89 | `test/features/add_book/add_book_form_test.dart` | should show duplicate dialog when similar title+author with ≥80% similarity | Widget |
| US-90 | `test/features/add_book/add_book_form_test.dart` | should insert new book with new UUID when "Add Anyway" is tapped | Widget |
| US-91 | `test/features/add_book/add_book_form_test.dart` | should offer "Restore Existing" vs "Add as New" when matching soft-deleted book | Widget |
| US-92 | `test/features/add_book/add_book_enrichment_test.dart` | should cancel first debounced search when title continues to be typed before 1.5s | Widget |
| US-93 | `test/features/add_book/add_book_enrichment_test.dart` | should show offline message in enrichment bottom sheet when device is offline | Widget |
| US-94 | `test/features/add_book/add_book_enrichment_test.dart` | should show "No matches found" message with Close button when API returns zero results | Widget |
| US-95 | `test/features/add_book/add_book_enrichment_test.dart` | should show rationale dialog with Allow/Deny on first cover save attempt | Widget |
| US-96 | `test/features/add_book/add_book_enrichment_test.dart` | should show dialog with "Open Settings" button when storage previously denied with "Don't ask again" | Widget |
| US-97 | `test/features/add_book/add_book_enrichment_test.dart` | should show existing genre in type-ahead and select it rather than creating new row | Widget |
| US-98 | `test/features/add_book/add_book_validation_test.dart` | should accept 4-digit year string without month/day | Unit |
| US-98 | `test/features/add_book/add_book_validation_test.dart` | should accept publication date with full date (YYYY-MM-DD) | Unit |
| US-99 | `test/features/add_book/add_book_validation_test.dart` | should convert known ISBN-10 0062315005 to 9780062315007 | Unit |
| US-99 | `test/features/add_book/add_book_validation_test.dart` | should strip hyphens from ISBN-10 before conversion | Unit |
| US-99 | `test/features/add_book/add_book_validation_test.dart` | should leave valid ISBN-13 unchanged | Unit |
| US-99 | `test/features/add_book/add_book_enrichment_test.dart` | should convert ISBN-10 0062315005 to ISBN-13 9780062315007 on save | Widget |
| US-100 | `test/features/add_book/add_book_validation_test.dart` | should pass validation when ISBN is null | Unit |
| US-100 | `test/features/add_book/add_book_validation_test.dart` | should pass validation when ISBN is empty string | Unit |
| US-100 | `test/features/add_book/add_book_enrichment_test.dart` | should save book with isbn=null when ISBN field is left blank | Widget |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should reject 12-digit ISBN as invalid | Unit |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should reject non-numeric ISBN like "abc" | Unit |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should reject ISBN with letters mixed in digits | Unit |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should accept valid ISBN-10 with X checksum | Unit |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should accept valid ISBN-13 without hyphens | Unit |
| US-101 | `test/features/add_book/add_book_validation_test.dart` | should accept ISBN-13 with hyphens (normalized on save) | Unit |
| US-101 | `test/features/add_book/add_book_enrichment_test.dart` | should show red error "Enter a valid 10 or 13 digit ISBN" for invalid ISBN | Widget |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should reject publication year "999" (< 1000) | Unit |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should reject publication year "3000" (> current year) | Unit |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should accept publication year "1988" (valid range) | Unit |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should accept year-only input without month/day | Unit |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should validate year boundary at exactly 1000 | Unit |
| US-102 | `test/features/add_book/add_book_validation_test.dart` | should validate year boundary at current year | Unit |
| US-102 | `test/features/add_book/add_book_enrichment_test.dart` | should show validation error for publication year < 1000 or > current year | Widget |
| US-103 | `test/features/add_book/add_book_validation_test.dart` | should reject empty title | Unit |
| US-103 | `test/features/add_book/add_book_validation_test.dart` | should reject whitespace-only title | Unit |
| US-103 | `test/features/add_book/add_book_validation_test.dart` | should accept non-empty title | Unit |
| US-103 | `test/features/add_book/add_book_validation_test.dart` | should trim whitespace and still accept if non-empty after trim | Unit |
| US-103 | `test/features/add_book/add_book_enrichment_test.dart` | should show red error "Title is required" and block save when title is blank | Widget |
| US-104 | `test/features/add_book/add_book_enrichment_test.dart` | should show "Enrich Online" button as disabled/greyed when quota exceeded | Widget |
| US-105 | `test/features/add_book/add_book_enrichment_test.dart` | should show timeout message with "Retry" button after 10s without response | Widget |
| US-106 | `test/features/add_book/add_book_enrichment_test.dart` | should offer "Save Without Cover" option when cover processing fails | Widget |
| US-107 | `test/features/add_book/add_book_enrichment_test.dart` | should render all fields empty/default with book placeholder for cover | Widget |
| US-108 | `test/features/add_book/add_book_enrichment_test.dart` | should show empty authors list area with only "+ Add Author" chip visible | Widget |
| US-109 | `test/features/add_book/add_book_enrichment_test.dart` | should show only "+ Add" chip in Genres row and Tags row when none selected | Widget |
| US-110 | `test/features/add_book/add_book_enrichment_test.dart` | should show book icon placeholder and three action buttons visible | Widget |
| US-111 | `test/features/add_book/add_book_enrichment_test.dart` | should announce field label for each input, dropdown, and segmented control | Widget |
| US-112 | `test/features/add_book/add_book_enrichment_test.dart` | should announce section headers as headings for TalkBack heading-based navigation | Widget |
| US-113 | `test/features/add_book/add_book_enrichment_test.dart` | should announce result card with title, author, and year for TalkBack | Widget |
| US-114 | `test/features/add_book/add_book_enrichment_test.dart` | should trap focus in dialog, describe matched book cover, and label both action buttons | Widget |
| US-115 | `test/features/add_book/add_book_enrichment_test.dart` | should make Material date picker calendar grid navigable by swipe and announce days | Widget |
| US-116 | `test/features/add_book/add_book_enrichment_test.dart` | should announce each cover source option with icon description | Widget |
| US-117 | `test/features/add_book/add_book_enrichment_test.dart` | should maintain contrast ratio ≥4.5:1 for red error text against surface background | Widget |

### Cross-Cutting Stories

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should allow browsing, searching, and filtering while offline | Widget |
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should allow adding a book while offline and queue for sync | Widget |
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should allow editing a book while offline and preserve changes | Widget |
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should allow deleting a book while offline (soft-delete) | Widget |
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should show amber sync bar with pending changes count when offline | Widget |
| US-118 | `test/features/catalog/catalog_performance_test.dart` | should not crash or block UI on any operation when network is absent | Widget |
| US-119 | `test/features/catalog/catalog_performance_test.dart` | should render list items using ListView.builder in chunks of 50 for lazy loading | Widget |
| US-119 | `test/features/catalog/catalog_performance_test.dart` | should lazy-load images and not block UI thread during scroll | Widget |
| US-119 | `test/features/catalog/catalog_performance_test.dart` | should render 2000 books without jank (frame times <16ms) | Widget |
| US-120 | `test/features/catalog/catalog_performance_test.dart` | should return FTS5 search results within 300ms on 2000-book library | Widget |
| US-120 | `test/features/catalog/catalog_performance_test.dart` | should debounce rapid search input to avoid expensive re-queries | Widget |

### Integration / E2E Tests

| Story ID | Test File | Test Name | Type |
|----------|-----------|-----------|------|
| US-1 | `integration_test/phase2_e2e_test.dart` | should complete 3-step setup wizard and land on catalog | E2E |
| US-1 | `integration_test/phase2_e2e_test.dart` | should show "Start Browsing" button after sync and navigate to /catalog | E2E |
| US-24, US-50 | `integration_test/phase2_e2e_test.dart` | should navigate from catalog grid to book detail and show all info cards | E2E |
| US-74, US-87 | `integration_test/phase2_e2e_test.dart` | should add a book with all sections and see it in catalog | E2E |
| US-54, US-75 | `integration_test/phase2_e2e_test.dart` | should edit an existing book from detail screen and see updated values | E2E |
| US-57, US-58 | `integration_test/phase2_e2e_test.dart` | should soft-delete a book from detail screen and restore it from deleted view | E2E |
| US-19, US-21 | `integration_test/phase2_e2e_test.dart` | should search for a book, apply genre filter, and see filtered results | E2E |
| US-25, US-26, US-31 | `integration_test/phase2_e2e_test.dart` | should enter multi-select mode, select books, delete them, and exit mode | E2E |
| US-88, US-90 | `integration_test/phase2_e2e_test.dart` | should show duplicate warning when adding book with same ISBN, allow Add Anyway | E2E |
| US-84, US-85 | `integration_test/phase2_e2e_test.dart` | should enrich book fields from Google Books and apply selected fields | E2E |
| US-118 | `integration_test/phase2_e2e_test.dart` | should perform all CRUD operations offline and show amber sync bar | E2E |

---

## File Inventory

### New Test Files Created

| File | Tests | Type |
|------|-------|------|
| `test/features/setup/setup_wizard_test.dart` | 34 | Widget |
| `test/features/catalog/catalog_grid_list_test.dart` | 33 | Widget |
| `test/features/catalog/catalog_edge_cases_test.dart` | 22 | Widget |
| `test/features/catalog/catalog_performance_test.dart` | 11 | Widget |
| `test/features/book_detail/book_detail_screen_test.dart` | 38 | Widget |
| `test/features/add_book/add_book_form_test.dart` | 26 | Widget |
| `test/features/add_book/add_book_enrichment_test.dart` | 26 | Widget |
| `test/features/add_book/add_book_validation_test.dart` | 23 | Unit |
| `integration_test/phase2_e2e_test.dart` | 11 | E2E |
| **TOTAL** | **224** | — |

### Existing Test Files (not modified)

| File | Status |
|------|--------|
| `test/features/catalog_screen_test.dart` | Existing — placeholder tests for Phase 1, kept as-is |
| `test/features/app_test.dart` | Existing — placeholder tests for Phase 1, kept as-is |
| `test/features/accessibility_test.dart` | Existing — placeholder tests for Phase 1, kept as-is |
| `test/features/navigation_drawer_test.dart` | Existing — placeholder, kept as-is |
| `test/features/sync_status_bar_test.dart` | Existing — placeholder, kept as-is |
| `test/features/fab_speed_dial_test.dart` | Existing — placeholder, kept as-is |
| `test/features/router_test.dart` | Existing — placeholder, kept as-is |
| `test/data/database/duplicate_detector_test.dart` | Existing — **PASSING** (Phase 1 LIGHT TDD) |
| `test/data/database/isbn_utils_test.dart` | Existing — **PASSING** (Phase 1 LIGHT TDD) |
| All other existing test files | Existing — Phase 1, kept as-is |

---

## Uncovered Stories

- **None.** All 120 user stories (US-1 through US-120) are covered by at least one test.

---

## Test Execution

### All New Phase 2 Tests

```bash
cd the_little_library_app
flutter test test/features/setup/ test/features/catalog/ test/features/book_detail/ test/features/add_book/
```

**Result:** `00:05 +0 -213: Some tests failed.`

✅ All 213 new tests **FAIL** as expected — no implementation exists (RED phase).

### Integration Tests

```bash
flutter test integration_test/phase2_e2e_test.dart
```

Integration tests cannot run without the app scaffold, but will fail with the same
"Implementation not yet created" message when the runner is configured.

### Overall Test Count

| Layer | Tests | Status |
|-------|-------|--------|
| Unit | 23 | RED (expected) |
| Widget | 190 | RED (expected) |
| E2E | 11 | RED (expected) |
| **Total New** | **224** | **ALL RED** |

---

## Notes for Implementer

1. All tests follow the `test("should [behavior] when [condition] — US-N", ...)` naming convention.
2. Each test includes commented ProviderScope pattern guidance for Riverpod integration.
3. Widget tests that need database seeding include example code for `AppDatabase.memory()`.
4. Enrichment tests reference `@GenerateNiceMocks([MockSpec<GoogleBooksClient>()])` for API mocking.
5. Test file structure mirrors `lib/features/` directory structure.
6. The existing `duplicate_detector_test.dart` and `isbn_utils_test.dart` from Phase 1 already PASS (green) — do not modify them.
7. Integration tests in `integration_test/phase2_e2e_test.dart` require the full app scaffold to be launched.

---

## Phase 2 Pipeline Allocation

| Pipeline | Workstream | Story Range | Test Count |
|----------|------------|-------------|------------|
| **FAST BUILD** | 2.1 Setup Wizard | US-1 – US-16 | 34 |
| **FAST BUILD** | 2.2 Catalog Screen | US-17 – US-49 | 66 |
| **FAST BUILD** | 2.3 Book Detail Screen | US-50 – US-73 | 38 |
| **FAST BUILD** | 2.4 Add/Edit Book UI | US-74 – US-87, US-92 – US-97, US-104 – US-117 | 51 |
| **LIGHT TDD** | 2.4 Duplicate Detection | US-88 – US-91 | 4 |
| **LIGHT TDD** | 2.4 Form Validation | US-98 – US-103 | 23 |
| **FAST BUILD** | Cross-Cutting | US-118 – US-120 | 11 |
| **FAST BUILD** | E2E Integration | Multi-story | 11 |
