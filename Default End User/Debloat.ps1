# Run as Administrator

Write-Host "Removing Windows bloat..."

$Apps = @(
"*Xbox*",
"Microsoft.XboxGamingOverlay",
"Microsoft.GamingApp",
"Microsoft.549981C3F5F10",
"Clipchamp.Clipchamp",
"MicrosoftTeams",
"MSTeams",
"Microsoft.GetHelp",
"Microsoft.Getstarted",
"Microsoft.WindowsFeedbackHub",
"Microsoft.MixedReality.Portal",
"Microsoft.BingNews",
"Microsoft.BingWeather",
"SpotifyAB.SpotifyMusic",
"Facebook.Facebook",
"BytedancePte.Ltd.TikTok",
"Instagram.Instagram",
"Microsoft.MicrosoftSolitaireCollection"
)

foreach ($App in $Apps) {
    Get-AppxPackage -AllUsers $App | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online |
    Where-Object DisplayName -like $App |
    Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "Removing OEM software..."

$OEMKeywords = @(
    "HP",
    "Wolf",
    "OMEN",
    "Dell",
    "SupportAssist",
    "MyDell",
    "Lenovo",
    "Vantage",
    "McAfee"
)

Get-Package |
Where-Object {
    $name = $_.Name
    $OEMKeywords | Where-Object { $name -match $_ }
} |
ForEach-Object {
    try {
        Uninstall-Package -Name $_.Name -Force
    }
    catch {}
}

Write-Host "Debloat complete."