# Set the registry key to disable the Windows 11 upgrade 
$regPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\WindowsUpdateBox"
$regName = "DisableWindows11Upgrade"
$regValue = "1"

# Check if the registry key already exists
if (Test-Path $regPath) {
    # Set the value of the existing registry key to disable the Windows 11 upgrade
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction SilentlyContinue
} else {
    # Create a new registry key and set its value to disable the Windows 11 upgrade
    New-Item -Path $regPath -Force | Out-Null
    New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD | Out-Null
}

# Display a message indicating the Windows 11 upgrade has been disabled
Write-Host "Windows 11 upgrade has been disabled. Please restart your computer for the changes to take effect."
