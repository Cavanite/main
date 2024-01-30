#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
#Make sure your app registration has the following permissions:
#User.Read.All
#AuditLog.Read.All

#This script will check account that havent signed in for x amount of days

$ClientId = ""
$TenantId = ""
$ClientSecret = ""

Write-Host "Checking if Microsoft.Graph.Authentication module is installed" -ForegroundColor Yellow


if (-not (Get-Module -Name Microsoft.Graph.Authentication -ListAvailable)) {
    Write-Host "Microsoft.Graph.Authentication module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser
}
Start-sleep -Seconds 2
Write-Host "Microsoft.Graph.Authentication module is installed, let's continue." -ForegroundColor Green

#create a user prompt for the days
$amountOfDays = Read-Host -Prompt 'Enter the signin age in days'

Write-Host "Connecting to Microsoft Graph API" -ForegroundColor Green 
Start-Sleep -Seconds 2
$ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential

Write-Host "Succesfully connected to Graph, retrieving users" -ForegroundColor Green
#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','Mail','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)

#Get All users along with the properties
$AllUsers = Get-MgUser -All -Property $Properties #| Select-Object $Properties

$SigninLogs = @()
$SigninAge = (Get-Date).AddDays(-$amountOfDays)

ForEach ($User in $AllUsers)
{
    $LastSignIn = $User.SignInActivity.LastSignInDateTime
    if ($LastSignIn -lt $SigninAge)
    {
        $SigninLogs += [PSCustomObject][ordered]@{
            LoginName       = $User.UserPrincipalName
            Email           = $User.Mail
            DisplayName     = $User.DisplayName
            UserType        = $User.UserType
            AccountEnabled  = $User.AccountEnabled
            LastSignIn      = $LastSignIn
        }
    }
}

#Export Data to CSV
if (Test-Path -Path "C:\Temp") {
    Write-Host "The directory C:\Temp exists, continuing" -ForegroundColor Green
    $SigninLogs | Export-Csv -Path "C:\Temp\SigninLogs.csv" -NoTypeInformation
    Write-Host "Successfully exported to CSV, at location C:\Temp\SigninLogs.csv" -ForegroundColor Green
} else {
    Write-Host "The directory C:\Temp does not exist, creating now" -ForegroundColor Yellow
    New-Item -Path "C:\Temp" -ItemType Directory
    $SigninLogs | Export-Csv -Path "C:\Temp\SigninLogs.csv" -NoTypeInformation
    Write-Host "Successfully exported to CSV, at location C:\Temp\SigninLogs.csv" -ForegroundColor Green
}
