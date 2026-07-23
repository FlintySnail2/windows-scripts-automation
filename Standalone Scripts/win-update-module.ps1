#Requires -RunAsAdministrator

Clear-Host

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Windows Update Utility" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Save existing execution policy
$OldPolicy = Get-ExecutionPolicy -Scope Process

try {

    Set-ExecutionPolicy Bypass -Scope Process -Force

    Write-Host "Checking NuGet provider..." -ForegroundColor Yellow

    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -Force
    }

    Write-Host "Configuring PowerShell Gallery..." -ForegroundColor Yellow

    Set-PSRepository `
        -Name PSGallery `
        -InstallationPolicy Trusted `
        -ErrorAction SilentlyContinue

    Write-Host "Checking PSWindowsUpdate module..." -ForegroundColor Yellow

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module `
            -Name PSWindowsUpdate `
            -Scope AllUsers `
            -Force
    }

    Import-Module PSWindowsUpdate -Force

    Write-Host ""
    Write-Host "Available Updates" -ForegroundColor Green
    Write-Host "-------------------------------------"

    Get-WindowsUpdate

    Write-Host ""
    $Proceed = Read-Host "Install all updates? (Y/N)"

    if ($Proceed -match '^[Yy]$')
    {
        Write-Host ""
        Write-Host "Installing Updates..." -ForegroundColor Green

        Install-WindowsUpdate `
            -MicrosoftUpdate `
            -AcceptAll `
            -IgnoreReboot `
            -Verbose
    }
    else
    {
        Write-Host "Updates cancelled by user."
        return
    }

}
catch
{
    Write-Host ""
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
finally
{
    Set-ExecutionPolicy `
        $OldPolicy `
        -Scope Process `
        -Force
}

Write-Host ""
Write-Host "====================================="
Write-Host " Update Process Complete "
Write-Host "====================================="
Write-Host ""

$Reboot = Read-Host "Reboot now? (Y/N)"

if ($Reboot -match '^[Yy]$')
{
    Write-Host ""
    Write-Host "Restarting computer..."
    Restart-Computer -Force
}
else
{
    Write-Host ""
    Write-Host "Please reboot later to finalise updates."
}