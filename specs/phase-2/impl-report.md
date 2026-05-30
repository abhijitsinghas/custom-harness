# Phase 2 Implementation Report

## UI Implementation — Phase 2 (Workstream 2.4)

## Screens Built
| Screen | Mockup | Widget Tests |
|--------|--------|-------------|
| AddBookScreen | add-book.html | test/features/add_book/add_book_form_test.dart (stub/RED) |
| AddBookScreen (edit mode) | add-book.html | test/features/add_book/add_book_form_test.dart (stub/RED) |
| EnrichmentSheet | add-book.html (enrich-overlay) | test/features/add_book/add_book_enrichment_test.dart (stub/RED) |
| DuplicateDialog | add-book.html (dup-dialog) | test/features/add_book/add_book_form_test.dart (stub/RED) |
| AuthorInputField | add-book.html (author section) | test/features/add_book/add_book_form_test.dart (stub/RED) |
| GenreTagChips | add-book.html (classification) | test/features/add_book/add_book_form_test.dart (stub/RED) |
| LocationCascade | add-book.html (location) | test/features/add_book/add_book_form_test.dart (stub/RED) |
| CoverPickerSheet | add-book.html (cover section) | test/features/add_book/add_book_form_test.dart (stub/RED) |

## States Handled
- **Loading:** CircularProgressIndicator during form initialization (edit mode loads book data)
- **Empty:** Form renders with empty/default values; author list shows only "+ Add Author" chip; genre/tag rows show only "+ Add" chip; cover preview shows book icon placeholder
- **Error:** Error screen with retry button on form load failure; validation errors shown inline per field; enrichment errors shown in bottom sheet with retry
- **Data:** Full form with all 8 sections populated; edit mode pre-fills all fields from existing book

## Files Created/Modified

### New Files
- `lib/core/book_validator.dart` — Validation logic for title, ISBN, publication year, page count, price
- `lib/data/api/google_books_providers.dart` — Riverpod providers for GoogleBooksClient and cache DAO
- `lib/features/add_book/add_book_provider.dart` — BookFormNotifier (ChangeNotifier) managing all form state
- `lib/features/add_book/add_book_screen.dart` — Full form screen with 8 sections
- `lib/features/add_book/widgets/author_input_field.dart` — Type-ahead author search with disambiguation
- `lib/features/add_book/widgets/genre_tag_chips.dart` — Multi-select chips with inline "+ Add"
- `lib/features/add_book/widgets/location_cascade.dart` — Cascading Room → Cupboard → Shelf dropdowns
- `lib/features/add_book/widgets/enrichment_sheet.dart` — Google Books enrichment bottom sheet with skeleton loaders
- `lib/features/add_book/widgets/duplicate_dialog.dart` — Duplicate warning dialog with Cancel/Add Anyway
- `lib/features/add_book/widgets/cover_picker_sheet.dart` — Cover source picker (Camera/Gallery/Online)

### Modified Files
- `lib/app.dart` — Updated `/book/edit/:id` route to use `AddBookScreen(editBookId: id)` instead of `BookDetailScreen`

## Architecture

### State Management
- Uses `Provider.family<BookFormNotifier, BookFormParams>` with ChangeNotifier
- Form state is mutable within the notifier; UI rebuilds via `ref.watch()`
- All form methods are on the notifier (setTitle, setIsbn, saveBook, searchEnrichment, etc.)

### Form Sections (matching mockup)
1. **Basic Info:** Title*, ISBN, Language dropdown, Format segmented buttons
2. **Authors:** Type-ahead search, existing author selection, new author creation, disambiguation prompt
3. **Details:** Publisher, Edition, Publication Date (date picker, year extraction), Page Count, Description
4. **Classification:** Genre multi-select chips + "+ Add", Tag multi-select chips + "+ Add"
5. **Location:** Cascading Room → Cupboard → Shelf dropdowns with "None" option
6. **Purchase:** Purchase Date (full calendar), Price Paid, Condition filter chips
7. **Cover Image:** Preview (placeholder or file image) + 3 action buttons
8. **Notes:** Free text area

### Duplicate Detection
- ISBN exact match via `DuplicateDetector`
- Fuzzy title+author match via Levenshtein similarity (≥80% threshold)
- Dialog with matched book details + "Add Anyway" / "Cancel"

### Enrichment
- Manual "Enrich Online" button in app bar
- Auto-enrich debounced at 1.5s (when enabled)
- Skeleton loaders during search
- Result cards with cover, title, author, year
- Per-field acceptance via "Apply Selected"
- Green checkmarks on enriched sections
- Quota exhausted state disables button
- Offline/timeout error states with retry

### Validation
- Title: required (non-empty, non-whitespace)
- ISBN: optional; if provided, must be 10 or 13 digits
- Publication Year: optional; if provided, must be 1000–current year
- ISBN-10 auto-converted to ISBN-13 on save via `toIsbn13()`

## Decisions Made

1. **ChangeNotifier over AsyncNotifier:** Used `Provider.family` with `ChangeNotifier` instead of `AsyncNotifierProvider.family` because Riverpod 3.x/4.x has a different API for family notifiers. The ChangeNotifier approach is simpler and works correctly with family providers.

2. **Form State Structure:** Kept all form fields as simple types (String, List, enum) rather than complex value objects. This makes the notifier easier to test and reason about.

3. **Edit Mode Pre-fill:** Loads full `BookWithDetails` from DAO in the notifier's `_initialize()` method, pre-filling all fields including the location hierarchy (loads cupboards/shelves for the existing location).

4. **Author Disambiguation:** Shows inline dialog (not full AlertDialog) within the author input field for a better UX. "Yes, same person" links to existing author; "No, different person" creates new author with disambiguation suffix.

5. **Genre/Tag Dedup:** When creating a new genre/tag inline, first checks for existing item with same name (case-insensitive). If found, selects the existing one instead of creating a duplicate.

6. **Cover Image:** Uses `Image.file` for cover preview when a path is set. Falls back to book icon placeholder. The actual image capture/picking is stubbed (would require image_picker integration).

7. **Navigation on Save:** Uses `context.go(kRouteCatalog)` to navigate back to catalog after successful save.

## Test Status

- **Compilation:** ✅ All tests compile successfully
- **RED Phase:** ✅ All 75 tests fail with `fail('Implementation not yet created')` as expected
- **Validation tests:** Reference `isbn_utils.dart` which exists with `toIsbn13()`, `validateIsbn10Checksum()`, `validateIsbn13Checksum()`, etc.
- **Widget tests:** Use ProviderScope pattern with `Provider` (not `AsyncNotifierProvider`) for overrides

## dart analyze

```
18 issues found (0 errors, all warnings/info)
```

No compilation errors. Remaining issues are deprecation warnings (withOpacity, surfaceVariant, value→initialValue) and info-level lint suggestions.
