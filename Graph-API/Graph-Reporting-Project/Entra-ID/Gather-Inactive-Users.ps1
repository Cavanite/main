#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

function Get-GraphModules {
    $graphModules = Get-Module -Name Microsoft.Graph.* -ListAvailable
    if ($graphModules) {
        Write-Host "Graph modules found:" -ForegroundColor Green
        $graphModules | ForEach-Object { 
            Write-Host "$($_.Name) - Version: $($_.Version)" -ForegroundColor Cyan 
        }
        
        # Check for updates and update if necessary
        Write-Host "Checking for module updates..." -ForegroundColor Yellow
        try {
            $installedModules = Get-InstalledModule -Name Microsoft.Graph.* -ErrorAction SilentlyContinue
            foreach ($module in $installedModules) {
                $latestVersion = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
                if ($latestVersion -and $latestVersion.Version -gt $module.Version) {
                    Write-Host "Updating $($module.Name) from $($module.Version) to $($latestVersion.Version)..." -ForegroundColor Yellow
                    Update-Module -Name $module.Name -Force
                    Write-Host "$($module.Name) updated successfully." -ForegroundColor Green
                }
            }
            Write-Host "All Graph modules are up to date." -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Host "Error checking for updates: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
            exit 1
        }
    } else {
        Write-Host "No Graph modules found." -ForegroundColor Yellow
        try {
            Write-Host "Installing Microsoft.Graph modules..." -ForegroundColor Yellow
            Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
            Write-Host "Microsoft.Graph modules installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error installing Microsoft.Graph modules: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
            exit 1
        }
    }
}

function Connect-Graph {
    param (
        [string]$ClientId,
        [string]$TenantId,
        [string]$ClientSecret
    )
    Write-Host "Connecting to Microsoft Graph API..." -ForegroundColor Green
    Start-Sleep -Seconds 2

    $ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
    $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass
    
    try {
        Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome
        Write-Host "Successfully connected to Microsoft Graph API." -ForegroundColor Green 
    }
    catch {
        Write-Host "Error connecting to Microsoft Graph API: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Gather-LicensedUsers {
    Write-Host "Gathering licensed users from Microsoft Entra ID..." -ForegroundColor Green
    Start-Sleep -Seconds 2

    try {
        $users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,SignInActivity,AssignedLicenses
        $licensedUsers = $users | Where-Object { $_.AssignedLicenses.Count -gt 0 }
        
        if ($licensedUsers) {
            Write-Host "Licensed users gathered successfully. Found $($licensedUsers.Count) licensed users." -ForegroundColor Green
            return $licensedUsers
        } else {
            Write-Host "No licensed users found." -ForegroundColor Yellow
            return @()
        }
    }
    catch {
        Write-Host "Error gathering licensed users: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Export-InactiveUsers {
    param (
        [int]$DaysThreshold = 60
    )
    
    Write-Host "Analyzing user sign-in activity..." -ForegroundColor Green
    
    try {
        $licensedUsers = Gather-LicensedUsers
        $cutoffDate = (Get-Date).AddDays(-$DaysThreshold)
        $inactiveUsers = @()
        
        foreach ($user in $licensedUsers) {
            $lastSignIn = $null
            $daysSinceLastSignIn = $null
            
            if ($user.SignInActivity -and $user.SignInActivity.LastSignInDateTime) {
                $lastSignIn = [DateTime]$user.SignInActivity.LastSignInDateTime
                $daysSinceLastSignIn = (Get-Date) - $lastSignIn | Select-Object -ExpandProperty Days
            }
            
            # If no sign-in data or last sign-in is older than threshold
            if (-not $lastSignIn -or $lastSignIn -lt $cutoffDate) {
                $inactiveUsers += [PSCustomObject]@{
                    DisplayName = $user.DisplayName
                    UserPrincipalName = $user.UserPrincipalName
                    LastSignInDate = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd HH:mm:ss") } else { "Never" }
                    DaysSinceLastSignIn = if ($daysSinceLastSignIn) { $daysSinceLastSignIn } else { "Never signed in" }
                    LicenseCount = $user.AssignedLicenses.Count
                }
            }
        }
        
        if ($inactiveUsers.Count -gt 0) {
            $exportPath = "InactiveUsers_$(Get-Date -Format 'dd-MM-yyyy').csv"
            $inactiveUsers | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
            Write-Host "Exported $($inactiveUsers.Count) inactive users to $exportPath" -ForegroundColor Green
        } else {
            Write-Host "No inactive users found (all users have signed in within $DaysThreshold days)." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error analyzing user activity: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Main script execution

Get-GraphModules

# Replace with your actual Azure AD app registration details
$ClientId = "your-client-id"
$TenantId = "your-tenant-id"
$ClientSecret = "your-client-secret"

Connect-Graph -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret
Export-InactiveUsers -DaysThreshold 60
Write-Host "Script execution completed." -ForegroundColor Green
# Disconnect from Microsoft Graph
Disconnect-MgGraph -Confirm:$false
Write-Host "Disconnected from Microsoft Graph." -ForegroundColor Green
