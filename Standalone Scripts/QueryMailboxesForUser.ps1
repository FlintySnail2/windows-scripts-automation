$email = Read-Host "Enter user email"

$Results = @()

Write-Host ""
Write-Host "Checking Full Access..." -ForegroundColor Yellow

Get-Mailbox `
    -RecipientTypeDetails UserMailbox,SharedMailbox `
    -ResultSize Unlimited |
ForEach-Object {

    $Mailbox = $_

    $FullAccess = Get-MailboxPermission `
        -Identity $Mailbox.Identity |
        Where-Object {
            $_.User -eq $email -and
            $_.AccessRights -contains "FullAccess" -and
            -not $_.IsInherited
        }

    if ($FullAccess)
    {
        $Results += [PSCustomObject]@{
            Mailbox    = $Mailbox.PrimarySmtpAddress
            Permission = "Full Access"
        }
    }

    $SendAs = Get-RecipientPermission `
        -Identity $Mailbox.Identity `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Trustee -eq $email
        }

    if ($SendAs)
    {
        $Results += [PSCustomObject]@{
            Mailbox    = $Mailbox.PrimarySmtpAddress
            Permission = "Send As"
        }
    }

    if ($Mailbox.GrantSendOnBehalfTo)
    {
        foreach ($User in $Mailbox.GrantSendOnBehalfTo)
        {
            if ($User.Name -eq $email)
            {
                $Results += [PSCustomObject]@{
                    Mailbox    = $Mailbox.PrimarySmtpAddress
                    Permission = "Send On Behalf"
                }
            }
        }
    }
}

$Results |
    Sort-Object Mailbox |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Total Permissions Found: $($Results.Count)" -ForegroundColor Green