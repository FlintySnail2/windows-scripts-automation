#Requires -RunAsAdministrator

Clear-Host

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " N-able Cache Cleanup Utility"
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$CacheFolders = @(
    "C:\Program Files (x86)\N-able Technologies\NablePatchCache",
    "C:\ProgramData\MspPlatform\FileCacheServiceAgent\cache"
)

function Get-FolderSizeGB {
    param([string]$Path)

    if (!(Test-Path $Path)) {
        return 0
    }

    $Size = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object Length -Sum).Sum

    :Round(($Size / 1GB), 2)
}

# Show current sizes

foreach ($Folder in $CacheFolders)
{
    $Size = Get-FolderSizeGB $Folder

    Write-Host ""
    Write-Host "$Folder" -ForegroundColor Yellow
    Write-Host "Size: $Size GB"
}

Write-Host ""
Read-Host "Press ENTER to begin cleanup"

# Stop service

$Services = @(
    "SolarWinds.MSP.Cache.Service",
    "File Cache Service Agent"
)

foreach ($Service in $Services)
{
    try
    {
        Get-Service | Where-Object {
            $_.Name -eq $Service -or $_.DisplayName -eq $Service
        } | Stop-Service -Force -ErrorAction Stop

        Write-Host "Stopped: $Service" -ForegroundColor Green
    }
    catch {}
}

# Clear cache folders

foreach ($Folder in $CacheFolders)
{
    if (Test-Path $Folder)
    {
        Write-Host ""
        Write-Host "Cleaning $Folder..." -ForegroundColor Yellow

        Get-ChildItem $Folder -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Restart service

foreach ($Service in $Services)
{
    try
    {
        Get-Service | Where-Object {
            $_.Name -eq $Service -or $_.DisplayName -eq $Service
        } | Start-Service -ErrorAction Stop

        Write-Host "Started: $Service" -ForegroundColor Green
    }
    catch {}
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host " Cleanup Complete"
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

foreach ($Folder in $CacheFolders)
{
    $Size = Get-FolderSizeGB $Folder

    Write-Host "$Folder"
    Write-Host "Current Size: $Size GB"
    Write-Host ""
}

Pause