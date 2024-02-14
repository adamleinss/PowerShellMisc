# PowerShell script to remove LAPS client from Windows Server 2019 or 2022

# Function to uninstall LAPS
function Uninstall-LAPS {
    # Check the registry for the UninstallString
    $uninstallString = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
                       Where-Object { $_.DisplayName -like "*Local Administrator Password Solution*" } | 
                       Select-Object -ExpandProperty UninstallString

    if ($uninstallString) {
        Start-Process msiexec.exe -ArgumentList "/q /uninstall {97E2CA7B-B657-4FF7-A6DB-30ECC73E1E28}" -Wait -NoNewWindow
        Write-Host "LAPS client has been uninstalled."
    } else {
        Write-Host "LAPS client is not installed or could not find the uninstall string."
    }
}

# Main script
try {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $version = [Version]$os.Version
    $isServer2019or2022 = $version -ge [Version]"10.0.17763" -and $version -lt [Version]"10.0.20348" # Windows Server 2019
    $isServer2022 = $version -ge [Version]"10.0.20348" # Windows Server 2022

    if ($isServer2019or2022 -or $isServer2022) {
        Write-Host "Running on Windows Server 2019 or 2022. Proceeding to uninstall LAPS."
        Uninstall-LAPS
    } else {
        Write-Host "This script is intended only for Windows Server 2019 or 2022."
    }
} catch {
    Write-Host "An error occurred: $_"
}
