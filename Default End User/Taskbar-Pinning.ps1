# Run as Administrator

Write-Host "Configuring Taskbar..."

# ============================================
# TASKBAR SETTINGS
# ============================================

# Disable Widgets
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
/v TaskbarDa `
/t REG_DWORD `
/d 0 `
/f

# Disable Task View
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
/v ShowTaskViewButton `
/t REG_DWORD `
/d 0 `
/f

# Disable Chat
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
/v TaskbarMn `
/t REG_DWORD `
/d 0 `
/f

# Search Icon Only
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" `
/v SearchboxTaskbarMode `
/t REG_DWORD `
/d 1 `
/f


# Always Show All Tray Icons
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" `
/v EnableAutoTray `
/t REG_DWORD `
/d 0 `
/f

# ============================================
# RESTART EXPLORER
# ============================================

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "Taskbar configured successfully."