Write-Host "Running maintenance..."

# Windows Update Scan
UsoClient StartScan

# Component Store Cleanup
DISM /Online /Cleanup-Image /StartComponentCleanup

# Repair Component Store
DISM /Online /Cleanup-Image /RestoreHealth

# System File Check
sfc /scannow

# Temp Files
Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue |
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Host "Cleanup complete."