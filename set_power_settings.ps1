Function Get-Laptop
{
 Param(
 [string]$computer = "localhost"
 )
 $isLaptop = $false
 if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | 
    Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 `
    -or $_.chassistypes -eq 14})
   { $isLaptop = $true }
 if(Get-WmiObject -Class win32_battery -ComputerName $computer) 
   { $isLaptop = $true }
 $isLaptop
} # end function Get-Laptop

# *** entry point to script ***

If(get-Laptop) { 
# set to balanced power plan
powercfg --% -SETACTIVE 381b4222-f694-41f0-9685-ff5bb260df2e
# set lid close to do nothing
powercfg --% -SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg --% -SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
# set power button action to shut down
powercfg --% -SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg --% -SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
# set sleep button action to do nothing
powercfg --% -SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
powercfg --% -SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
}

else { 
# set to high performance plan
start-process powercfg -Argumentlist '-SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
# turn of monitor sleep
start-process powercfg -Argumentlist '-change -monitor-timeout-ac 0'
# turn off disk sleep
start-process powercfg -Argumentlist '-change -disk-timeout-ac 0'
# turn off standby
start-process powercfg -Argumentlist '-change -standby-timeout-ac 0'
# turn off hiberation
start-process powercfg -Argumentlist '-h off'
}

