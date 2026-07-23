
MinimizeMaximizeClose



















































































Harry Mclean
Harry Mclean
Copilot Chat (Basic)


Upgrade

Auto

New design


You said:
does this mean dark mode cant be changee back to light?
Copilot said:
Nope. Those registry settings are just setting the default theme for the current user.

This:




PowerShell
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
/v SystemUsesLightTheme `
/t REG_DWORD `
/d 0 `
/f
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
/v AppsUseLightTheme `
/t REG_DWORD `
/d 0 `
/f
simply means:




Plain Text
0 = Dark Mode
1 = Light Mode
The user can still go to:




Plain Text
Settings
→ Personalization
→ Colors
→ Choose your mode
and switch back to:




Plain Text
Light
Dark
Custom
whenever they want.

The only time you'd lock it down is if you used Group Policy such as:




Plain Text
Prevent changing theme
Force specific theme
Force dark mode
which you're not doing.

For an MSP image I'd actually recommend:

Option 1 (My Preference)
Don't set a theme at all.

Let Windows use:




Plain Text
Default Light Mode
because that's what most business users expect.

Option 2
Set Dark Mode as the default:




PowerShell
SystemUsesLightTheme = 0
AppsUseLightTheme = 0
User can still change it later.

Personally I'd leave Dark Mode out of the deployment entirely. It doesn't add any business value and some users love it while others hate it. Everything else in your build has a practical benefit, whereas theme choice is purely personal preference.



You said:
cool give me the full script please
Copilot said:
Based on everything we've cut out and moved into the XML, this is the final Tweaks.ps1 I'd run during FirstLogon:




PowerShell
# Run as Administrator
 
Write-Host ""
Write-Host "====================================="
Write-Host "Applying Windows Tweaks"
Write-Host "====================================="
Write-Host ""
 
# ============================================
# SHOW HIDDEN FILES
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    /v Hidden `
    /t REG_DWORD `
    /d 1 `
    /f
 
# ============================================
# SHOW PROTECTED OPERATING SYSTEM FILES
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    /v ShowSuperHidden `
    /t REG_DWORD `
    /d 1 `
    /f
 
# ============================================
# DISABLE SUGGESTED CONTENT
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    /v SubscribedContent-338388Enabled `
    /t REG_DWORD `
    /d 0 `
    /f
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    /v SubscribedContent-353694Enabled `
    /t REG_DWORD `
    /d 0 `
    /f
 
# ============================================
# DISABLE LOCK SCREEN TIPS
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    /v RotatingLockScreenOverlayEnabled `
    /t REG_DWORD `
    /d 0 `
    /f
 
# ============================================
# DISABLE WINDOWS WELCOME EXPERIENCE
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    /v SoftLandingEnabled `
    /t REG_DWORD `
    /d 0 `
    /f
 
# ============================================
# DISABLE NOTIFICATION SUGGESTIONS
# ============================================
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" `
    /v NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK `
    /t REG_DWORD `
    /d 0 `
    /f
 
# ============================================
# RESTART EXPLORER
# ============================================
 
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe
 
Write-Host ""
Write-Host "====================================="
Write-Host "Tweaks Complete"
Write-Host "====================================="
Write-Host ""

Show less
Let the XML handle:
✅ File Extensions
✅ Open Explorer to This PC
✅ Widgets Disabled
✅ Task View Disabled
✅ Search Icon
✅ Edge First Run
✅ Edge Startup Boost
✅ Edge Background Mode
✅ Long Paths
✅ Consumer Experience
✅ Taskbar Layout / Pins
✅ Copilot

Your final script stack becomes:



Plain Text
SYSTEM
└── Debloat.ps1
 
FIRSTLOGON
├── InstallApps.ps1
│   ├── Office Offline
│   ├── Chrome
│   ├── Firefox
│   ├── Adobe
│   ├── MSP Tools
│   └── Adobe Sign-In Block
│
├── Tweaks.ps1
│
└── PostInstall.ps1
    ├── Windows Update Scan
    ├── Component Cleanup
    ├── Remove HWiNFO
    ├── Remove CPU-Z
    ├── Remove CrystalDiskInfo
    ├── Remove CrystalDiskMark
    └── Temp Cleanup

Show more lines
That's a pretty clean MSP-style deployment setup without duplicating what Schneegans is already doing in the XML.



You said:
in this can we renable light mode at the end too?


# Run as Administrator



Write-Host ""
Write-Host "====================================="
Write-Host "Starting Post Installation Cleanup"
Write-Host "====================================="
Write-Host ""



# ============================================
# WINDOWS UPDATE SCAN
# ============================================



Write-Host "Starting Windows Update Scan..."
UsoClient StartScan



# ============================================
# COMPONENT STORE CLEANUP
# ============================================



Write-Host "Cleaning Component Store..."
DISM /Online /Cleanup-Image /StartComponentCleanup



# ============================================
# REMOVE VALIDATION SOFTWARE
# ============================================



Write-Host "Removing Validation Software..."



$UninstallApps = @(
    "REALiX.HWiNFO",
    "CPUID.CPU-Z",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark"
)



foreach ($App in $UninstallApps)
{
    try
    {
        Write-Host "Removing $App"



        winget uninstall `
            --id $App `
            --exact `
            --silent `
            --accept-source-agreements



        Write-Host "$App removed."
    }
    catch
    {
        Write-Host "$App not found or already removed."
    }
}



# ============================================
# TEMP FILE CLEANUP
# ============================================



Write-Host "Cleaning TEMP folders..."



Get-ChildItem `
    "$env:TEMP" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Remove-Item `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue



# ============================================
# RECYCLE BIN
# ============================================



Write-Host "Emptying Recycle Bin..."



Clear-RecycleBin `
    -Force `
    -ErrorAction SilentlyContinue



# ============================================
# WINDOWS OLD
# ============================================



if (Test-Path "C:\Windows.old")
{
    Write-Host "Removing Windows.old..."



    Remove-Item `
        "C:\Windows.old" `
        -Force `
        -Recurse `
        -ErrorAction SilentlyContinue
}



# ============================================
# WINGET SOURCES UPDATE
# ============================================



Write-Host "Updating Winget Sources..."



winget source update



# ============================================
# FINISHED
# ============================================



Write-Host ""
Write-Host "====================================="
Write-Host "Cleanup Complete"
Write-Host "====================================="
Write-Host ""



Write-Host "Installed Applications Remaining:"
Write-Host "- Microsoft 365"
Write-Host "- Google Chrome"
Write-Host "- Mozilla Firefox"
Write-Host "- Adobe Acrobat Reader"
Write-Host "- 7-Zip"
Write-Host "- Notepad++"
Write-Host "- WizTree"
Write-Host "- Angry IP Scanner"
Write-Host "- PuTTY"
Write-Host "- WinSCP"

Copilot said:
Yep. If you're using Dark Mode during validation/build and want the customer to receive the machine in Light Mode, add this near the end of the script before the final "Cleanup Complete" section.




PowerShell
# ============================================
# SET LIGHT MODE
# ============================================
 
Write-Host "Setting Windows Light Mode..."
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    /v SystemUsesLightTheme `
    /t REG_DWORD `
    /d 1 `
    /f
 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    /v AppsUseLightTheme `
    /t REG_DWORD `
    /d 1 `
    /f

Show more lines
Then refresh Explorer:




PowerShell
# ============================================
# REFRESH EXPLORER
# ============================================
 
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe
So your flow becomes:




Plain Text
Windows Update Scan
↓
Component Cleanup
↓
Remove HWiNFO
↓
Remove CPU-Z
↓
Remove CrystalDiskInfo
↓
Remove CrystalDiskMark
↓
Temp Cleanup
↓
Recycle Bin
↓
Delete Windows.old
↓
Winget Source Update
↓
Set Light Mode
↓
Restart Explorer
↓
Cleanup Complete

Show more lines
This gives you:

✅ Office Installed
✅ Chrome Installed
✅ Acrobat Installed
✅ Adobe Sign-In Blocked
✅ Validation Tools Removed
✅ Light Mode Enabled
✅ Customer-ready presentation at handover

Honestly, I'd hand over in Light Mode. It feels more "new PC out of the box" and avoids users immediately asking why everything is black. 😉



You said:
can you give me the full script?
Generating response 
Copilot said:



PowerShell
# Run as Administrator
 
Write-Host ""
Write-Host "====================================="
Write-Host "Starting Post Installation Cleanup"
Write-Host "====================================="
Write-Host ""
 
# ============================================
# WINDOWS UPDATE SCAN
# ============================================
 
Write-Host "Starting Windows Update Scan..."
 
try {
    UsoClient StartScan
}
catch {
    Write-Host "Unable to start update scan."
}
 
# ============================================
# COMPONENT STORE CLEANUP
# ============================================
 
Write-Host "Cleaning Component Store..."
 
DISM /Online /Cleanup-Image /StartComponentCleanup
 
# ============================================
# REMOVE VALIDATION SOFTWARE
# ============================================
 
Write-Host "Removing Validation Software..."
 
$UninstallApps = @(
    "REALiX.HWiNFO",
    "CPUID.CPU-Z",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark"
)
 
foreach ($App in $UninstallApps)
{
    try
    {
        Write-Host "Removing $App"
 
        winget uninstall `
            --id $App `
            --exact `
            --silent `
            --accept-source-agreements
 
        Write-Host "$App removed."
    }
    catch
    {
        Write-Host "$App not found or already removed."
    }
}
 
# ============================================
# TEMP FILE CLEANUP
# ============================================
 
Write-Host "Cleaning TEMP folders..."
 
Get-ChildItem `
    "$env:TEMP" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Remove-Item `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue
 
# ============================================
# RECYCLE BIN
# ============================================
 
Write-Host "Emptying Recycle Bin..."
 
Clear-RecycleBin `
    -Force `
    -ErrorAction SilentlyContinue
 
# ============================================
# WINDOWS.OLD
# ============================================
 
if (Test-Path "C:\Windows.old")
{
    Write-Host "Removing Windows.old..."
 
    Remove-Item `
        "C:\Windows.old" `
        -Force `
        -Recurse `
        -ErrorAction SilentlyContinue
}
 
# ============================================
# UPDATE WINGET SOURCES
# ============================================
 
Write-Host "Updating Winget Sources..."
 
winget source update
 
# ============================================
# SET LIGHT MODE FOR CUSTOMER HANDOVER
# ============================================
 
Write-Host "

Show less



Message Copilot



AI-generated content may be incorrect
