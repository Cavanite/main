# Parameters
$TenantId = ""
$ClientId = ""
$SecretId = ""

$uri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $SecretId
    resource      = "https://api.partnercenter.microsoft.com/user_impersonation"
}

$resp = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/x-www-form-urlencoded"

Write-Host "Access Token: $($resp.access_token)"
