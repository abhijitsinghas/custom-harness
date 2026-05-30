# The Little Library — UI Specification v2 (Phase 2 Additions)

> **Purpose:** Augments `docs/ui-spec.md` with Phase 2 UI requirements. Use this to generate/update mockups for `bulk-scanner.html`, `photo-ocr.html`, and `locations.html`.
> **References:** `docs/spec-v2.md` (P2-F1, P2-F2, P2-F3), `docs/ui-spec.md` (base screens 1–20)

---

## P2-F1: Bulk Shelf Scanner — Mockup Augmentation

**Existing mockup:** `bulk-scanner.html` has spine visualization, results list, Accept/Edit/Skip, Fetch All, confidence indicators.
**Missing:** Capture step, processing progress, spine adjustment tools.

### Screen 18a: Bulk Scanner — Capture Step

**Purpose:** User captures or selects a photo of a bookshelf before processing.

**Layout:**
- **Camera Viewfinder (primary):** Full-screen camera preview with guide overlay
  - Guide overlay: dashed rectangle outline with text "Position shelf within frame. Ensure spines are clearly visible."
  - Semi-transparent vignette outside the guide area
- **Gallery Button (bottom-left):** Square thumbnail of last taken photo, tappable to open gallery
- **Capture Button (bottom-center):** Large circular shutter button with white border
- **Torch Toggle (top-right):** Flash on/off icon
- **Cancel (top-left):** Back arrow, returns to catalog

**Permission Handling:**
- First use: rationale dialog "The Little Library needs camera access to scan your bookshelf."
- Denied: "Camera access is needed. Open Settings to enable." [Open Settings]

**Gallery Picker (alternative):**
- Tapping gallery button → system photo picker or bottom sheet with recent photos
- After selecting: proceed directly to Processing Step

### Screen 18b: Bulk Scanner — Processing Step

**Purpose:** Show progress while the app detects book spines and runs OCR.

**Layout:**
- **Selected photo:** Displayed full-width with detected spine regions appearing progressively
  - Spine regions appear as numbered, colored bounding boxes overlaying the photo
  - Boxes appear one by one as detection completes (animated reveal)
- **Progress bar (below photo):** Determinate progress "Reading spines… 8 of 12 complete" with percentage bar
- **Progress subtext:** "Detecting books…" → "Reading spine 1 of 12…" → "Matching titles online…" (varies by stage)
- **Cancel button:** Stops processing, returns to Capture Step

**Stages (shown in progress subtext):**
1. "Detecting book spines…" (ML model inference)
2. "Reading spine N of M…" (OCR per spine, updates per book)
3. "Matching titles online…" (Google Books API, if online)
4. "Preparing results…" (final assembly)

**Spine Adjustment Mode:**
- After detection completes, user can enter "Adjust" mode:
  - Tappable bounding boxes with resize handles (corner and edge drag points)
  - Long-press a box to drag/reposition it
  - **Merge tool:** Button in toolbar → "Draw a rectangle around books to merge" → user draws rectangle → two adjacent boxes become one
  - **Split tool:** Button in toolbar → "Tap a spine to split it" → user taps within a box → box divides into two
  - **Reset:** Revert to original ML detection
  - "Done Adjusting" button → proceed to Results Step

### Screen 18c: Bulk Scanner — Results Step (already partially in mockup)

**Existing in mockup:** Spine thumbnails, Accept/Edit/Skip buttons, confidence badges, Fetch All, counter bar.
**Add to mockup:**
- **Header bar:** "Scan Results" with back arrow + "Review Accepted (N)" button (disabled until ≥1 accepted)
- **Empty results:** "No books detected. Try a clearer photo." [Retake Photo]
- **Accepted counter bar:** Sticky at bottom: "5 of 12 accepted" + "Fetch All" button (secondary) + "Review Accepted" button (primary, enabled when ≥1 accepted)
- **Skip confirmation:** When tapping Skip, book card animates out (slide left) with undo snackbar: "Skipped 'Atomic Habits'. [Undo]"
- **Edit flows into Screen 4 (Add Book Form)** pre-filled with OCR + match data
- **Offline state:** Only OCR text shown (no Google Books matches). "Offline — title matching unavailable" banner.

---

## P2-F2: Hindi / Sanskrit OCR (Devanagari Script) — New UI

**Existing mockup:** `photo-ocr.html` shows Latin script OCR only.
**Missing:** Script detection indicator, mixed-script display, Devanagari text support.

### Addition to Screen 6: Photo OCR Screen — Script Detection

**Purpose:** When OCR processes text in multiple scripts, the UI must show which script was detected per text block and handle mixed output.

**Layout additions to existing Photo OCR screen:**

#### Script Indicator per Text Block
- Each detected text block in the results shows:
  - The extracted text
  - A small script badge next to it:
    - `[A]` or "Latin" for English/Roman script (light blue)
    - `[द]` or "Devanagari" for Hindi/Sanskrit script (amber/orange)
    - `[?]` for unknown/undetected script (grey)
  - Tap behavior unchanged (assign to Title/Author)

#### Mixed-Script Shelf Display
- When a photo contains both Latin and Devanagari text:
  - Highlighted regions on the photo are color-coded by script:
    - Blue bounding boxes = Latin text
    - Orange bounding boxes = Devanagari text
  - Legend below photo: "🔵 Latin   🟠 Devanagari"
  - Text chips below maintain script badge

#### Language Hint in Assignment
- When user assigns text to "Title" field:
  - If assigned text is Devanagari, auto-suggest book language as "Hindi" or "Sanskrit"
  - A subtle chip appears: "Detected: Hindi script — set language to Hindi?" tappable to auto-set
- If both Latin and Devanagari text are detected (e.g., English book with Hindi title on same shelf):
  - The script badges help user distinguish which text belongs to which book

#### Google Books API Integration
- When searching Google Books with Devanagari text:
  - Query includes the script/language hint for better results
  - Match results display shows original script (not transliterated)

#### OCR Processing States (Phase 2)
- Processing: "Scanning text… (Latin + Devanagari)" when mixed scripts detected
- Performance: Devanagari OCR may be slower — show per-block progress

---

## P2-F3: Bulk Location Assignment — Mockup Augmentation

**Existing mockup:** `locations.html` has a stub `alert("Assign books flow")` for the Assign Books action.
**Missing:** Full book picker flow from a shelf.

### Addition to Screen 8: Location Management — Assign Books Flow

**Purpose:** User selects a shelf, then picks multiple books to assign to it.

#### Flow Entry
- From the locations nested list, user taps a Shelf row
- Shelf row expands to show options: "Edit Name" | "Assign Books" | "View Books (N)" | "Delete"
- Tapping "Assign Books" opens the book picker

**Replaces the current stub `alert()` in the mockup.**

#### Book Picker Screen
- **App bar:** "Assign to [Shelf Name]" with back arrow
- **Search bar:** Filter books by title, author (same as catalog search)
- **Filter chips:** Genre, Language, Status (same as catalog) — helps narrow selection
- **Book list (scrollable):**
  - Each book row shows:
    - Checkbox (left)
    - Cover thumbnail (small, 40×56dp)
    - Title + Primary author
    - Current location badge (e.g., "Study / Shelf 1" or "No location")
    - If book is already on this shelf: badge "Already here" (green outline)
    - If book is checked out/loaned: status badge still shown
  - Books already on this shelf are pre-selected
- **Selection counter (sticky bottom bar):**
  - "X books selected" + "Assign to [Shelf Name]" button (primary)
  - If 0 selected: button disabled, shows "Select books to assign"
- **Confirmation dialog on assign:**
  - "Move X books to [Shelf Name]?"
  - Lists: "Y books will be moved from other locations. Z books currently have no location."
  - [Cancel] [Assign]

#### Post-Assign
- Success snackbar: "X books assigned to [Shelf Name]. [View]"
- Tapping "View" navigates to catalog filtered by that shelf
- Books' location badges update immediately (reactive)

---

## Summary: What Each Mockup Needs

| Mockup File | What to Add | Section Reference |
|------------|-------------|-------------------|
| `bulk-scanner.html` | Screen 18a — Capture step (camera/gallery + guide overlay) | P2-F1 §18a |
| `bulk-scanner.html` | Screen 18b — Processing step (progress bar, stage indicators, spine adjustment tools) | P2-F1 §18b |
| `bulk-scanner.html` | Screen 18c — Add skip confirmation undo, empty state, offline banner | P2-F1 §18c |
| `photo-ocr.html` | Script badge per text block (`[A]` / `[द]` / `[?]`) | P2-F2 |
| `photo-ocr.html` | Color-coded bounding boxes by script (blue=Latin, orange=Devanagari) | P2-F2 |
| `photo-ocr.html` | Language auto-suggest chip ("Detected: Hindi script") | P2-F2 |
| `photo-ocr.html` | Mixed-script processing indicator | P2-F2 |
| `locations.html` | Expand shelf row with action options (replace stub alert) | P2-F3 |
| `locations.html` | Full book picker screen with checkboxes, search, filters, location badges | P2-F3 |
| `locations.html` | Selection counter sticky bar + confirmation dialog | P2-F3 |
| `locations.html` | Post-assign snackbar | P2-F3 |
