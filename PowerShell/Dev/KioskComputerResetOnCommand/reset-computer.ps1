<# 
    Script: Kiosk Reset Script
    Author: Bert de Zeeuw (Bizway) 
    Purpose:
        This script will reset a kiosk / loan device and revert it to a “clean” state.
        - Optionally removes all local user profiles (except a defined whitelist).
        - Optionally removes installed applications (except a defined whitelist).
        - Optionally creates a fresh local user with a random password.
        - Logs all actions to C:\KioskReset\reset_log.txt

    NOTE:
        - This is a convenience reset, NOT a certified secure wipe.
        - For high-security / compliance situations, use proper wiping or re-imaging.
#>

#region Banner
Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta
#endregion Banner

#region Admin Check
# Make sure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole] "Administrator"
    )) {
    Write-Host "This script must be run as an administrator. Please restart PowerShell with elevated privileges." -ForegroundColor Red
    exit 1
}
#endregion Admin Check

#region Logging
$logFolder = "C:\KioskReset"
$logFile = Join-Path $logFolder "reset_log.txt"

if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
}

Start-Transcript -Path $logFile -Append
#endregion Logging

Write-Host "Starting kiosk computer reset process..." -ForegroundColor Green

#region Helper Functions
function Read-YN([string]$Prompt) {
    while ($true) {
        $answer = Read-Host -Prompt $Prompt
        switch ($answer.ToUpper()) {
            "Y" { return $true }
            "N" { return $false }
            default { Write-Host "Please enter Y or N." -ForegroundColor Yellow }
        }
    }
}
#endregion Helper Functions

##############################################################################################
# 1. Delete User Profiles and Local Users
##############################################################################################

$DeleteUserProfiles = Read-YN "Would you like to remove all user profiles of this device (except admin/whitelisted)? (Y/N)"
Write-Host "User selected option (delete profiles): $DeleteUserProfiles, let's proceed." -ForegroundColor Yellow

if ($DeleteUserProfiles) {
    try {
        # Define users to keep (adjust to your environment)
        $keepUsers = @(
            "Bizway-Admin",
            "Administrator",
            "DefaultAccount",
            "Public",
            "Guest",
            "WDAGUtilityAccount"
        )

        Write-Host "Collecting user profiles to remove..." -ForegroundColor Cyan

        # Remove user profiles (files + registry ties), except special ones and whitelisted
        Get-CimInstance Win32_UserProfile | Where-Object {
            -not $_.Special -and
            ($_.LocalPath -like 'C:\Users\*') -and
            ($keepUsers -notcontains (Split-Path $_.LocalPath -Leaf))
        } | ForEach-Object {
            Write-Host "Removing profile: $($_.LocalPath)" -ForegroundColor Yellow
            try {
                Remove-CimInstance $_ -ErrorAction Stop
                Write-Host "Successfully removed profile: $($_.LocalPath)" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove profile $($_.LocalPath): $($_.Exception.Message)" -ForegroundColor Red
                $_ | Out-File -FilePath $logFile -Append
            }
        }

        # Remove local users (accounts), except whitelisted
        Write-Host "Collecting local users to remove..." -ForegroundColor Cyan

        $usersToRemove = Get-LocalUser | Where-Object {
            $keepUsers -notcontains $_.Name -and
            $_.Enabled -eq $true
        }

        foreach ($user in $usersToRemove) {
            try {
                Write-Host "Removing local user: $($user.Name)" -ForegroundColor Yellow
                Remove-LocalUser -Name $user.Name -Confirm:$false -ErrorAction Stop
                Write-Host "Successfully removed user: $($user.Name)" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove user $($user.Name): $($_.Exception.Message)" -ForegroundColor Red
                $_ | Out-File -FilePath $logFile -Append
            }
        }
    }
    catch {
        Write-Host "An error occurred while cleaning users: $($_.Exception.Message)" -ForegroundColor Red
        $_ | Out-File -FilePath $logFile -Append
    }
}
else {
    Write-Host "Skipping user profile and local user removal." -ForegroundColor Cyan
}

##############################################################################################
# 2. Application Cleanup Section
##############################################################################################

$RemoveApps = Read-YN "Would you like to remove all installed applications (except a whitelist)? (Y/N)"
Write-Host "User selected option (remove apps): $RemoveApps, let's proceed." -ForegroundColor Yellow

if ($RemoveApps) {
    # Whitelist of applications to keep – adjust to your environment
    $appWhitelist = @(
        "Microsoft Visual C++*",
        "Microsoft .NET*",
        "Windows Software Development Kit*",
        "Microsoft Edge",
        "Microsoft Edge Update",
        "Microsoft Windows Desktop Runtime*",
        "Microsoft ASP.NET Core*",
        "Google Chrome",
        "Mozilla Firefox",
        "Adobe Reader*",
        "7-Zip*",
        "Notepad++",
        "VLC media player",
        "TeamViewer*",
        "Remote Desktop*",
        "Microsoft 365*",
        "Microsoft Office*",
        "Office 365*",
        "Microsoft Word*",
        "Microsoft Excel*",
        "Microsoft PowerPoint*",
        "Microsoft Outlook*",
        "Microsoft OneNote*",
        "Microsoft Access*",
        "Microsoft Publisher*",
        "Microsoft Teams*",
        "OneDrive*"
    )

    try {
        Write-Host "Retrieving installed applications (this may take a while)..." -ForegroundColor Cyan
        $installedApps = Get-WmiObject -Class Win32_Product

        foreach ($app in $installedApps) {
            $shouldKeep = $false

            foreach ($whitelistItem in $appWhitelist) {
                if ($app.Name -like $whitelistItem) {
                    $shouldKeep = $true
                    break
                }
            }

            if (-not $shouldKeep) {
                try {
                    Write-Host "Removing application: $($app.Name)" -ForegroundColor Yellow
                    $result = $app.Uninstall()
                    if ($result.ReturnValue -eq 0) {
                        Write-Host "Successfully removed application: $($app.Name)" -ForegroundColor Green
                    }
                    else {
                        Write-Host "Uninstall returned code $($result.ReturnValue) for application: $($app.Name)" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host "Failed to remove application $($app.Name): $($_.Exception.Message)" -ForegroundColor Red
                    $_ | Out-File -FilePath $logFile -Append
                }
            }
            else {
                Write-Host "Keeping whitelisted application: $($app.Name)" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "An error occurred during application cleanup: $($_.Exception.Message)" -ForegroundColor Red
        $_ | Out-File -FilePath $logFile -Append
    }
}
else {
    Write-Host "Skipping application removal." -ForegroundColor Cyan
}

##############################################################################################
# 3. Basic System Cleanup (Temp, Recycle Bin)
##############################################################################################

$DoCleanup = Read-YN "Would you like to clean Windows temp folders and Recycle Bin? (Y/N)"

if ($DoCleanup) {
    Write-Host "Cleaning temporary files and Recycle Bin..." -ForegroundColor Cyan

    # Clean Windows temp
    $tempPaths = @(
        "$env:WINDIR\Temp",
        "$env:TEMP"
    )

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            try {
                Write-Host "Cleaning temp folder: $path" -ForegroundColor Yellow
                Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
            catch {
                Write-Host "Failed to clean temp folder $path : $($PSItem.Exception.Message)" -ForegroundColor Red
                $_ | Out-File -FilePath $logFile -Append
            }
        }
    }

    # Clear recycle bin
    try {
        Write-Host "Clearing Recycle Bin..." -ForegroundColor Yellow
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "Recycle Bin cleared." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to clear Recycle Bin: $($_.Exception.Message)" -ForegroundColor Red
        $_ | Out-File -FilePath $logFile -Append
    }
}
else {
    Write-Host "Skipping temp and recycle bin cleanup." -ForegroundColor Cyan
}

##############################################################################################
# 4. User Creation Section
##############################################################################################

$newLocalUser = Read-YN "Would you like to create a new local user on this device? (Y/N)"
Write-Host "User selected option (create new local user): $newLocalUser, let's proceed." -ForegroundColor Yellow

if ($newLocalUser) {
    $confirmation = Read-YN "Are you sure you want to create a new local user? (Y/N)"
    if (-not $confirmation) {
        Write-Host "User creation cancelled." -ForegroundColor Red
        $newLocalUser = $false
    }
}

if ($newLocalUser) {
    $username = Read-Host -Prompt "Enter the username for the new local user"

    # Generate a random passphrase-style password
    $adjectives = @("Swift", "Bright", "Happy", "Strong", "Quick", "Smart", "Bold", "Calm", "Fair", "Kind")
    $nouns = @("Tiger", "Eagle", "River", "Mountain", "Ocean", "Forest", "Thunder", "Lightning", "Phoenix", "Dragon")
    $numbers = Get-Random -Minimum 100 -Maximum 999

    $randomPassphrase = "$($adjectives | Get-Random)$($nouns | Get-Random)$numbers!"
    $password = ConvertTo-SecureString -String $randomPassphrase -AsPlainText -Force

    Write-Host "Generated password for '$username': $randomPassphrase" -ForegroundColor Cyan
    Write-Host "Please save this password securely!" -ForegroundColor Yellow

    try {
        # Create the new local user
        New-LocalUser -Name $username -Password $password -FullName $username -Description "Kiosk Local User" -ErrorAction Stop
        Write-Host "Local user '$username' created successfully." -ForegroundColor Green

        # Add the user to the 'Users' group
        Add-LocalGroupMember -Group "Users" -Member $username -ErrorAction Stop
        Write-Host "User '$username' added to 'Users' group." -ForegroundColor Green
    }
    catch {
        Write-Host "An error occurred while creating the user: $($_.Exception.Message)" -ForegroundColor Red
        $_ | Out-File -FilePath $logFile -Append
    }
}
else {
    Write-Host "Skipping new user creation." -ForegroundColor Cyan
}

##############################################################################################
# 5. Final
##############################################################################################

Write-Host "Kiosk reset script completed. Please review the log at: $logFile" -ForegroundColor Green

$doReboot = Read-YN "Do you want to restart the device now? (Y/N)"
if ($doReboot) {
    Write-Host "Rebooting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

Stop-Transcript
