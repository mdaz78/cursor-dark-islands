# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Cursor Dark Islands is a [Cursor](https://www.cursor.com) theme distributed as a **two-part** package:

1. A standard VS Code-format color theme (`themes/islands-dark.json`, referenced from `package.json` via `contributes.themes`). Cursor accepts VS Code theme JSON unmodified.
2. A large block of CSS-as-JSON in `settings.json` under the `custom-ui-style.stylesheet` key, injected by the third-party **Custom UI Style** extension (`subframe7536.custom-ui-style`). This is what produces the floating panels, rounded corners, glass borders, and animations — the color theme alone cannot do any of that.

There is **no build, lint, or test pipeline**. There are no `node_modules`, no compiler, no CI checks. "Building" the extension means copying `package.json` + `themes/` into `~/.cursor/extensions/bwya77.cursor-dark-islands-1.0.0/`. Validation is visual — install it and look at Cursor.

## Common tasks

| Task | How |
|---|---|
| Apply local changes to your own Cursor | `./install.sh` (macOS/Linux) or `.\install.ps1` (Windows). Locates the `cursor` CLI, checks Cursor isn't running, copies the theme to `~/.cursor/extensions/`, installs Custom UI Style (with VSIX-download fallback), installs Bear Sans UI fonts, deep-merges `settings.json`, then quits and relaunches Cursor. |
| Re-apply CSS changes only (after editing `settings.json`) | Reload Cursor. If styles don't take effect: Command Palette → `Custom UI Style: Reload`, or disable + re-enable. |
| Roll back | `./uninstall.sh` / `.\uninstall.ps1` — restores from the `.pre-cursor-dark-islands` backup. |

The `bootstrap.sh` / `bootstrap.ps1` scripts are the public one-liner installers — they `git clone` the repo to `~/.cursor-dark-islands-temp` and run the appropriate `install` script. Don't use them locally; just run `install.sh` directly.

## Architecture

### The CSS-as-JSON convention

Every visual tweak lives in `settings.json` under `custom-ui-style.stylesheet`, which Custom UI Style parses as `{ "selector": { "property": "value" } }` and serializes to a stylesheet at runtime. Three consequences:

- **Edits to UI styling go in `settings.json`, not a `.css` file.** The one exception is `animations.css`, which is a free-standing keyframes/animation file referenced by the README but not currently wired into any installer — treat it as a design reference, not shipped code, until you've confirmed how it gets loaded.
- **Values are JSON strings**, so `!important` is just part of the string and CSS shorthand works literally (`"margin": "var(--islands-panel-top) var(--islands-panel-gap) 0 var(--islands-panel-gap)"`).
- **JSONC features** (`// comments`, trailing commas) are not native JSON. The PowerShell installer includes a `Strip-Jsonc` helper before `ConvertFrom-Json`; the bash installer uses `sed` for the same. The `"// Cursor Dark Islands Settings v0.1.0": ""` line at the top of `settings.json` is a key-with-comment-text-as-value, not a real comment.

### The CSS variable layer

All visual tuning is funneled through `--islands-*` custom properties defined once on `.monaco-workbench`:

```json
"--islands-panel-radius": "24px",   // sidebar, editor, terminal/bottom panel, aux bar
"--islands-widget-radius": "14px",  // notifications, command palette, chat input
"--islands-input-radius": "12px",   // search, SCM input, buttons, tooltips
"--islands-item-radius": "6px",     // list rows, tabs, pane headers
"--islands-panel-gap": "6px",       // horizontal spacing between panels
"--islands-panel-top": "6px",       // top margin (space below title bar)
"--islands-bg-canvas": "#121216",   // deep base layer behind panels
"--islands-bg-surface": "#181a1d"   // panel/surface fill (chat input, widgets)
```

Prefer adjusting these over hard-coding new pixel values in selector blocks. Pill-shaped elements (activity bar, scrollbar thumbs, command center, badges) intentionally bypass the radius variables.

### Installer architecture

Both `install.sh` and `install.ps1` follow the same seven-step shape, and any change to one should usually be mirrored in the other:

1. **Cursor CLI preflight** — resolve the `cursor` binary by checking `$PATH` first, then a list of known install locations (`/Applications/Cursor.app/...` on macOS, `$LOCALAPPDATA\Programs\cursor\...` on Windows, `/usr/bin`/`/opt/Cursor` on Linux). Fail loud with actionable error if not found.
2. **Quit-if-running preflight** — Custom UI Style patches Cursor's core CSS at install time. If Cursor is running when the patch is applied, the running instance reverts the patch on quit. The installer detects a running Cursor (`pgrep` or `Get-Process`) and prompts the user to quit. PowerShell takes a `-Force` flag to skip the prompt.
3. **Theme install** — copy `package.json` + `themes/` into `~/.cursor/extensions/bwya77.cursor-dark-islands-1.0.0/`. The dir name is intentionally fixed at `1.0.0` regardless of the manifest version so uninstall scripts can find it.
4. **Custom UI Style three-tier install** — (a) `cursor --install-extension subframe7536.custom-ui-style`, (b) download the VSIX from the VS Code marketplace REST endpoint and side-load via `cursor --install-extension <vsix>`, (c) print manual instructions and continue. Tier 1 alone may exit 0 with a stderr-only error, so verify success by checking the extension dir exists. This three-tier shape exists because Cursor defaults to Open VSX, not the VS Code marketplace where Custom UI Style is published.
5. **Font install** — Bear Sans UI `.otf` files into the OS font directory.
6. **Settings merge** — back up existing `settings.json` to `settings.json.pre-cursor-dark-islands`, then **deep-merge** the new settings into it. The bash installer uses `jq` (falls back to overwrite if `jq` is missing). The PowerShell installer uses a `Strip-Jsonc` helper + `ConvertFrom-Json` + manual hashtable merge with a special-case deep-merge of `custom-ui-style.stylesheet`. Cursor Dark Islands keys win on conflict; the user's existing `custom-ui-style.stylesheet` selectors are preserved unless we redefine them.
7. **Reload** — quit and relaunch Cursor (Windows: `Stop-Process` + `Start-Process`; macOS/Linux: `cursor --reload-window`). Print explicit guidance to run `Custom UI Style: Reload` if the glass effect doesn't appear within ~5 seconds.

If you change the settings merge logic, change it in both installers — drift between them was the most common bug class in the upstream `vscode-dark-islands` repo.

### Issues directory

`issues/*.md` are post-mortem write-ups, not GitHub issue mirrors. They document *why* specific workarounds exist in `settings.json`:

- `terminal-panel-bottom-cutoff.md` — explains the `margin-top: -7px` on `.part.panel.bottom > .content`. Don't remove that without re-reading the doc; Cursor's JS layout engine (inherited from VS Code) doesn't account for CSS borders on `.part.panel.bottom`.
- `panel-glass-borders-and-styling.md` — explains why the bottom panel uses `inset` shadows + a separate border on `.terminal-outer-container` (xterm's opaque canvas paints over inset shadows on the parent).

Read these before editing styling on the bottom panel or terminal.

## Versioning

Three places track the version and must stay in sync:

- `package.json` → `version`
- `settings.json` → the `"// Cursor Dark Islands Settings vX.Y.Z"` marker key at the top
- `CHANGELOG.md`

The extension directory name (`bwya77.cursor-dark-islands-1.0.0`) used by the install scripts is intentionally fixed at `1.0.0` regardless of the manifest version — don't try to "fix" this without checking that all install/uninstall scripts agree.
