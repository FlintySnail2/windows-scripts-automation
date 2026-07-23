#Requires -RunAsAdministrator

$ErrorActionPreference = "SilentlyContinue"

# =====================================================
# REPORT PATHS
# =====================================================

$ReportRoot = "C:\BuildReport"
$ReportFile = Join-Path $ReportRoot "Report.html"
$TemplateFile = Join-Path $PSScriptRoot "report-template.html"

New-Item -ItemType Directory -Force -Path $ReportRoot | Out-Null

Write-Host ""
Write-Host "Collecting system information..."
Write-Host ""

# =====================================================
# SYSTEM INFO
# =====================================================

$Computer = Get-CimInstance Win32_ComputerSystem
$CPU      = Get-CimInstance Win32_Processor
$BIOS     = Get-CimInstance Win32_BIOS
$OS       = Get-CimInstance Win32_OperatingSystem

$CPUName  = $CPU.Name.Trim()
$Cores    = $CPU.NumberOfCores
$Threads  = $CPU.NumberOfLogicalProcessors
$CPUClock = ("{0:N2} GHz" -f ($CPU.MaxClockSpeed / 1000))

# =====================================================
# MEMORY
# =====================================================

$RAMGB = :Round(
    $Computer.TotalPhysicalMemory / 1GB,
    0
)

$MemoryModules = Get-CimInstance Win32_PhysicalMemory

$MemoryRows = ""

foreach($Module in $MemoryModules)
{
    $DDRTypeRow = switch($Module.SMBIOSMemoryType)
    {
        20 {"DDR"}
        21 {"DDR2"}
        24 {"DDR3"}
        26 {"DDR4"}
        34 {"DDR5"}
        Default {"Unknown"}
    }

    $MemoryRows += @"
<tr>
<td>$($Module.DeviceLocator)</td>
<td>$DDRTypeRow</td>
<td>$(:Round($Module.Capacity / 1GB,0)) GB</td>
<td>$($Module.Speed) MHz</td>
</tr>
"@
}

$PrimaryMemory = $MemoryModules | Select-Object -First 1

$DDRType = switch($PrimaryMemory.SMBIOSMemoryType)
{
    20 {"DDR"}
    21 {"DDR2"}
    24 {"DDR3"}
    26 {"DDR4"}
    34 {"DDR5"}
    Default {"Unknown"}
}

$RAMSpeed = "$($PrimaryMemory.Speed) MHz"

# =====================================================
# DISKS
# =====================================================

$PhysicalDisks = Get-PhysicalDisk

$DiskRows = ""
$HealthValues = @()

foreach($Disk in $PhysicalDisks)
{
    $Health = switch($Disk.HealthStatus)
    {
        "Healthy" {100}
        "Warning" {75}
        Default {50}
    }

    $HealthValues += $Health

    $DiskRows += @"
<tr>
<td>$($Disk.FriendlyName)</td>
<td>$($Disk.MediaType)</td>
<td>$(:Round($Disk.Size / 1GB,0)) GB</td>
<td>
<div class='health-wrapper'>
<div class='health-bar'>
<div class='health-fill' style='width:$Health%'></div>
</div>
<div class='health-text'>$Health%</div>
</div>
</td>
</tr>
"@
}

$AverageHealth = 100

if($HealthValues.Count -gt 0)
{
    $AverageHealth = :Round(
        ($HealthValues | Measure-Object -Average).Average,
        0
    )
}

# =====================================================
# WINDOWS ACTIVATION
# =====================================================

$Activated = "No"

try
{
    $License = Get-CimInstance SoftwareLicensingProduct |
        Where-Object {
            $_.PartialProductKey -and
            $_.LicenseStatus -eq 1
        }

    if($License)
    {
        $Activated = "Yes"
    }
}
catch{}

# =====================================================
# TPM
# =====================================================

$TPMStatus = "Unknown"

try
{
    $TPM = Get-Tpm

    if($TPM.TpmPresent)
    {
        $TPMStatus = "Detected"
    }
    else
    {
        $TPMStatus = "Not Present"
    }
}
catch{}

# =====================================================
# SECURE BOOT
# =====================================================

$SecureBoot = "Unsupported"

try
{
    if(Confirm-SecureBootUEFI)
    {
        $SecureBoot = "Enabled"
    }
    else
    {
        $SecureBoot = "Disabled"
    }
}
catch{}

# =====================================================
# SOFTWARE VALIDATION
# =====================================================

$RequiredSoftware = @(
    "Firefox",
    "7-Zip",
    "Notepad++",
    "CPU-Z",
    "CrystalDiskInfo",
    "CrystalDiskMark",
    "HWiNFO",
    "WizTree",
    "Angry IP Scanner"
)

$InstalledApps = Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue

$SoftwareRows = ""

foreach($Software in $RequiredSoftware)
{
    $Found = $InstalledApps |
        Where-Object {
            $_.DisplayName -like "*$Software*"
        }

    if($Found)
    {
        $Status = "✅ Installed"
    }
    else
    {
        $Status = "❌ Missing"
    }

    $SoftwareRows += @"
<tr>
<td>$Software</td>
<td>$Status</td>
</tr>
"@
}

# =====================================================
# BENCHMARK APPLICATIONS
# =====================================================

$DiskMarkResult = "Not Found"

$CrystalDiskMark = @(
    "C:\Program Files\CrystalDiskMark\DiskMark64.exe",
    "C:\Program Files\CrystalDiskMark8\DiskMark64.exe"
)

foreach($Path in $CrystalDiskMark)
{
    if(Test-Path $Path)
    {
        Start-Process $Path
        $DiskMarkResult = "Launched Successfully"
        break
    }
}

$CrystalDiskInfo = @(
    "C:\Program Files\CrystalDiskInfo\DiskInfo64.exe",
    "C:\Program Files\CrystalDiskInfo\DiskInfo32.exe"
)

foreach($Path in $CrystalDiskInfo)
{
    if(Test-Path $Path)
    {
        Start-Process $Path
        break
    }
}

$HWiNFO = @(
    "C:\Program Files\HWiNFO64\HWiNFO64.exe",
    "C:\Program Files\HWiNFO64\HWiNFO.exe"
)

foreach($Path in $HWiNFO)
{
    if(Test-Path $Path)
    {
        Start-Process $Path
        break
    }
}

# =====================================================
# VALIDATION TABLE
# =====================================================

$ValidationRows = ""

function Add-ValidationRow
{
    param(
        [string]$Name,
        [bool]$Passed
    )

    if($Passed)
    {
        $Result = "✅ PASS"
    }
    else
    {
        $Result = "❌ FAIL"
    }

    $script:ValidationRows += @"
<tr>
<td>$Name</td>
<td>$Result</td>
</tr>
"@
}

Add-ValidationRow "Windows Activated" ($Activated -eq "Yes")
Add-ValidationRow "TPM Detected" ($TPMStatus -eq "Detected")
Add-ValidationRow "Secure Boot Enabled" ($SecureBoot -eq "Enabled")
Add-ValidationRow "Physical Disks Detected" ($PhysicalDisks.Count -gt 0)
Add-ValidationRow "RAM Detected" ($RAMGB -gt 0)
Add-ValidationRow "CrystalDiskMark Available" ($DiskMarkResult -eq "Launched Successfully")

# =====================================================
# OVERALL STATUS
# =====================================================

$OverallStatus = "✅ PASS"

if($ValidationRows -match "❌ FAIL")
{
    $OverallStatus = "❌ FAIL"
}

# =====================================================
# LOAD HTML TEMPLATE
# =====================================================

if(!(Test-Path $TemplateFile))
{
    Write-Host ""
    Write-Host "Template missing:"
    Write-Host $TemplateFile
    Write-Host ""

    exit
}

$Html = Get-Content $TemplateFile -Raw

# =====================================================
# PLACEHOLDER REPLACEMENT
# =====================================================

$Html = $Html.Replace('{{DATE}}',(Get-Date))
$Html = $Html.Replace('{{CPU}}',$CPUName)
$Html = $Html.Replace('{{CORES}}',$Cores)
$Html = $Html.Replace('{{THREADS}}',$Threads)
$Html = $Html.Replace('{{CPUCLOCK}}',$CPUClock)

$Html = $Html.Replace('{{TOTALRAM}}',"$RAMGB GB")
$Html = $Html.Replace('{{DDR}}',$DDRType)
$Html = $Html.Replace('{{RAMSPEED}}',$RAMSpeed)

$Html = $Html.Replace('{{AVGHEALTH}}',$AverageHealth)
$Html = $Html.Replace('{{DRIVECOUNT}}',$PhysicalDisks.Count)

$Html = $Html.Replace('{{COMPUTERNAME}}',$env:COMPUTERNAME)
$Html = $Html.Replace('{{MANUFACTURER}}',$Computer.Manufacturer)
$Html = $Html.Replace('{{MODEL}}',$Computer.Model)
$Html = $Html.Replace('{{SERIAL}}',$BIOS.SerialNumber)
$Html = $Html.Replace('{{OS}}',$OS.Caption)
$Html = $Html.Replace('{{BUILD}}',$OS.BuildNumber)

$Html = $Html.Replace('{{ACTIVATED}}',$Activated)
$Html = $Html.Replace('{{TPM}}',$TPMStatus)
$Html = $Html.Replace('{{SECUREBOOT}}',$SecureBoot)

$Html = $Html.Replace('{{OVERALL_STATUS}}',$OverallStatus)
$Html = $Html.Replace('{{CDMSTATUS}}',$DiskMarkResult)

$Html = $Html.Replace('{{MEMORY_ROWS}}',$MemoryRows)
$Html = $Html.Replace('{{DISK_ROWS}}',$DiskRows)
$Html = $Html.Replace('{{SOFTWARE_ROWS}}',$SoftwareRows)
$Html = $Html.Replace('{{VALIDATION_ROWS}}',$ValidationRows)

$Html = $Html.Replace('{{CDI_SCREENSHOT}}','Not Captured')
$Html = $Html.Replace('{{CDM_SCREENSHOT}}','Not Captured')
$Html = $Html.Replace('{{CPUZ_SCREENSHOT}}','Not Captured')
$Html = $Html.Replace('{{HWINFO_SCREENSHOT}}','Not Captured')

# =====================================================
# SAVE REPORT
# =====================================================

$Html | Set-Content $ReportFile -Encoding UTF8

Write-Host ""
Write-Host "========================================"
Write-Host " Validation Complete"
Write-Host "========================================"
Write-Host ""
Write-Host "Report: $ReportFile"
Write-Host ""

Start-Process explorer.exe $ReportRoot

Start-Sleep 1

Invoke-Item $ReportFile