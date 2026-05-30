# Code Review — Phase 2, Round 1

**Round:** 1 of 2
**`dart analyze`:** 36 issues (1 error in test/widget_test.dart, 0 errors in lib/)
**`flutter test` (Phase 2 tests only):** 0 passed, 213 failed — all RED with `fail('Implementation not yet created')` as expected for FAST_BUILD pipeline
**Build:** `flutter build apk --debug` succeeds

---

## BLOCKER — Must Fix

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 1 | `add_book_provider.dart:708` | `addBookFormProvider` is a `Provider.family<BookFormNotifier, BookFormParams>` wrapping a `ChangeNotifier`. A plain `Provider` does **not** listen to `notifyListeners()`, so the Add Book UI never rebuilds when form state changes (validation errors, enrichment results, author additions, duplicate dialogs). AGENTS.md forbids `ChangeNotifierProvider`; refactor to `@riverpod` + `Notifier`/`AsyncNotifier` with immutable state (see `CatalogNotifier` for correct pattern). | US-74–US-117 |
| 2 | `add_book_screen.dart:137` | `TextFormField` uses `initialValue: notifier.title` + `onChanged`. Because the widget does not listen to notifier changes, enrichment-applied values (`applyEnrichment`) mutate `notifier.title` but the text field never updates visually. Use `TextEditingController` managed by the notifier or a fully reactive pattern. | US-85 |
| 3 | `book_detail_screen.dart:708` | `_doDelete` directly instantiates `BookDao(db)` inside the UI layer. AGENTS.md: "UI Layer: Widgets only. No direct database access." Route through a provider / repository. | US-57 |
| 4 | `book_detail_screen.dart:730` | `_restoreBook` directly instantiates `BookDao(db)` inside the UI layer. Same architecture violation as #3. | US-58 |
| 5 | `book_card.dart:317` | `_getPrimaryAuthor` is a stub returning `[]` unconditionally. Every card shows "Unknown Author" instead of the real primary author. The semantic label also hardcodes "by Unknown Author". | US-17, US-44 |
| 6 | `catalog_state_provider.dart:249` | `_buildBookFilters()` never maps `state.filters.checkedOutByMe` into the `BookFilters` object passed to the DAO. The "Checked Out by Me" chip toggles UI state but the DAO query never receives the filter, so results are unchanged. | US-29 |
| 7 | `catalog_state_provider.dart:309` | `_applySortInMemory` for `CatalogSort.author` sorts by `a.title.toLowerCase()` instead of by author name, and does **not** duplicate multi-author books under each author as required. | US-23 |
| 8 | `add_book_provider.dart:616` | `_performSave` (add mode) stores `isbn: isbn.isNotEmpty ? isbn : null` — the raw input ISBN, **not** the converted ISBN-13. `toIsbn13()` is called only for duplicate detection. The stored `isbn` must be normalized to ISBN-13 per US-99. | US-99 |
| 9 | `duplicate_dialog.dart:74` | `ExactIsbnMatch` duplicate message displays `notifier.title` (the **new** book's title) instead of the **matched existing** book's title. Users see the wrong book name in the warning. | US-88 |
| 10 | `duplicate_dialog.dart:35` | Dialog only shows "Cancel" / "Add Anyway". Missing: (a) matched book cover thumbnail, (b) "Restore Existing" vs "Add as New" options when the duplicate is a soft-deleted book (US-91). | US-88, US-91 |
| 11 | `author_input_field.dart:136` | "No, different person" button calls `cancelAuthorDisambiguation()` which just dismisses the prompt. It never asks for the required `disambiguation` note nor creates a new author with a modified `normalized_name`. The `confirmAuthorDisambiguation(false, note)` path exists in the notifier but is unreachable from the UI. | US-77 |
| 12 | `setup_screen.dart:303` | Step 1 "Skip for now" `TextButton` has an **empty** `onPressed: () {}`. It never calls `ref.read(setupWizardProvider.notifier).skipSignIn()`, so the skip flow is non-functional. | US-2 |

---

## SHOULD FIX — Important

| # | File:Line | Issue | Story |
|---|-----------|-------|-------|
| 13 | `setup_screen.dart:652` | `_SyncOffline` "Start Browsing" button `onPressed` is empty; does not navigate to catalog. | US-11 |
| 14 | `book_detail_screen.dart:543` | `_shareBook` shares only `book.title`. The story requires a formatted summary: "[Title] by [Author] (Format) — Status on Location". | US-55 |
| 15 | `book_detail_screen.dart:355` | `_StatusBadge` displays only the raw status enum name (e.g., "Available"), not the location-aware text required by US-71 ("Status: Available on Study Shelf 2"). `BookDetailState.statusText` already computes the correct string but is unused. | US-71 |
| 16 | `book_card.dart:298` | `_buildStatusBadge` for `available` shows generic "Available" badge. Does not show location name ("Study / Shelf 2") or "No location" per US-30 priority #3/#4. | US-30 |
| 17 | `book_card.dart:278` | `_buildStatusBadge` does not implement overdue detection (`BookLoan.dueDate` vs `DateTime.now()`). Missing red "Overdue — due [date]" badge. | US-30 |
| 18 | `book_detail_screen.dart:133` | Cover hero `Semantics` label is `'Cover image for ${book.title}'` but US-70 requires `'Cover image for [Title] by [Primary Author]'`. | US-70 |
| 19 | `book_detail_screen.dart:487` | "Return to Shelf" button has empty `onPressed: () {}`. Non-functional. | US-52 |
| 20 | `book_detail_screen.dart:502` | "Returned" button has empty `onPressed: () {}`. Non-functional. | US-52 |
| 21 | `catalog_widgets.dart:606` | `_FilterChip` height is 36dp. Material accessibility guidelines require tappable targets ≥48dp in at least one dimension. | US-47 |
| 22 | `catalog_state_provider.dart:265` | `_getUnplacedBooks()` fetches **all** books (`limit: 1000`) into memory then filters in Dart. For large libraries this is an N+1 memory bomb. Replace with a single SQL join (`LEFT JOIN book_shelf WHERE shelf_id IS NULL`). | US-28, US-119 |
| 23 | `catalog_state_provider.dart:277` | `_getUnplacedBookCount()` fetches up to 10,000 books into memory to compute a count. Use `COUNT(*)` query instead. | US-28, US-119 |
| 24 | `add_book_provider.dart:596` | Edit mode performs **two separate DB writes**: `updateBookWithRelations` then a second `update(_db.books).write(...)`. If the second fails, the book is left in a partially-updated state. Wrap in a single drift transaction. | US-75 |
| 25 | `add_book_provider.dart:659` | `searchEnrichment()` fires an HTTP request but there is no cancellation token. If the title changes during a slow request, the stale result may overwrite newer state (US-92 debounce only cancels the timer, not the in-flight future). | US-92 |
| 26 | `duplicate_dialog.dart:67` | `DuplicateDialog` has no `barrierDismissible: false` on the parent `showDialog` call in `AddBookScreen._handleSave`, but US-114 explicitly requires "Tapping outside the dialog does not dismiss it." (The `showDialog` call in `_handleSave` does set `barrierDismissible: false`, so this is technically correct, but the dialog itself should also set `barrierDismissible: false` for defense-in-depth.) | US-114 |
| 27 | `setup_screen.dart:423` | Step-accessibility `Semantics` widget is created but **discarded** (not part of the returned widget tree). TalkBack will never announce the step label. Move it into the returned `Column`. | US-14 |
| 28 | `catalog_screen.dart:51` | `GlobalKey<ScaffoldState> scaffoldKey` is instantiated inside `build()`, causing a new key on every rebuild. Move to widget field or use a stable key. | — |
| 29 | `add_book_screen.dart:525` | Uses deprecated `Theme.of(context).colorScheme.surfaceVariant` (replaced by `surfaceContainerHighest`). | — |
| 30 | `add_book_screen.dart:577` | Uses deprecated `Colors.black.withOpacity(0.08)` (replaced by `withValues(alpha: ...)`). | — |
| 31 | `add_book_screen.dart:588` | `showModalBottomSheet` missing explicit type argument (`inference_failure_on_function_invocation`). | — |
| 32 | `add_book_screen.dart:639` | Uses deprecated `Colors.black.withOpacity(0.08)` again. | — |
| 33 | `add_book_screen.dart:693` | `showDialog` missing explicit type argument. | — |
| 34 | `add_book_screen.dart:732` | `showModalBottomSheet` missing explicit type argument. | — |
| 35 | `enrichment_sheet.dart:114` | Uses deprecated `Colors.grey.withOpacity(0.2)`. | — |
| 36 | `enrichment_sheet.dart:205` | Uses deprecated `theme.colorScheme.surfaceVariant`. | — |
| 37 | `location_cascade.dart:28` | `DropdownButtonFormField` uses deprecated `value` parameter (replaced by `initialValue`). | — |
| 38 | `location_cascade.dart:51` | Same deprecated `value` parameter. | — |
| 39 | `location_cascade.dart:74` | Same deprecated `value` parameter. | — |

---

## NICE TO HAVE — Optional

| # | File:Line | Suggestion | Story |
|---|-----------|------------|-------|
| 40 | `catalog_widgets.dart:518` | `SkeletonBookCard` uses static colored containers. A true shimmer animation (`Shimmer` widget or `AnimatedContainer` with gradient sweep) would better match US-48. | US-48 |
| 41 | `add_book_provider.dart` | Cover image optimization (resize to 800px, JPEG 80%) is not implemented. `_performSave` stores the raw `coverImagePath`. | US-83 |
| 42 | `cover_picker_sheet.dart` | Storage permission rationale (US-95) and "Open Settings" on second denial (US-96) are not implemented; cover picker is stubbed with snackbars. | US-95, US-96 |
| 43 | `add_book_screen.dart:343` | Publication date `showDatePicker` opens a full calendar but only extracts the year. A dedicated year picker or `DatePickerDialog` with `initialDatePickerMode: DatePickerMode.year` would better match the "year-only" UX. | US-98 |
| 44 | `add_book_screen.dart:137` | `_SectionCard` renders section headers as plain `Text`, not `Semantics(header: true)`. TalkBack heading navigation won't recognize them. | US-112 |
| 45 | `book_detail_screen.dart:91` | Deleted-book cover uses full grayscale matrix (1.0) + `Opacity(0.6)`. Story specifies `grayscale(0.7) opacity(0.6)`. Use a blended `ColorFilter` for partial desaturation. | US-60 |
| 46 | `test/widget_test.dart:16` | References `MyApp` which does not exist (app entry point is `LittleLibraryApp`). Causes the sole `dart analyze` error. Delete or update to `const LittleLibraryApp()`. | — |

---

## Architecture Observations

### Correct patterns (keep these)
- `CatalogNotifier` (`@riverpod` + immutable `CatalogState`) is the canonical pattern and rebuilds correctly.
- `SyncStatusNotifier`, `ThemeModeNotifier`, and `SetupWizardNotifier` all follow Riverpod conventions properly.
- DAO layer uses `@DriftAccessor` and typed queries; drift tables have proper indices and converters.
- Repository layer (`BookRepository`, `LocationRepository`, etc.) correctly sits between UI and DAO.
- Navigation routes are centralized in `core/routes.dart` and registered in `app.dart` via `go_router`.

### Violations found
- **ChangeNotifier in plain Provider (#1 above):** The Add Book form state management is architecturally broken for Riverpod. It must be rewritten as an immutable-state `@riverpod` Notifier (or AsyncNotifier).
- **UI → DAO direct access (#3, #4 above):** `BookDetailScreen` instantiates `BookDao` directly. Always route through a repository provider.
- **Deprecated API usage:** 10+ deprecation warnings across Phase 2 files indicate the code was written against an older Flutter API surface or wasn't checked with `dart analyze --fatal-infos`.

---

## Verdict: NEEDS FIXES (12 blockers)

The implementation is structurally sound in the data layer and mostly correct in the catalog/setup screens, but the **Add Book form has a critical rebuild bug** that makes it non-functional for user interaction. In addition, several user-story requirements are outright missing or incorrectly wired:

1. Skip sign-in doesn't work.
2. Author disambiguation "different person" path is a no-op.
3. Duplicate dialog lacks the "Restore Existing" branch and shows the wrong book title.
4. ISBN-13 normalization is missing on save.
5. Book cards never show real authors.
6. "Checked Out by Me" filter is UI-only (no query effect).
7. Author sort doesn't duplicate rows per author.
8. Book detail delete/restore directly accesses DAOs from widgets.

**Recommended fix order:**
1. Rewrite `addBookFormProvider` as `@riverpod` + immutable-state `Notifier` (fixes #1, #2, and enables all enrichment/duplicate UI flows).
2. Wire up `checkedOutByMe` into `BookFilters` and DAO query (#6).
3. Fix `_getPrimaryAuthor` in `book_card.dart` (#5).
4. Fix skip sign-in `onPressed` (#12).
5. Fix author disambiguation UI path (#11).
6. Fix duplicate dialog message + restore option (#9, #10).
7. Store converted ISBN-13 on save (#8).
8. Fix author-sort duplication logic (#7).
9. Remove DAO instantiation from `BookDetailScreen` (#3, #4).
10. Address deprecation warnings (#29–#39).
