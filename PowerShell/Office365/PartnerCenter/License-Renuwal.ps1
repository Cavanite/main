# Install the Partner Center module if not already installed
if (-not (Get-Module -ListAvailable -Name PartnerCenter)) {
    Install-Module -Name PartnerCenter -Force
}

# Import the Partner Center module
Import-Module -Name PartnerCenter

# Authenticate with Partner Center
$clientId = "YOUR_CLIENT_ID"
$clientSecret = "YOUR_CLIENT_SECRET"
$tenantId = "YOUR_TENANT_ID"

$credentials = New-PartnerAccessToken -ApplicationId $clientId -Credential (Get-Credential) -ServicePrincipal -Tenant $tenantId
Connect-PartnerCenter -AccessToken $credentials.AccessToken -TenantId $tenantId -AccountId $credentials.AccountId

# Get customers and license information
$customers = Get-PartnerCustomer
$licenseInfo = foreach ($customer in $customers) {
    $licenses = Get-PartnerCustomerLicense -CustomerId $customer.CustomerId

    foreach ($license in $licenses) {
        [PSCustomObject]@{
            CustomerName      = $customer.CompanyName
            CustomerId        = $customer.CustomerId
            LicenseName       = $license.SkuId
            LicenseDisplayName = @{
O365_BUSINESS_ESSENTIALS                  = Office 365 Business Essentials
O365_BUSINESS_PREMIUM                    = Office 365 Business Premium
DESKLESSPACK                             = Office 365 (Plan K1)
DESKLESSWOFFPACK                         = Office 365 (Plan K2)
LITEPACK                                 = Office 365 (Plan P1)
EXCHANGESTANDARD                         = Office 365 Exchange Online Only
STANDARDPACK                             = Enterprise Plan E1
STANDARDWOFFPACK                         = Office 365 (Plan E2)
ENTERPRISEPACK                           = Enterprise Plan E3
ENTERPRISEPACKLRG                        = Enterprise Plan E3
ENTERPRISEWITHSCAL                       = Enterprise Plan E4
VISIOCLIENT                              = Visio Pro Online
POWER_BI_ADDON                           = Office 365 Power BI Addon
POWER_BI_INDIVIDUAL_USE                  = Power BI Individual User
POWER_BI_STANDALONE                      = Power BI Stand Alone
POWER_BI_STANDARD                        = Power-BI Standard
PROJECTESSENTIALS                        = Project Lite
PROJECTCLIENT                            = Project Professional
PROJECTONLINE_PLAN_1                     = Project Online
PROJECTONLINE_PLAN_2                     = Project Online and PRO
ProjectPremium                           = Project Online Premium
EMS                                      = Enterprise Mobility Suite
RIGHTSMANAGEMENT_ADHOC                   = Windows Azure Rights Management
SHAREPOINTSTORAGE                        = SharePoint storage
PLANNERSTANDALONE                        = Planner Standalone
BI_AZURE_P1                              = Power BI Reporting and Analytics
INTUNE_A                                 = Windows Intune Plan A
PROJECTWORKMANAGEMENT                    = Office 365 Planner Preview
ATP_ENTERPRISE                           = Exchange Online Advanced Threat Protection
EQUIVIO_ANALYTICS                        = Office 365 Advanced eDiscovery
AAD_BASIC                                = Azure Active Directory Basic
RMS_S_ENTERPRISE                         = Azure Active Directory Rights Management
AAD_PREMIUM                              = Azure Active Directory Premium
MFA_PREMIUM                              = Azure Multi-Factor Authentication
                # Add mappings for other license SKUs
            }[$license.SkuId]
            LicenseRenewalDate = $license.ExpirationDate
        }
    }
}

# Export data to CSV
$exportPath = "C:\temp\export.csv"
$licenseInfo | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "License information exported to: $exportPath"
