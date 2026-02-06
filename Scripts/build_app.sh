#!/bin/bash

# Configuration
APP_NAME="OpenBright"
# Assume script is run from Scripts/ directory, so root is one level up
PROJECT_ROOT=".."
OUTPUT_DIR="${PROJECT_ROOT}"
APP_BUNDLE="${OUTPUT_DIR}/${APP_NAME}.app"
BINARY_NAME="XDRBrightEx"
SOURCES_DIR="${PROJECT_ROOT}/Sources"
ASSETS_DIR="${PROJECT_ROOT}/Assets"

# Ensure we are in the Scripts directory (optional safety check)
cd "$(dirname "$0")"

# Clean previous build
rm -rf "${APP_BUNDLE}"

# Create Directory Structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Compile
echo "Compiling..."
# Compile sources from Sources directory
swiftc "${SOURCES_DIR}/main.swift" "${SOURCES_DIR}/DisplayControls.swift" "${SOURCES_DIR}/OverlayWindow.swift" "${SOURCES_DIR}/EDRView.swift" "${SOURCES_DIR}/ControlPanel.swift" -o "${BINARY_NAME}" -framework Cocoa -framework SwiftUI -framework Metal -framework QuartzCore

# Check if compilation succeeded
if [ -f "${BINARY_NAME}" ]; then
    echo "Compilation successful."
else
    echo "Compilation failed."
    exit 1
fi

# Move binary to bundle
mv "${BINARY_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Handle Icon Generation (if source icon exists)
ICON_SOURCE="${ASSETS_DIR}/app_icon_sun.png"
if [ -f "${ICON_SOURCE}" ]; then
    echo "Generating AppIcon.icns..."
    mkdir -p "OpenBright.iconset"
    
    # Generate standard sizes
    sips -z 16 16     "${ICON_SOURCE}" --out "OpenBright.iconset/icon_16x16.png" > /dev/null
    sips -z 32 32     "${ICON_SOURCE}" --out "OpenBright.iconset/icon_16x16@2x.png" > /dev/null
    sips -z 32 32     "${ICON_SOURCE}" --out "OpenBright.iconset/icon_32x32.png" > /dev/null
    sips -z 64 64     "${ICON_SOURCE}" --out "OpenBright.iconset/icon_32x32@2x.png" > /dev/null
    sips -z 128 128   "${ICON_SOURCE}" --out "OpenBright.iconset/icon_128x128.png" > /dev/null
    sips -z 256 256   "${ICON_SOURCE}" --out "OpenBright.iconset/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   "${ICON_SOURCE}" --out "OpenBright.iconset/icon_256x256.png" > /dev/null
    sips -z 512 512   "${ICON_SOURCE}" --out "OpenBright.iconset/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   "${ICON_SOURCE}" --out "OpenBright.iconset/icon_512x512.png" > /dev/null
    sips -z 1024 1024 "${ICON_SOURCE}" --out "OpenBright.iconset/icon_512x512@2x.png" > /dev/null
    
    # Convert to icns
    iconutil -c icns "OpenBright.iconset"
    
    # Copy to Resources
    cp "OpenBright.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    
    # Clean up
    rm -rf "OpenBright.iconset" "OpenBright.icns"
    echo "Icon bundled."
else
    echo "Warning: ${ICON_SOURCE} not found. App will have default icon."
fi

# Create Info.plist - IMPORTANT: LSUIElement=1 makes it a menu-bar only app (no dock icon)
echo "Creating Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.saandev.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "Remove quarantine (if any) to allow local execution..."
xattr -d com.apple.quarantine "${APP_BUNDLE}" 2>/dev/null || true

echo "App Bundle created at ${APP_BUNDLE}"
