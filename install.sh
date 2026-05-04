#!/bin/bash

set -e

EXT_ID="bwya77.cursor-dark-islands"
EXT_DIR_NAME="${EXT_ID}-1.0.0"
CUI_ID="subframe7536.custom-ui-style"
CUI_VSIX_URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/subframe7536/vsextensions/custom-ui-style/latest/vspackage"
BACKUP_SUFFIX=".pre-cursor-dark-islands"
SENTINEL_NAME=".cursor_dark_islands_first_run"

echo "🏝️  Cursor Dark Islands Installer for macOS/Linux"
echo "================================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ---------------------------------------------------------------------------
# Step 1: Locate the Cursor CLI
# ---------------------------------------------------------------------------
echo "🔎 Step 1: Locating the Cursor CLI..."
CURSOR_BIN=""
if command -v cursor &> /dev/null; then
    CURSOR_BIN="$(command -v cursor)"
elif [[ "$OSTYPE" == "darwin"* ]] && [ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]; then
    CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
else
    for candidate in \
        "/usr/local/bin/cursor" \
        "/usr/bin/cursor" \
        "/opt/Cursor/bin/cursor" \
        "$HOME/.local/bin/cursor"; do
        if [ -x "$candidate" ]; then
            CURSOR_BIN="$candidate"
            break
        fi
    done
fi

if [ -z "$CURSOR_BIN" ]; then
    echo -e "${RED}❌ Error: Cursor CLI (cursor) not found!${NC}"
    echo "Please install Cursor and make sure the 'cursor' command is in your PATH."
    echo "Inside Cursor:"
    echo "  1. Press Cmd+Shift+P (macOS) or Ctrl+Shift+P (Linux)"
    echo "  2. Run 'Shell Command: Install \"cursor\" command in PATH'"
    exit 1
fi
echo -e "${GREEN}✓ Cursor CLI found at: $CURSOR_BIN${NC}"

# ---------------------------------------------------------------------------
# Step 2: Ensure Cursor is not running (Custom UI Style patches CSS at install
#         time and the patch is reverted on the next launch if Cursor is open)
# ---------------------------------------------------------------------------
echo ""
echo "🛑 Step 2: Checking that Cursor is not running..."
CURSOR_RUNNING=0
if [[ "$OSTYPE" == "darwin"* ]]; then
    if pgrep -f "Cursor.app/Contents/MacOS/Cursor" > /dev/null 2>&1; then
        CURSOR_RUNNING=1
    fi
else
    if pgrep -x Cursor > /dev/null 2>&1; then
        CURSOR_RUNNING=1
    fi
fi

if [ "$CURSOR_RUNNING" -eq 1 ]; then
    echo -e "${YELLOW}⚠️  Cursor is currently running.${NC}"
    echo "   Custom UI Style modifies Cursor's core CSS, and a running Cursor will"
    echo "   revert the patch on quit. Please quit Cursor and re-run this script."
    if [ -t 0 ]; then
        read -p "   Press Enter to continue anyway, or Ctrl+C to abort..."
    else
        exit 1
    fi
fi
echo -e "${GREEN}✓ Cursor is not running${NC}"

# ---------------------------------------------------------------------------
# Step 3: Install the theme extension
# ---------------------------------------------------------------------------
echo ""
echo "📦 Step 3: Installing Cursor Dark Islands theme extension..."
EXT_DIR="$HOME/.cursor/extensions/${EXT_DIR_NAME}"
rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"
cp "$SCRIPT_DIR/package.json" "$EXT_DIR/"
cp -r "$SCRIPT_DIR/themes" "$EXT_DIR/"

if [ -d "$EXT_DIR/themes" ]; then
    echo -e "${GREEN}✓ Theme extension installed to $EXT_DIR${NC}"
else
    echo -e "${RED}❌ Failed to install theme extension${NC}"
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 4: Install Custom UI Style (three-tier fallback)
# ---------------------------------------------------------------------------
echo ""
echo "🔧 Step 4: Installing Custom UI Style extension..."

cui_installed() {
    ls "$HOME/.cursor/extensions/${CUI_ID}-"* > /dev/null 2>&1
}

CUI_OK=0

# Tier 1: marketplace install via the cursor CLI
if "$CURSOR_BIN" --install-extension "$CUI_ID" --force > /dev/null 2>&1 && cui_installed; then
    CUI_OK=1
    echo -e "${GREEN}✓ Custom UI Style installed via Cursor's marketplace${NC}"
fi

# Tier 2: download the VSIX from the VS Code marketplace and side-load it
if [ "$CUI_OK" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Marketplace install failed; trying VSIX download...${NC}"
    CUI_VSIX="${TMPDIR:-/tmp}/custom-ui-style.vsix"
    if curl -fL --silent --show-error -o "$CUI_VSIX" "$CUI_VSIX_URL" \
        && "$CURSOR_BIN" --install-extension "$CUI_VSIX" > /dev/null 2>&1 \
        && cui_installed; then
        CUI_OK=1
        echo -e "${GREEN}✓ Custom UI Style installed from downloaded VSIX${NC}"
    fi
fi

# Tier 3: print manual instructions and continue
if [ "$CUI_OK" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Custom UI Style could not be installed automatically.${NC}"
    echo "   The color theme will work, but the floating glass panels will not."
    echo "   To install Custom UI Style manually:"
    echo "     1. Open Cursor → Cmd/Ctrl+Shift+X"
    echo "     2. Click the '...' menu → 'Install from VSIX'"
    echo "     3. Download the VSIX from"
    echo "        https://marketplace.visualstudio.com/items?itemName=${CUI_ID}"
    echo "        (click 'Download Extension' in the right column)"
fi

# ---------------------------------------------------------------------------
# Step 5: Install Bear Sans UI fonts
# ---------------------------------------------------------------------------
echo ""
echo "🔤 Step 5: Installing Bear Sans UI fonts..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
    echo "   Installing fonts to: $FONT_DIR"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ Fonts installed to Font Book${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    echo "   Installing fonts to: $FONT_DIR"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    fc-cache -f 2>/dev/null || true
    echo -e "${GREEN}✓ Fonts installed${NC}"
else
    echo -e "${YELLOW}⚠️  Could not detect OS type for automatic font installation${NC}"
    echo "   Please manually install the fonts from the 'fonts/' folder"
fi

# ---------------------------------------------------------------------------
# Step 6: Apply Cursor settings (deep-merge, with overwrite-with-backup
#         fallback if jq is missing)
# ---------------------------------------------------------------------------
echo ""
echo "⚙️  Step 6: Applying Cursor settings..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
else
    SETTINGS_DIR="$HOME/.config/Cursor/User"
fi

mkdir -p "$SETTINGS_DIR"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    BACKUP_FILE="${SETTINGS_FILE}${BACKUP_SUFFIX}"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}⚠️  Existing settings.json backed up to:${NC}"
    echo "   $BACKUP_FILE"

    if command -v jq > /dev/null 2>&1; then
        # Strip JSONC line comments (lines whose first non-whitespace chars are //)
        # and trailing commas so jq can parse the existing file. We only strip
        # line-leading `//` so that JSON string values like our marker key
        # `"// Cursor Dark Islands Settings v0.1.0"` are preserved.
        EXISTING_JSON=$(sed -E 's:^[[:space:]]*//.*$::g; s:,([[:space:]]*[}\]]):\1:g' "$SETTINGS_FILE" 2>/dev/null || cat "$SETTINGS_FILE")
        # Deep-merge with jq's `*` operator: shipped values override on conflict;
        # user's other top-level keys and unique stylesheet selectors are preserved.
        if MERGED=$(jq -s '.[0] * .[1]' \
            <(echo "$EXISTING_JSON") \
            "$SCRIPT_DIR/settings.json" 2>/dev/null); then
            echo "$MERGED" > "$SETTINGS_FILE"
            echo -e "${GREEN}✓ Settings merged into existing settings.json${NC}"
        else
            echo -e "${YELLOW}⚠️  Merge failed; replacing settings.json (backup preserved)${NC}"
            cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
        fi
    else
        echo -e "${YELLOW}⚠️  jq not found; replacing settings.json instead of merging.${NC}"
        echo "   Install jq (brew install jq / apt install jq) to preserve your existing keys."
        cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
    fi
else
    cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
    echo -e "${GREEN}✓ Cursor Dark Islands settings written to:${NC}"
    echo "   $SETTINGS_FILE"
fi

# ---------------------------------------------------------------------------
# Step 7: First-run notes and reload
# ---------------------------------------------------------------------------
echo ""
echo "🚀 Step 7: Wrapping up..."

FIRST_RUN_FILE="$SCRIPT_DIR/$SENTINEL_NAME"
if [ ! -f "$FIRST_RUN_FILE" ]; then
    touch "$FIRST_RUN_FILE"
    echo ""
    echo -e "${YELLOW}📝 Important Notes:${NC}"
    echo "   • IBM Plex Mono and FiraCode Nerd Font Mono need to be installed separately"
    echo "   • After Cursor reloads, you may see a 'corrupt installation' warning"
    echo "   • This is expected with Custom UI Style — click the gear icon and select 'Don't Show Again'"
    echo "   • If the floating glass panels don't appear within ~5 seconds of reload,"
    echo "     run 'Custom UI Style: Reload' from the command palette."
    echo ""
    if [ -t 0 ]; then
        read -p "Press Enter to continue and reload Cursor..."
    fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e 'display notification "Cursor Dark Islands installed successfully!" with title "🏝️ Cursor Dark Islands"' 2>/dev/null || true
fi

echo "   Reloading Cursor..."
"$CURSOR_BIN" --reload-window 2>/dev/null || "$CURSOR_BIN" . 2>/dev/null || true

echo ""
echo -e "${GREEN}Done! 🏝️${NC}"
