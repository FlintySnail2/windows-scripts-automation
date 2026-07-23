
@echo off
echo Disabling Windows Update...

:: Stop services
net stop wuauserv
net stop bits
net stop dosvc

:: Disable services
sc config wuauserv start= disabled
sc config bits start= disabled
sc config dosvc start= disabled

:: Block medic service (re-enables updates normally)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f

echo Windows Updates Disabled.
pause
