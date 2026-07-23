@echo off
title Windows Update Repair - Stubborn Fix
color 0A

echo.
echo ===========================================
echo Windows Update Repair Utility
echo ===========================================
echo.

echo [1/10] Stopping services...
net stop wuauserv /y
net stop bits /y
net stop cryptsvc /y
net stop msiserver /y
net stop usosvc /y

echo.
echo [2/10] Clearing BITS queue...

del /f /q "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" 2>nul

echo.
echo [3/10] Renaming update cache folders...

ren C:\Windows\SoftwareDistribution SoftwareDistribution.old 2>nul
ren C:\Windows\System32\catroot2 catroot2.old 2>nul

echo.
echo [4/10] Resetting network stack...

netsh winsock reset
netsh winhttp reset proxy

echo.
echo [5/10] Re-registering Windows Update components...

regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll

echo.
echo [6/10] Repairing Windows component store...

DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo [7/10] Performing component cleanup...

DISM /Online /Cleanup-Image /StartComponentCleanup

echo.
echo [8/10] Running System File Checker...

sfc /scannow

echo.
echo [9/10] Restarting services...

net start cryptsvc
net start bits
net start wuauserv
net start msiserver

echo.
echo [10/10] Triggering update scan...

usoclient RefreshSettings
usoclient StartScan

echo.
echo ===========================================
echo Repair Complete
echo ===========================================
echo.
echo Recommended:
echo 1. Reboot PC
echo 2. Run Windows Update again
echo.

pause