Set-ExecutionPolicy Bypass Process 
New-Item -Type Directory -Path "D:\HWID"
Set-Location -Path "D:\HWID"
$env:Path += "C:\Program Files\WindowsPowerShell\Scripts"
Install-Script -Name Get-WindowsAutopilotInfo -Force
Get-WindowsAutopilotInfo -OutputFile .\$env:COMPUTERNAME.csv