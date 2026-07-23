# Run as Administrator

Write-Host "Starting software installation..."

# ============================================
# MICROSOFT 365 OFFLINE
# ============================================

$OfficeSetup = "C:\Installers\Office\setup.exe"
$OfficeConfig = "C:\Installers\Office\configuration.xml"

if ((Test-Path $OfficeSetup) -and (Test-Path $OfficeConfig))
{
    Write-Host "Installing Microsoft 365 Apps..."

    Start-Process `
        -FilePath $OfficeSetup `
        -ArgumentList "/configure `"$OfficeConfig`"" `
        -Wait

    Write-Host "Microsoft 365 install complete."
}
else
{
    Write-Warning "Office installer not found. Skipping."
}

# ============================================
# APPLICATIONS
# ============================================

$Apps = @(
    "Google.Chrome",
    "Mozilla.Firefox",
    "Adobe.Acrobat.Reader.64-bit",
    "7zip.7zip",
    "REALiX.HWiNFO",
    "CPUID.CPU-Z",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark",
    "AntibodySoftware.WizTree",
    "angryziber.AngryIPScanner",
)

foreach ($App in $Apps)
{
    Write-Host "Installing $App"

    winget install `
        --id $App `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent
}

Write-Host "Application installation complete."

# ============================================
# WAIT FOR ADOBE TO FINISH
# ============================================

Start-Sleep -Seconds 15

# ============================================
# ADOBE READER LOCKDOWN
# ============================================

Write-Host "Configuring Adobe Reader..."

$AdobePath = "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"

New-Item -Path $AdobePath -Force | Out-Null

# Disable Reader updater
New-ItemProperty `
    -Path $AdobePath `
    -Name "bUpdater" `
    -PropertyType DWord `
    -Value 0 `
    -Force | Out-Null

# Disable upsell prompts
New-ItemProperty `
    -Path $AdobePath `
    -Name "bAcroSuppressUpsell" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

# Disable Adobe Sign
New-ItemProperty `
    -Path $AdobePath `
    -Name "bDisableAdobeSign" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

# Disable cloud services / sign-in advertising
New-ItemProperty `
    -Path $AdobePath `
    -Name "bToggleAdobeDocumentServices" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

Write-Host "Adobe configuration complete."

Write-Host "Deployment complete."
