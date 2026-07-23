
#Set execution policy 
$oldPolicy = Get-ExecutionPolicy -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force


#Install powershell win module 
@echo "Install Nuget pkg manager"
Install-PackageProvider -Name NuGet -Force # Install Nuget pkg manager

@echo "Install Update module"
Install-Module -Name PSWindowsUpdate -Force # Install update module

# wait 5s
sleep 5

@echo "Get all updates"
Get-WindowsUpdate

Read-Host "Paused - Hit enter to continue"

#Wait 5s
sleep 5

Install-WindowsUpdate -AcceptAll


# Revert execution policy back
Set-ExecutionPolicy $oldPolicy -Scope Process -Force


$choice = Read-Host "Reboot now? (Y/N)"

if ($choice -match "^[Yy]$") {
    Write-Host "Rebooting in 60 seconds..."
    Start-Sleep -Seconds 60
    Restart-Computer -Force
} else {
    Write-Host "No reboot selected.  process killed."
}

