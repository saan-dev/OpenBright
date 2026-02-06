#!/bin/bash

APP_NAME="OpenBright"
DMG_NAME="OpenBright_Installer.dmg"
STAGING_DIR="dist"

# Ensure we are in Scripts/
cd "$(dirname "$0")"

# Root is one level up
PROJECT_ROOT=".."
APP_PATH="${PROJECT_ROOT}/${APP_NAME}.app"

# 1. Clean previous build
rm -rf "${PROJECT_ROOT}/${STAGING_DIR}" "${PROJECT_ROOT}/${DMG_NAME}"
mkdir -p "${PROJECT_ROOT}/${STAGING_DIR}"

# 2. Prepare Staging Area
echo "Preparing staging area..."
# Copy from root
cp -R "${APP_PATH}" "${PROJECT_ROOT}/${STAGING_DIR}/"

# 3. Add Applications Symlink (Drag-and-Drop installation)
ln -s /Applications "${PROJECT_ROOT}/${STAGING_DIR}/Applications"

# 4. Create DMG
echo "Creating DMG..."
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${PROJECT_ROOT}/${STAGING_DIR}" \
    -ov -format UDZO \
    "${PROJECT_ROOT}/${DMG_NAME}"

# 5. Cleanup
rm -rf "${PROJECT_ROOT}/${STAGING_DIR}"

echo "✅ DMG Created: ${DMG_NAME}"
echo "You can upload this file to Product Hunt/GitHub!"
