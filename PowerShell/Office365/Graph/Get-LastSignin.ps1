#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
#Make sure your app registration has the following permissions:
#User.Read.All
#AuditLog.Read.All

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
$amountOfDays = Read-Host -Prompt 'Enter the amount of days to check for last login'

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
$Last60Days = (Get-Date).AddDays(-$amountOfDays)

ForEach ($User in $AllUsers)
{
    $LastSignIn = $User.SignInActivity.LastSignInDateTime
    if ($LastSignIn -ge $Last60Days)
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

$SigninLogs

#Export Data to CSV
$SigninLogs | Export-Csv -Path "C:\Temp\SigninLogs.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\Temp\SigninLogs.csv" -ForegroundColor Green