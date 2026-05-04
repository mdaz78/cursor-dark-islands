# Cursor Dark Islands

<a href="https://www.buymeacoffee.com/bwya77" style="margin-right: 10px;">
    <img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" />
</a>
<a href="https://github.com/sponsors/bwya77">
    <img src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA" />
</a>


A dark color theme for [Cursor](https://www.cursor.com) inspired by the easemate IDE. Features floating glass-like panels, rounded corners, smooth animations, and a deeply refined UI.

- [easemate](https://x.com/easemate)
- [easemate Nav](https://x.com/Jakubantalik/status/1952672176450215944)
- [easemate effects](https://x.com/aaroniker/status/1989727838992539655)


![Cursor Dark Islands Screenshot](assets/CleanShot%202026-02-19%20at%2019.37.59@2x.png)

## Features

- Deep dark canvas (`#131217`) with floating panels
- Glass-effect borders with directional light simulation (brighter top/left, subtle bottom/right)
- Rounded corners on all panels, notifications, command palette, and sidebars
- Pill-shaped activity bar with glass selection indicators
- Breadcrumb bar and status bar that dim when not hovered
- Tab close buttons that fade in on hover
- Smooth transitions on sidebar selections, scrollbars, and status bar
- Pill-shaped scrollbar thumbs
- Color-matched icon glow effect (works best with [Seti Folder](https://marketplace.visualstudio.com/items?itemName=l-igh-t.vscode-theme-seti-folder) icon theme)
- Warm syntax highlighting with comprehensive language support (JS/TS, Python, Go, Rust, HTML/CSS, JSON, YAML, Markdown)
- IBM Plex Mono in the editor, FiraCode Nerd Font Mono in the terminal

![Cursor Dark Islands Screenshot UI](assets/CleanShot%202026-02-14%20at%2021.45.00@2x.png)

## Installation

This theme has two parts: a **color theme** and **CSS customizations** that create the floating glass panel look.

### One-Liner Install (Recommended)

The fastest way to install:

#### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/bootstrap.sh | bash
```

#### Windows

```powershell
irm https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/bootstrap.ps1 | iex
```

### Manual Clone Install

If you prefer to clone first:

#### macOS/Linux

```bash
git clone https://github.com/mdaz78/cursor-dark-islands.git
cd cursor-dark-islands
./install.sh
```

#### Windows

```powershell
git clone https://github.com/mdaz78/cursor-dark-islands.git
cd cursor-dark-islands
.\install.ps1
```

The scripts will automatically:
- ✅ Install the Cursor Dark Islands theme extension
- ✅ Install the Custom UI Style extension (with VSIX-download fallback)
- ✅ Install Bear Sans UI fonts
- ✅ Back up your existing settings and **merge** Cursor Dark Islands settings into them
- ✅ Reload Cursor

> **Note:** IBM Plex Mono and FiraCode Nerd Font Mono must be installed separately.
>
> **Note:** Quit Cursor before running the installer. Custom UI Style patches Cursor's core CSS at install time, and a running instance will revert the patch on quit.

### Manual Installation

If you prefer to install manually, follow these steps:

#### Step 1: Install the theme

Clone this repo and copy the extension files:

```bash
git clone https://github.com/mdaz78/cursor-dark-islands.git
cd cursor-dark-islands
mkdir -p ~/.cursor/extensions/bwya77.cursor-dark-islands-1.0.0
cp package.json ~/.cursor/extensions/bwya77.cursor-dark-islands-1.0.0/
cp -r themes ~/.cursor/extensions/bwya77.cursor-dark-islands-1.0.0/
```

On Windows (PowerShell):
```powershell
git clone https://github.com/mdaz78/cursor-dark-islands.git
cd cursor-dark-islands
$ext = "$env:USERPROFILE\.cursor\extensions\bwya77.cursor-dark-islands-1.0.0"
New-Item -ItemType Directory -Path $ext -Force
Copy-Item package.json $ext\
Copy-Item themes $ext\themes -Recurse
```

#### Step 2: Install the Custom UI Style extension

The floating panels, rounded corners, glass borders, and animations are powered by the **Custom UI Style** extension by `subframe7536`. See [Custom UI Style on Cursor](#custom-ui-style-on-cursor) below — Cursor's marketplace differs from VS Code's, so the install may need a manual VSIX step.

#### Step 3: Install recommended icon theme

For the best experience with the color-matched icon glow effect, install the **Seti Folder** icon theme:

1. Open **Extensions** in Cursor (`Cmd+Shift+X` / `Ctrl+Shift+X`)
2. Search for **[Seti Folder](https://marketplace.visualstudio.com/items?itemName=l-igh-t.vscode-theme-seti-folder)** (by `l-igh-t`)
3. Click **Install**
4. Set it as your icon theme: **Command Palette** > **Preferences: File Icon Theme** > **Seti Folder**

#### Step 4: Install fonts

This theme uses three fonts:

- **IBM Plex Mono** — used in the editor
- **FiraCode Nerd Font Mono** — used in the terminal
- **Bear Sans UI** — used in the sidebar, tabs, command center, and status bar (included in `fonts/` folder)

To install Bear Sans UI:
1. Open the `fonts/` folder in this repo
2. Select all `.otf` files and double-click to open in Font Book (macOS) or right-click > Install (Windows)

If you prefer different fonts, update the `editor.fontFamily`, `terminal.integrated.fontFamily`, and `font-family` values in the settings.

#### Step 5: Apply the settings

Copy the contents of `settings.json` from this repo into your Cursor settings:

1. Open the **Command Palette** (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Search for **Preferences: Open User Settings (JSON)**
3. Merge the contents of this repo's `settings.json` into your settings file

> **Note:** If you already have existing settings, merge carefully. The key settings are `workbench.colorTheme`, `custom-ui-style.stylesheet`, and the font/indent preferences.

#### Step 6: Enable Custom UI Style

1. Open the **Command Palette** (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Run **Custom UI Style: Enable**
3. Cursor will reload

> **Note:** You may see a "corrupt installation" warning after enabling. This is expected since Custom UI Style injects CSS into Cursor. Click the gear icon on the warning and select **Don't Show Again**.

## Custom UI Style on Cursor

Cursor is a fork of VS Code, so it accepts standard VS Code theme files and Custom UI Style works inside it. However, **Cursor's default extension marketplace is Open VSX, not the VS Code marketplace** where Custom UI Style is published. The installer handles this with a three-tier fallback:

1. Try installing via Cursor's CLI (`cursor --install-extension subframe7536.custom-ui-style`).
2. If that fails, download the VSIX directly from the VS Code marketplace and side-load it via `cursor --install-extension <vsix-path>`.
3. If that also fails, the installer prints manual instructions and continues — colors will work but the floating glass effect will not.

If you need to install manually:

1. Open **Extensions** in Cursor (`Cmd+Shift+X` / `Ctrl+Shift+X`)
2. Click the `...` menu in the Extensions panel → **Install from VSIX...**
3. Download the VSIX from [https://marketplace.visualstudio.com/items?itemName=subframe7536.custom-ui-style](https://marketplace.visualstudio.com/items?itemName=subframe7536.custom-ui-style) (click **Download Extension** in the right column) and select it

## What the CSS customizations do

| **Element** | **Effect** |
|-------------|------------|
| **Canvas** | Deep dark background (`--islands-bg-canvas`) behind all panels |
| **Sidebar** | Floating with rounded corners (`--islands-panel-radius`), glass borders, drop shadow |
| **Editor** | Floating with rounded corners (`--islands-panel-radius`), glass borders, browser-tab effect |
| **Activity bar** | Pill-shaped with glass inset shadows, circular selection indicator |
| **Command center** | Pill-shaped with glass effect |
| **Bottom panel** | Floating with rounded corners (`--islands-panel-radius`), glass borders |
| **Right sidebar** | Floating with rounded corners (`--islands-panel-radius`), glass borders |
| **Notifications** | Rounded corners (`--islands-widget-radius`), glass borders, deep drop shadow |
| **Command palette** | Rounded corners (`--islands-widget-radius`), glass borders, rounded list rows |
| **Scrollbars** | Pill-shaped thumbs with fade transition |
| **Tabs** | Browser-tab style (active tab open at bottom), close button fades in on hover |
| **Breadcrumbs** | Hidden until hover with smooth fade transition |
| **Status bar** | Dimmed text that brightens on hover |
| **File icons** | Color-matched glow via drop-shadow (best with Seti Folder icon theme) |

## Customization

All key visual properties are controlled by CSS custom properties defined at the top of the `custom-ui-style.stylesheet` in `settings.json`. Edit the variables on `.monaco-workbench` to quickly adjust the look:

```json
".monaco-workbench": {
    "--islands-panel-radius": "24px",
    "--islands-widget-radius": "14px",
    "--islands-input-radius": "12px",
    "--islands-item-radius": "6px",
    "--islands-panel-gap": "8px",
    "--islands-panel-top": "8px",
    "--islands-bg-canvas": "#121216",
    "--islands-bg-surface": "#181a1d",
    "background-color": "var(--islands-bg-canvas) !important"
}
```

### Colors

| **Variable** | **Default** | **Applies to** |
|--------------|-------------|----------------|
| `--islands-bg-canvas` | `#121216` | Deep background behind all panels (workbench, title bar, status bar, activity bar) |
| `--islands-bg-surface` | `#181a1d` | Panel/surface background (chat input, editor widgets) |

These two colors define the theme's depth. The canvas is the darker base layer visible between panels, while the surface is the slightly lighter color used for interactive elements. To override the theme's panel colors (sidebar, editor, terminal backgrounds), use Cursor's `workbench.colorCustomizations` in your settings.

### Border Radius

| **Variable** | **Default** | **Applies to** |
|--------------|-------------|----------------|
| `--islands-panel-radius` | `24px` | Sidebar, editor, terminal/bottom panel, auxiliary bar |
| `--islands-widget-radius` | `14px` | Notifications, chat input, command palette |
| `--islands-input-radius` | `12px` | Search bars, SCM commit input, buttons, hover tooltips |
| `--islands-item-radius` | `6px` | List rows, tabs, pane headers, terminal tabs |

For example, to make everything sharper, set all values to `8px`. For a fully rounded look, try `32px` / `20px` / `16px` / `8px`. Pill-shaped elements (activity bar, scrollbar thumbs, command center, badges) are not affected by these variables.

### Panel Spacing

| **Variable** | **Default** | **Applies to** |
|--------------|-------------|----------------|
| `--islands-panel-gap` | `8px` | Horizontal spacing between sidebar, editor, chat/auxiliary bar, terminal, and notifications |
| `--islands-panel-top` | `8px` | Top margin of panels (space below the title bar) |

Increase to `12px` or `16px` for a more spaced-out layout, or reduce to `4px` for a tighter look.

## Known Limitations

This release styles Cursor's VS Code-inherited surfaces (sidebar, editor, terminal, command palette, notifications, status bar). Cursor adds AI-specific surfaces that are **not yet styled**:

- **Chat sidebar** (`Cmd+L`) — renders with default Cursor styling
- **Composer / Agent pane** — renders with default Cursor styling
- **Inline edit overlay** (`Cmd+K`) — renders as a standard widget without glass borders
- **Tab autocomplete ghost text** — uses Cursor's default rendering

The color theme cascades into these surfaces, so they don't look out of place — they just don't get the floating-glass treatment. Contributions to extend the CSS to these areas are welcome.

## Troubleshooting

### Changes aren't taking effect
Try disabling and re-enabling Custom UI Style:
1. **Command Palette** > **Custom UI Style: Disable**
2. Reload Cursor
3. **Command Palette** > **Custom UI Style: Enable**
4. Reload Cursor

### Glass panels missing but colors work
Custom UI Style failed to install or activate. Re-run the installer with Cursor closed, or follow the manual VSIX install steps under [Custom UI Style on Cursor](#custom-ui-style-on-cursor).

### "Corrupt installation" warning
This is expected after enabling Custom UI Style. Dismiss it or select **Don't Show Again**.

### Previously used "Custom CSS and JS Loader" extension
If you previously used the **Custom CSS and JS Loader** extension (`be5invis.vscode-custom-css`), it may have injected CSS directly into Cursor's `workbench.html` that persists even after disabling. If styles conflict, reinstall Cursor to get a clean `workbench.html`, then use only **Custom UI Style**.

## Uninstalling

Run the uninstall script to restore your Cursor to its previous state:

**macOS/Linux:**
```bash
# If you still have the repo cloned:
cd cursor-dark-islands
./uninstall.sh

# Or download and run directly:
curl -fsSL https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/uninstall.sh | bash
```

**Windows (PowerShell):**
```powershell
# If you still have the repo cloned:
cd cursor-dark-islands
.\uninstall.ps1

# Or download and run directly:
irm https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/uninstall.ps1 | iex
```

The uninstall script will:
- Restore your previous settings from the `settings.json.pre-cursor-dark-islands` backup
- Remove the Cursor Dark Islands theme extension

After running the script, you'll need to:
1. Open the **Command Palette** (`Cmd+Shift+P` / `Ctrl+Shift+P`) and run **Custom UI Style: Disable**
2. Open the **Command Palette** and search **Preferences: Color Theme** to select a new theme
3. Reload Cursor

## Credits

Forked from [bwya77/vscode-dark-islands](https://github.com/bwya77/vscode-dark-islands) and adapted for Cursor. Original theme inspired by the [JetBrains Islands Dark](https://www.jetbrains.com/) UI theme.

## License

MIT
