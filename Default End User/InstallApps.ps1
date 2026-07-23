# Run as Administrator

$Apps = @(
"Google.Chrome",
"Mozilla.Firefox",
"Microsoft.OutlookForWindows",
"Adobe.Acrobat.Reader.64-bit",
"7zip.7zip",
"Notepad++.Notepad++",
"REALiX.HWiNFO",
"CPUID.CPU-Z",
"CrystalDewWorld.CrystalDiskInfo",
"CrystalDewWorld.CrystalDiskMark",
"AntibodySoftware.WizTree",
"angryziber.AngryIPScanner",
"PuTTY.PuTTY",
"WinSCP.WinSCP"
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