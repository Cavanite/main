<# Purpose: This script will import all the printers from a file and install them on the local machine.
The script will also install the correct drivers for the printers.
#>
<#Script information
Created on 8-7-2024
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
Start-Transcript -Path "$LogPath\Install-Printer-Drivers.log" -Append
#######################################################################################################

if (-not (Test-Path -Path "C:\Scripts" -PathType Container)) {
    New-Item -ItemType Directory -Path "C:\Scripts"
    write-host -f Green "Log Directory Created"
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
}
#######################################################################################################
#Variables
$LogPath = "C:\Scripts"
$FilePath = Read-Host "Enter the path to the printer drivers file. Example: C:\Scripts\printer_drivers.printerExport"
$Computer = $env:COMPUTERNAME
$Destination = "$LocalPath\printer_drivers.printerExport"
#######################################################################################################
Write-Host "Processing computer $Computer"
try {
    Start-BitsTransfer -Source $FilePath -Destination $Destination -Description "Copy $driverFile to $Computer" -DisplayName "Copying"
}
catch {
    Write-Host "Error copying file: $($_.Exception.Message)"
    Stop-Transcript
    Exit 1
}


Write-Host "Launching installation using Printbrm.exe on $Computer. This may take a while, please be patient..."
try {
    C:\Windows\System32\spool\tools\Printbrm.exe -F $Destination -R
    Write-Host "Printbrm.exe completed successfully"
    #The following line is optional, but it can be useful to check if the installation was successful using Microsoft Intune.
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Printers" /v Bulk-Printer-Install-Status /t REG_SZ /d 1 /f
}
catch {
    Write-Host "Printbrm.exe returned an error. Check console output above"
    exit
}
#######################################################################################################
Stop-Transcript
