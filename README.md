<p align="center">
  <img src="Resources/icon.png" width="128" height="128" alt="PDFStitch Logo" />
</p>

# PDFStitch 🧵📄

<p align="center">
  <a href="https://github.com/kaziomarSH24/PDFStitch/releases/latest">
    <img src="https://img.shields.io/badge/Download-macOS%20(DMG)-blue?style=for-the-badge&logo=apple&logoColor=white" alt="Download for Mac" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
  </a>
</p>

**PDFStitch** is a lightweight, ultra-fast native macOS desktop application built with **Swift & SwiftUI** to combine images and PDFs, visually reorder pages via drag-and-drop or direct page jump, standardize pages to clean **A4 dimensions**, and export with smart file-size compression (e.g. Target < 9MB).

---

## 📥 Installation

1. Download **`PDFStitch-v1.0.0.dmg`** from [Releases](https://github.com/kaziomarSH24/PDFStitch/releases/latest).
2. Open the `.dmg` file and drag **PDFStitch** into your **Applications** folder.

### ⚠️ Note on macOS Gatekeeper ("App is damaged and can't be opened")

Because PDFStitch is a free, open-source project without a paid Apple Developer certificate ($99/year), macOS Gatekeeper may show a warning when opening for the first time:

> *"PDFStitch is damaged and can't be opened. You should eject the disk image."*

**How to open (one-time approval):**

- **Method 1 (Easiest)**: In Finder, open your **Applications** folder. **Right-Click** (or `Control + Click`) on **PDFStitch**, select **Open**, and click **Open** in the confirmation prompt.
- **Method 2 (System Settings)**: Open **System Settings** > **Privacy & Security**, scroll down to the Security section where it says *"PDFStitch was blocked from use"*, and click **Open Anyway**.
- **Method 3 (Terminal)**: Run this single command to remove the quarantine flag:
  ```bash
  xattr -cr /Applications/PDFStitch.app
  ```

---

## ✨ Features

- **Drag & Drop Import**: Drop JPEG, PNG, HEIC, TIFF images or multi-page PDFs directly into the app.
- **Visual Reordering**: 
  - Drag thumbnail cards to rearrange page sequence.
  - Click on any page number badge to jump directly to a specific page number.
  - Right-click context menu to *Move to First (Page 1)* or *Move to Last*.
- **Standard A4 Standardization**:
  - Automatically fits and centers every image/document onto a crisp white standard A4 canvas (210 × 297 mm).
  - Supports *A4 (Standard)*, *A4 Auto (Orientation)*, and *Original Size*.
- **Smart Size & Quality Control**:
  - 🟢 **Maximum (< 5 MB)**: 72 DPI, high compression for email and chat.
  - 🔵 **Balanced (< 9 MB)**: 85 DPI, optimized for upload limits.
  - 🟣 **High Quality**: 150 DPI, crisp for reading and printing.
  - ⚪ **Original Quality**: Source resolution.
  - **Custom Slider**: Fine-tune DPI and JPEG quality.
- **Pure Native & Lightweight**: Built with pure Apple frameworks (`PDFKit`, `Quartz`, `SwiftUI`) — zero external dependencies, total binary size under 600 KB.

---

## 🛠️ Build from Source

### Prerequisites
- macOS 13.0 or later
- Xcode or Xcode Command Line Tools (`swift`)

### Run from Terminal
```bash
swift run
```

### Build `.app` and `.dmg` Installer
Run the packaging script to generate both `PDFStitch.app` and `PDFStitch-v1.0.0.dmg`:
```bash
./build_app.sh
```

---

## 📜 License
This project is open-source under the [MIT License](LICENSE).
