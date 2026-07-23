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