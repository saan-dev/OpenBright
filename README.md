# OpenBright ☼

**Open Source XDR Brightness Unlocker for macOS**  
*Unlock the full 1600 nits of your Liquid Retina XDR display using native Metal APIs.*

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)]()
[![Build](https://github.com/saan-dev/openbright/actions/workflows/build.yml/badge.svg)](https://github.com/saan-dev/openbright/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/saan-dev/openbright?label=download)](https://github.com/saan-dev/openbright/releases/latest)

<p align="center">
  <img src="Assets/readme/comparison.png" alt="Split-screen comparison: the left half shows macOS at its default 500-nit limit, the right half shows the same desktop at 1600 nits with OpenBright enabled and its menu bar dropdown open." width="900">
</p>
<p align="center"><sub>Illustration. Screenshots cannot capture backlight brightness, so the difference is simulated; the menu is the real one.</sub></p>

## 📥 Download

Grab `OpenBright_Installer.dmg` from the [latest release](https://github.com/saan-dev/openbright/releases/latest), open it, and drag OpenBright to Applications. Every release is built from source on a clean macOS runner by the [CI workflow](.github/workflows/build.yml). See the Gatekeeper & Signing section below for the first-launch step.

## 🚀 Overview

OpenBright is a lightweight, native macOS utility that bypasses the software-imposed 500-nit brightness clamp on Apple Silicon MacBook Pros. It forces the display controller to engage EDR (Extended Dynamic Range) headroom, typically reserved for HDR content, allowing the full 1600 nits to be used for standard desktop tasks.

It is a free, MIT-licensed alternative to commercial or paid tools like *Vivid*, *BetterDisplay*, or *BrightIntosh*.

## ⚙️ Technical Implementation

OpenBright does **not** use private APIs, system hacks, or firmware modifications. It relies exclusively on standard frameworks (`Metal`, `CoreAnimation`, `Cocoa`).

### 1. The Metal Layer (`CAMetalLayer`)
The core mechanism involves creating a transparent, click-through `NSWindow` that overlays the entire screen. Inside this window, we initialize a `CAMetalLayer` with specific EDR properties:
*   **Pixel Format**: `.rgba16Float` (16-bit Floating Point).
*   **Color Space**: `extendedLinearDisplayP3` (Crucial for unrestricted brightness values).
*   **Compositing**: The layer is set to `wantsExtendedDynamicRangeContent = true`.

### 2. Pixel Injection
To force the hardware backlight to ramp up, we render a specific pixel value into the framebuffer.
*   **RGB Component**: `850.9` (Linear P3). This massive value signals "Max HDR Brightness" to the display engine.
*   **Alpha Component**: `0.0000435`. This specific alpha value is key. It is high enough to prevent the Window Server from culling the layer as "invisible," but low enough to be perceptually transparent to the human eye.

### 3. Battery Protection (`pmset`)
High brightness consumes significantly more power. To prevent unexpected drain:
*   OpenBright spawns a background `Process` to query `/usr/bin/pmset -g batt`.
*   It parses the stdout stream to detect (1) Power Source and (2) Battery Percentage.
*   **Logic**: If `Source == Battery` AND `Level < 20%`, the EDR boost is automatically disabled.

### 4. Application State (Persistence)
*   State is managed via `UserDefaults`.
*   The app remembers `isEnabled`, `currentRGB`, and `currentAlpha` values across restarts.

## 📂 Project Structure

```text
OpenBright/
├── Sources/
│   ├── main.swift           # Entry point
│   ├── DisplayControls.swift # App Logic & StatusBar Management
│   ├── EDRView.swift        # Metal Rendering Engine
│   └── OverlayWindow.swift   # Passthrough Window Configuration
├── Scripts/
│   ├── build_app.sh         # Compiles source into .app bundle
│   └── package_dmg.sh       # Creates distributable DMG
├── Assets/
│   ├── app_icon_sun.png     # Source asset for app icon
│   └── readme/              # README illustrations
└── .github/workflows/
    └── build.yml            # CI: build, package, publish releases on v* tags
```

## 🛠 Build from Source

**Prerequisites:** Xcode Command Line Tools (`xcode-select --install`).

### Option 1: Full App Bundle (Recommended)
This script compiles the Swift sources, generates the `.icns` file from assets, and assembles the `.app` bundle.

```bash
./Scripts/build_app.sh
open OpenBright.app
```

### Option 2: Distribution DMG
Creates a drag-and-drop installer.

```bash
./Scripts/package_dmg.sh
```

## ⚠️ Gatekeeper & Signing
This open-source project does **not** have a paid Apple Developer ID signature.
When opening the app for the first time, you must:
1.  **Right-Click** `OpenBright.app`.
2.  Select **Open**.
3.  Confirm **Open** in the dialog.

## 📄 License
MIT License. Copyright (c) 2026 OpenBright Contributors.
