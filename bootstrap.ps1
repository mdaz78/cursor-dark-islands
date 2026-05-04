# Cursor Dark Islands Bootstrap Installer for Windows
# One-liner: irm https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/bootstrap.ps1 | iex

param()

$ErrorActionPreference = "Stop"

Write-Host "Cursor Dark Islands Bootstrap Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$RepoUrl = "https://github.com/mdaz78/cursor-dark-islands.git"
$Branch = "main"
$InstallDir = "$env:TEMP\cursor-dark-islands-temp"

Write-Host "Step 1: Downloading Cursor Dark Islands..."
Write-Host "   Repository: $RepoUrl"

if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

try {
    git clone $RepoUrl $InstallDir --quiet --branch $Branch
} catch {
    Write-Host "Failed to download Cursor Dark Islands" -ForegroundColor Red
    Write-Host "   Make sure Git is installed: https://git-scm.com/download/win"
    exit 1
}

Write-Host "Downloaded successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Running installer..."
Write-Host ""

Set-Location $InstallDir
try {
    .\install.ps1
} catch {
    Write-Host "Installation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host ""
Write-Host "Step 3: Cleaning up..."
$remove = Read-Host "   Remove temporary files? (y/n)"
if ($remove -eq 'y' -or $remove -eq 'Y') {
    Set-Location $env:TEMP
    Remove-Item -Recurse -Force $InstallDir
    Write-Host "Temporary files removed" -ForegroundColor Green
} else {
    Write-Host "   Files kept at: $InstallDir"
}

Write-Host ""
Write-Host "Done! Enjoy your Cursor Dark Islands theme!" -ForegroundColor Green
