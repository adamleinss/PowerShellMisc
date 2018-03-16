# Ignore error about non-existent registry key

$erroractionpreference = 'Continue'

# Change CREO Config files

$configFiles = Get-ChildItem "C:\Creo 2.0"  -filter *.psf -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}

# Change CREO PIM XML file

$configFiles = Get-ChildItem "C:\Creo 2.0"  -filter *.xml -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}

# Change supporting Creo install files

$configFiles = Get-ChildItem "C:\Creo 2.0"  -filter *.bat -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}

# Change ISODRAW Startup Preferences for all user profiles

$configFiles = Get-ChildItem "C:\users\*\Appdata\Roaming\PTC" -filter *.prf -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}

# Change CreoView MCAD config for all user profiles

$configFiles = Get-ChildItem "C:\users\*\Appdata\Roaming\PTC" -filter *.xml -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}

# Change Mathcad Prime config file

$configFiles = Get-ChildItem "C:\programdata\ptc" -filter *.config -recurse -exclude *.dll, *.exe

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "WKLIC01", "WKLIC09" } |
    Set-Content $file.PSPath
}


# If PTC_D_LICENSE_FILE exists, update its value, otherwise do nothing.

if (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name PTC_D_LICENSE_FILE) 

 { 
 write-output "PTC_D_LICENSE_FILE exists"

 Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name PTC_D_LICENSE_FILE -Value "7788@WKLIC09" 
 Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name PTC_D_LICENSE_FILE

 }
