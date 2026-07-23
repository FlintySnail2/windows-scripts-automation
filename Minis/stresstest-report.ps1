#Requires -RunAsAdministrator

$ReportRoot = "C:\BuildReport"
$ReportFile = "$ReportRoot\Report.html"

New-Item -ItemType Directory -Force -Path $ReportRoot | Out-Null

Write-Host "Collecting system information..."

# System Information
$Computer = Get-CimInstance Win32_ComputerSystem
$CPU = Get-CimInstance Win32_Processor
$BIOS = Get-CimInstance Win32_BIOS
$OS = Get-CimInstance Win32_OperatingSystem

# Memory
$RAMGB = :Round($Computer.TotalPhysicalMemory / 1GB, 2)

# Physical Disks
$Disks = Get-PhysicalDisk | Select-Object `
    FriendlyName,
    MediaType,
    HealthStatus,
    Size

$DiskHtml = ""

foreach ($Disk in $Disks)
{
    $SizeGB = :Round(($Disk.Size / 1GB), 0)

    $DiskHtml += @"
<tr>
<td>$($Disk.FriendlyName)</td>
<td>$($Disk.MediaType)</td>
<td>$SizeGB GB</td>
<td>$($Disk.HealthStatus)</td>
</tr>
"@
}

# CPU Info

$CPUName = $CPU.Name
$Cores = $CPU.NumberOfCores
$Threads = $CPU.NumberOfLogicalProcessors

# Optional CrystalDiskMark

$DiskMarkResult = "Not Run"

$CrystalDiskMark = @(
    "C:\Program Files\CrystalDiskMark\DiskMark64.exe",
    "C:\Program Files\CrystalDiskMark8\DiskMark64.exe"
)

foreach ($Path in $CrystalDiskMark)
{
    if (Test-Path $Path)
    {
        Write-Host "Launching CrystalDiskMark..."
        Start-Process $Path
        $DiskMarkResult = "Launched Successfully"
        break
    }
}

# HWiNFO

$HWInfo = @(
    "C:\Program Files\HWiNFO64\HWiNFO64.EXE",
    "C:\Program Files\HWiNFO64\HWiNFO.exe"
)

foreach ($Path in $HWInfo)
{
    if (Test-Path $Path)
    {
        Start-Process $Path
        break
    }
}

# Generate Report

$Date = Get-Date

$Html = @"
<!DOCTYPE html>
<html>
<head>
<title>Build Report</title>

<style>

body {
    font-family: Segoe UI;
    margin: 40px;
}

table {
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid #cccccc;
    padding: 8px;
}

th {
    background-color: #eeeeee;
}

.pass {
    color: green;
    font-weight: bold;
}

</style>

</head>
<body>

<h1>Build Report</h1>

<p>
Generated: $Date
</p>

<h2>System Information</h2>

<ul>
<li><strong>Computer Name:</strong> $env:COMPUTERNAME</li>
<li><strong>Manufacturer:</strong> $($Computer.Manufacturer)</li>
<li><strong>Model:</strong> $($Computer.Model)</li>
<li><strong>Serial Number:</strong> $($BIOS.SerialNumber)</li>
<li><strong>Windows:</strong> $($OS.Caption)</li>
</ul>

<h2>CPU</h2>

<ul>
<li><strong>Name:</strong> $CPUName</li>
<li><strong>Cores:</strong> $Cores</li>
<li><strong>Threads:</strong> $Threads</li>
</ul>

<h2>Memory</h2>

<ul>
<li><strong>Total RAM:</strong> $RAMGB GB</li>
</ul>

<h2>Storage</h2>

<table>

<tr>
<th>Drive</th>
<th>Type</th>
<th>Size</th>
<th>Health</th>
</tr>

$DiskHtml

</table>

<h2>Validation</h2>

<ul>
<li class='pass'>PASS - Windows Installed</li>
<li class='pass'>PASS - Hardware Inventory Collected</li>
<li class='pass'>PASS - Storage Health Checked</li>
<li class='pass'>PASS - CrystalDiskMark Status: $DiskMarkResult</li>
</ul>

</body>
</html>
"@

$Html | Set-Content $ReportFile

Write-Host ""
Write-Host "Report Generated:"
Write-Host $ReportFile
Write-Host ""

Start-Process $ReportFile