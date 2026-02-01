# Define search term and log folder
$SearchTerm = "redacted"
$LogPath    = "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Google\Identity"

# Get all DCs
$DomainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

foreach ($DC in $DomainControllers) {
    Write-Host "=== Searching $DC ==="

    try {
        Invoke-Command -ComputerName $DC -ScriptBlock {
            param($SearchTerm, $LogPath)

            Write-Output "---- File Log Search ----"
            if (Test-Path $LogPath) {
                Get-ChildItem -Path $LogPath -Recurse -File -ErrorAction SilentlyContinue |
                Select-String -Pattern $SearchTerm -SimpleMatch |
                Select-Object Path, LineNumber, Line
            }
            else {
                Write-Output "No log folder found: $LogPath"
            }

            Write-Output "---- Event Log Search ----"
            try {
                # Correct log name is simply "Google"
                $events = Get-WinEvent -LogName "Google" -ErrorAction Stop |
                          Where-Object { $_.Message -match $SearchTerm }

                $events | Select-Object TimeCreated, Id, LevelDisplayName, Message
            }
            catch {
                Write-Output "Google event log not found"
            }
        } -ArgumentList $SearchTerm, $LogPath -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to query $DC $_"
    }
}
