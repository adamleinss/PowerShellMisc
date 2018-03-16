$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData"
((Get-ChildItem $path).PsPath |Remove-Item -Recurse)

if (-not (Test-Path HKLM:\Software\AcmeDesktop))
 {
  New-Item -Path HKLM:\Software -Name AcmeDesktop –Force
 }
$registryPath = "HKLM:\Software\AcmeDesktop"
$Name = "SetBlueColor"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null