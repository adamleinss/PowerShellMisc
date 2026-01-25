$serviceName = "adfssrv"

# Hashtable mapping privilege constants to their display names
$privilegeMap = @{
    "SeAssignPrimaryTokenPrivilege" = "Replace a process level token"
    "SeAuditPrivilege" = "Generate security audits"
    "SeBackupPrivilege" = "Back up files and directories"
    "SeChangeNotifyPrivilege" = "Bypass traverse checking"
    "SeCreateGlobalPrivilege" = "Create global objects"
    "SeCreatePagefilePrivilege" = "Create a pagefile"
    "SeCreatePermanentPrivilege" = "Create permanent shared objects"
    "SeCreateSymbolicLinkPrivilege" = "Create symbolic links"
    "SeCreateTokenPrivilege" = "Create a token object"
    "SeDebugPrivilege" = "Debug programs"
    "SeDelegateSessionUserImpersonatePrivilege" = "Impersonate other users"
    "SeEnableDelegationPrivilege" = "Enable computer and user accounts to be trusted for delegation"
    "SeImpersonatePrivilege" = "Impersonate a client after authentication"
    "SeIncreaseBasePriorityPrivilege" = "Increase scheduling priority"
    "SeIncreaseQuotaPrivilege" = "Adjust memory quotas for a process"
    "SeIncreaseWorkingSetPrivilege" = "Increase a process working set"
    "SeLoadDriverPrivilege" = "Load and unload device drivers"
    "SeLockMemoryPrivilege" = "Lock pages in memory"
    "SeMachineAccountPrivilege" = "Add workstations to domain"
    "SeManageVolumePrivilege" = "Perform volume maintenance tasks"
    "SeProfileSingleProcessPrivilege" = "Profile single process"
    "SeRelabelPrivilege" = "Modify an object label"
    "SeRemoteShutdownPrivilege" = "Force shutdown from a remote system"
    "SeRestorePrivilege" = "Restore files and directories"
    "SeSecurityPrivilege" = "Manage auditing and security log"
    "SeShutdownPrivilege" = "Shut down the system"
    "SeSyncAgentPrivilege" = "Synchronize directory service data"
    "SeSystemEnvironmentPrivilege" = "Modify firmware environment values"
    "SeSystemProfilePrivilege" = "Profile system performance"
    "SeSystemtimePrivilege" = "Change the system time"
    "SeTakeOwnershipPrivilege" = "Take ownership of files or other objects"
    "SeTcbPrivilege" = "Act as part of the operating system"
    "SeTimeZonePrivilege" = "Change the time zone"
    "SeTrustedCredManAccessPrivilege" = "Access Credential Manager as a trusted caller"
    "SeUndockPrivilege" = "Remove computer from docking station"
    "SeUnsolicitedInputPrivilege" = "Not applicable"
    # Add more if needed for rare privileges
}

# Get the required privileges from registry
$privileges = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName" -Name "RequiredPrivileges" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty RequiredPrivileges

if ($privileges) {
    Write-Output "Required privileges for service '$serviceName':"
    foreach ($priv in $privileges) {
        $displayName = $privilegeMap[$priv]
        if ($displayName) {
            Write-Output "- $priv : $displayName"
        } else {
            Write-Output "- $priv : (Unknown or custom privilege)"
        }
    }
} else {
    Write-Output "No additional required privileges specified for service '$serviceName'."
}