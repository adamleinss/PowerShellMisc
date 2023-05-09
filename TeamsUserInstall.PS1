# Define the path to the Teams installer and the location of the user's startup folder
$TeamsInstaller = "\\vm-schools-01\netlogon\teams\TeamsSetup_c_w_.exe"

$OSInfo = Get-WmiObject -Class Win32_OperatingSystem
$OSVersion = [System.Version]::Parse($OSInfo.Version)
$OSCaption = $OSInfo.Caption

$IsWindows10or11 = ($OSVersion.Major -eq 10 -or $OSVersion.Major -eq 11) -and (-not $OSCaption.Contains("Server"))
$IsServer2012R2orLater = $OSCaption.Contains("Server") -and ($OSVersion.Major -gt 6 -or ($OSVersion.Major -eq 6 -and $OSVersion.Minor -ge 3))

# Check if Teams is installed in the user's profile
if (-not (Test-Path "$env:LOCALAPPDATA\Microsoft\Teams\Current\Teams.exe") -and $IsWindows10or11 -and -not $IsServer2012R2orLater) {
    # Teams is not installed in user's profile, so run the Teams user installer script
    write-output "Teams not installed"
	Start-Sleep -Seconds 60
    & $TeamsInstaller
}

<#
# Check if the Teams shortcut already exists in the user's startup folder
if (-not (Test-Path "$StartupFolder\$ShortcutName.lnk")) {

$CurrentUser = [Environment]::UserName
$TargetPath = "C:\Users\$CurrentUser\AppData\Local\Microsoft\Teams\Update.exe"
$Arguments = '--processStart "Teams.exe"'
$StartInPath = "C:\Users\$CurrentUser\AppData\Local\Microsoft\Teams"
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ShortcutFile = "$StartupFolder\$ShortcutName.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Arguments = $Arguments
$Shortcut.WorkingDirectory = $StartInPath
$Shortcut.Save()


} #>