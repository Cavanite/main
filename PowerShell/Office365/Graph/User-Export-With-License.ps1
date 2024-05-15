# Purpose: This script will export all users from Office 365 with their licenses and save it to a CSV file.

#Script information

#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta

#Logging Section
#######################################################################################################
Start-Transcript -Path "C:\Scripts\Export-Office365-Users-With-License.log" -Append
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
#Graph Variables
$ClientId = ""
$TenantId = ""
$ClientSecret = ""
#######################################################################################################
if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
    Write-Host "Microsoft.Graph module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph
}
Start-sleep -Seconds 2
Write-Host "Microsoft.Graph module is installed, let's continue." -ForegroundColor Green
#######################################################################################################
#Connect to Graph API
try {
    Write-Host "Connecting to Microsoft Graph API" -ForegroundColor Green 
    Start-Sleep -Seconds 2
    $ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
    $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass
    Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome -Scope "Directory.Read.All"
    Write-Host "Succesfully connected to Graph" -ForegroundColor Green
    Start-Sleep -Seconds 3
}
catch {
    Write-Host "Failed to connect to Graph" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}
############################################################################
#Get all users from Office 365
$Users = Get-MgUser -All

try {
    $UserList = @()
    foreach ($User in $Users) {
        $UserList += [PSCustomObject]@{
            "UserPrincipalName" = $User.UserPrincipalName
            "DisplayName"       = $User.DisplayName
            "License"           = $User.AssignedLicenses[0].SkuId
        }
    }
    $UserList | Export-Csv -Path "C:\Scripts\Office365-Users-With-License.csv" -NoTypeInformation
    Write-Host "Exported all users to C:\Scripts\Office365-Users-With-License.csv" -ForegroundColor Green
    Start-Sleep -Seconds 3
}
catch {
    Write-Host "Failed to export users" -ForegroundColor Red
    exit
}
#######################################################################################################
Stop-Transcript