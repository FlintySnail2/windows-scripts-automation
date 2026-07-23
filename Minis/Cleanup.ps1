Write-Host "Running cleanup..."

DISM /Online /Cleanup-Image /StartComponentCleanup

DISM /Online /Cleanup-Image /RestoreHealth

sfc /scannow

Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue |
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Host "Cleanup complete."