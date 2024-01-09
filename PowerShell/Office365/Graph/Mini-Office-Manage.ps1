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
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential
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

#Get All users along with the properties
$AllUsers = Get-MgUser -All -Property $Properties #| Select-Object $Properties

$SigninLogs = @()
$SigninAge = (Get-Date).AddDays(-$amountOfDays)

ForEach ($User in $AllUsers)
{
    $LastSignIn = $User.SignInActivity.LastSignInDateTime
    if ($LastSignIn -gt $SigninAge)
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
$SigninLogs | Export-Csv -Path "C:\scripts\SigninLogs.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\SigninLogs.csv" -ForegroundColor Green
############################################################################

if (-not (Get-Module -Name Microsoft.Graph.Reports -ListAvailable)) {
    Write-Host "Microsoft.Graph.Reports module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph.Reports -Scope CurrentUser
}
start-sleep -Seconds 2
Write-Host "Microsoft.Graph.Reports module is installed, let's continue." -ForegroundColor Green
Write-Host "Getting all risky sign-ins and exporting to CSV..." -ForegroundColor Yellow

Import-Module Microsoft.Graph.Reports
$Signins = Get-MgAuditLogSignIn -Top 5000
$FilteredSignins = $Signins | Where-Object { $_.RiskLevelAggregated -ne "None" }
$FilteredSignins | Select-Object UserDisplayName, UserPrincipalName, RiskDetail, RiskEventTypes, RiskEventTypesV2, RiskLevelAggregated, RiskLevelDuringSignIn, RiskState
$FilteredSignins | Export-Csv -Path "C:\scripts\RiskyLoginsLogs.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\RiskyLoginsLogs.csv" -ForegroundColor Green
############################################################################
Write-Host "Getting all logins from outside The Netherlands and exporting to CSV..." -ForegroundColor Yellow
$Signins = Get-MgAuditLogSignIn -Top 5000
$FilteredSignins = $Signins | Where-Object { $_.Location.CountryOrRegion -ne "Netherlands" }
$FilteredSignins | Select-Object UserDisplayName, UserPrincipalName, Location, ClientAppUsed, AppDisplayName, DeviceDetail
$FilteredSignins | Export-Csv -Path "C:\scripts\SigninsOutsideNL.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\SigninsOutsideNL.csv" -ForegroundColor Green
############################################################################
#getting named locations
Write-Host "Getting all named locations and exporting to CSV..." -ForegroundColor Yellow
$NamedLocations = Get-MgNamedLocation
$NamedLocations | Export-Csv -Path "C:\scripts\NamedLocations.csv" -NoTypeInformation
Write-Host "Successfully exported to CSV, at location C:\scripts\NamedLocations.csv" -ForegroundColor Green
############################################################################
Write-Host "Getting all conditional access policies and exporting to CSV..." -ForegroundColor Yellow
$ConditionalAccessPolicies = Get-MgConditionalAccessPolicy
$ConditionalAccessPolicies | Export-Csv -Path "C:\scripts\ConditionalAccessPolicies.csv" -NoTypeInformation
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

Function Get_MailboxSize
{
 $Stats=Get-MailboxStatistics -Identity $UPN
 $ItemCount=$Stats.ItemCount
 $TotalItemSize=$Stats.TotalItemSize
 $TotalItemSizeinBytes= $TotalItemSize –replace “(.*\()|,| [a-z]*\)”, “”
 $TotalSize=$stats.TotalItemSize.value -replace "\(.*",""
 $DeletedItemCount=$Stats.DeletedItemCount
 $TotalDeletedItemSize=$Stats.TotalDeletedItemSize

#Export result to csv
$Result=@{'Display Name'=$DisplayName;'User Principal Name'=$upn;'Mailbox Type'=$MailboxType;'Primary SMTP Address'=$PrimarySMTPAddress;'Archive Status'=$Archivestatus;'Item Count'=$ItemCount;'Total Size'=$TotalSize;'Total Size (Bytes)'=$TotalItemSizeinBytes;'Deleted Item Count'=$DeletedItemCount;'Deleted Item Size'=$TotalDeletedItemSize;'Issue Warning Quota'=$IssueWarningQuota;'Prohibit Send Quota'=$ProhibitSendQuota;'Prohibit send Receive Quota'=$ProhibitSendReceiveQuota}
$Results= New-Object PSObject -Property $Result  
$Results | Select-Object 'Display Name','User Principal Name','Mailbox Type','Primary SMTP Address','Item Count','Total Size','Total Size (Bytes)','Archive Status','Deleted Item Count','Deleted Item Size','Issue Warning Quota','Prohibit Send Quota','Prohibit Send Receive Quota' | Export-Csv -Path $ExportCSV -Notype -Append 
}

$ExportCSV="C:\scripts\Mailbox_Report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv" 

$Result=""   
$Results=@()  
$MBCount=0
$PrintedMBCount=0
Write-Host Generating mailbox size report...

#Check for input file
if([string]$MBNamesFile -ne "") 
{ 
 #We have an input file, read it into memory 
 $Mailboxes=@()
 $Mailboxes=Import-Csv -Header "MBIdentity" $MBNamesFile
 foreach($item in $Mailboxes)
 {
  $MBDetails=Get-Mailbox -Identity $item.MBIdentity
  $UPN=$MBDetails.UserPrincipalName  
  $MailboxType=$MBDetails.RecipientTypeDetails
  $DisplayName=$MBDetails.DisplayName
  $PrimarySMTPAddress=$MBDetails.PrimarySMTPAddress
  $IssueWarningQuota=$MBDetails.IssueWarningQuota -replace "\(.*",""
  $ProhibitSendQuota=$MBDetails.ProhibitSendQuota -replace "\(.*",""
  $ProhibitSendReceiveQuota=$MBDetails.ProhibitSendReceiveQuota -replace "\(.*",""
  #Check for archive enabled mailbox
  if(($MBDetails.ArchiveDatabase -eq $null) -and ($MBDetails.ArchiveDatabaseGuid -eq $MBDetails.ArchiveGuid))
  {
   $ArchiveStatus = "Disabled"
  }
  else
  {
   $ArchiveStatus= "Active"
  }
  $MBCount++
  Write-Progress -Activity "`n     Processed mailbox count: $MBCount "`n"  Currently Processing: $DisplayName"
  Get_MailboxSize
  $PrintedMBCount++
 }
}

#Get all mailboxes from Office 365
else
{
 Get-Mailbox -ResultSize Unlimited | foreach {
  $UPN=$_.UserPrincipalName
  $Mailboxtype=$_.RecipientTypeDetails
  $DisplayName=$_.DisplayName
  $PrimarySMTPAddress=$_.PrimarySMTPAddress
  $IssueWarningQuota=$_.IssueWarningQuota -replace "\(.*",""
  $ProhibitSendQuota=$_.ProhibitSendQuota -replace "\(.*",""
  $ProhibitSendReceiveQuota=$_.ProhibitSendReceiveQuota -replace "\(.*",""
  $MBCount++
  Write-Progress -Activity "`n     Processed mailbox count: $MBCount "`n"  Currently Processing: $DisplayName"
  if($SharedMBOnly.IsPresent -and ($Mailboxtype -ne "SharedMailbox"))
  {
   return
  }
  if($UserMBOnly.IsPresent -and ($MailboxType -ne "UserMailbox"))
  {
   return
  }  
  #Check for archive enabled mailbox
  if(($_.ArchiveDatabase -eq $null) -and ($_.ArchiveDatabaseGuid -eq $_.ArchiveGuid))
  {
   $ArchiveStatus = "Disabled"
  }
  else
  {
   $ArchiveStatus= "Active"
  }
  Get_MailboxSize
  $PrintedMBCount++
 }
}

#Open output file after execution 
If($PrintedMBCount -eq 0)
{
 Write-Host No mailbox found
}
Disconnect-ExchangeOnline
Write-Host "Disconnected from Exchange Online" -ForegroundColor Green
Write-Host "Successfully exported to CSV, at location C:\scripts\MailboxSizes.csv" -ForegroundColor Green
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


