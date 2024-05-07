<#
Purpose: Duo to a vulnerability in the Windows Logon, Duo has released an update to fix this issue. This script will update the Duo software on the devices.
https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-duo-infodisc-rLCEqm6T
#>
#Script information
<#
This script will check the installed Duo version and compare it to the required version. If the installed version is lower than the required version, the script will download the latest version of the Duo software and install it.
#>

#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta

#Logging Section
#######################################################################################################
#######################################################################################################
if (-not (Test-Path -Path "C:\Scripts" -PathType Container)) {
    New-Item -ItemType Directory -Path "C:\Scripts"
    write-host -f Green "Log Directory Created"
    Start-Sleep -Seconds 3
}
else {
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 3
}

#######################################################################################################
#######################################################################################################
Start-Transcript -Path "C:\Scripts\DUO-Updater.log" -Append
#######################################################################################################
#Variables
$downloadURL = "https://dl.duosecurity.com/duo-win-login-latest.exe"
$downloadPath = "C:\Scripts\duo-win-login-latest.exe"
$RequiredVersion = "4.3.1"

#######################################################################################################

#Gather the installed Duo Version
$InstalledVersion = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "Duo Authentication for Windows Logon x64" }).DisplayVersion

try {
    if ($InstalledVersion -lt $RequiredVersion) {
        Write-Host "Updating Duo software..."
        Invoke-WebRequest -Uri $downloadURL -OutFile $downloadPath 
        Start-Process -FilePath $downloadPath -ArgumentList "/S" -Wait
        Write-Host "Duo software updated successfully."
        Start-Sleep -Seconds 3
        Stop-Transcript
        exit 0
    }
    else {
        Write-Host "Duo software is already up to date."
        Stop-Transcript
        Start-Sleep -Seconds 3
        exit 0
    }
    
}
catch {
    Write-Host "An error occurred: $_"
    Start-Sleep -Seconds 3
    Stop-Transcript
    exit 1
}
