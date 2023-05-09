Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

#Set Parameters
$TenantAdminURL= ""

#Setup Credentials to connect
$Cred = Get-Credential

Try {
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($TenantAdminURL)
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
    #Get tenant object
    $Tenant= New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($Ctx)
    $Ctx.Load($Tenant)
    $Ctx.ExecuteQuery()
    #Disable Sync button for OneDrive 
    $Tenant.HideSyncButtonOnODB = $false
    $Tenant.Update()
    $Ctx.ExecuteQuery()
}
Catch {
write-host -f Red "Error Updating Tenant Settings!" $_.Exception.Message
}