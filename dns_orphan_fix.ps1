[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [bool]$dryrun = $false
)

# Initialization: Set the log file path
$logFilePath = "D:\CRON\DNS_Orphan_Fix\log.txt"
if (-not (Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File
}

# Start of Execution: Add the current date and time to the log
Add-Content -Path $logFilePath -Value ("Execution started at: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
# Import required modules
Import-Module ActiveDirectory
Import-Module DnsServer

# Connect to the DNS server
$DnsServer = "yourdnsserver"

# Get the domain's root distinguished name
$DomainDN = (Get-ADDomain).DistinguishedName

$DeletedComputers = Get-ADObject -Filter 'ObjectClass -eq "computer"' -IncludeDeletedObjects -SearchBase "CN=Deleted Objects,$DomainDN" -Properties IsDeleted,WhenChanged | Where-Object {
    $_.IsDeleted -eq $true -and $_.WhenChanged -gt (Get-Date).AddMinutes(-60)
}


foreach ($computer in $DeletedComputers) {
    # Extract the original name of the computer before the \0ADEL: part
     $OriginalName = ($computer.Name -split "`n")[0]
         
    # Construct the computer's DNS name
    $DnsName = "$OriginalName.<your_domain>"
    
   

# Check if dryrun is set to false, if so, try to delete the DNS record
if (-not $dryrun) {
    try {
        # Attempt to delete the DNS record
        Remove-DnsServerResourceRecord -ZoneName "<your_zone>" -RRType "A" -Name $DnsName -ComputerName $DnsServer -Force -ErrorAction Stop
        $message = "DNS record for $DnsName has been deleted."
        Write-Output $message
        Add-Content -Path $logFilePath -Value $message
    } catch {
        Write-Output $error_message
            $error_message = "Failed to delete $DnsName due to: $($_.Exception.Message)"
            Add-Content -Path $logFilePath -Value $error_message
    }
} else {
    # If dryrun is set to true, just print out what would happen
     $message = "Would delete DNS record for $DnsName."
     Write-Output $message
     Add-Content -Path $logFilePath -Value $message
}
}

