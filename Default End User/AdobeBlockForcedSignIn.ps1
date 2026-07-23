New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Force

New-ItemProperty `
-Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" `
-Name bUpdater `
-Type DWord `
-Value 0 `
-Force

New-ItemProperty `
-Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" `
-Name bAcroSuppressUpsell `
-Type DWord `
-Value 1 `
-Force