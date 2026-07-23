# Run as Administrator

Write-Host ""
Write-Host "====================================="
Write-Host "Configuring Adobe Acrobat Reader"
Write-Host "====================================="
Write-Host ""

$AdobePath = "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"

# Create policy path
New-Item -Path $AdobePath -Force | Out-Null

# Disable Updates
New-ItemProperty `
    -Path $AdobePath `
    -Name "bUpdater" `
    -PropertyType DWord `
    -Value 0 `
    -Force | Out-Null

# Suppress Upgrade / Pro Upsell Prompts
New-ItemProperty `
    -Path $AdobePath `
    -Name "bAcroSuppressUpsell" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

# Disable Adobe Sign Features
New-ItemProperty `
    -Path $AdobePath `
    -Name "bDisableAdobeSign" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

# Disable Adobe Cloud Services
New-ItemProperty `
    -Path $AdobePath `
    -Name "bToggleAdobeDocumentServices" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

Write-Host "Adobe Reader policies applied successfully."
Write-Host ""

Pause