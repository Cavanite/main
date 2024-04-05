# Purpose: This script is an example of a starting script that can be used as a template for other scripts.
#Real world example of the script.


#Script information


#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta
#######################################################################################################
#Making sure the script is running in PowerShell 7.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or later" -ForegroundColor Red
    Exit 
}
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

Start-Transcript -Path "C:\Scripts\Get-Signinlogs-Outside-NL.log" -Append
#######################################################################################################
#Installing Module and Setting up Connection to AzureAD
Write-Host "Script is starting" -ForegroundColor DarkMagenta
Start-Sleep -Seconds 2
Write-Host "Checking if AzureADPreview Module is installed" -ForegroundColor DarkMagenta
If (-not (Get-Module -Name AzureADPreview -ListAvailable)) {
    Install-Module -Name AzureADPreview -Force
    Import-Module AzureADPreview
}
Write-Host "AzureADPreview Module is installed" -ForegroundColor DarkMagenta

Write-Host "Connecting to AzureAD" -ForegroundColor DarkMagenta
Connect-AzureAD
Start-Sleep -Seconds 2
Write-Host "Connected to AzureAD" -ForegroundColor DarkMagenta
#######################################################################################################
#Gathering the SigninLogs
Write-Host "Gathering SigninLogs" -ForegroundColor DarkMagenta
try {
    #Get-AzureADAuditSignInLogs
}
catch {
    <#Do this if a terminating exception happens#>
}




Stop-Transcript