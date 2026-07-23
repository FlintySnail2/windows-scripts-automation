# Run as Administrator

Write-Host "Removing unwanted Windows apps..."

$Apps = @(
"Microsoft.XboxApp",
"Microsoft.GamingApp",
"Microsoft.XboxGamingOverlay",
"Microsoft.XboxIdentityProvider",
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

foreach ($App in $Apps)
{
    Get-AppxPackage -AllUsers $App -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Get-AppxProvisionedPackage -Online |
    Where-Object {$_.DisplayName -like $App} |
    Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "Debloat complete."
