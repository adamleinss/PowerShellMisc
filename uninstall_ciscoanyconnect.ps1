#Based on code from: http://www.weirdwindowsfixes.com/2016/12/powershell-functions-to-uninstall.html
#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Script Version
#$sScriptVersion = "1.0"
#script root

#$PSScriptRoot = ($MyInvocation.MyCommand.Path | Split-Path | Resolve-Path).ProviderPath

#logging variables.
#logdir = "$($env:ALLUSERSPROFILE)\InstallLogs"
#$Logfile = "$($logdir)\remove_anyconnect_$(get-date -format `"yyyyMMdd_hhmmsstt`").log"

# Set path to current script location

$dir = (Get-Item -Path ".\" -Verbose).FullName
Write-host "My directory is $dir"

#Function LogWrite($string, $color)
#{
#   if ($Color -eq $null) {$color = "white"}
#   write-host $string -foregroundcolor $color
#   $string | out-file -Filepath $logfile -append
#}

#if(!(Test-Path -Path $logdir )){
#    New-Item -ItemType directory -Path $logdir
#}


########################################
#$CP_USER_NAME = (Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
#$user = New-Object System.Security.Principal.NTAccount("corp", "$CP_USER_NAME") 
#$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
#$userprofile = Get-WmiObject -Namespace root/cimv2 -Class win32_userprofile -Filter "SID='$($sid.value)'"
#$CP_USER_HOME = $userprofile.localpath


function stopservices(){
get-service 'ciscod.exe', 'acwebsecagent' | ? { $_.Status -eq 'Started'  } | % {
  $_ | stop-service
  sleep 1
  $result = if (($_ | get-service).Status -eq "Running") {"success"} else {"failure"}
  LogWrite "Service stopped $result"
}
}

Function acuninstall()
{
            $uninstallerfile = "$PSScriptRoot\Uninstall.exe"
            $UninstallSyntax = "-remove -silent"
            $process = Start-Process $uninstallerfile -ArgumentList $UninstallSyntax -Wait -Passthru

            if ($process.ExitCode -eq 0) {
                 LogWrite "AnyConnect has been successfully uninstalled" yellow
            }
            else {
                LogWrite "installer exit code  $($process.ExitCode) for AnyConnect" red
 }
 
}

Function dartuninstall()
{
    
    $dart = Get-WmiObject -Namespace "root\cimv2\sms" -Class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Diagnostics" }
    $uninst = $dart.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $dartuninstallcode = $uninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $dartuninstallcode /quiet /norestart" -Wait
 
}

function startbeforeloginuninstall()
{
 $startbeforelogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Start Before Login Module"}
 $startbeforeloginuninst = $startbeforelogin.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
 $startbeforeloginuninstcode = $startbeforeloginuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $startbeforeloginuninstcode /quiet /norestart" -Wait
}

function websecurityuninstall()
{
 $websecuritylogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Web Security Module" }
 $websecurityuninst = $websecuritylogin.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
 $websecurityuninstcode = $websecurityuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $websecurityuninstcode /quiet /norestart" -Wait
}

function postureuninstall()
{
 $posturelogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Posture Module" }
 $postureuninst = $posturelogin.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
 $postureuninstcode = $postureuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $postureuninstcode /quiet /norestart" -Wait
}

function telemetryuninstall()
{
 $telemetrylogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Telemetry Module" }
 $telemetryuninst = $telemetrylogin.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
 $telemetryuninstcode = $telemetryuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $telemetryuninstcode /quiet /norestart" -Wait
}
function namuninstall()
{
 $namlogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Network Access Manager" }
 $namuninst = $namlogin.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
 $namuninstcode = $namuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $namuninstcode /quiet /norestart" -Wait
}

function anyconnectuninstall()
{
 $anyconnectlogin = Get-WmiObject -NameSpace "root\cimv2\sms" -class SMS_InstalledSoftware | where { $_.ARPDisplayName -match "Cisco AnyConnect Secure Mobility Client" }
 $anyconnectuninst = $anyconnectlogin.SoftwareCode
 $anyconnectuninstcode = $anyconnectuninst.Trim()
 Start-Process "msiexec.exe" -arg "/X $anyconnectuninstcode /quiet /norestart" -Wait
}

# if we have an IP address that is in the VPN IP range, bomb out

function checkifonvpn()

{

 $IPAddresses = (get-netipaddress).ipaddress

 if (($IPAddresses -like "192.168.81.*") -or ($IPAddresses -like "192.168.82.*")  -or ($IPAddresses -like "192.168.83.*") -or ($IPAddresses -like "192.168.84.*") -or ($IPAddresses -like "192.168.87.*"))

 { 
 write-host "On VPN!"
 exit 12345
 }

 
}

function installnewac ()

{

write-host $dir

start-process "msiexec.exe" -Argumentlist "/i $dir\anyconnect-win-4.5.01044-core-vpn-predeploy-k9.msi /norestart /quiet /lvx* C:\windows\temp\anyconnect-vpn.log"  -Wait -PassThru
start-process "msiexec.exe" -Argumentlist "/i $dir\anyconnect-win-4.5.01044-gina-predeploy-k9.msi /norestart /quiet /lvx* C:\windows\temp\anyconnect-sbl.log" -Wait -PassThru
start-process "msiexec.exe" -Argumentlist "/i $dir\anyconnect-win-4.5.01044-websecurity-predeploy-k9.msi /norestart /quiet /lvx* C:\windows\temp\anyconnect-web.log" -Wait -PassThru
}

function mrclean ()

{

Try {

    $Keys=Get-ChildItem HKCR:\Installer -Recurse -ErrorAction Stop | Get-ItemProperty -name ProductName -ErrorAction SilentlyContinue

}

Catch {
    New-PSDrive -Name HKCR -PSProvider registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    $Keys=Get-ChildItem HKCR:\Installer -Recurse | Get-ItemProperty -name ProductName -ErrorAction SilentlyContinue
    }
    
Finally { 
    foreach ($Key in $Keys) {

        if ($Key.ProductName -like "*Anyconnect*") {
    
           Remove-Item $Key.PSPath -Force -Recurse         
        }
     }

}

}

# If on VPN, bomb out with error code 12345 and try later

checkifonvpn

# Uninstall SBL

startbeforeloginuninstall

# Uninstall websecurity

websecurityuninstall

# Uninstall main client

anyconnectuninstall

# Make sure we are clean from any previous install of Anyconnect

mrclean

# install new AnyConnect version

installnewac