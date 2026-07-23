Import-Module ActiveDirectory

Clear-Host

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Active Directory Group Removal Tool"
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$User = Read-Host "Enter username (samAccountName)"

try {
    $UserObject = Get-ADUser -Identity $User -ErrorAction Stop
}
catch {
    Write-Host ""
    Write-Host "User not found." -ForegroundColor Red
    pause
    exit
}

$Groups = Get-ADPrincipalGroupMembership -Identity $User |
    Sort-Object Name

Write-Host ""
Write-Host "User: $($UserObject.Name)" -ForegroundColor Green
Write-Host ""
Write-Host "Current Group Memberships"
Write-Host "-------------------------------------"

$Groups | Select-Object Name | Format-Table -AutoSize

Write-Host ""
Write-Host "Total Groups: $($Groups.Count)"
Write-Host ""

$Confirm = Read-Host "Continue and remove memberships? (Y/N)"

if ($Confirm -notmatch '^[Yy]$') {
    Write-Host ""
    Write-Host "Operation cancelled."
    exit
}

Write-Host ""
Write-Host "Press ANY KEY to start removal..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$ProtectedGroups = @(
    "Domain Users",
    "Domain Computers",
    "Denied RODC Password Replication Group",
    "Users",
    "Everyone"
)

$Success = 0
$Failed = 0

foreach ($Group in $Groups)
{
    if ($Group.Name -in $ProtectedGroups)
    {
        Write-Host "Skipped: $($Group.Name)" -ForegroundColor Yellow
        continue
    }

    try
    {
        Remove-ADGroupMember `
            -Identity $Group `
            -Members $UserObject `
            -Confirm:$false `
            -ErrorAction Stop

        Write-Host "Removed: $($Group.Name)" -ForegroundColor Green
        $Success++
    }
    catch
    {
        Write-Host "Failed : $($Group.Name)" -ForegroundColor Red
        $Failed++
    }
}

Write-Host ""
Write-Host "====================================="
Write-Host " Summary"
Write-Host "====================================="
Write-Host ""
Write-Host "Removed : $Success" -ForegroundColor Green
Write-Host "Failed  : $Failed" -ForegroundColor Red
Write-Host ""

Write-Host "Remaining Memberships:"
Write-Host "-------------------------------------"

Get-ADPrincipalGroupMembership -Identity $User |
    Sort-Object Name |
    Select-Object Name |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Completed."
Write-Host ""

Pause