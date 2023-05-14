# Load the Exchange Online PowerShell module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

# Get the mailbox you want to modify calendar permissions for
$Mailbox = Read-Host "Enter the email address of the mailbox you want to modify:"

# Get the current calendar permissions for the mailbox
$CalendarFolder = Get-MailboxFolderStatistics -Identity $Mailbox -FolderScope Calendar -ErrorAction SilentlyContinue
$KalendarFolder = Get-MailboxFolderStatistics -Identity $Mailbox -FolderScope Kalendar -ErrorAction SilentlyContinue
$AgendaFolder = Get-MailboxFolderStatistics -Identity $Mailbox -FolderScope Agenda -ErrorAction SilentlyContinue

if (!$CalendarFolder) {
    Write-Host "The Calendar folder is not available for $Mailbox"
}
else {
    $CalendarPermissions = Get-MailboxFolderPermission -Identity $Mailbox:\Calendar
    Write-Host "Current calendar permissions for $Mailbox's Calendar:"
    $CalendarPermissions | Format-Table
}

if (!$KalendarFolder) {
    Write-Host "The Kalendar folder is not available for $Mailbox"
}
else {
    $KalendarPermissions = Get-MailboxFolderPermission -Identity $Mailbox:\Kalendar
    Write-Host "Current calendar permissions for $Mailbox's Kalendar:"
    $KalendarPermissions | Format-Table
}

if (!$AgendaFolder) {
    Write-Host "The Agenda folder is not available for $Mailbox"
}
else {
    $AgendaPermissions = Get-MailboxFolderPermission -Identity $Mailbox:\Agenda
    Write-Host "Current calendar permissions for $Mailbox's Agenda:"
    $AgendaPermissions | Format-Table
}

# Prompt the user to add or modify calendar permissions
$Action = Read-Host "Do you want to add or modify calendar permissions? Type 'Add' or 'Modify':"

# If the user wants to add permissions
if ($Action -eq "Add") {
    # Prompt the user for the user they want to add
    $User = Read-Host "Enter the email address of the user you want to add:"
    # Prompt the user for the permissions level they want to grant
    $Permission = Read-Host "Enter the permissions level you want to grant (Reviewer, Editor, etc.):"

    if ($CalendarFolder) {
        Add-MailboxFolderPermission -Identity $Mailbox:\Calendar -User $User -AccessRights $Permission
        Write-Host "$User has been granted $Permission permissions to $Mailbox's Calendar."
    }

    if ($KalendarFolder) {
        Add-MailboxFolderPermission -Identity $Mailbox:\Kalendar -User $User -AccessRights $Permission
        Write-Host "$User has been granted $Permission permissions to $Mailbox's Kalendar."
    }

    if ($AgendaFolder) {
        Add-MailboxFolderPermission -Identity $Mailbox:\Agenda -User $User -AccessRights $Permission
        Write-Host "$User has been granted $Permission permissions to $Mailbox's Agenda."
    }
}
# If the user wants to modify permissions
elseif ($Action -eq "Modify") {
    # Prompt the user for the user whose permissions they want to modify
    $User = Read-Host "Enter the email address of the user whose permissions you want to modify:"
    # Prompt the user for the new permissions level
    $NewPermission = Read-Host "Enter the new permissions level (Reviewer, Editor

if ($CalendarFolder) {
    # Get the current permissions for the specified user
    $CurrentPermission = Get-MailboxFolderPermission -Identity $Mailbox:\Calendar -User $User
    # Prompt the user to confirm they want to modify the permissions for the specified user
    $Confirm = Read-Host "Are you sure you want to modify permissions for $User? Type 'Yes' or 'No':"
    if ($Confirm -eq "Yes") {
        Set-MailboxFolderPermission -Identity $Mailbox:\Calendar -User $User -AccessRights $NewPermission -Confirm:$false
        Write-Host "$User's permissions have been updated to $NewPermission for $Mailbox's Calendar."
    }
}

if ($KalendarFolder) {
    # Get the current permissions for the specified user
    $CurrentPermission = Get-MailboxFolderPermission -Identity $Mailbox:\Kalendar -User $User
    # Prompt the user to confirm they want to modify the permissions for the specified user
    $Confirm = Read-Host "Are you sure you want to modify permissions for $User? Type 'Yes' or 'No':"
    if ($Confirm -eq "Yes") {
        Set-MailboxFolderPermission -Identity $Mailbox:\Kalendar -User $User -AccessRights $NewPermission -Confirm:$false
        Write-Host "$User's permissions have been updated to $NewPermission for $Mailbox's Kalendar."
    }
}

if ($AgendaFolder) {
    # Get the current permissions for the specified user
    $CurrentPermission = Get-MailboxFolderPermission -Identity $Mailbox:\Agenda -User $User
    # Prompt the user to confirm they want to modify the permissions for the specified user
    $Confirm = Read-Host "Are you sure you want to modify permissions for $User? Type 'Yes' or 'No':"
    if ($Confirm -eq "Yes") {
        Set-MailboxFolderPermission -Identity $Mailbox:\Agenda -User $User -AccessRights $NewPermission -Confirm:$false
        Write-Host "$User's permissions have been updated to $NewPermission for $Mailbox's Agenda."
    }
}
}
# If the user did not enter a valid action
else {
Write-Host "Invalid action entered."
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
