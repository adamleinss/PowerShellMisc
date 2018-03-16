# Keep going if errors are encountered

$ErrorActionPreference = 'Continue'
$RunCode=0
$ConfigPath = "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\"

# Install VPN + GINA + DART

$dir = (Get-Item -Path ".\" -Verbose).FullName
write-host $dir

 Foreach($item in (ls $dir *.msi -Name))
	 {
	    Write-Host $item
	    $item = $dir + "\" + $item
	    $install = Start-Process msiexec -ArgumentList "/i $item /quiet /norestart" -Wait -Passthru
        $RunCode += $install.ExitCode
        Write-Host RunCode in Loop: $RunCode
	 }

# Create profiles folder if it doesn't exist
if (!(test-path $ConfigPath))

{
New-Item -Path $ConfigPath -Force -ItemType Directory
}

# Copy config file

Copy-Item *.xml -Destination $ConfigPath -Force

$LASTEXITCODE = $RunCode

Write-Host RunCode at end: $RunCode
Write-Host ExitCode at end: $LASTEXITCODE

# Return last execution result to batch file wrapper

return $LASTEXITCODE