#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

# Check if BitLocker is active on the system
$bitLockerStatus = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue

if ($bitLockerStatus) {
    $bitLockerProtectionStatus = $bitLockerStatus.ProtectionStatus

    # Check if BitLocker is active
    if ($bitLockerProtectionStatus -eq "On") {
        # Suspend BitLocker encryption
        Suspend-BitLocker -MountPoint "C:" # Replace "C:" with the appropriate drive letter if necessary

        # Inform the user
        Write-Host "BitLocker encryption has been suspended."
    }
    elseif ($bitLockerProtectionStatus -eq "Off") {
        # Inform the user that BitLocker is not active
        Write-Host "BitLocker is not active on the system."
    }
}

# Check if PSWindowsUpdate module is installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    # Install the PSWindowsUpdate module
    Write-Host "Installing PSWindowsUpdate module..."
    try {
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Write-Host "PSWindowsUpdate module installed successfully."
    }
    catch {
        Write-Host "Failed to install PSWindowsUpdate module. Please make sure you have an active internet connection and try again."
    }
}

# Import the PSWindowsUpdate module
Import-Module -Name PSWindowsUpdate -Force

# Check for available Windows updates
$updates = Get-WindowsUpdate -AcceptAll -Install -Verbose -IgnoreReboot -IgnoreRebootRequired

# If updates are available
if ($updates.Count -gt 0) {
    # Install updates without automatically restarting
    Write-Host "Installing updates..."
    $installResult = Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

    # Check for installation errors
    if ($installResult.FailureCount -gt 0) {
        Write-Host "Installation failed. Please check the error messages for details."
    }
    else {
        Write-Host "Installation completed successfully."
    }
}
else {
    # Inform the user that no updates are available
    Write-Host "No updates are available."
}

# Resume BitLocker encryption if it was previously suspended
if ($bitLockerStatus -and $bitLockerProtectionStatus -eq "On") {
    Resume-BitLocker -MountPoint "C:" # Replace "C:" with the appropriate drive letter if necessary

    # Inform the user
    Write-Host "BitLocker encryption has been resumed."
}