Set-ExecutionPolicy Bypass Process 
$scriptname = Get-WindowsAutopilotinfo
# check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}
$path = "D:\HWID"
try {
    if (-not (Test-Path $path)) {
        New-Item -Type Directory -Path $path -Force
        Write-Host "Directory created at $path" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "Directory already exists at $path" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}
catch {
    Write-Host "Error creating directory: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    Start-Sleep -Seconds 2
    exit
}
try {
    Write-Host "Starting $scriptname..." -ForegroundColor Green
    Install-Script -Name $scriptname
}
catch {
    Write-Host "Error occurred while starting ${scriptname}: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    Start-Sleep -Seconds 2
    exit
}

try {
    Write-Host "Running $scriptname..." -ForegroundColor Green
    Get-WindowsAutopilotinfo -OutputFile "$path\$env:COMPUTERNAME.csv"
}
catch {
    Write-Host "Error occurred while running ${scriptname}: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    Start-Sleep -Seconds 2
    exit
}