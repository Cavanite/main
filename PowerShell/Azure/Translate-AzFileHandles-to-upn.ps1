# Connect to Azure and sign in to Azure AD
$tenantId = Read-Host "Please enter the Azure AD Tenant ID"
Connect-AzAccount -TenantId $tenantId
$AzStorageAccountName = Read-Host "Please enter the StorageAccountName"
$AzresourceGroupName = Read-Host "Please enter the ResourceGroupName"
test
# Get the storage account key
$storageAccountName = "$AzStorageAccountName"
$resourceGroupName = "$AzresourceGroupName"
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value

# Set the storage context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$AzFileShareName = Read-Host "Please enter the FileShareName"

# List the file handles in the file share
$shareName = "$AzFileShareName"
$sessions = Get-AzStorageFileHandle -Context $ctx -ShareName $shareName

# Look up the user identity associated with the session
$sessionId = Read-Host "Please enter the Session ID"
$userId = ($sessions | Where-Object {$_.SessionId -eq $sessionId}).UserId

# Get the user identity from Azure AD
$user = Get-AzADUser -ObjectId $userId

# Get the user's UPN
$userPrincipalName = $user.UserPrincipalName