# Based on https://4sysops.com/archives/remove-hkcu-registry-keys-of-multiple-users-with-powershell/

$users = (Get-ChildItem -path c:\users).name
foreach($user in $users)
 {
 reg load "hku\$user" "C:\Users\$user\NTUSER.DAT"
 write-host $user
 # Do what you need with "hkey_users\$user" here which links to that user HKU
 # Example: reg add "hkey_users\$user\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t "REG_DWORD" /d "0" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "Composition" /t "REG_DWORD" /d "1" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationColor" /t "REG_DWORD" /d "3291058124" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationColorBalance" /t "REG_DWORD" /d "00000059" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationAfterglow" /t "REG_DWORD" /d "3291058124" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationAfterglowBalance" /t "REG_DWORD" /d "10" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationBlurBalance" /t "REG_DWORD" /d "1" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorizationGlassAttribute" /t "REG_DWORD" /d "1" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t "REG_DWORD" /d "1" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "AccentColor" /t "REG_DWORD" /d "4291596073" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "ColorPrevalence" /t "REG_DWORD" /d "0" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\DWM" /v "EnableWindowColorization" /t "REG_DWORD" /d "1" /f

 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentPalette" /t "REG_BINARY" /d "79b0d1ff4fa5d8ff2c9ee2ff298fccff2480b6ff2071a1ff1f5b7eff88179800" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "StartColorMenu" /t "REG_DWORD" /d "4290150436" /f
 REG ADD "HKEY_USERS\$user\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentColorMenu" /t "REG_DWORD" /d "4291596073" /f

 REG ADD "HKEY_USERS\$user\Control Panel\Desktop" /v "AutoColorization" /t "REG_DWORD" /d "0" /f


 reg unload "hku\$user"
 }