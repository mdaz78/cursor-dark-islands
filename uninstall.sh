#!/bin/bash

set -e

EXT_ID="bwya77.cursor-dark-islands"
EXT_DIR_NAME="${EXT_ID}-1.0.0"
BACKUP_SUFFIX=".pre-cursor-dark-islands"

echo "🏝️  Cursor Dark Islands Uninstaller for macOS/Linux"
echo "===================================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Step 1: Restore previous Cursor settings
# ---------------------------------------------------------------------------
echo "⚙️  Step 1: Restoring Cursor settings..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
else
    SETTINGS_DIR="$HOME/.config/Cursor/User"
fi

SETTINGS_FILE="$SETTINGS_DIR/settings.json"
BACKUP_FILE="${SETTINGS_FILE}${BACKUP_SUFFIX}"

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$SETTINGS_FILE"
    echo -e "${GREEN}✓ Settings restored from backup${NC}"
    echo "   Backup file: $BACKUP_FILE"
else
    echo -e "${YELLOW}⚠️  No backup found at $BACKUP_FILE${NC}"
    echo "   You may need to manually edit your Cursor settings."
fi

# ---------------------------------------------------------------------------
# Step 2: Remind the user to disable Custom UI Style
# ---------------------------------------------------------------------------
echo ""
echo "🔧 Step 2: Disabling Custom UI Style..."
echo -e "${YELLOW}   Please disable Custom UI Style manually:${NC}"
echo "   1. Open the Command Palette (Cmd+Shift+P / Ctrl+Shift+P)"
echo "   2. Run 'Custom UI Style: Disable'"
echo "   3. Cursor will reload"

# ---------------------------------------------------------------------------
# Step 3: Remove the theme extension
# ---------------------------------------------------------------------------
echo ""
echo "🗑️  Step 3: Removing Cursor Dark Islands extension..."
EXT_DIR="$HOME/.cursor/extensions/${EXT_DIR_NAME}"
if [ -d "$EXT_DIR" ] || [ -L "$EXT_DIR" ]; then
    rm -rf "$EXT_DIR"
    echo -e "${GREEN}✓ Theme extension removed${NC}"
else
    echo -e "${YELLOW}⚠️  Extension directory not found (may already be removed)${NC}"
fi

# ---------------------------------------------------------------------------
# Step 4: Choose a new color theme
# ---------------------------------------------------------------------------
echo ""
echo "🎨 Step 4: Pick a new color theme..."
echo "   1. Open the Command Palette (Cmd+Shift+P / Ctrl+Shift+P)"
echo "   2. Run 'Preferences: Color Theme'"
echo "   3. Select your preferred theme"

echo ""
echo -e "${GREEN}✓ Cursor Dark Islands has been uninstalled!${NC}"
echo ""
echo "   Reload Cursor to complete the process."
echo ""
