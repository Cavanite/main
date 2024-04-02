#Script information
<#
This script will create a new Exchange Online Retention Policy and creates all the nessesary tags for the policy.

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
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
}

Start-Transcript -Path "C:\Scripts\Create-Retention-Tags-Policy.log" -Append
#######################################################################################################
#######################################################################################################
Write-Host "Script Started" -ForegroundColor Green

if (Get-Module -Name ExchangeOnlineManagement -ListAvailable) {
    Write-Host "Exchange Online Module is already installed" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Exchange Online Module is not installed" -ForegroundColor Red
    Write-Host "Installing Exchange Online Module" -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    Start-Sleep -Seconds 2
}
try {
    Write-Host "Connecting to Exchange Online" -ForegroundColor Yellow
    Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName -ShowProgress $true
    Start-Sleep -Seconds 2
    Write-Host "Connected to Exchange Online" -ForegroundColor Green
}
catch {
    Write-Host "Failed to connect to Exchange Online" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit 1
}

$RetentionPolicyName = "Custom MRM Policy"
try {
    Write-Host "Gathering all the Retention Policies" -ForegroundColor Yellow
    $RetentionPolicy = Get-RetentionPolicy | Select-Object -ExpandProperty Name | Where-Object {$_ -eq $RetentionPolicyName}
    Start-Sleep -Seconds 2
    if (-not $RetentionPolicy) {
        Write-Host "No existing Retention Policy found" -ForegroundColor Green
        Start-Sleep -Seconds 1
        Enable-OrganizationCustomization
        Start-Sleep -Seconds 5
        Write-Host "Creating new Retention Policy and tags" -ForegroundColor Yellow
        New-RetentionPolicyTag -Name "Custom 6 months move to archive" -Type All -RetentionAction MovetoArchive -AgeLimitForRetention 180 -RetentionEnabled $true
        New-RetentionPolicyTag -Name "Applied automatically to default folder (Calendar)" -Type Calendar -RetentionAction DeleteAndAllowRecovery -RetentionEnabled $false
        New-RetentionPolicy -Name $RetentionPolicyName -RetentionPolicyTagLinks "Custom 6 months move to archive", "Applied automatically to default folder (Calendar)", "1 Month Delete", "1 Week Delete", "1 Year Delete", "5 Year Delete", "Junk Email", "Never Delete", "Recoverable items 14 days move to archive"
        Write-Host "New Retention Policy and tags have been created successfully" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "Existing Retention Policy found" -ForegroundColor Green
        Start-Sleep -Seconds 2
        $RetentionPolicyTags = Get-RetentionPolicyTag | Select-Object -ExpandProperty Name | Where-Object {$_ -eq "Applied automatically to default folder (Calendar)"}
        try {
            if (-not $RetentionPolicyTags) {
                Write-Host "Creating New tag and add to existing policy" -ForegroundColor Yellow
                New-RetentionPolicyTag -Name "Applied automatically to default folder (Calendar)" -Type Calendar -RetentionAction DeleteAndAllowRecovery -RetentionEnabled $false
                Start-Sleep -Seconds 2
                Write-Host "Don't archive Calendar has been created succesfully" -ForegroundColor Green
                Write-Host "Adding new tag to existing policy" -ForegroundColor Yellow
                Set-RetentionPolicy -Identity $RetentionPolicyName -RetentionPolicyTagLinks "Custom 6 months move to archive", "Applied automatically to default folder (Calendar)", "1 Month Delete", "1 Week Delete", "1 Year Delete", "5 Year Delete", "Junk Email", "Never Delete", "Recoverable items 14 days move to archive"    
            }
            else {
                Write-Host "Don't archive Calendar tag already exists" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Failed to create Don't archive Calendar" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
        }
}
catch {
    Write-Host "Failed to create Retention Policy and tags" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Start-Sleep -Seconds 2
}
$Response = Read-Host "Would you like to add the Retention Policy to everyone (y/n)?"
if ($Response -eq "y") {
    Write-Host "Adding Retention Policy to all mailboxes" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetentionPolicy $RetentionPolicyName
    Write-Host "Retention Policy has been added to all mailboxes" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Retention Policy has not been added to all mailboxes" -ForegroundColor Red
    Start-Sleep -Seconds 2
}
$EnableArchive = Read-Host "Would you like to enable Archive for all mailboxes (y/n)?"
if ($EnableArchive -eq "y") {
    Write-Host "Enabling Archive for all mailboxes" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Get-Mailbox -ResultSize Unlimited | Enable-Mailbox -Archive
    Write-Host "Archive has been enabled for all mailboxes" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Archive has not been enabled for all mailboxes" -ForegroundColor Red
    Start-Sleep -Seconds 2
}

Write-Host "Script Completed" -ForegroundColor Green
Stop-Transcript

