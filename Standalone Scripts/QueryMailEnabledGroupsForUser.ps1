# Requires Exchange Online PowerShell
# Connect-ExchangeOnline first if not already connected

Clear-Host

Write-Host ""
Write-Host "====================================="
Write-Host " Exchange Group Membership Lookup"
Write-Host "====================================="
Write-Host ""

$User = Read-Host "Enter email address, alias, UPN or display name"

try
{
    Write-Host ""
    Write-Host "Locating user..." -ForegroundColor Yellow

    $UserObject = Get-User `
        -Identity $User `
        -ErrorAction Stop

    $UserDN = $UserObject.DistinguishedName

    Write-Host ""
    Write-Host "User Found:" -ForegroundColor Green
    Write-Host "Name  : $($UserObject.Name)"
    Write-Host "Alias : $($UserObject.Alias)"
    Write-Host ""

    Write-Host "Searching memberships..." -ForegroundColor Yellow

    $Groups = Get-Recipient `
        -ResultSize Unlimited `
        -Filter "Members -eq '$UserDN'" |
        Select-Object `
            Name,
            RecipientTypeDetails,
            PrimarySmtpAddress |
        Sort-Object Name

    Write-Host ""

    if (-not $Groups)
    {
        Write-Host "No group memberships found." -ForegroundColor Yellow
        return
    }

    Write-Host "====================================="
    Write-Host " Groups Found: $($Groups.Count)"
    Write-Host "====================================="
    Write-Host ""

    $Groups | Format-Table `
        Name,
        RecipientTypeDetails,
        PrimarySmtpAddress `
        -AutoSize

    Write-Host ""

    $Export = Read-Host "Export results to CSV? (Y/N)"

    if ($Export -match '^[Yy]$')
    {
        $Date = Get-Date -Format "yyyyMMdd-HHmmss"

        $CsvPath = "$env:USERPROFILE\Desktop\$($UserObject.Alias)-Groups-$Date.csv"

        $Groups | Export-Csv `
            -Path $CsvPath `
            -NoTypeInformation

        Write-Host ""
        Write-Host "CSV exported:" -ForegroundColor Green
        Write-Host $CsvPath
    }
}
catch
{
    Write-Host ""
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Lookup Complete"
Write-Host ""