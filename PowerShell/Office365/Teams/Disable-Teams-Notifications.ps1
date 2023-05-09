#Import-Module MicrosoftTeams

#Connect-MicrosoftTeams

# Get the user account for which you want to disable email notifications
$users = Import-Csv '.\data.csv' -Delimiter ';'

foreach ($user in $users) {
        Write-Host "Updating the user :" $user.UserPrincipalName -ForegroundColor Yellow 

        # Disable email notifications for the user
        Set-UserTeamsMeetingPolicy -Identity $user.UserPrincipalName -AllowEmailNotification $false

}
