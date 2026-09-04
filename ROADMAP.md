# PDFStitch — Master Feature Roadmap & Architecture Specification

> **Project Goal**: Build the ultimate, 100% free, lightweight, privacy-first, and all-in-one native macOS PDF Suite using Swift, SwiftUI, and Apple's native frameworks (PDFKit, Vision, CoreGraphics).

---

## 🏛️ System Architecture & Memory Management Principles

To keep the application running at under 30–50 MB RAM with zero memory leaks, all future modules must adhere to these strict rules:

1. **Single Responsibility & Small Files**:
   - Every file must be modular and focused, keeping line count strictly under ~100 lines.
   - Comprehensive English documentation/comments for every struct, class, and method.
2. **Value Types First (`struct`)**:
   - Models and views must be structs allocated on the stack to prevent reference cycles.
3. **ARC & Retain Cycle Prevention**:
   - ViewModels and long-lived handlers must use `[weak self]` in closures and background tasks.
4. **Tight Autorelease Pools (`autoreleasepool`)**:
   - Every loop that renders, decodes, or transforms CoreGraphics bitmaps or PDF pages must wrap each iteration in `autoreleasepool { ... }` so temporary raw pixels are destroyed immediately.
5. **No Bloatware**:
   - Rely strictly on native Apple frameworks (`PDFKit`, `Vision`, `Quartz`, `CoreGraphics`, `SwiftUI`) — zero bulky third-party dependencies.

---

## 📋 Comprehensive Feature Specification

### Module 1: Reader & Viewer Experience (Phase 1)
- [x] **Continuous Vertical Scroll**: Native smooth multi-page reading.
- [x] **Zoom Controls**: Zoom in, Zoom out, Fit to window.
- [ ] **Thumbnails Drawer (`PDFThumbnailView`)**: Collapsible left sidebar strip with page previews for instant page jumping.
- [ ] **Floating Navigation Pill**: Bottom floating bar with `< 1 / 43 >`, zoom percentage, and rotate shortcuts.
- [ ] **Reading Themes**: Light mode, Dark mode, Sepia/Warm paper mode, and Inverted Night mode.
- [ ] **In-Document Search (`Cmd + F`)**: Real-time keyword search with page result highlighting.
- [ ] **Bookmarks & Outline**: Visual table of contents and custom user bookmarks.

---

### Module 2: Page Organization & Layout (Core Complete)
- [x] **Drag & Drop Reordering**: Interactive thumbnail cards with smooth animation.
- [x] **Direct Page Jump**: Click page badge to jump directly to any page number.
- [x] **Context Actions**: Right-click to Move to First (Page 1), Move to Last, Rotate 90°, and Delete.
- [x] **Standard A4 Canvas Fitting**: Centered layout with 12pt clean white margins.
- [x] **Paper Size Modes**: A4 Standard, A4 Auto-Orientation, and Original Size.
- [ ] **Bulk Page Rotate**: 1-click rotate all pages 90° clockwise/counter-clockwise.
- [ ] **Page Extraction / Splitter**: Split document or extract specific page ranges (e.g. Pages 5–12) into a new PDF.
- [ ] **Insert Blank Page & Merge**: Add blank pages or insert other PDF/image files anywhere in the document.

---

### Module 3: Smart Compression & File Size Optimization (Core Complete)
- [x] **Compression Presets**:
  - `Low (Smallest Size)`: 85 DPI, 30% quality (compact for email & web).
  - `Medium (Balanced)`: 110 DPI, 48% quality (crisp text, optimized for < 9MB).
  - `High (Print Quality)`: 150 DPI, 70% quality (sharp high resolution).
  - `Maximum (Original)`: 300 DPI, 95% quality (lossless source).
- [x] **Custom Sliders**: Live DPI (60–250) and JPEG Quality (15–90%) sliders.
- [x] **Live Estimated Size Progress Bar**: Real-time visual progress bar and color-coded status gauge (Green, Blue, Orange, Red).
- [ ] **Grayscale Optimization**: 1-click convert color PDF to high-contrast black & white to drastically cut file size.

---

### Module 4: Annotation & Markup Tools (Phase 2)
- [ ] **Free Text Tool (`PDFAnnotation.Subtype.freeText`)**: Click anywhere on a page to type custom text with font, color, and size options.
- [ ] **Digital Signatures**:
  - Draw signature on trackpad/mouse.
  - Import signature image or use stylized text font.
  - Save signatures in user library for 1-click placement.
- [ ] **Text Markups**:
  - Highlight (`.highlight`).
  - Underline (`.underline`).
  - Strikethrough (`.strikeOut`).
- [ ] **Freehand Vector Pen & Eraser (`.ink`)**: Draw notes, arrows, and circles smoothly.
- [ ] **Geometric Shapes**: Rectangles, Circles, Arrows, and Lines.
- [ ] **Permanent Redaction (Blackout)**: True irreversible redaction to permanently obscure confidential data.
- [ ] **Stamps & Seals**: "APPROVED", "PAID", "CONFIDENTIAL", "VOID", and custom image stamps.

---

### Module 5: Security & Document Integrity (Phase 3)
- [ ] **Password Encryption (Lock PDF)**:
  - Open Password (protects document from opening).
  - Permission Password (restricts printing and text copying).
  - Standard AES-128 / AES-256 bit encryption via PDFKit.
- [ ] **Password Removal (Unlock PDF)**: Permanently decrypt files when owner enters valid password.
- [ ] **Bates Numbering / Auto Page Numbers**: Automatically stamp `Page X of Y` in any corner or footer.
- [ ] **Custom Watermarking**: Overlay semi-transparent text or logo at customized angles.

---

### Module 6: Conversions & Export Hub (Phase 3)
- [ ] **PDF to Images**: Batch export PDF pages into PNG, JPEG, or TIFF files.
- [ ] **Images to PDF**: Convert photos and receipts into clean multi-page documents.
- [ ] **PDF to Plain Text**: Extract readable text stream into `.txt` files.

---

### Module 7: AI Assistant & Smart OCR (Phase 4 — BYOK Model)
- [ ] **Apple Vision Framework OCR**:
  - Offline, on-device OCR using `VNRecognizeTextRequest` on Apple Neural Engine.
  - Converts scanned images and receipts into searchable and copyable PDFs.
- [ ] **BYOK (Bring Your Own Key) AI Assistant**:
  - Zero server cost: Users plug in their own free Google Gemini API key or OpenAI key.
  - Key securely saved in encrypted **Apple Keychain**.
  - **⚡ Summarize Document**: 1-click executive summary and key takeaways.
  - **💬 Chat with PDF**: Ask questions against the document with exact page citations.
  - **🌐 Translate**: Translate document summaries into Bengali or other languages.

---

## 🗓️ 4-Week Implementation Roadmap

| Week | Milestone | Focus Areas |
| :--- | :--- | :--- |
| **Week 1** | **Reader & Navigation Polish** | `PDFThumbnailView` drawer, Floating Navigation Pill, Bookmarks, and Shortcuts. |
| **Week 2** | **Annotation & Markup Engine** | Digital Signature, Free Text, Highlighter, Pen/Eraser, Shapes, Redaction. |
| **Week 3** | **Security & Page Tools** | AES Password Lock, Bates Page Numbers, Watermark, Splitter, Batch Image Export. |
| **Week 4** | **AI Assistant & Memory Audit** | BYOK Gemini Integration, Apple Vision OCR, Instruments Leaks Profiling & Release. |

---

*Last Updated: September 2026 | PDFStitch Open-Source Project*
