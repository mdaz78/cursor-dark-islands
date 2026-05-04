# Cursor Dark Islands Theme Installer for Windows

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ExtId = "bwya77.cursor-dark-islands"
$ExtDirName = "$ExtId-1.0.0"
$CuiId = "subframe7536.custom-ui-style"
$CuiVsixUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/subframe7536/vsextensions/custom-ui-style/latest/vspackage"
$BackupSuffix = ".pre-cursor-dark-islands"
$SentinelName = ".cursor_dark_islands_first_run"

Write-Host "Cursor Dark Islands Installer for Windows" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------------------------------------------------------------------------
# Step 1: Locate the Cursor CLI
# ---------------------------------------------------------------------------
Write-Host "Step 1: Locating the Cursor CLI..."
$cursorBin = $null
$cmd = Get-Command "cursor" -ErrorAction SilentlyContinue
if ($cmd) {
    $cursorBin = $cmd.Source
} else {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin\cursor.cmd",
        "$env:LOCALAPPDATA\Programs\Cursor\resources\app\bin\cursor.cmd",
        "$env:ProgramFiles\Cursor\resources\app\bin\cursor.cmd",
        "${env:ProgramFiles(x86)}\Cursor\resources\app\bin\cursor.cmd"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            $cursorBin = $candidate
            break
        }
    }
}

if (-not $cursorBin) {
    Write-Host "Error: Cursor CLI (cursor) not found!" -ForegroundColor Red
    Write-Host "Please install Cursor and ensure the 'cursor' command is in your PATH."
    Write-Host "Inside Cursor:"
    Write-Host "  1. Press Ctrl+Shift+P"
    Write-Host "  2. Run 'Shell Command: Install ''cursor'' command in PATH'"
    exit 1
}
Write-Host "Cursor CLI found at: $cursorBin" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 2: Ensure Cursor is not running
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 2: Checking that Cursor is not running..."
$running = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
if ($running) {
    if ($Force) {
        Write-Host "Cursor is running; -Force specified, terminating..." -ForegroundColor Yellow
        Stop-Process -Name "Cursor" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Cursor is currently running." -ForegroundColor Yellow
        Write-Host "   Custom UI Style modifies Cursor's core CSS, and a running Cursor will"
        Write-Host "   revert the patch on quit. Please quit Cursor and re-run, or pass -Force."
        Read-Host "   Press Enter to continue anyway, or Ctrl+C to abort"
    }
}
Write-Host "Cursor is not running" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 3: Install the theme extension
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 3: Installing Cursor Dark Islands theme extension..."
$extDir = "$env:USERPROFILE\.cursor\extensions\$ExtDirName"
if (Test-Path $extDir) {
    Remove-Item -Recurse -Force $extDir
}
New-Item -ItemType Directory -Path $extDir -Force | Out-Null
Copy-Item "$scriptDir\package.json" "$extDir\" -Force
Copy-Item "$scriptDir\themes" "$extDir\themes" -Recurse -Force

if (Test-Path "$extDir\themes") {
    Write-Host "Theme extension installed to $extDir" -ForegroundColor Green
} else {
    Write-Host "Failed to install theme extension" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 4: Install Custom UI Style (three-tier fallback)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 4: Installing Custom UI Style extension..."

function Test-CuiInstalled {
    return @(Get-ChildItem "$env:USERPROFILE\.cursor\extensions\$CuiId-*" -ErrorAction SilentlyContinue).Count -gt 0
}

$cuiOk = $false

# Tier 1: marketplace install via the cursor CLI
try {
    & $cursorBin --install-extension $CuiId --force 2>&1 | Out-Null
    if (Test-CuiInstalled) {
        $cuiOk = $true
        Write-Host "Custom UI Style installed via Cursor's marketplace" -ForegroundColor Green
    }
} catch {
    # fall through to tier 2
}

# Tier 2: download the VSIX from the VS Code marketplace and side-load it
if (-not $cuiOk) {
    Write-Host "Marketplace install failed; trying VSIX download..." -ForegroundColor Yellow
    $cuiVsix = Join-Path $env:TEMP "custom-ui-style.vsix"
    try {
        Invoke-WebRequest -Uri $CuiVsixUrl -OutFile $cuiVsix -UseBasicParsing
        & $cursorBin --install-extension $cuiVsix 2>&1 | Out-Null
        if (Test-CuiInstalled) {
            $cuiOk = $true
            Write-Host "Custom UI Style installed from downloaded VSIX" -ForegroundColor Green
        }
    } catch {
        # fall through to tier 3
    }
}

# Tier 3: print manual instructions and continue
if (-not $cuiOk) {
    Write-Host "Custom UI Style could not be installed automatically." -ForegroundColor Yellow
    Write-Host "   The color theme will work, but the floating glass panels will not."
    Write-Host "   To install Custom UI Style manually:"
    Write-Host "     1. Open Cursor -> Ctrl+Shift+X"
    Write-Host "     2. Click the '...' menu -> 'Install from VSIX'"
    Write-Host "     3. Download the VSIX from"
    Write-Host "        https://marketplace.visualstudio.com/items?itemName=$CuiId"
    Write-Host "        (click 'Download Extension' in the right column)"
}

# ---------------------------------------------------------------------------
# Step 5: Install Bear Sans UI fonts
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 5: Installing Bear Sans UI fonts..."
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontDir)) {
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
}
try {
    $fonts = Get-ChildItem "$scriptDir\fonts\*.otf"
    foreach ($font in $fonts) {
        try { Copy-Item $font.FullName $fontDir -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host "Fonts installed" -ForegroundColor Green
    Write-Host "   Note: You may need to restart applications to use the new fonts" -ForegroundColor DarkGray
} catch {
    Write-Host "Could not install fonts automatically" -ForegroundColor Yellow
    Write-Host "   Please manually install the fonts from the 'fonts/' folder"
}

# ---------------------------------------------------------------------------
# Step 6: Apply Cursor settings (deep-merge with overwrite-with-backup fallback)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 6: Applying Cursor settings..."
$settingsDir = "$env:APPDATA\Cursor\User"
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}
$settingsFile = Join-Path $settingsDir "settings.json"

# Strip JSONC features (line-leading // comments, /* block */ comments, and
# trailing commas) for ConvertFrom-Json. We only strip `//` at the start of a
# line so JSON string values that begin with `//` (like our marker key
# `"// Cursor Dark Islands Settings v0.1.0"`) are preserved intact.
function Strip-Jsonc {
    param([string]$Text)
    $Text = $Text -replace '(?m)^\s*//.*$', ''
    $Text = $Text -replace '/\*[\s\S]*?\*/', ''
    $Text = $Text -replace ',(\s*[}\]])', '$1'
    return $Text
}

$newRaw = Get-Content "$scriptDir\settings.json" -Raw
# Our shipped settings.json is strict JSON; no need to strip. Parse directly so
# any malformed shipped file fails loudly.
$newSettings = $newRaw | ConvertFrom-Json

if (Test-Path $settingsFile) {
    $backupFile = "$settingsFile$BackupSuffix"
    Copy-Item $settingsFile $backupFile -Force
    Write-Host "Existing settings.json backed up to:" -ForegroundColor Yellow
    Write-Host "   $backupFile"

    try {
        $existingRaw = Get-Content $settingsFile -Raw
        $existingSettings = (Strip-Jsonc $existingRaw) | ConvertFrom-Json

        # Recursive deep-merge: shipped values win on conflict; user-only keys
        # at every depth are preserved. Mirrors jq's `*` operator semantics.
        function Merge-Deep {
            param($Old, $New)
            if ($null -eq $Old) { return $New }
            if ($null -eq $New) { return $Old }
            if ($Old -isnot [PSCustomObject] -or $New -isnot [PSCustomObject]) { return $New }
            $merged = [ordered]@{}
            $Old.PSObject.Properties | ForEach-Object { $merged[$_.Name] = $_.Value }
            foreach ($prop in $New.PSObject.Properties) {
                if ($merged.Contains($prop.Name)) {
                    $merged[$prop.Name] = Merge-Deep $merged[$prop.Name] $prop.Value
                } else {
                    $merged[$prop.Name] = $prop.Value
                }
            }
            return [PSCustomObject]$merged
        }

        $mergedSettings = Merge-Deep $existingSettings $newSettings
        $mergedSettings | ConvertTo-Json -Depth 100 | Set-Content $settingsFile
        Write-Host "Settings merged into existing settings.json" -ForegroundColor Green
    } catch {
        Write-Host "Merge failed; replacing settings.json (backup preserved)" -ForegroundColor Yellow
        Copy-Item "$scriptDir\settings.json" $settingsFile -Force
    }
} else {
    Copy-Item "$scriptDir\settings.json" $settingsFile -Force
    Write-Host "Cursor Dark Islands settings written to: $settingsFile" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Step 7: First-run notes and reload
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 7: Wrapping up..."

$firstRunFile = Join-Path $scriptDir $SentinelName
if (-not (Test-Path $firstRunFile)) {
    New-Item -ItemType File -Path $firstRunFile | Out-Null
    Write-Host ""
    Write-Host "Important Notes:" -ForegroundColor Yellow
    Write-Host "   - IBM Plex Mono and FiraCode Nerd Font Mono need to be installed separately"
    Write-Host "   - After Cursor reloads, you may see a 'corrupt installation' warning"
    Write-Host "   - This is expected with Custom UI Style - click the gear icon and select 'Don't Show Again'"
    Write-Host "   - If the floating glass panels don't appear within ~5 seconds of reload,"
    Write-Host "     run 'Custom UI Style: Reload' from the command palette."
    Write-Host ""
    Read-Host "Press Enter to continue and reload Cursor"
}

Write-Host "Cursor Dark Islands has been installed!" -ForegroundColor Green
Write-Host ""

# Fully quit and relaunch Cursor so Custom UI Style finishes patching CSS.
Write-Host "   Closing Cursor..." -ForegroundColor Cyan
Stop-Process -Name "Cursor" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

Write-Host "   Relaunching Cursor..." -ForegroundColor Cyan
Start-Process $cursorBin -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
Write-Host "If the floating glass panels are not applied, open the Command Palette" -ForegroundColor Yellow
Write-Host "(Ctrl+Shift+P) and run: Custom UI Style: Reload" -ForegroundColor Yellow

Start-Sleep -Seconds 3
