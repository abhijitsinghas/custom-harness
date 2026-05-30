# Handoff Plan — Remaining Workstreams

> **Generated:** 2026-05-30
> **Purpose:** Resume from old pipeline. Phases 0-2 completed, Phase 3 stories done but unimplemented, Phases 4-6 not started.
> **Pipeline:** 3-agent → feature agents in dependency order. Each commits independently.
> **Gate check before starting:** `git status` clean. `flutter analyze` clean. `flutter test` all passing.

---

## Workstreams (dependency order)

### W01: Barcode Scanner (formerly Phase 3.1)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** existing codebase (Phase 0-2 has everything needed)
- **Files:**
  - `lib/features/scanner/barcode/barcode_scanner_screen.dart` (full-screen camera, barcode detection, ISBN lookup)
  - `lib/features/scanner/barcode/widgets/scan_overlay.dart` (animated corner brackets + scan line)
  - `lib/features/scanner/barcode/widgets/detected_bar.dart` (ISBN value + Lookup/Dismiss buttons)
  - `test/features/scanner/barcode/barcode_scanner_test.dart`
- **Description:** Full-screen camera viewfinder with ML Kit barcode scanning. Animated scan line overlay. Torch toggle. On detection: show detected ISBN with lookup option. Google Books API search → pre-fill Add Book form. Offline: pre-fill ISBN only. "Enter ISBN manually" fallback. Camera permission rationale dialog.
- **Stories reference:** `specs/phase-3/stories.md` (Barcode Scanner sections)

### W02: Photo OCR (formerly Phase 3.2)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** W01 (shares scanner patterns, not code dependency)
- **Files:**
  - `lib/features/scanner/ocr/photo_ocr_screen.dart` (camera/gallery picker, ML Kit text recognition)
  - `lib/features/scanner/ocr/widgets/ocr_result_screen.dart` (bounding boxes, tappable chips, field assignment)
  - `lib/features/scanner/ocr/widgets/crop_editor.dart` (crop/rotate before OCR)
  - `test/features/scanner/ocr/photo_ocr_test.dart`
- **Description:** Camera/Gallery picker → ML Kit text recognition → extracted text as tappable chips → user assigns to Title/Author/Language fields. Online: Google Books search with extracted text. Offline: manual assignment. Crop/rotate editor before processing. No text detected fallback.
- **Stories reference:** `specs/phase-3/stories.md` (Photo OCR sections)

### W03: Voice Input + LLM (formerly Phase 3.3)
- **Tier:** Complex
- **Model:** deepseek-v4-pro high
- **Depends on:** W01, W02 (order only, not code)
- **Files:**
  - `lib/features/voice_input/voice_input_screen.dart` (mic UI, waveform animation, live transcription)
  - `lib/features/voice_input/voice_extraction_service.dart` (LLM extraction pipeline: cloud API + regex fallback)
  - `test/features/voice_input/voice_input_test.dart`
- **Description:** Microphone UI with waveform. Platform STT via `speech_to_text`. LLM extraction pipeline: Tier 1 (on-device placeholder), Tier 2 (Gemini API structured extraction), Tier 3 (regex fallback). Extracted fields → pre-fill Add Book form. Voice search mic on Catalog (F5) already done in Phase 2.
- **Stories reference:** `specs/phase-3/stories.md` (Voice Input sections)

### W04: Location Management (formerly Phase 4.1)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** existing codebase (dao/repo exist)
- **Files:**
  - `lib/features/locations/locations_screen.dart` (nested tree: Room→Cupboard→Shelf)
  - `lib/features/locations/widgets/location_tree_tile.dart` (expandable tile with actions)
  - `lib/features/locations/widgets/location_delete_dialog.dart` (book count warning)
  - `test/features/locations/locations_screen_test.dart`
- **Description:** Nested expandable tree hierarchy. Context-aware FAB. Swipe-to-delete with confirmation. Assign Books overlay (scaffolded, refined later in W09).
- **Mockup:** `locations.html`
- **Stories:** Create from specs/plan.md §4.1

### W05: Lending & Status Tracking (formerly Phase 4.2)
- **Tier:** Complex
- **Model:** deepseek-v4-pro high
- **Depends on:** W04 (order only)
- **Files:**
  - `lib/features/lending/checkout_screen.dart` (bottom sheet: family member dropdown + custom name)
  - `lib/features/lending/loan_screen.dart` (borrower details, dates, notes)
  - `lib/features/lending/active_loans_screen.dart` (checked out + loaned sections)
  - `lib/features/lending/widgets/return_dialog.dart` (3 return options)
  - `lib/features/lending/widgets/overdue_banner.dart` (catalog banner)
  - `test/features/lending/loan_flow_test.dart`
- **Description:** Checkout bottom sheet with status transitions (available→checkedOut→available). Loan form with borrower details. Return dialog with location options. Overdue tracking and indicators. Active Loans screen in drawer. Status transition validation.
- **Mockups:** `checkout-loan.html`, `active-loans.html`, `book-detail.html` (status section)
- **Stories:** Create from specs/plan.md §4.2

### W06: Management Screens (formerly Phase 4.3)
- **Tier:** Simple
- **Model:** deepseek-v4-flash high
- **Depends on:** existing codebase (dao/repo exist)
- **Files:**
  - `lib/features/settings/management/genres_screen.dart`
  - `lib/features/settings/management/tags_screen.dart`
  - `lib/features/settings/management/languages_screen.dart`
  - `lib/features/settings/management/widgets/management_list_tile.dart` (shared list tile)
  - `lib/features/settings/management/widgets/add_edit_dialog.dart` (shared dialog)
  - `test/features/settings/management_screen_test.dart`
- **Description:** Unified list+CRUD pattern for Genres, Tags, Languages. Visibility toggle, built-in items (locked), custom items swipe-to-delete. Seed 20 genres + 3 languages. Delete confirmation with usage count.
- **Mockup:** `management.html`
- **Stories:** Create from specs/plan.md §4.3

### W07: Recent Activity Feed (formerly Phase 5.1)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** existing codebase (ChangeLogDao exists)
- **Files:**
  - `lib/features/activity/activity_screen.dart` (chronological feed with filter chips)
  - `lib/features/activity/widgets/activity_card.dart` (user avatar, book cover, timestamp, description)
  - `lib/features/activity/activity_filter_chips.dart`
  - `test/features/activity/activity_screen_test.dart`
- **Description:** Chronological feed from change_log_table. Filter chips (All, Added, Edited, Checked Out, Loaned, Returned). Natural language event descriptions. Tap → Book Detail. Pull-to-refresh, infinite scroll (50/page). Empty state.
- **Mockup:** `recent-activity.html`
- **Stories:** Create from specs/plan.md §5.1

### W08: Conflict Resolver + Sync UI (formerly Phase 5.2)
- **Tier:** Complex
- **Model:** deepseek-v4-pro high
- **Depends on:** existing codebase (SyncEngine exists)
- **Files:**
  - `lib/features/sync_ui/conflict_resolver_screen.dart` (side-by-side conflict cards, editable, adopt chip)
  - `lib/features/sync_ui/sync_status_screen.dart` (last sync, pending count, sync now button)
  - `lib/features/sync_ui/widgets/conflict_card.dart`
  - `test/features/sync_ui/conflict_resolver_test.dart`
- **Description:** Displays queued sync conflicts. Per-conflict: title, field name, two versions (A vs B) with timestamps. Inline editable field with "Keep Mine/Keep Theirs/Custom" actions. Remaining count. Completion state.
- **Mockup:** `conflict-resolver.html`
- **Stories:** Create from specs/plan.md §5.2

### W09: Settings, Export, Sharing (formerly Phase 5.3)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** existing codebase (auth, sync)
- **Files:**
  - `lib/features/settings/settings_screen.dart` (full settings: account, sync, preferences, data, about)
  - `lib/features/settings/export_screen.dart` (JSON/CSV/Text format selector, share sheet)
  - `lib/features/settings/share_library_screen.dart` (link copy, QR, email invite)
  - `test/features/settings/settings_screen_test.dart`
- **Description:** Settings with account section, sync status, sharing, preferences (auto-enrich, API key, sort order), data management. Export in 3 formats. Share via link/QR/email.
- **Mockups:** `settings.html`, `export.html`, `share-library.html`
- **Stories:** Create from specs/plan.md §5.3

### W10: Deleted Books & Edge Cases (formerly Phase 5.4)
- **Tier:** Simple
- **Model:** deepseek-v4-flash high
- **Depends on:** W09 (order only)
- **Files:**
  - `lib/features/deleted/deleted_books_screen.dart` (catalog variant with is_deleted filter)
  - `lib/features/change_history/change_history_screen.dart` (per-book event timeline)
  - `lib/features/force_update/force_update_screen.dart` (blocking screen)
  - `test/features/deleted/deleted_books_test.dart`
- **Description:** Deleted books catalog (greyed out, restore only). Change history timeline per book. Force update blocking screen. Image storage full warning. Empty/error/loading states across all screens. Accessibility pass.
- **Mockups:** `deleted-books.html`, `change-history.html`, `force-update.html`
- **Stories:** Create from specs/plan.md §5.4

### W11: Bulk Shelf Scanner (formerly Phase 6.1)
- **Tier:** Complex
- **Model:** deepseek-v4-pro xhigh
- **Depends on:** W01, W02 (scanner infra), existing codebase
- **Files:**
  - `lib/features/bulk_scan/bulk_scanner_screen.dart` (capture → process → adjust → results → review)
  - `lib/features/bulk_scan/widgets/spine_detection_overlay.dart`
  - `lib/features/bulk_scan/widgets/bounding_box_editor.dart` (resize, merge, split, delete)
  - `lib/features/bulk_scan/widgets/result_chip.dart` (confidence badges)
  - `test/features/bulk_scan/bulk_scanner_test.dart`
- **Description:** Full bulk scanning flow. Camera with shelf guide overlay. Spine detection + OCR. Interactive adjustment (resize/merge/split). Results with confidence. Batch enrich. FAB speed dial update. Offline mode.
- **Mockup:** `bulk-scanner.html`
- **Stories:** Create from specs/plan.md §6.1

### W12: Hindi/Sanskrit OCR (formerly Phase 6.2)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** W02 (Photo OCR)
- **Files:** (enhancements to existing Photo OCR files)
  - `lib/features/scanner/ocr/photo_ocr_screen.dart` (enhanced: script detection, dual model)
  - `lib/features/scanner/ocr/widgets/script_badge.dart` (language badge per text block)
  - `test/features/scanner/ocr/devanagari_ocr_test.dart`
- **Description:** Enable ML Kit Devanagari model. Auto-detect script per text block. Color-coded bounding boxes. Language auto-suggest. Google Books API language hint.
- **Stories:** Create from specs/plan.md §6.2

### W13: Bulk Location Assignment (formerly Phase 6.3)
- **Tier:** Medium
- **Model:** deepseek-v4-pro high
- **Depends on:** W04 (Locations), existing catalog code
- **Files:** (enhancements to Locations screen)
  - `lib/features/locations/locations_screen.dart` (enhanced: shelf actions, book picker overlay)
  - `lib/features/locations/widgets/book_picker_overlay.dart` (search + filter + checkbox list)
  - `test/features/locations/bulk_location_test.dart`
- **Description:** From shelf row → Assign Books → book picker with search, filter chips, checkboxes. Selection counter. Current location badges.
- **Stories:** Create from specs/plan.md §6.3

---

## Migration Notes

| Consideration | Handling |
|--------------|----------|
| **Existing Phase 3 stories** | Already at `specs/phase-3/stories.md` — reference for feature agents |
| **No stories for Phases 4-6** | Feature agents write tests alongside code; no separate story-writing step needed |
| **Existing impl-report/reviews** | Keep in `specs/phase-*/` for reference, not used by new pipeline |
| **Phase boundaries** | Dropped — workstreams are the only unit. Order by dependency, not phase number |
| **Model routing** | Simple → Flash high, Medium → Pro high, Complex → Pro high, Foundation → Pro xhigh |
| **Git commits** | Each workstream commits independently: `git add -A && git commit -m "W{N}: {Name}"` |

## Tier Summary

| Tier | Workstreams | Model | Thinking |
|------|-------------|-------|----------|
| Simple (2) | W06, W10 | `deepseek-v4-flash` | high |
| Medium (7) | W01, W02, W04, W07, W09, W12, W13 | `deepseek-v4-pro` | high |
| Complex (4) | W03, W05, W08, W11 | `deepseek-v4-pro` | high (W03/W05/W08) / xhigh (W11) |

**Total: 13 workstreams remaining.**
