#Requires -RunAsAdministrator

Clear-Host

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Windows Cleanup Utility" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# USER TEMP
# ============================================

Write-Host "Cleaning User TEMP files..." -ForegroundColor Yellow

Get-ChildItem `
    "$env:TEMP" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Remove-Item `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

# ============================================
# WINDOWS TEMP
# ============================================

Write-Host "Cleaning Windows TEMP files..." -ForegroundColor Yellow

Get-ChildItem `
    "C:\Windows\Temp" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Remove-Item `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

# ============================================
# WINDOWS UPDATE DOWNLOAD CACHE
# ============================================

Write-Host "Cleaning Update Download Cache..." -ForegroundColor Yellow

Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service bits -Force -ErrorAction SilentlyContinue

Get-ChildItem `
    "C:\Windows\SoftwareDistribution\Download" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Remove-Item `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

Start-Service bits -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

# ============================================
# COMPONENT STORE CLEANUP
# ============================================

Write-Host "Running Component Store Cleanup..." -ForegroundColor Yellow

DISM /Online /Cleanup-Image /StartComponentCleanup

# ============================================
# DEEP COMPONENT STORE CLEANUP
# ============================================

Write-Host "Reducing WinSxS footprint..." -ForegroundColor Yellow

DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# ============================================
# SYSTEM FILE CHECK
# ============================================

Write-Host "Running System File Checker..." -ForegroundColor Yellow

sfc /scannow

# ============================================
# DISK CLEANUP
# ============================================

Write-Host "Running Disk Cleanup..." -ForegroundColor Yellow

cleanmgr /verylowdisk

# ============================================
# RECYCLE BIN
# ============================================

Write-Host "Emptying Recycle Bin..." -ForegroundColor Yellow

Clear-RecycleBin `
    -Force `
    -ErrorAction SilentlyContinue

# ============================================
# WINDOWS.OLD
# ============================================

if (Test-Path "C:\Windows.old")
{
    Write-Host "Removing Windows.old..." -ForegroundColor Yellow

    Remove-Item `
        "C:\Windows.old" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

# ============================================
# SHADOW STORAGE LIMIT
# ============================================

Write-Host "Setting Restore Point Storage to 5GB..." -ForegroundColor Yellow

vssadmin Resize ShadowStorage `
    /For=C: `
    /On=C: `
    /MaxSize=5GB | Out-Null

# ============================================
# COMPLETE
# ============================================

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host " Cleanup Complete" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Recommended: Reboot the PC." -ForegroundColor Yellow
Write-Host ""