#connecting to the Azure AD
#Connect-AzureAD 

#importing the CSV source which has the changes
$users = Import-Csv '.\data.csv' -Delimiter ';'

#Iterating through each user in the CSV
foreach ($user in $users) {
    #INFO in the Console
    Write-Host "Updating the user :"  $user.UserPrincipalName    " manager to "  $user.Manager  -ForegroundColor Yellow 

    #Updating the Manager
    $ManagerId = (Get-AzureADUser -ObjectId $user.Manager).objectId
    if ($managerId.count -eq 1) {
        Set-AzureADUserManager -ObjectId (Get-AzureADUser -ObjectId $user.UserPrincipalName).Objectid -RefObjectId $ManagerId
    }
    elseif ($managerId.count -gt 1) {
        Write-Host "More than one user with the same display name exists. Please check the CSV file" -ForegroundColor Red
    }
    else {
        Write-Host "No user with the display name exists. Please check the CSV file" -ForegroundColor Red
    }

    #Completion info in the console for the specified user
    Write-Host "Updated" -ForegroundColor Green

}