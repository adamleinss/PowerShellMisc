# =====================================================================
# Setup ProcMon Continuous Logging using saved filter config (excel.pmc)
# Cleaned arguments (no /NoMemoryLogger, no /Compress)
# =====================================================================

$ProcMonExe = "C:\Tools\procmon.exe"
$ConfigFile = "C:\Tools\excel.pmc"
$LogFolder  = "C:\Logs\Procmon"
New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null

# Scheduled Task names
$TaskNameStart  = "ProcMon Continuous Excel Logging (PMC)"
$TaskNameRotate = "ProcMon Daily Rotate (PMC)"

# Remove any existing tasks
foreach ($t in @($TaskNameStart,$TaskNameRotate)) {
    if (Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $t -Confirm:$false
    }
}

# === Create wrapper script for startup ===
$StartScript = @'
$Date = Get-Date -Format "yyyyMMdd"
$LogFile = Join-Path "C:\Logs\Procmon" "procmon_$Date.pml"
$LauncherLog = Join-Path "C:\Logs\Procmon" "procmon_launcher_$Date.log"

"[$(Get-Date)] Starting ProcMon wrapper with PMC config..." | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
"[$(Get-Date)] Target PML: $LogFile" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8

# Cleanup old logs (keep 7 days)
try {
    Get-ChildItem -Path "C:\Logs\Procmon" -Filter "procmon_*.pml" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 7 |
        Remove-Item -Force -ErrorAction SilentlyContinue
    "[$(Get-Date)] Old logs cleaned up." | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
} catch {
    "[$(Get-Date)] Cleanup error: $_" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
}

# ProcMon args
$Args = "/Quiet /Minimized /AcceptEula " +
        "/LoadConfig C:\Tools\excel.pmc " +
        "/Backingfile `"$LogFile`""

"[$(Get-Date)] Command: C:\Tools\procmon.exe $Args" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8

try {
    $proc = Start-Process -FilePath "C:\Tools\procmon.exe" -ArgumentList $Args -PassThru
    "[$(Get-Date)] ProcMon launched, PID: $($proc.Id)" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
} catch {
    "[$(Get-Date)] Launch error: $_" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
}
'@

$StartScriptPath = Join-Path $LogFolder "start_procmon.ps1"
$StartScript | Out-File -FilePath $StartScriptPath -Encoding ASCII -Force

# Startup task: run wrapper script at boot (SYSTEM)
$ActionStart   = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$StartScriptPath`""
$TriggerStart  = New-ScheduledTaskTrigger -AtStartup
$Principal     = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName $TaskNameStart -Action $ActionStart -Trigger $TriggerStart -Principal $Principal -Description "Starts ProcMon with excel.pmc filter at boot"

# === Create rotation script for midnight ===
$RotateScript = @'
$Date = Get-Date -Format "yyyyMMdd"
$LauncherLog = Join-Path "C:\Logs\Procmon" "procmon_launcher_$Date.log"

"[$(Get-Date)] Rotation starting..." | Out-File -FilePath $LauncherLog -Append -Encoding UTF8

# Terminate ProcMon cleanly under SYSTEM
try {
    & "C:\Tools\procmon.exe" /AcceptEula /Terminate
    "[$(Get-Date)] ProcMon terminated." | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
} catch {
    "[$(Get-Date)] Terminate error: $_" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
}

Start-Sleep -Seconds 5

# Restart ProcMon with wrapper
try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Logs\Procmon\start_procmon.ps1"
    "[$(Get-Date)] Restart command executed." | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
} catch {
    "[$(Get-Date)] Restart error: $_" | Out-File -FilePath $LauncherLog -Append -Encoding UTF8
}
'@

$RotateScriptPath = Join-Path $LogFolder "rotate_procmon.ps1"
$RotateScript | Out-File -FilePath $RotateScriptPath -Encoding ASCII -Force

$ActionRotate  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$RotateScriptPath`""
$TriggerRotate = New-ScheduledTaskTrigger -Daily -At 00:01
Register-ScheduledTask -TaskName $TaskNameRotate -Action $ActionRotate -Trigger $TriggerRotate -Principal $Principal -Description "Rotates ProcMon log at midnight"
