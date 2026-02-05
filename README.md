# OpenBright 1.0

**Open Source XDR Brightness Unlocker for macOS**

OpenBright uses native macOS Metal APIs to unlock the full brightness potential of your Liquid Retina XDR display, pushing it beyond the standard 500-nit limit to its hardware maximum (up to 1600 nits), similar to paid tools like *Vivid* or *BetterDisplay*, but completely free and open source.

> [!NOTE]
> **Developer Preview**: This project is currently provided as source code. You will need to compile it (one liner below) to run it. A pre-compiled `.app` is coming soon.

## 🚀 How It Works (The Technical Part)

Standard macOS apps are clamped to "SDR" brightness (Standard Dynamic Range), approx 500 nits. However, XDR displays have immense "EDR Headroom" (Extended Dynamic Range) reserved for HDR content.

OpenBright works by creating a transparent, click-through overlay window that covers your entire screen.
1.  **Metal Layer**: It initializes a `CAMetalLayer` with a 16-bit Floating Point pixel format (`.rgba16Float`) and the `extendedLinearDisplayP3` color space.
2.  **Pixel Injection**: It renders a specific color value to this layer.
    *   RGB: `850.9` (Linear P3). This massive value forces the display backend to ramp up the backlight to accommodate the "HDR" content.
    *   Alpha: `0.0000435`. This ultra-low alpha keeps the pixel technically "visible" to the Window Server (preventing optimization culling) while remaining perceptually invisible to the human eye.
3.  **Result**: The system sees "content" that requires 1600 nits, so it engages the full backlight. Since our content is transparent, your underlying desktop shines through at 1600 nits.

## 💻 Supported Hardware

This tool works on Apple Silicon Macs with **Liquid Retina XDR** displays:

*   **MacBook Pro 14-inch** (M1 Pro/Max, M2 Pro/Max, M3 Pro/Max) — 2021 and later
*   **MacBook Pro 16-inch** (M1 Pro/Max, M2 Pro/Max, M3 Pro/Max) — 2021 and later
*   *Potentially Pro Display XDR (Untested)*

## 🛠️ Build & Run

**Prerequisites:** Xcode Command Line Tools (`xcode-select --install`).

To run the app from source:

```bash
# Compile
swiftc main.swift StatusBarController.swift OverlayWindow.swift EDRView.swift ControlPanel.swift -o XDRBrightEx -framework Cocoa -framework SwiftUI -framework Metal -framework QuartzCore

# Run
./XDRBrightEx
```

Once running:
1.  Look for the "Sun" icon in your Menu Bar.
2.  Click **"Toggle High Brightness"** (or press `Cmd+B` while the menu is open).
3.  The screen will instantly boost to max brightness.

## ✅ TODO / Roadmap

- [ ] Create a downloadable, notarized `.app` for non-coders (DMG installer).
- [ ] Add "HDR Content Detection" (Auto-disable when watching real HDR movies to prevent clipping).
- [ ] Battery protection mode (Force disable on low battery).
- [ ] Battery protection mode (Force disable on low battery).

## 🛡️ Safety & Disclaimer

**No Private APIs. No System Hacks.**

OpenBright relies exclusively on public, standard macOS frameworks (`Metal`, `CoreAnimation`, `Cocoa`).
It does **NOT**:
*   Modify system files or boot arguments.
*   Flash firmware or modify hardware registries.
*   Use private or undocumented Apple APIs.
*   Inject code into other processes.

It simply asks the OS to display a specific HDR color, and the OS handles the rest safely. Using your display at maximum brightness for extended periods (hours) may drain your battery faster and slightly increase heat, exactly as if you were watching an HDR movie or editing HDR photos.
## 📄 License

**MIT License**

Copyright (c) 2026 OpenBright Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
