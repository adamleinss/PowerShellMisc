<#
.SYNOPSIS
    Remove the local GPO cache on multiple computers via the C$ share.

.DESCRIPTION
    Reads a text file containing computer names, connects through the
    admin share (\\COMPUTER\C$\...), deletes every file/folder inside
    C:\Windows\System32\GroupPolicy, and logs/prints the outcome.

.PARAMETER ComputerListPath
    Path to the text file (one computer name per line).

.NOTES
    • PowerShell 5.1, plain ASCII.  
    • The run-as account must have rights to the C$ share.  
    • Logs are UTF-8 in C:\temp\gpo_cache_MMddyyyy.log.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ComputerListPath
)

# ===== USER SETTINGS =====
$DryRun = $false      # $true = preview only, $false = delete
# =========================

# ----- Logging helpers -----
$logFolder = 'C:\temp'
if (-not (Test-Path $logFolder)) { New-Item $logFolder -ItemType Directory -Force | Out-Null }

$logFile = Join-Path $logFolder ("gpo_cache_{0}.log" -f (Get-Date -Format 'MMddyyyy'))
New-Item $logFile -ItemType File -Force | Out-Null   # overwrite each day

function Write-Info {
    param([string]$msg)
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$stamp : $msg" | Tee-Object -FilePath $logFile -Append
}

Write-Info "===== Script started ====="
Write-Info "Dry-Run mode: $DryRun"
Write-Info "Reading computer list from '$ComputerListPath'"

# ----- Load computer names -----
$Computers = Get-Content $ComputerListPath |
             Where-Object { $_.Trim() } |
             ForEach-Object { $_.Trim() }

# ----- Main loop -----
foreach ($Computer in $Computers) {

    Write-Info "----- $Computer -----"

    if (-not (Test-Connection $Computer -Count 1 -Quiet)) {
        Write-Info "$Computer : UNREACHABLE"
        continue
    }

    $RemotePath = "\\$Computer\C$\Windows\System32\GroupPolicy"

    if (-not (Test-Path $RemotePath)) {
        Write-Info "$Computer : Path not found"
        continue
    }

    # Build list once for dry-run verbosity
    $items = Get-ChildItem $RemotePath -Force -Recurse -ErrorAction SilentlyContinue

    if ($DryRun) {
        if ($items.Count) {
            foreach ($i in $items) {
                $local = "C:\Windows\System32\GroupPolicy\" + `
                         $i.FullName.Substring($RemotePath.Length).TrimStart('\')
                Write-Info "Would delete : $local"
            }
        } else {
            Write-Info "$Computer : No files or folders to delete"
        }
        continue
    }

    # Real deletion – one call, no ordering issues
    try {
        Remove-Item (Join-Path $RemotePath '*') -Recurse -Force -ErrorAction Stop
        Write-Info "$Computer : Cache removed"
    } catch {
        Write-Info "$Computer : FAILED - $_"
    }
}

Write-Info "===== Script finished ====="
