# The Little Library — UI Specification v3 (Spine Adjustment Gap)

> **Purpose:** Single remaining gap in Phase 2 mockups. `docs/The-Little-Library---Proto-2/bulk-scanner.html` is missing the spine adjustment mode. All other P2-F1, P2-F2, and P2-F3 requirements are implemented.
> **Target mockup:** `bulk-scanner.html` — add between the Processing Step and Results Step.

---

## Gap: Spine Adjustment Mode (bulk-scanner.html)

**Where to insert:** After the processing progress completes, before transitioning to the Results Step. The user needs a chance to review and correct the ML-detected spine regions.

### Flow

```
Capture → Processing (spines detected) → [NEW: Adjustment Mode] → Results (Accept/Edit/Skip)
```

The adjustment mode is an optional step. If the user taps "Done Adjusting" without changes, it proceeds directly to Results.

---

### Screen: Spine Adjustment Mode

**Trigger:** Processing completes. Instead of auto-advancing to Results, the app enters Adjustment Mode.

**Layout:**

#### Top Bar
- **Title:** "Adjust Spines" 
- **Left:** Back arrow (returns to Processing Step to re-detect)
- **Right:** "Done" button (proceeds to Results Step)

#### Shelf Photo (Interactive)
- The captured/selected shelf photo fills the screen
- Detected spine regions shown as **numbered, interactive bounding boxes**:
  - Each box has a number label (1, 2, 3…) in the top-right corner
  - Boxes are semi-transparent brown with a 2.5px primary-color border
  - **Selected box** (tapped once): border becomes thicker (3.5px), color changes to amber/secondary, resize handles appear

#### Resize Handles (visible on selected box)
- **8 handle points:** 4 corners + 4 edge midpoints
- Each handle is a 12×12px white circle with a 2px primary-color border
- Corner handles: resize diagonally (maintain aspect ratio optional)
- Edge handles: resize horizontally (left/right edges) or vertically (top/bottom edges)
- Touch/drag a handle to resize the bounding box
- Visual feedback: box dimensions update in real-time as user drags

#### Drag to Reposition
- **Long-press** (300ms) on any box → box lifts slightly (elevation shadow)
- Drag to move the box to a new position
- Release to drop
- Other boxes remain stationary

#### Toolbar (below photo, above the fold)
A horizontal row of icon buttons:

| Icon | Label | Action |
|------|-------|--------|
| 🔗➕ | **Merge** | Enters merge mode |
| ✂️ | **Split** | Enters split mode |
| ↺ | **Reset** | Reverts all changes to original ML detection |
| 🗑️ | **Delete** | Removes selected box (for false positives — e.g., detected a gap as a spine) |

#### Merge Mode
1. User taps "Merge" button → button highlights (amber), cursor/touch mode changes
2. Instruction text appears: "Draw a rectangle around the books you want to merge"
3. User draws a rectangle on the photo (touch-drag to define area)
4. Any two or more boxes fully inside the drawn rectangle merge into one larger box
5. The merged box gets the lowest number of the merged set
6. Remaining boxes renumber automatically
7. Tap "Done" or tap "Merge" again to exit merge mode

**Undo merge:** A snackbar appears after merge: "Merged books 3 and 4. [Undo]"

#### Split Mode
1. User taps "Split" button → button highlights (amber), mode changes
2. Instruction text appears: "Tap inside a spine to split it"
3. User taps within a bounding box → box splits vertically into two equal halves
4. New boxes get sequential numbers (renumbering following boxes)
5. Tap "Done" or tap "Split" again to exit split mode

**Undo split:** Snackbar: "Split book 5. [Undo]"

#### Delete Box
1. User selects a box (tap to select)
2. Taps "Delete" (trash icon) in toolbar
3. Box animates out (fade + shrink)
4. Remaining boxes renumber
5. **Undo:** Snackbar: "Removed book 7. [Undo]"

#### Reset
- Tapping "Reset" shows confirmation dialog: "Reset all adjustments to original detection?" [Cancel] [Reset]
- All boxes revert to their original ML-detected positions and sizes
- All merge/split/delete/resize operations undone

#### Bottom Bar
- Sticky at bottom:
  - Left: "12 spines detected"
  - Right: **"Done Adjusting"** button (primary, filled)
- Tapping "Done Adjusting" → advances to Results Step

---

### States

| State | Description |
|-------|-------------|
| **No selection** | All boxes shown with default styling. Toolbar: Merge, Split, Reset enabled. Delete disabled (greyed). "Done Adjusting" enabled. |
| **Box selected** | Selected box has amber border, resize handles visible. Delete enabled. Other toolbar buttons enabled. |
| **Merge mode active** | Merge button highlighted amber. Instruction text visible. Drawing rectangle interaction active. Split/Delete/Reset disabled until mode exited. |
| **Split mode active** | Split button highlighted amber. Instruction text visible. Tap-on-box interaction active. Merge/Delete/Reset disabled until mode exited. |
| **All boxes adjusted** | "Done Adjusting" always enabled. User can proceed regardless of adjustments made. |

---

### Transition to Results

When user taps "Done Adjusting":
- The adjusted box positions are used for the OCR crop regions
- If adjustments changed which text belongs to which spine, OCR re-runs on affected regions
- Brief loading: "Re-reading adjusted spines…"
- Then → Results Step (already implemented in mockup)

---

## What to Add to bulk-scanner.html

1. **New HTML section:** `<!-- ========== ADJUSTMENT STEP ========== -->` between Processing Step and Results Step
2. **CSS classes:** `.adjust-step`, `.adjust-photo`, `.bbox-adjust`, `.bbox-adjust.selected`, `.resize-handle`, `.corner-handle`, `.edge-handle`, `.adjust-toolbar`, `.adjust-toolbar button`, `.adjust-toolbar button.active`, `.merge-instruction`, `.split-instruction`
3. **JavaScript functions:** `enterAdjustMode()`, `selectBox(id)`, `startResize(handle, event)`, `startDrag(box, event)`, `enterMergeMode()`, `drawMergeRect()`, `enterSplitMode()`, `splitBox(id)`, `deleteBox(id)`, `resetAdjustments()`, `finishAdjusting()`
4. **Snackbar:** Merge/Split/Delete undo snackbars (reuse existing snackbar pattern from skip confirmation)
5. **Renumbering logic:** After any merge/split/delete, renumber remaining boxes 1..N
