






## Connect to Microsoft Graph API using Application Permissions
## API Permissions Required:
## Application Permissions:
## - User.Read.All

function Connect-GraphAPI {
    param (
        [Parameter(Mandatory = $true)]
        $ApplicationId,
        [Parameter(Mandatory = $true)]
        $TenantId,
        [Parameter(Mandatory = $true)]
        $ClientSecret
    )
}



