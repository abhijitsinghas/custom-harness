# Phase 3 — User Stories: Input Methods

## Workstream 3.1 — Barcode Scanner (F3)

### Happy Path

**US-3.1.1 — Barcode scanner opens with camera viewfinder**
Given the user taps "+" FAB → "Scan Barcode"
When the scanner screen opens
Then the camera viewfinder is displayed with barcode detection overlay and corner bracket animation
And a torch toggle is visible in the top-right corner
And "Enter ISBN manually" link is shown at the bottom

**US-3.1.2 — Barcode detected and ISBN looked up online**
Given the camera is active and scanning
When a barcode is detected
Then the detected ISBN value is shown in a bottom sheet with "Lookup Book" and "Dismiss" buttons
When the user taps "Lookup Book"
Then a loading overlay is shown while querying Google Books API
And on success, the Add Book form is pre-filled with all available fields

**US-3.1.3 — Barcode detected offline — ISBN-only pre-fill**
Given the camera is active and no internet connection
When a barcode is detected and "Lookup Book" is tapped
Then the app detects offline state
And navigates to the Add Book form with only the ISBN pre-filled

**US-3.1.4 — Non-ISBN barcode handled gracefully**
Given the camera is active
When a barcode is detected that is not a valid ISBN format
Then a snackbar shows "Not a recognized ISBN"
And the "Enter ISBN manually" link is still available

### Edge Cases

**US-3.1.5 — Torch toggle works**
Given the barcode scanner is open
When the user taps the torch icon
Then the camera flash toggles on/off and the icon updates accordingly

**US-3.1.6 — Manual ISBN entry fallback**
Given the barcode scanner is open
When the user taps "Enter ISBN manually"
Then a text input dialog appears for typing an ISBN
And on submit, navigates to the Add Book form with that ISBN pre-filled

### Error States

**US-3.1.7 — Camera permission denied — first time**
Given the user taps "Scan Barcode" for the first time
When the camera permission dialog appears and is denied
Then a rationale dialog is shown explaining why camera access is needed

**US-3.1.8 — Camera permission denied — second time**
Given the user has denied camera permission once before
When they tap "Scan Barcode" again
Then a dialog shows "Open Settings" button linking to app settings

**US-3.1.9 — Google Books API timeout or error**
Given a barcode has been detected
When the Google Books lookup fails or times out (10s)
Then an error message is shown: "Could not look up this ISBN. You can enter details manually."
And the user can proceed to the Add Book form with ISBN pre-filled

### Empty States

**US-3.1.10 — No barcode detected (empty scan state)**
Given the barcode scanner is open
When no barcode has been detected yet
Then the viewfinder continues scanning with the overlay animation
And instructional text "Point camera at a barcode" is shown

### Accessibility

**US-3.1.11 — Scanner accessibility**
Given the barcode scanner screen
Then all buttons have semantic labels
And the detected value is announced via TalkBack
And the torch toggle has an accessible label

---

## Workstream 3.2 — Photo OCR (F4)

### Happy Path

**US-3.2.1 — Photo source selection (camera or gallery)**
Given the user taps "+" FAB → "Scan Book Cover"
When the screen opens
Then a bottom sheet is shown with two options: "Take Photo" and "Choose from Gallery"

**US-3.2.2 — Photo captured and OCR processes text**
Given the user takes a photo or selects from gallery
When the image is loaded
Then a "Scanning text…" overlay with progress dots is shown
And ML Kit text recognition processes the image (Latin script)

**US-3.2.3 — OCR results shown with highlighted text regions**
Given text recognition completes
Then the photo is displayed with bounding boxes around detected text regions
And extracted text blocks are shown as tappable chips below the photo

**US-3.2.4 — User assigns text to Title or Author**
Given extracted text chips are shown
When the user taps a chip
Then a context menu appears with options: "Assign as Title" and "Assign as Author"
And the chip is colored to indicate its assignment (blue for title, green for author)

**US-3.2.5 — Assigned text pre-fills Add Book form (online)**
Given the user has assigned text to Title and/or Author
When they tap "Continue" or "Search Online"
Then Google Books API is queried with the assigned title+author
And top matches are presented for selection
And the selected match pre-fills the Add Book form

**US-3.2.6 — No internet — manual assignment pre-fills form**
Given the user has assigned text while offline
When they tap "Continue"
Then the assigned title and author directly pre-fill the Add Book form without online lookup

### Edge Cases

**US-3.2.7 — Crop/rotate before OCR**
Given an image is selected
When the user taps "Crop" or "Rotate"
Then a crop/rotate editor opens
And changes are applied before OCR processing begins

**US-3.2.8 — Multiple text blocks detected**
Given a photo with multiple text regions
When OCR completes
Then each text block is shown as a separate tappable chip
And the user can assign multiple chips to different fields

### Error States

**US-3.2.9 — No text detected**
Given OCR processing completes
When no text is found in the image
Then a message shows "Try a clearer photo or enter manually"
And the user can retake/choose another photo or navigate to manual entry

**US-3.2.10 — Non-English text detected (Phase 1)**
Given the image may contain non-Latin text
When Latin OCR returns low-confidence results
Then a message shows "Non-English text detected. Please enter manually."
And offers to navigate to manual entry

**US-3.2.11 — Storage permission for gallery**
Given the user taps "Choose from Gallery"
When storage permission is needed
Then a just-in-time rationale is shown
And "Open Settings" on second denial

### Empty States

**US-3.2.12 — No photo selected yet**
Given the OCR screen just opened
When no photo has been captured/selected
Then the source selection bottom sheet is shown
And instructional text explains the flow

### Accessibility

**US-3.2.13 — OCR screen accessibility**
Given text chips are displayed
Then each chip has a semantic label showing the detected text
And the bounding box overlay is described to screen readers
And all action buttons have labels

---

## Workstream 3.3 — Voice Input + LLM (F11)

### Happy Path

**US-3.3.1 — Voice input screen opens with microphone**
Given the user taps "+" FAB → "Voice Input"
When the screen opens
Then a microphone UI is displayed with pulsing waveform animation
And "Tap to speak" / "Listening…" text indicates state

**US-3.3.2 — Speech captured and transcribed**
Given the microphone is active
When the user speaks naturally (e.g., "Add The Alchemist by Paulo Coelho")
Then the speech is transcribed in real-time via platform STT
And the transcription text appears below the waveform

**US-3.3.3 — LLM extracts structured fields from transcript (Tier 2 — cloud)**
Given speech transcription is complete
When processing begins
Then a "Extracting fields… (Tier 2)" indicator is shown
And the Gemini API (cloud) is called with a structured extraction prompt
And extracted fields (title, authors, publisher, year, etc.) are returned as JSON

**US-3.3.4 — LLM extraction pre-fills Add Book form**
Given fields are extracted from the transcript
When the user reviews and confirms
Then the Add Book form opens pre-filled with extracted values
And "Enrich Online" is available for further enrichment

**US-3.3.5 — Regex fallback works when cloud LLM unavailable (Tier 3)**
Given cloud LLM is unavailable (offline/timeout)
When extraction falls back to Tier 3
Then regex patterns extract "by [Author]", "published in [Year]", "[Genre]" from the raw transcript
And partially filled fields are presented to the user for completion
And a badge shows "Fields extracted (offline mode)"

### Edge Cases

**US-3.3.6 — Voice search from catalog screen**
Given the catalog screen search bar
When the user taps the microphone icon
Then platform STT activates and transcribes speech
And the transcribed text fills the search bar for immediate searching
(No LLM extraction needed)

**US-3.3.7 — Incomplete or ambiguous extraction**
Given the transcript has limited information
When LLM extraction completes with partial fields
Then only the extracted fields are pre-filled
And empty fields show default/placeholder values
And a note indicates which fields were automatically filled

### Error States

**US-3.3.8 — No speech detected**
Given the microphone is active
When no speech is detected for 10 seconds
Then a message shows "No speech detected. Try again or enter manually."
And the user can retry or navigate to manual entry

**US-3.3.9 — LLM extraction failed**
Given the speech was transcribed
When the LLM extraction fails or returns unparseable JSON
Then a message shows "Could not extract book details. You can enter them manually."
And the raw transcript is shown for the user to copy

**US-3.3.10 — Microphone permission denied**
Given the user taps "Voice Input" for the first time
When the microphone permission is denied
Then a rationale dialog is shown explaining why microphone access is needed
And on second denial, a dialog shows "Open Settings" button

### Empty States

**US-3.3.11 — Voice input initial state**
Given the voice input screen just opened
When no speech has been captured yet
Then the microphone icon pulses gently (idle animation)
And instructional text "Describe the book you want to add" is shown
And sample prompt examples are shown (e.g., "Try: 'Add The Alchemist by Paulo Coelho'")

### Accessibility

**US-3.3.12 — Voice input accessibility**
Given the voice input screen
Then all buttons have semantic labels
And the recording state is announced via TalkBack
And the extracted fields result is announced when ready
And error messages are announced
