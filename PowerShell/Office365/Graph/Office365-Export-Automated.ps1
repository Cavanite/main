param (
    [string]$TenantId,
    [string]$AppId,
    [string]$CertificateThumbprint,
    [Switch]$FindUsersWithLicenseAssignmentErrors,
    [switch]$DisabledUsersOnly,
    [string]$UserName,
    [switch] $RoleBasedAdminReport, 
    [switch] $ExcludeGroups,
    [String] $AdminName = $null, 
    [String] $RoleName = $null,
    [switch]$CreateSession
)
#######################################################################################################
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

#######################################################################################################
Start-Transcript "$scriptpath\Office365-Export.log" -Append
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
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
}
#######################################################################################################
#######################################################################################################
$ErrorActionPreference = "Stop"
# Check for Module Availability
function Check-ModuleAvailability {
    param (
        [string]$ModuleName,
        [string]$ModuleDisplayName
    )
    $module = Get-Module $ModuleName -ListAvailable
    if ($module -eq $null) {
        Write-Host "Important: $ModuleDisplayName module is unavailable. It is mandatory to have this module installed in the system to run the script successfully."
        $confirm = Read-Host "Are you sure you want to install $ModuleDisplayName module? [Y] Yes [N] No"
        if ($confirm -match "[yY]") {
            Write-Host "Installing $ModuleDisplayName module..."
            Install-Module $ModuleName -Scope CurrentUser -AllowClobber
            Write-Host "$ModuleDisplayName module is installed in the machine successfully" -ForegroundColor Magenta
        }
        else {
            Write-Host "Exiting. `nNote: $ModuleDisplayName module must be available in your system to run the script" -ForegroundColor Red
            Exit
        }
    }
}
#######################################################################################################
function Process-ExternalUsers {
    param(
        [System.Object]$ExternalTenantUser,
        [hashtable]$UsersinTenant,
        [System.Array]$B2BGuest,
        [System.Array]$B2BMember,
        [System.Array]$LocalGuest,
        [System.Array]$B2BDirectConnect
    )
    $processedUsers = @()
    if ($ExternalTenantUser) {
        $Members = $ExternalTenantUser.ExternalTenants.AdditionalProperties.members
        if ($Members) {
            foreach ($Member in $Members) {
                if ($UsersinTenant.ContainsKey($Member)) {
                    $processedUsers += $ExternalTenantUser.GuestOrExternalUserTypes -split ',' | ForEach-Object {
                        switch -Wildcard ($_) {
                            'b2bCollaborationGuest' {
                                $B2BGuest | Where-Object { $_ -in $UsersinTenant[$Member] }
                            }
                            'b2bCollaborationMember' {
                                $B2BMember | Where-Object { $_ -in $UsersinTenant[$Member] }
                            }
                            'internalGuest' {
                                $LocalGuest
                            }
                            'b2bDirectConnectUser' {
                                $B2BDirectConnect | Select-Object -Unique | Where-Object { $_.Id -in $UsersinTenant[$Member] }
                            }
                        }
                    }
                }
            }
        }
        else {
            $processedUsers += $ExternalTenantUser.GuestOrExternalUserTypes -split ',' | ForEach-Object {
                switch -Wildcard ($_) {
                    'b2bCollaborationGuest' {
                        $B2BGuest
                    }
                    'b2bCollaborationMember' {
                        $B2BMember
                    }
                    'internalGuest' {
                        $LocalGuest
                    }
                    'b2bDirectConnectUser' {
                        $B2BDirectConnect | Select-Object -Unique
                    }
                }
            }
        }
    }
    return $processedUsers
}
#######################################################################################################
# Function to get the members of the roles
function Get-UserIdsByRole {
    param (
        [array]$Roles,
        [array]$DirectoryRole
    )

    $UserIds = @()

    foreach ($Role in $Roles) {
        $DirRole = $DirectoryRole | Where-Object { $_.RoleTemplateId -eq $Role }
        if ($DirRole) {
            $RoleMembers = Get        'MFA Enforced Via' = "No user(s) found: $Output"eId $DirRole.Id
            if ($RoleMembers) {
                $UserIds += $RoleMembers.Id
            }
        }
    }
    return $UserIds
}
#######################################################################################################
# Check for Module Availability
Check-ModuleAvailability -ModuleName "MsOnline" -ModuleDisplayName "MsOnline"
Check-ModuleAvailability -ModuleName "Microsoft.Graph.Beta" -ModuleDisplayName "Microsoft Graph Beta"
Check-ModuleAvailability -ModuleName "ImportExcel" -ModuleDisplayName "ImportExcel"
#######################################################################################################
# Disconnect from the Microsoft Graph If already connected
if (Get-MgContext) {
    Write-Host "Disconnecting from the previous sesssion...." -ForegroundColor Yellow
    Disconnect-MgGraph | Out-Null
}
#######################################################################################################
# Credentials check and Certificate check
if (($UserName -ne "") -and ($Password -ne "")) {
    $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
    $Credential = New-Object System.Management.Automation.PSCredential $UserName, $SecuredPassword
    $CredentialPassed = $true
}

if ((($AppId -ne "") -and ($CertificateThumbPrint -ne "")) -and ($TenantId -ne "")) {
    $CBA = $true
}
#######################################################################################################
# Version check
# Connecting to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..."
try {
    if ($CBA -eq $true) {
        Connect-MgGraph -ApplicationId $AppId -TenantId $TenantId -CertificateThumbPrint $CertificateThumbprint
        Write-Host "Connected to Microsoft Graph PowerShell using (Get-MgContext).AppName application" -ForegroundColor Yellow
    }
    else {
        Connect-MgGraph -Scopes 'User.Read.All', 'Policy.Read.all', 'Policy.ReadWrite.SecurityDefaults', 'Team.ReadBasic.All', 'Directory.Read.All', 'AuditLog.read.All' -NoWelcome
        Write-Host "Connected to Microsoft Graph PowerShell using (Get-MgContext).Account account" -ForegroundColor Yellow
    }
}
catch [Exception] {
    Write-Host "Error: An error occurred while connecting to Microsoft Graph: $($_.Exception.Message)" -ForegroundColor Red
    Exit
}
#######################################################################################################
# Connecting to Msonline
Write-Host "Connecting to MSOnline......"
try {
    if ($CredentialPassed -eq $true) {
        Connect-MsolService -Credential $Credential
    }
    elseif ($CBA -eq $true) {
        Write-Host "MSonline module doesn't support certificate based authentication. Please enter the credential in the prompt"
        Connect-MsolService
    }
    else {
        Connect-MsolService
    }
    Write-Host "Connected to MSOnline" -ForegroundColor Yellow
}
catch {
    Write-Host "Error: An error occurred while connecting to MsOnline: $($_.Exception.Message)" -ForegroundColor Red
    Exit
}
#######################################################################################################
# Get Users From Msonline
$Users = Get-MsolUser -All | Select-Object ObjectId, StrongAuthenticationRequirements
$MgBetaUsers = Get-MgBetaUser -All | Sort-Object DisplayName
# Check Security Default is enabled or not
$SecurityDefault = (Get-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy).IsEnabled
$DirectoryRole = Get-MgBetaDirectoryRole -All
#######################################################################################################
# Get the User Registration Details
$UserAuthenticationDetail = Get-MgBetaReportAuthenticationMethodUserRegistrationDetail -All | Select-Object UserPrincipalName, MethodsRegistered, IsMFARegistered, Id
$ProcessedUserCount = 0
#######################################################################################################
# Check for Security default if disabled start to process the Conditional access policies
$PolicySetting = 'True'
$TotalUser = $Users.count
if ($SecurityDefault) {
    $PolicySetting = 'False'
}
else {
    # Initialize the array
    $IncludeId = @()
    $ExcludeId = @()
    $IncludeUsers = @()
    $ExcludeUsers = @()
    $Registered = @()
    $NotRegistered = @()
    $UsersInPolicy = @{}

    # Get conditional access policies that involve MFA and enabled
    $Policies = Get-MgBetaIdentityConditionalAccessPolicy -All | Where-Object { ($_.GrantControls.BuiltInControls -contains 'mfa' -or $_.GrantControls.AuthenticationStrength.RequirementsSatisfied -contains 'mfa') -and $_.State -contains 'enabled' }
    $Policy = $Policies | Where-Object { $_.displayname -eq 'Authentication' }
    $ProcessedPolicyCount = 0
#######################################################################################################
    # Get the External users if it was specified in the policy
    if ($Policies.Conditions.Users.IncludeGuestsOrExternalUsers -ne $null -or $Policies.Conditions.Users.ExcludeGuestsOrExternalUsers -ne $null) {
        Write-Host "Getting Information about External Users"
        $ExternalUsers = $MgBetaUsers | where-object { $_.ExternalUserState -ne $null }
        $UsersinTenant = @{}
        foreach ($GuestUser in $ExternalUsers) {
            try {
                if ($GuestUser.othermails -ne $null) {
                    $Parts = $GuestUser.othermails -split "@"
                    $DomainName = $Parts[1]
                    $Url = "https://login.microsoftonline.com/$DomainName/.well-known/openid-configuration"
                    $Response = Invoke-RestMethod -Uri $Url -Method Get
                    $Issuer = $Response.issuer
                    $TenantId = [regex]::Match($Issuer, "[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}").Value
                    if (-not $UsersinTenant.ContainsKey($TenantId)) {
                        $UsersinTenant[$TenantId] = @($GuestUser.Id)
                    }
                    else {
                        $UsersinTenant[$TenantId] += $GuestUser.Id
                    }
                }
            }
            catch {
                Write-Host "External Domain Name $DomainName is Invalid" -ForegroundColor Red
                continue;
            }
        }
        $B2BGuest = $ExternalUsers | where-object { $_.UserType -eq 'Guest' }
        $B2BMember = $ExternalUsers | where-object { $_.UserType -ne 'Member' }
        $LocalGuest = $MgBetaUsers | where-object { $_.ExternalUserState -eq $null -and $_.UserType -eq 'Guest' }
#######################################################################################################
        # B2B Direct connect
        $Groups = Get-MgBetaTeam -All
        $B2BDirectConnect = @()
        ForEach ($ExternalUser in $ExternalUsers) {
            $MemberOfs = Get-MgBetaUserMemberof -UserId $ExternalUser.Id | Where-Object { $_.Id -ne $null }
            ForEach ($MemberOf in $MemberOfs) {
                if ($Groups.Id -contains $MemberOf.Id) {
                    $B2BDirectConnect += $ExternalUser.Id
                }
            }
        }
    }
#######################################################################################################
    # Hash table of the Required Authentication Strength with respect to the Registered method
    $AllowedCombinations = @{
        "mobilephone"                         = @("sms", "Password,sms")
        "alternateMobilePhone"                = @("sms", "Password,sms")
        "officePhone"                         = @("sms", "Password,sms")
        "microsoftAuthenticatorPush"          = @("microsoftAuthenticatorPush", "Password,microsoftAuthenticatorPush")
        "softwareOneTimePasscode"             = @("Password,SoftwareOath")
        "MicrosoftAuthenticatorPzasswordless" = @("MicrosoftAuthenticator(PhoneSignIn)")
        "windowsHelloForBusiness"             = @("windowsHelloForBusiness")
        "hardwareOneTimePasscode"             = @("password,hardwareOath")
        "passKeyDeviceBound"                  = @("fido2")
        "passKeyDeviceBoundAuthenticator"     = @("fido2")
        "passKeyDeviceBoundWindowsHello"      = @("fido2")
        "fido2SecurityKey"                    = @("fido2")
        "temporaryAccessPass"                 = @("TemporaryAccessPassOneTime", "TemporaryAccessPassMultiuse")
    }
#######################################################################################################
    Write-Host "Processing the policies..."
    foreach ($Policy in $Policies) {
        $ProcessedPolicyCount++
        Write-Progress -Activity "`n    Processed Policy count: $ProcessedPolicyCount `n" -Status "Currently processing Policy: $($Policy.DisplayName)"
#######################################################################################################
        ### Conditions ###
        $IncludeUsers = $null
        $ExcludeUsers = $null
        $Check = $true
        $CurrentPolicy = $false
        $IncludedExternalUser = $Policy.Conditions.Users.IncludeGuestsOrExternalUsers
        $ExcludedExternalUser = $Policy.Conditions.Users.ExcludeGuestsOrExternalUsers

        $IncludeUsers = if ($Policy.Conditions.Users.IncludeUsers -ne 'All') {
            $Policy.Conditions.Users.IncludeUsers
        }
        elseif ($Policy.Conditions.Users.IncludeUsers -eq 'All') {
            $MgBetaUsers.Id
            $Check = $false
        }
    }
    if ($Check) {
        $IncludeUsers += if ($Policy.Conditions.Users.IncludeGroups) { $Policy.Conditions.Users.IncludeGroups | ForEach-Object {ect { Members = rs =MgBetaGroupMember -GroupId $_ $Members.Id } if ($Owner = Get-MgBetaGroupOwner -GroupId $_) { $Owner.Id } } }
        $IncludeUsers += Get-UserIdsByRole -Roles $Policy.Conditions.Users.IncludeRoles -DirectoryRole $DirectoryRole
        $IncludeUsers += Process-ExternalUsers -ExternalTenantUser $IncludedExternalUser -UsersinTenant $UsersinTenant -B2BGuest $B2BGuest.Id -B2BMember $B2BMember.Id -LocalGuest $LocalGuest.Id -B2BDirectConnect $B2BDirectConnect
    }
    $ExcludeUsers = if ($Policy.Conditions.Users.ExcludeUsers) { $Policy.Conditions.Users.ExcludeUsers }
    $ExcludeUsers += if ($Policy.Conditions.Users.ExcludeGroups) { $Policy.Conditions.Users.ExcludeGroups | ForEach-Object { if ($Members = Get-MgBetaGroupMember -GroupId $_) { $Members.Id } if ($Owner = Get-MgBetaGroupOwner -GroupId $_) { $Owner.Id } } }
    $ExcludeUsers += Get-UserIdsByRole -Roles $Policy.Conditions.Users.ExcludeRoles -DirectoryRole $DirectoryRole
    $ExcludeUsers += Process-ExternalUsers -ExternalTenantUser $ExcludedExternalUser -UsersinTenant $UsersinTenant -B2BGuest $B2BGuest.Id -B2BMember $B2BMember.Id -LocalGuest $LocalGuest.Id -B2BDirectConnect $B2BDirectConnect
    $ExcludeId += $ExcludeUsers
    $IncludeId += $IncludeUsers | Where-Object { $_ -notin $ExcludeUsers }
    $UsersInPolicy[$Policy.DisplayName] += $IncludeUsers | Where-Object { $_ -notin $ExcludeUsers }
#######################################################################################################
    if ($Policy.GrantControls.AuthenticationStrength.RequirementsSatisfied -contains 'mfa') {
        $NotRegistered += $IncludeUsers | Where-Object { $_ -notin $ExcludeUsers }
        $CurrentPolicy = $true
        $Strength = $Policy.GrantControls.AuthenticationStrength.AllowedCombinations
        foreach ($IncludeUser in $IncludeUsers) {
            $UserAuthDetails = $UserAuthenticationDetail | Where-Object { $_.Id -eq $IncludeUser }
            $MethodsRegistered = if ($UserAuthDetails.MethodsRegistered -ne $null) { $UserAuthDetails.MethodsRegistered -split ',' } else { 'None' }

            foreach ($Method in $MethodsRegistered) {
                if ($AllowedCombinations.ContainsKey($Method)) {
                    foreach ($MFA in $AllowedCombinations[$Method]) {
                        if ($Strength -contains $MFA) {
                            # Check if the user is included in any other policies with MFA strength
                            $Registered += $IncludeUser -join ','
                        }
                    }
                }
            }
        }
    }
    $Registered = $Registered | Select-Object -Unique
    if (!$CurrentPolicy) {
        $NotRegistered = $NotRegistered.GUID | Where-Object { $_ -notin $IncludeUsers.GUID }
    }
}
$ProcessedUserCount = 0
$FilePath = "C:\scripts\O365-Export-$((Get-Date -format 'dd-MM-yyyy').ToString()).xlsx"
#######################################################################################################
# Now starts the Process of Checking various conditions for the users and Export to the .csv file in the D local storage
foreach ($User in $MgBetaUsers) {
    $name = @()
    $ProcessedUserCount++
    $percent = ($ProcessedUserCount / $TotalUser) * 100
    Write-Progress -Activity "`n    Processed user count: $ProcessedUserCount `n" -Status "Currently processing User: $($User.DisplayName)" -PercentComplete $percent
    $Peruser = $Users | Where-Object { $_.ObjectID -contains $User.Id }

    # Get user authentication details
    $UserAuthDetails = $UserAuthenticationDetail | Where-Object { $_.UserPrincipalName -eq $User.UserPrincipalName }
    $MethodsRegistered = if ($UserAuthDetails.MethodsRegistered -ne "") { $UserAuthDetails.MethodsRegistered -join ',' } else { 'None' }
    $Name += foreach ($Pol in $Policies.DisplayName) { if ($UsersInPolicy[$pol] -contains $user.Id) { $Pol } }
    $PolicyName = $Name -join ','
}
    $MFAEnforce = @{
        'User Display Name' = $User.DisplayName
        'User Principal Name' = $User.UserPrincipalName
'Enforced Via' = if ($PerUser.StrongAuthenticationRequirements.State -eq 'Enforced' -and $PolicySetting -eq 'True' -and $IncludedUsers -contains $User.Id) { 'Per User MFA , Conditional Access Policy' }
        elseif ($PerUser.StrongAuthenticationRequirements.State -eq 'Enforced' -and $SecurityDefault -eq $true) { 'Per User MFA , Security Default' }
        elseif ($PerUser.StrongAuthenticationRequirements.State -eq 'Enforced') { 'Per User MFA' }
        elseif ($SecurityDefault -eq $true) { 'Security Default' }
        elseif ($PolicySetting -eq 'True' -and $IncludedUsers -contains $User.Id) { 'Conditional Access Policy' }
        elseif ($Peruser.BlockCredential -eq $true) { 'SignIn Blocked' }
        else { 'Disabled' }
        'Is Registered MFA Supported in CA' = if ($IncludedUsers -contains $User.Id) { if ($UserAuthDetails.IsMFARegistered -contains 'True') { if ($PolicySetting -eq 'True' -and $NotRegistered -notcontains $User.Id) { $true } elseif ($Registered -contains $User.Id) { $true } else { 'False' } } else { 'False' } } else {
        }
    }
#######################################################################################################
    #Open output file after execution
    if ((Test-Path -Path $FilePath) -eq "True") {
        Write-Host "Exported report has $ProcessedUserCount user(s)" -ForegroundColor cyan
        $Prompt = New-Object -ComObject wscript.shell
        $UserInput = $Prompt.popup("Do you want to open output file?", 0, "Open Output File", 4)
        if ($UserInput -eq 6) {
            Invoke-Item "$FilePath"
        }
        Write-Host "Detailed report available in: " -NoNewline -ForegroundColor Yellow
        Write-Host $FilePath 
    }
        else {
$Registered = $Registered | Select-Object -Unique 
if (!$CurrentPolicy) {
    $NotRegistered = $NotRegistered.GUID | Where-Object { $_ -notin $IncludeUsers.GUID }
} 
$IncludedUsers = $IncludeId | Select-Object -Unique
}
$ProcessedUserCount = 0
Write-Host "Processing the Users"
$FilePath = "C:\scripts\O365-Export-$((Get-Date -format 'dd-MM-yyyy').ToString()).xlsx"
#######################################################################################################
# Now starts the Process of Checking various conditions for the users and Export to the .csv file in the script folder.
foreach ($User in $MgBetaUsers) 
{
    $name  = @()
    $ProcessedUserCount++
    $percent = ($ProcessedUserCount/$TotalUser)*100
    Write-Progress -Activity "`n    Processed user count: $ProcessedUserCount `n" -Status "Currently processing User: $($User.DisplayName)" -PercentComplete $percent
    $Peruser = $Users | Where-Object {$_.ObjectID -contains $User.Id} 
    # Get user authentication details
    $UserAuthDetails   = $UserAuthenticationDetail | Where-Object { $_.UserPrincipalName -eq $User.UserPrincipalName }
    $MethodsRegistered = if ($UserAuthDetails.MethodsRegistered -ne "") { $UserAuthDetails.MethodsRegistered -join ',' } else { 'None' }
    $Name   += foreach($Pol in $Policies.DisplayName){if($UsersInPolicy[$pol] -contains $user.Id){$Pol}}
    $PolicyName = $Name -join','
    $MFAEnforce = @{
        'User Display Name'         = $User.DisplayName
        'User Principal Name'       = $User.UserPrincipalName
        'MFA Enforced Via'          =  if($PerUser.StrongAuthenticationRequirements.State -eq 'Enforced' -and $PolicySetting -eq 'True' -and $IncludedUsers -contains $User.Id){'Per User MFA , Conditional Access Policy'} 
        elseif ( $PerUser.StrongAuthenticationRequirements.State -eq 'Enforced' -and $SecurityDefault -eq $true) { 'Per User MFA , Security Default' }
        elseif ($PerUser.StrongAuthenticationRequirements.State -eq 'Enforced') { 'Per User MFA' } 
        elseif ($SecurityDefault -eq $true) { 'Security Default' } 
        elseif ($PolicySetting -eq 'True' -and $IncludedUsers -contains $User.Id){'Conditional Access Policy'}
        elseif ($Peruser.BlockCredential -eq $true) {'SignIn Blocked'}
        else {'Disabled'}
        'Is Registered MFA Supported in CA' = if($IncludedUsers -contains $User.Id){
            if($UserAuthDetails.IsMFARegistered -contains 'True'){
                if($PolicySetting -eq 'True' -and  $NotRegistered -notcontains $User.Id) {$true}
                elseif($Registered -contains $User.Id){$true}
                else{'False'}
            }
            else{'False'}
        }
        else{''}
        'CA MFA Status'              = if($IncludedUsers -contains $User.Id){'Enabled'}else{'Disabled'}
        'Assigned CA Policy'         = if($IncludedUsers -contains $User.Id){$PolicyName}else{''}
        'Per User MFA Status'        =  if ($PerUser.StrongAuthenticationRequirements.State) { $PerUser.StrongAuthenticationRequirements.State } else { 'Disabled' }
        'Security Default Status'    = if ($SecurityDefault -eq $false){'Disabled'} else{'Enabled'}
        'MFA Registered'             = $UserAuthDetails.IsMFARegistered -contains 'True'
        'Methods Registered'         = if($MethodsRegistered){$MethodsRegistered}else{'None'} 
    }
    $MFAEnforced = New-Object PSObject -Property $MFAEnforce
    try
    {
        $MFAEnforced | Select-Object 'User Display Name','User Principal Name','MFA Registered','Methods Registered','MFA Enforced Via','Per User MFA Status','Security Default Status','CA MFA Status','Assigned CA Policy','Is Registered MFA Supported in CA' | Export-Excel -Path $FilePath -Append -WorksheetName "MFA Report"
    }
    catch
    {       
        Write-Host "Error occurred While Exporting: $_" -ForegroundColor Red
    }
}
Write-Host "MFA Report Script executed successfully" -ForegroundColor Green
#######################################################################################################
#######################################################################################################

Write-Host "Now we are gathering the admin roles in the tenant."

Write-Host "Microsoft Graph Beta Powershell module is connected successfully" -ForegroundColor Green
Write-Host "`nNote: If you encounter module related conflicts, run the script in a fresh Powershell window." -ForegroundColor Yellow
Write-Host "`nPreparing admin report..." 
$Admins=@() 
$RoleList = @() 
function Process_AdminReport
{ 
    $AdminMemberOf=Get-MgBetaUserTransitiveMemberOf -UserId $Admins.Id |Select-Object -ExpandProperty AdditionalProperties
    $AssignedRoles=$AdminMemberOf|?{$_.'@odata.type' -eq '#microsoft.graph.directoryRole'} 
    $DisplayName=$Admins.DisplayName
    if($Admins.AssignedLicenses -ne $null)
    { 
        $LicenseStatus = "Licensed" 
    }
    else
    { 
        $LicenseStatus= "Unlicensed" 
    } 
    if($Admins.AccountEnabled -eq $true)
    { 
        $SignInStatus = "Allowed" 
    }
    else
    { 
        $SignInStatus = "Blocked" 
    } 
    Write-Progress -Activity "Currently processing: $DisplayName" -Status "Updating CSV file"
    if($AssignedRoles -ne $null) 
    { 
        $ExportResult=@{'Admin EmailAddress'=$Admins.mail;'Admin Name'=$DisplayName;'Assigned Roles'=(@($AssignedRoles.displayName)-join ',');'License Status'=$LicenseStatus;'SignIn Status'=$SignInStatus } 
        $ExportResults= New-Object PSObject -Property $ExportResult         
        $ExportResults | Select-Object 'Admin Name','Admin EmailAddress','Assigned Roles','License Status','SignIn Status' | Export-Excel -path $FilePath -Append -WorksheetName "AdminReport"
    } 
} 
#######################################################################################################
function Process_RoleBasedAdminReport
{ 
    $AdminList = Get-MgBetaDirectoryRoleMember -DirectoryRoleId $AdminRoles.Id |Select-Object -ExpandProperty AdditionalProperties
    $RoleName=$AdminRoles.DisplayName
    if($ExcludeGroups.IsPresent)
    {
        $AdminList=$AdminList| Where-Object {$_.'@odata.type' -eq '#microsoft.graph.user'}
        $DisplayName=$AdminList.displayName 
    }
    else
    {
        $DisplayName=$AdminList.displayName
    }
    if($DisplayName -ne $null)
    { 
        Write-Progress -Activity "Currently Processing $RoleName role" -Status "Updating CSV file"
        $ExportResult=@{'Role Name'=$RoleName;'Admin EmailAddress'=(@($AdminList.mail)-join ',');'Admin Name'=(@($DisplayName)-join ',');'Admin Count'=$DisplayName.Count} 
        $ExportResults= New-Object PSObject -Property $ExportResult 
        $ExportResults | Select-Object 'Role Name','Admin Name','Admin EmailAddress','Admin Count' | Export-Excel -path $FilePath -Append -WorksheetName "RoleBasedAdminReport"
    }
}
#######################################################################################################
#Check to generate role based admin report
if($RoleBasedAdminReport.IsPresent)
{ 
    Get-MgBetaDirectoryRole -All| ForEach-Object { 
    $AdminRoles= $_ 
    Process_RoleBasedAdminReport 
    } 
}
#######################################################################################################
#Check to get admin roles for specific user
elseif($AdminName -ne "")
{ 
    $AllUPNs = $AdminName.Split(",")
    ForEach($Admin in $AllUPNs) 
    { 
        $Admins=Get-MgBetaUser -UserId $Admin -ErrorAction SilentlyContinue 
        if($Admins -eq $null)
        { 
            Write-host "$Admin is not available. Please check the input" -ForegroundColor Red 
        }
        else
        { 
            Process_AdminReport 
        } 
    }
}
#######################################################################################################
#Check to get all admins for a specific role
elseif($RoleName -ne "")
{ 
    $RoleNames = $RoleName.Split(",")
    ForEach($Name in $RoleNames) 
    { 
        $AdminRoles= Get-MgBetaDirectoryRole -Filter "DisplayName eq '$Name'" -ErrorAction SilentlyContinue 
        if($AdminRoles -eq $null)
        { 
            Write-Host "$Name role is not available. Please check the input" -ForegroundColor Red 
        }
        else
        { 
            Process_RoleBasedAdminReport 
        } 
    } 
}
#######################################################################################################
#Generating all admins report
else
{ 
    Get-MgBetaUser -All | ForEach-Object { 
    $Admins= $_ 
    Process_AdminReport 
    } 
} 
#######################################################################################################
Write-Host "Admin report script executed successfully" -ForegroundColor Green
#######################################################################################################

Write-Host "Now we are gathering the last sign-in information for the users older then 60 days."

#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','Mail','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)
$amountOfDays = 60
#Get All users along with the properties
$AllUsers = Get-MgBetaUser -All -Property $Properties #| Select-Object $Properties

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

Write-Host "Exporting the last sign-in information to CSV file" -ForegroundColor Green
try {
    Write-Host "Exporting the last sign-in information to CSV file" -ForegroundColor Green
    $SigninLogs | Export-Excel -Path $FilePath -Append -WorksheetName "LastSignInReport"
    Write-Host "Last Sign-in report script executed successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error occurred while exporting the last sign-in information to CSV file" -ForegroundColor Red
    write-host "Error: $_" -ForegroundColor Red
}
#######################################################################################################
Write-Host "Exporting users with license." -ForegroundColor Green

#######################################################################################################

# Function to convert friendly name
Function Convert-FrndlyName {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$InputIds
    )
    $EasyName = $FriendlyNameHash[$SkuName]
    if (!($EasyName)) {
        $NamePrint = $SkuName
    }
    else {
        $NamePrint = $EasyName
    }
    return $NamePrint
}

# Initialize variables
$ExportResult = ""
$ExportResults = @()
$PrintedUser = 0

# Get license in the organization and save it as a hash table
$SKUHashtable = @{ }
Get-MgBetaSubscribedSku -All | ForEach-Object {
    $SKUHashtable[$_.skuid] = $_.Skupartnumber
}
# Get friendly name of Subscription plan from external file
$FriendlyNameHash = Get-Content -Raw -Path C:\scripts\LicenseFriendlyName.txt -ErrorAction Stop | ConvertFrom-StringData
# Get friendly name of Service plan from external file
$ServicePlanHash = @{ }
Import-Csv -Path C:\scripts\ServicePlansFrndlyName.csv | ForEach-Object {
    $ServicePlanHash[$_.ServicePlanId] = $_.ServicePlanFriendlyNames
}
$GroupNameHash = @{ }
# Process users
$RequiredProperties = @('UserPrincipalName','DisplayName','EmployeeId','CreatedDateTime','AccountEnabled','Department','JobTitle','LicenseAssignmentStates','AssignedLicenses','SigninActivity')
Get-MgBetaUser -All -Property $RequiredProperties | Select-Object $RequiredProperties | ForEach-Object {
    $Count++
    $Print = 1
    $DirectlyAssignedLicense = @()
    $GroupBasedLicense = @()
    $DirectlyAssignedLicense_FrndlyName = @()
    $GroupBasedLicense_FrndlyName = @()
    $UPN = $_.UserPrincipalName

    Write-Progress -Activity "`n     Processing user: $Count - $UPN"

    $DisplayName = $_.DisplayName
    $AccountEnabled = $_.AccountEnabled
    $Department = $_.Department
    $JobTitle = $_.JobTitle
    $LastSignIn = $_.SignInActivity.LastSignInDateTime

    if ($LastSignIn -eq $null) {
        $LastSignIn = "Never Logged In"
        $InactiveDays = "-"
    }
    else {
        $InactiveDays = (New-TimeSpan -Start $LastSignIn).Days
    }

    $LicenseAssignmentStates = $_.LicenseAssignmentStates

    if ($AccountEnabled -eq $true) {
        $AccountStatus = 'Enabled'
    }
    else {
        $AccountStatus = 'Disabled'
    }
    foreach ($License in $licenseAssignmentStates) { 
        $SkuName = $SkuHashtable[$License.SkuId]
        $FriendlyName = Convert-FrndlyName -InputIds $SkuName
        $DisabledPlans = $License.DisabledPlans
        $ServicePlanNames = @()
        if ($DisabledPlans.count -ne 0) {
            foreach ($DisabledPlan in $DisabledPlans) {
                $ServicePlanName = $ServicePlanHash[$DisabledPlan]
                if (!($ServicePlanName)) {
                    $NamePrint = $DisabledPlan
                }
                else {
                    $NamePrint = $ServicePlanName
                }
                $ServicePlanNames += $NamePrint
            }
        }
        $DisabledPlans = $ServicePlanNames -join ","
        $State = $License.State
        $Error = $License.Error
        # Filter for users with license assignment errors
        if ($FindUsersWithLicenseAssignmentErrors.IsPresent -and ($State -eq "Active")) {
            $Print = 0
        }
        if ($License.AssignedByGroup -eq $null) {
            $LicenseAssignmentPath = "Directly assigned"
            $GroupName = "NA"
            # Filter for group based license assignment
            if ($ShowGrpBasedLicenses.IsPresent) {
                $Print = 0
            }
        }
        else {
            $LicenseAssignmentPath = "Inherited from group"

            # Filter for directly assigned licenses
            if ($ShowDirectlyAssignedLicenses.IsPresent) {
                $Print = 0
            }
            $AssignedByGroup = $License.AssignedByGroup
            # Check if Id-Name pair already exists in hash table
            if ($GroupNameHash.ContainsKey($AssignedByGroup)) {
                $GroupName = $GroupNameHash[$AssignedByGroup]
            }
            else {
                $GroupName = (Get-MgBetagroup -GroupId $AssignedByGroup).DisplayName
                $GroupNameHash[$AssignedByGroup] = $GroupName
            }
        }
        if ($Print -eq 1) {
            $ExportResult = [PSCustomObject]@{
                'Display Name' = $DisplayName
                'UPN' = $UPN
                'License Assignment Path' = $LicenseAssignmentPath
                'Sku Name' = $SkuName
                'Sku_FriendlyName' = $FriendlyName
                'Disabled Plans' = $DisabledPlans
                'Assigned via(group name)' = $GroupName
                'State' = $State
                'Error' = $Error
                'Last Signin Time' = $LastSignIn
                'Inactive Days' = $InactiveDays
                'Account Status' = $AccountStatus
                'Department' = $Department
                'Job Title' = $JobTitle
            }

            $ExportResult | Export-Excel -Path $FilePath -Append -WorksheetName "License-Report"
        }
    }
}
# Open output file after execution
Write-Host "Script executed successfully"
########################################################################################################

Write-Host "Now we are gathering the mailbox size information for the users."
Write-Host "First connecting to Exchange Online..."
# Connect to Exchange Online
#First check if the module is installed
if (-not(Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}
else {
    Write-Host "Exchange Online Management module is already installed" -ForegroundColor Yellow
    Connect-ExchangeOnline
}

Function Get_MailboxSize
{
    $Stats = Get-MailboxStatistics -Identity $UPN
    $ItemCount = $Stats.ItemCount
    $TotalItemSize = $Stats.TotalItemSize
    $TotalItemSizeinBytes = $TotalItemSize -replace "(.*\()|,| [a-z]*\)", ""
    $TotalSize = $stats.TotalItemSize.value -replace "\(.*",""
    $DeletedItemCount = $Stats.DeletedItemCount
    $TotalDeletedItemSize = $Stats.TotalDeletedItemSize

    # Export result to csv
    $Result = @{
        'Display Name' = $DisplayName;
        'User Principal Name' = $upn;
        'Mailbox Type' = $MailboxType;
        'Primary SMTP Address' = $PrimarySMTPAddress;
        'Archive Status' = $Archivestatus;
        'Item Count' = $ItemCount;
        'Total Size' = $TotalSize;
        'Total Size (Bytes)' = $TotalItemSizeinBytes;
        'Deleted Item Count' = $DeletedItemCount;
        'Deleted Item Size' = $TotalDeletedItemSize;
        'Issue Warning Quota' = $IssueWarningQuota;
        'Prohibit Send Quota' = $ProhibitSendQuota;
        'Prohibit Send Receive Quota' = $ProhibitSendReceiveQuota
    }
    $Results = New-Object PSObject -Property $Result  
    $Results | Select-Object 'Display Name','User Principal Name','Mailbox Type','Primary SMTP Address','Item Count','Total Size','Total Size (Bytes)','Archive Status','Deleted Item Count','Deleted Item Size','Issue Warning Quota','Prohibit Send Quota','Prohibit Send Receive Quota' | Export-Excel -Path $FilePath -Append -WorksheetName "Mailbox Size Report"
}

$Result = ""   
$Results = @()  
$MBCount = 0
$PrintedMBCount = 0
Write-Host "Generating mailbox size report..."

# Check for input file
if ([string]$MBNamesFile -ne "") 
{ 
    # We have an input file, read it into memory 
    $Mailboxes = @()
    $Mailboxes = Import-Csv -Header "MBIdentity" $MBNamesFile
    foreach ($item in $Mailboxes)
    {
        $MBDetails = Get-Mailbox -Identity $item.MBIdentity
        $UPN = $MBDetails.UserPrincipalName  
        $MailboxType = $MBDetails.RecipientTypeDetails
        $DisplayName = $MBDetails.DisplayName
        $PrimarySMTPAddress = $MBDetails.PrimarySMTPAddress
        $IssueWarningQuota = $MBDetails.IssueWarningQuota -replace "\(.*",""
        $ProhibitSendQuota = $MBDetails.ProhibitSendQuota -replace "\(.*",""
        $ProhibitSendReceiveQuota = $MBDetails.ProhibitSendReceiveQuota -replace "\(.*",""
        # Check for archive enabled mailbox
        if (($MBDetails.ArchiveDatabase -eq $null) -and ($MBDetails.ArchiveDatabaseGuid -eq $MBDetails.ArchiveGuid))
        {
            $ArchiveStatus = "Disabled"
        }
        else
        {
            $ArchiveStatus = "Active"
        }
        $MBCount++
        Write-Progress -Activity "`n     Processed mailbox count: $MBCount "`n"  Currently Processing: $DisplayName"
        Get_MailboxSize
        $PrintedMBCount++
    }
}
# Get all mailboxes from Office 365
else
{
    Get-Mailbox -ResultSize Unlimited | ForEach-Object {
        $UPN = $_.UserPrincipalName
        $Mailboxtype = $_.RecipientTypeDetails
        $DisplayName = $_.DisplayName
        $PrimarySMTPAddress = $_.PrimarySMTPAddress
        $IssueWarningQuota = $_.IssueWarningQuota -replace "\(.*",""
        $ProhibitSendQuota = $_.ProhibitSendQuota -replace "\(.*",""
        $ProhibitSendReceiveQuota = $_.ProhibitSendReceiveQuota -replace "\(.*",""
        $MBCount++
        Write-Progress -Activity "`n     Processed mailbox count: $MBCount "`n"  Currently Processing: $DisplayName"
        if ($SharedMBOnly.IsPresent -and ($Mailboxtype -ne "SharedMailbox"))
        {
            return
        }
        if ($UserMBOnly.IsPresent -and ($MailboxType -ne "UserMailbox"))
        {
            return
        }  
        # Check for archive enabled mailbox
        if (($_.ArchiveDatabase -eq $null) -and ($_.ArchiveDatabaseGuid -eq $_.ArchiveGuid))
        {
            $ArchiveStatus = "Disabled"
        }
        else
        {
            $ArchiveStatus = "Active"
        }
        Get_MailboxSize
        $PrintedMBCount++
    }
}


Write-Host "Mailbox Folder Statistics Report generated successfully!" -ForegroundColor Green

#######################################################################################################
