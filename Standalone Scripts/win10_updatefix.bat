@echo =off
net stop wuauserv
net stop bits
del /s /q  C:\Windows\SoftwareDistribution\*
net start wuauserv
net start
echo process complete
pause