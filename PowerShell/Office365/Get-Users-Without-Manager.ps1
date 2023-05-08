#Connect-AzureAD

$Users = Get-AzureADUser -All $True | Where-Object {$_.UserType -eq 'Member' -and $_.AssignedLicenses -ne $null}
$NoManagerUsers = @()
foreach ($user in $Users) 
{
    $Manager = Get-AzureADUserManager -ObjectId $user.UserPrincipalName
    if ($null -eq $Manager)
    {
        $NoManagerUsers += $user
    }
}
$NoManagerUsers | Select-Object DisplayName, UserPrincipalName | Export-Csv -Path "C:\temp\UserswithnoManager.csv" -NoTypeInformation