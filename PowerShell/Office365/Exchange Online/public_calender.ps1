$users = Get-Mailbox -Resultsize Unlimited
foreach ($user in $users) {
    Write-Host -ForegroundColor green "adding permission for $($user.alias)..."
        add-MailboxFolderPermission -Identity "$($user.alias):\calendar" -User Default -AccessRights LimitedDetails
        add-MailboxFolderPermission -Identity "$($user.alias):\agenda" -User Default -AccessRights LimitedDetails
        add-MailboxFolderPermission -Identity "$($user.alias):\kalender" -User Default -AccessRights LimitedDetails
}


foreach ($user in $users) {
    Write-Host -ForegroundColor green "Setting permission for $($user.alias)..."
        set-MailboxFolderPermission -Identity "$($user.alias):\calendar" -User Default -AccessRights LimitedDetails
        set-MailboxFolderPermission -Identity "$($user.alias):\agenda" -User Default -AccessRights LimitedDetails
        set-MailboxFolderPermission -Identity "$($user.alias):\kalender" -User Default -AccessRights LimitedDetails
}

foreach ($user in $users) {
    Write-Host -ForegroundColor green "getting permission for $($user.alias)..."
        get-MailboxFolderPermission -Identity "$($user.alias):\calendar" -erroraction 'silentlycontinue'
        get-MailboxFolderPermission -Identity "$($user.alias):\agenda" -erroraction 'silentlycontinue' 
        get-MailboxFolderPermission -Identity "$($user.alias):\kalender" -erroraction 'silentlycontinue'
}
