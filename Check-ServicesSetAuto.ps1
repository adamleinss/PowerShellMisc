$ErrorActionPreference = "SilentlyContinue"

$ComputerNames = get-content D:\serverplus11.txt

Invoke-Command -Credential (Get-Credential) -ComputerName $ComputerNames -ScriptBlock {
    # Get all services with Startup Type 'Automatic' that aren't running
    $Services = Get-WmiObject -Class Win32_Service -Filter { State != 'Running' and StartMode = 'Auto' }

    foreach ($Service in $Services) {
        # Exclude service if Triggered
        if (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.Name)\TriggerInfo\") {
            continue
        }

        # Exclude service if Delayed
        $ItemProperty = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.Name)"
        if ($ItemProperty.Start -eq 2 -and $ItemProperty.DelayedAutoStart -eq 1) {
            continue
        }

        if ($service.name -eq "twdservice" -or $service.name -eq "Brother XP spl Service" -or $service.name -eq "TrustedInstaller") {

        continue 

        }

        # Output Service
        New-Object -TypeName PSObject -Property @{
            Status = $Service.State
            Name = $Service.Name
            DisplayName = $Service.DisplayName
            StartMode = $Service.StartMode
        }
    }
}