@echo off

echo Disabling Windows Update...

net stop wuauserv
net stop bits
net stop dosvc
net stop usosvc

sc config wuauserv start= disabled
sc config bits start= disabled
sc config dosvc start= disabled
sc config usosvc start= disabled

reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f

schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable

echo.
echo Windows Update services disabled.
echo Reboot recommended.
pause