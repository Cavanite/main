#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
param (
    [string]$Updateto
)

if ([string]::IsNullOrEmpty($Updateto)) {
    Write-Host "############################################################################################################" -ForegroundColor Green
    Write-Host "Please provide the Office version to update to, example: scriptname.ps1 -officeVersionupdateto 16.0.17231.20236" -ForegroundColor Red
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
Add-Content -Path "C:\Scripts\Office365Update.log" -Value "Office 365 update process started. .$(Get-Date -format "dd-MM-yyyy ss:mm:HH"))" 
$logfile = "C:\Scripts\Office365Update$((Get-Date).ToString('dd-MM-yyyy')).log"
Write-Host "Log file created: $logfile" -ForegroundColor Green

Write-Host "############################################################################################################" -ForegroundColor Green
Write-Host "Starting the Office 365 update process..." -ForegroundColor DarkMagenta
Add-Content -Path $logfile -Value "Starting the Office 365 update process...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"

if (Test-Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe") {
    Write-Host "OfficeC2RClient.exe exists"
    Write-Host "Let's continue with the update process..." -ForegroundColor Green
    Add-Content -Path $logfile -Value "OfficeC2RClient.exe exists $(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
} else {
    Write-Host "OfficeC2RClient.exe does not exist"
    Add-Content -Path $logfile -Value "OfficeC2RClient.exe does not exist. $(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
    Write-Host "Exiting the update process..." -ForegroundColor Red
    Add-Content -Path $logfile -Value "Exiting the update process...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
    Write-Host "############################################################################################################" -ForegroundColor Green
    exit 1
}
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Checking the Office version...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
Write-Host "Checking the Office version..." -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Checking the Office version...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
Start-Sleep 2
$officeVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration").VersionToReport
Write-Host "Office version: $officeVersion" -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Office version: $officeVersion $(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
Start-Sleep 2

if ($officeVersion -eq $Updateto) {
    Write-Host "Office is already up to date" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Office is already up to date. $(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
    Write-Host "Exiting the update process..." -ForegroundColor DarkMagenta
    Write-Host "############################################################################################################" -ForegroundColor Green
    Add-Content -Path $logfile -Value "Exiting the update process...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
    Start-Sleep 2
    exit 0
}
Write-Host "############################################################################################################" -ForegroundColor Green
Set-Location "C:\Program Files\Common Files\Microsoft Shared\ClickToRun"
Write-Host "Starting the update process..." -ForegroundColor DarkMagenta
.\OfficeC2RClient.exe /update user updatetoversion=$Updateto
Write-Host "Waiting for the update process to finish..." -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Waiting for the update process to finish...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
Start-Sleep 600
Write-Host "############################################################################################################" -ForegroundColor Green
Write-Host "Checking the Office version..." -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Checking the Office version...$(Get-Date -format "dd-MM-yyyy ss:mm:HH")"
Start-Sleep 2
$officeVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration").VersionToReport
Write-Host "Office version: $officeVersion" -ForegroundColor DarkMagenta
Write-Host "############################################################################################################" -ForegroundColor Green
Add-Content -Path $logfile -Value "Office version: $officeVersion $(Get-Date -format "dd-MM-yyyy ss:mm:HH")" 
exit