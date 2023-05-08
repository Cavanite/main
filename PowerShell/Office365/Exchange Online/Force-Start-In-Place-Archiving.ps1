# Check if the Exchange Online PowerShell module is installed
if (-not (Get-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue)) {
    Write-Host "The Exchange Online PowerShell module is not installed. Installing now..."
    Install-Module ExchangeOnlineManagement -RequiredVersion 3.0.0
}

# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..."
Connect-ExchangeOnline

# Get the UPN of the mailbox to check from the user
$UPN = Read-Host -Prompt 'Enter the email address of the mailbox to check'

# Get the mailbox with the specified UPN
$mailbox = Get-Mailbox -Identity $UPN

if ($mailbox.ArchiveStatus -eq "Active") {
    # Get the GUID for the archive mailbox
    $guid = $mailbox.ArchiveGuid

    # Check if archiving is already running
    $archivingStatus = Get-MailboxStatistics -Archive -Identity $guid
    if ($archivingStatus.ArchiveStatus -eq "InProgress") {
        Write-Host "Archiving is already in progress for mailbox $UPN"
    }
    else {
        # Start archiving
        Start-ManagedFolderAssistant -Identity $guid
        Write-Host "Archiving has been started for mailbox $UPN"
    }
}
else {
    Write-Host "Archiving is not active for mailbox $UPN"
}