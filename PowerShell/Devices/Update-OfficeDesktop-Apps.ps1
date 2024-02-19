#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
param (
    [string]$Updateto,
    [string]$quiet
)

if ([string]::IsNullOrEmpty($Updateto)) {
    Write-Host "############################################################################################################" -ForegroundColor Green
    Write-Host "Please provide the Office version to update to, example: scriptname.ps1 -officeVersionupdateto 16.0.17231.20236" -quiet true or false -ForegroundColor Red
    Write-Host "############################################################################################################" -ForegroundColor Green
    exit 1
}

Write-Host "############################################################################################################" -ForegroundColor Green
Write-Host "Checking script directory..." -ForegroundColor Green
if (!(Test-Path "C:\Scripts")) {
    Write-Host "Creating the C:\Scripts directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path "C:\Scripts"
}
Write-Host "Script directory exists" -ForegroundColor Green
Write-Host "############################################################################################################" -ForegroundColor Green
Write-Host "Creating log file..." -ForegroundColor Green
Get-Date | Out-File -FilePath "C:\Scripts\Office365Update.log"
Add-Content -Path "C:\Scripts\Office365Update.log" -Value "Office 365 update process started" 
$logfile = "C:\Scripts\Office365Update$((Get-Date).ToString('dd-MM-yyyy')).log"
Write-Host "Log file created: $logfile" -ForegroundColor Green

Write-Host "############################################################################################################" -ForegroundColor Green
Write-Host "Starting the Office 365 update process..." -ForegroundColor DarkMagenta
Add-Content -Path $logfile -Value "Starting the Office 365 update process..."

if (Test-Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe") {
    Write-Host "OfficeC2RClient.exe exists"
    Write-Host "Let's continue with the update process..." -ForegroundColor Green
    Add-Content -Path $logfile -Value "OfficeC2RClient.exe exists"
} else {
    Write-Host "OfficeC2RClient.exe does not exist"
    Add-Content -Path $logfile -Value "OfficeC2RClient.exe does not exist"
    Write-Host "Exiting the update process..." -ForegroundColor Red
    Add-Content -Path $logfile -Value "Exiting the update process..."
    Write-Host "############################################################################################################" -ForegroundColor Green
    exit 1
}
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Checking the Office version..."
Write-Host "Checking the Office version..." -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Checking the Office version..."
Start-Sleep 2
$officeVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration").VersionToReport
Write-Host "Office version: $officeVersion" -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Office version: $officeVersion"
Start-Sleep 2

if ($officeVersion -eq $Updateto) {
    Write-Host "Office is already up to date" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Office is already up to date"
    Write-Host "Exiting the update process..." -ForegroundColor DarkMagenta
    Write-Host "############################################################################################################" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Exiting the update process..."
    Start-Sleep 2
    exit 0
}
Write-Host "############################################################################################################" -ForegroundColor Green
cmd.exe "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user displaylevel=$quiet forceappshutdown=false

Write-Host "Waiting for the update process to finish..." -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
if ($LASTEXITCODE -eq 0) {
    Write-Host "Office 365 update was successful" -ForegroundColor Green
    Write-Host "############################################################################################################" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Office 365 update was successful"
} else {
    Write-Host "Office 365 update failed" -ForegroundColor Red
    Write-Host "############################################################################################################" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Office 365 update failed"
}