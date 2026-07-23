$Apps = @(
"Mozilla.Firefox",
"7zip.7zip",
"Notepad++.Notepad++",
"REALiX.HWiNFO",
"CPUID.CPU-Z",
"CrystalDewWorld.CrystalDiskInfo",
"CrystalDewWorld.CrystalDiskMark",
"AntibodySoftware.WizTree",
"angryziber.AngryIPScanner"
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