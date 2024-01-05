#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################


Write-Host "Checking if AzureAD module is installed..." -ForegroundColor Yellow
If (-not (Get-Module -Name AzureAD)) {
    Write-Host "Installing AzureAD module..." -ForegroundColor Yellow
    Install-Module -Name AzureAD -Force
}

Else {
    Write-Host "AzureAD module is installed" -ForegroundColor Green
}

Write-Host "Importing AzureAD module..." -ForegroundColor Yellow
Import-Module AzureAD
Write-Host "Connecting to Azure AD..." -ForegroundColor Yellow
Connect-AzureAD
Start-Sleep -Seconds 15

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