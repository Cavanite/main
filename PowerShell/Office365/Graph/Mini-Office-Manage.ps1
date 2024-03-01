#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
#Make sure your app registration has the following permissions:
# 	Policy.Read.All
# 	Reports.Read.All
# 	SignIns.Read.All
#   AuditLog.Read.All


#This script will get the following information:
    #Office365 Admin Center
# - All users
#- Blocked users with license
# - Temp Accounts
# - Unused licenses
# - Admin roles

    #Entra Admin Center
# - Signins older then two months (Users that haven't signed in for two months) done
# - Singins from outside The Netherlands
# - Risky signins
#- Gets all named locations
# - Conditional Access Policies

    #Exchange Admin Center
# - Mailbox sizes
# - Mailbox Archiving status

    #Intune Admin Center
# - Non-compliant devices
# - Device encryption status
# - App installation errors


############################################################################
$ClientId = ""
$TenantId = ""
$ClientSecret = ""
############################################################################
Write-Host "Checking if Microsoft.Graph module is installed" -ForegroundColor Yellow
############################################################################
Start-Transcript -Path "C:\scripts\Mini-Office-Manage.log" -Append
############################################################################
if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
    Write-Host "Microsoft.Graph module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph
}
Start-sleep -Seconds 2
Write-Host "Microsoft.Graph module is installed, let's continue." -ForegroundColor Green
############################################################################
Write-Host "Connecting to Microsoft Graph API" -ForegroundColor Green 
Start-Sleep -Seconds 2
$ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome
Start-Sleep -Seconds 5
############################################################################
Write-Host "Succesfully connected to Graph" -ForegroundColor Green
Start-Sleep -Seconds 2
############################################################################
Write-Host "Connecting to Office365 Admin Center" -ForegroundColor Yellow
Start-Sleep -Seconds 2
############################################################################
Write-Host "Creating scripts folder..." -ForegroundColor Yellow
New-Item -Path "C:\scripts" -ItemType Directory -Force
Write-host "Folder created" -ForegroundColor Green
############################################################################

# Get all users and export to CSV with the following properties
Start-Sleep -Seconds 2
Write-Host "Getting all active users and exporting to CSV..." -ForegroundColor Yellow

$Properties = @(
    "DisplayName",
    "UserPrincipalName",
    "AccountEnabled",
    "UserType"
)
$ActiveUsers = Get-MgUser -Filter "accountEnabled eq true" -Select $Properties

$UserList = foreach ($User in $ActiveUsers) {
    $UserProperties = [PSCustomObject]@{
        "DisplayName" = $User.DisplayName
        "UserPrincipalName" = $User.UserPrincipalName
        "AccountEnabled" = $User.AccountEnabled.ToString()
        "UserType" = $User.UserType
    }
    $UserProperties
}

$UserList | Export-Csv -Path "C:\scripts\ActiveUsers.csv" -NoTypeInformation -Append
Write-Host "All active users exported to CSV" -ForegroundColor Green
Start-Sleep -Seconds 2
############################################################################

$adminRoles = @(
    "Exchange Administrator",
    "SharePoint Administrator",
    "Teams Administrator",
    "User Administrator",
    "Global Administrator",
    "Helpdesk Administrator"
    "Global Reader"
    "Security Administrator"
    "Guest Inviter"
    "Billing Administrator"
    "Compliance Administrator"
    "Device Administrator"
    "Intune Administrator"
    "Authentication Administrator"
    "Application Administrator"
    "Application Developer"
)

$adminUsers = [System.Collections.Generic.List[PSCustomObject]]::new()

Write-Host "Getting admin users and their roles..." -ForegroundColor Yellow
foreach ($role in $adminRoles) {
    $directoryRole = Get-MgDirectoryRole -Filter "DisplayName eq '$role'"
    if ($directoryRole) {
        $roleId = $directoryRole.Id
        $userList = Get-MgDirectoryRoleMember -DirectoryRoleId $roleId

        foreach ($user in $userList) {
            $upn = (Get-MgUser -UserId $user.id).UserPrincipalName
            $adminUser = [PSCustomObject]@{
                "AdminRoles" = $role
                "UserPrincipalName" = $upn
            }
            $adminUsers.Add($adminUser)
            Write-Host "Admin user found: $upn, Role: $role" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}
Write-Host "Admin users and their roles retrieved." -ForegroundColor Green
Start-Sleep -Seconds 2

if ($adminUsers.Count -gt 0) {
    $adminUsers | Export-Csv -Path "C:\scripts\AdminUsers.csv" -NoTypeInformation
} else {
    Write-Host "No admin users found."
}
Start-Sleep -Seconds 2

############################################################################
Write-Host "Getting all blocked users with license and exporting to CSV..." -ForegroundColor Yellow
New-Item -Path "C:\scripts\BlockedUsers.csv" -ItemType File -Force
$BlockedUsers = Import-Csv -Path "C:\scripts\BlockedUsers.csv"

foreach ($User in $BlockedUsers) {
    $UserLicenseDetail = Get-MgUserLicenseDetail -UserId $User.UserPrincipalName
    if ($UserLicenseDetail) {
        $User | Export-Csv -Path "C:\scripts\BlockedUsers-WithLicenses.csv" -NoTypeInformation -Append
    }
if ($BlockedUsers.Count -eq 0) {
    Write-Host "No blocked users found with licenses." -ForegroundColor Yellow
}
}
Write-Host "Blocked users analyzed and exported to CSV, lets continue." -ForegroundColor Green

############################################################################

Write-Host "Getting all temp accounts and exporting to CSV..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
############################################################################

#Getting temp accounts
Write-Host "Getting all temp accounts and exporting to CSV..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$keywords = @("temp", "tijdelijk","test")
$users = Get-MgUser | Where-Object { 
    $displayName = $_.DisplayName.ToLower()
    $keywords | Where-Object { $displayName -like "*$_*" } 
}
$usersToExport = $users | Select-Object UserPrincipalName, DisplayName
$usersToExport | Export-Csv -Path "C:\scripts\TempAccounts.csv" -NoTypeInformation -Append
Write-Host "Successfully exported temp accounts to CSV, at location C:\scripts\TempAccounts.csv" -ForegroundColor Green

############################################################################

#Getting Guest users
Write-Host "Getting all guest users and exporting to CSV..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$GuestUsers = Get-MgUser -Filter "userType eq 'Guest'"
$GuestUsersToExport = $GuestUsers | Select-Object DisplayName, UserPrincipalName
$GuestUsersToExport | Export-Csv -Path "C:\scripts\GuestUsers.csv" -NoTypeInformation -Append

Write-Host "Successfully exported guest users to CSV, at location C:\scripts\GuestUsers.csv" -ForegroundColor Green
Start-Sleep -Seconds 2

############################################################################
Write-Host "Office365 Admin Center done" -ForegroundColor Green
############################################################################
Write-Host "Connecting to entra Admin Center" -ForegroundColor Yellow
############################################################################
Write-Host "Successfully connected to entra Admin Center" -ForegroundColor Green
############################################################################
Write-Host "Getting all signins older then two months and exporting to CSV..." -ForegroundColor Yellow
#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','Mail','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)
$amountOfDays = 60
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

$SigninLogs | Export-Csv -Path "C:\scripts\SigninLogs.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\SigninLogs.csv" -ForegroundColor Green
############################################################################

Write-Host "Finding risky users"
[array]$RiskyUsers = Get-MgRiskyUser -Filter "(riskState ne 'remediated') and (riskState ne 'dismissed')" | Sort-Object RiskLastUpdatedDateTime -Descending

$Uri = "https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/c2b6c2b9-dddc-acd0-2b39-d519d803dbc3"
[datetime]$CheckDate = (Get-Date).AddDays(-183)

ForEach ($User in $RiskyUsers) {  
   If ($User.RiskLastUpdatedDateTime -le $CheckDate) {
      Write-Host ("Risky User Found!" -f $User.UserDisplayName, $User.UserPrincipalName, $User.RiskLastUpdatedDateTime)
      $DismissedUserInfo = '{"UserIds": [ "' + $User.Id + '" ]}'
      Invoke-MgGraphRequest -Uri $Uri -Body $DismissedUserInfo -Method Post
   }
}

Write-Host "Successfully exported to CSV, at location C:\scripts\RiskyUsers.csv" -ForegroundColor Green

############################################################################
Write-Host "Getting all logins from outside The Netherlands and exporting to CSV..." -ForegroundColor Yellow

$SignInLogs = Get-MgAuditLogSignIn -Top 5000

try {
    foreach ($Signin in $SigninLogs) {
        if ($Signin.Location.CountryOrRegion -ne "Netherlands") {
            $Signin | Select-Object -Property AppDisplayName, ConditionalAccessStatus, UserDisplayName, IPAddress , Location, RiskDetail      | Export-Csv -Path "C:\scripts\SigninsOutsideNL.csv" -NoTypeInformation -Append
        }
    } 
}
catch {
    Write-Host "No signins from outside The Netherlands found." -ForegroundColor Yellow
}

Write-Host "Successfully exported to CSV, at location C:\scripts\SigninsOutsideNL.csv" -ForegroundColor Green
############################################################################
#getting named locations
Write-Host "Getting all named locations and exporting to CSV..." -ForegroundColor Yellow
$NamedLocations = Get-MgIdentityConditionalAccessNamedLocation -All
$NamedLocations | Select-Object -Property  DisplayName, CreatedDateTime, ModifiedDateTime   | Export-Csv -Path "C:\scripts\NamedLocations.csv" -NoTypeInformation
Start-Sleep -Seconds 2
Write-Host "Successfully exported to CSV, at location C:\scripts\NamedLocations.csv" -ForegroundColor Green
############################################################################
Write-Host "Getting all conditional access policies and exporting to CSV..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$ConditionalAccessPolicies = Get-MgIdentityConditionalAccessPolicy
$ConditionalAccessPolicies| Select-Object -Property DisplayName, State | Export-Csv -Path "C:\scripts\ConditionalAccessPolicies.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\ConditionalAccessPolicies.csv" -ForegroundColor Green
############################################################################
Write-Host "Entra Admin Center done" -ForegroundColor Green
############################################################################
Write-Host "Connecting to Exchange Admin Center" -ForegroundColor Yellow
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Write-Host "ExchangeOnlineManagement module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
}
Start-sleep -Seconds 20
############################################################################
Write-Host "Successfully connected to Exchange Admin Center" -ForegroundColor Green
############################################################################
Write-Host "Getting all mailbox sizes, Archive status and exporting to CSV..." -ForegroundColor Yellow

try {
    Connect-ExchangeOnline
    $mailboxes = Get-EXOMailbox -ResultSize Unlimited 
    $mailboxSizes = foreach ($mailbox in $mailboxes) {
        $mailbox | Select-Object -Property DisplayName, UserPrincipalName, RecipientTypeDetails 
    }
    $mailboxSizes | Export-Csv -Path "C:\scripts\Mailboxes-Rreport.csv" -NoTypeInformation -Append
}
catch {
    Write-Host "Error getting mailbox sizes." -ForegroundColor Yellow
}
Write-Host "Successfully exported to CSV, at location C:\scripts\Mailboxes-Rreport.csvv" -ForegroundColor Green

Write-Host "Gathering archive mailbox information..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$Result = @()
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
$totalmbx = $mailboxes.Count

try {
    foreach ($mbx in $mailboxes) {
        if ($mbx.ArchiveStatus -eq "Active") {
            $mbs = Get-MailboxStatistics $mbx.UserPrincipalName -Archive
    
            if ($mbs.TotalItemSize -ne $null) {
                $size = [math]::Round(($mbs.TotalItemSize.ToString().Split('(')[1].Split(' ')[0].Replace(',', '') / 1MB), 2)
            } else {
                $size = 0
            }
        }
    
        $Result += [PSCustomObject]@{
            UserName = $mbx.DisplayName
            UserPrincipalName = $mbx.UserPrincipalName
            ArchiveStatus = $mbx.ArchiveStatus
            ArchiveName = $mbx.ArchiveName
            ArchiveState = $mbx.ArchiveState
            ArchiveMailboxSizeInMB = $size
            ArchiveWarningQuota = if ($mbx.ArchiveStatus -eq "Active") { $mbx.ArchiveWarningQuota } else { $null }
            ArchiveQuota = if ($mbx.ArchiveStatus -eq "Active") { $mbx.ArchiveQuota } else { $null }
            AutoExpandingArchiveEnabled = $mbx.AutoExpandingArchiveEnabled
        }
    }
}
catch {
    Write-Host "No archive mailboxes found." -ForegroundColor Yellow
}

$Result | Export-CSV "C:\scripts\Archive-Mailbox-Report.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Successfully exported to CSV, at location C:\scripts\Archive-Mailbox-Report.csv" -ForegroundColor Green
############################################################################
Write-Host "Exchange Admin Center done" -ForegroundColor Green
############################################################################
Write-Host "Connecting to Intune Admin Center" -ForegroundColor Yellow

if (-not (Get-Module -Name Microsoft.Graph.Intune -ListAvailable)) {
    Write-Host "Microsoft.Graph.Intune module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser
}
Start-sleep -Seconds 5
Write-Host "Microsoft.Graph.Intune module is installed, let's continue." -ForegroundColor Green
############################################################################
Write-Host "Successfully connected to Intune Admin Center" -ForegroundColor Green
############################################################################
Write-Host "Getting all non-compliant devices and exporting to CSV..." -ForegroundColor Yellow
$NonCompliantDevices = Get-IntuneManagedDevice -Filter "complianceState eq 'noncompliant'"


Stop-Transcript