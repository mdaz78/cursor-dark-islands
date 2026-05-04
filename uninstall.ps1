# Cursor Dark Islands Uninstaller for Windows

param()

$ErrorActionPreference = "Stop"

$ExtId = "bwya77.cursor-dark-islands"
$ExtDirName = "$ExtId-1.0.0"
$BackupSuffix = ".pre-cursor-dark-islands"

Write-Host "Cursor Dark Islands Uninstaller for Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Restore previous settings
Write-Host "Step 1: Restoring Cursor settings..."
$settingsDir = "$env:APPDATA\Cursor\User"
$settingsFile = Join-Path $settingsDir "settings.json"
$backupFile = "$settingsFile$BackupSuffix"

if (Test-Path $backupFile) {
    Copy-Item $backupFile $settingsFile -Force
    Write-Host "Settings restored from backup" -ForegroundColor Green
    Write-Host "   Backup file: $backupFile"
} else {
    Write-Host "No backup found at $backupFile" -ForegroundColor Yellow
    Write-Host "   You may need to manually edit your Cursor settings."
}

# Step 2: Disable Custom UI Style (manual step)
Write-Host ""
Write-Host "Step 2: Disabling Custom UI Style..."
Write-Host "   Please disable Custom UI Style manually:" -ForegroundColor Yellow
Write-Host "   1. Open the Command Palette (Ctrl+Shift+P)"
Write-Host "   2. Run 'Custom UI Style: Disable'"
Write-Host "   3. Cursor will reload"

# Step 3: Remove the theme extension
Write-Host ""
Write-Host "Step 3: Removing Cursor Dark Islands extension..."
$extDir = "$env:USERPROFILE\.cursor\extensions\$ExtDirName"
if (Test-Path $extDir) {
    Remove-Item -Recurse -Force $extDir
    Write-Host "Theme extension removed" -ForegroundColor Green
} else {
    Write-Host "Extension directory not found (may already be removed)" -ForegroundColor Yellow
}

# Step 4: Pick a new color theme
Write-Host ""
Write-Host "Step 4: Pick a new color theme..."
Write-Host "   1. Open the Command Palette (Ctrl+Shift+P)"
Write-Host "   2. Run 'Preferences: Color Theme'"
Write-Host "   3. Select your preferred theme"

Write-Host ""
Write-Host "Cursor Dark Islands has been uninstalled!" -ForegroundColor Green
Write-Host ""
Write-Host "   Reload Cursor to complete the process."
Write-Host ""

Start-Sleep -Seconds 2
