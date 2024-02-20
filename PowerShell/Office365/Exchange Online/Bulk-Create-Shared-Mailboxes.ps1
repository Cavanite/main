#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
#Bulk create sharedmailbox from CSV file

# Import CSV file
$Datas = Import-Csv "CSV path HERE"

# CSV examples:
# Name,DisplayName,User,AccessRights
# Testbox, Testbox 1,USER-EMAIL;USER-EMAIL2,FullAccess

# Get all recipients
$Recipients = Get-Recipient -ResultSize Unlimited | select Name

foreach ($Data in $Datas) {

    # Check if shared mailbox does not exist
    If (($Recipients | Where { $_.Name -eq $Data.Name }) -eq $Null) {

        # Create shared mailbox
        New-Mailbox -Name $Data.Name -DisplayName $Data.DisplayName -Shared
        Write-Host -f Green "Shared mailbox '$($Data.Name)' created successfully."
    }
    Else {
        Write-Host -f Green "Shared Mailbox '$($Data.Name)' already exists."
    }
    # Assign permissions on shared mailbox
    $Users = $Data.User -split ";"
    foreach ($User in $Users) {
        Add-MailboxPermission -Identity $Data.Name -User $User.Trim() -AccessRights $Data.AccessRights
    }
}