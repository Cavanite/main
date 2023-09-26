# Check if OneDrive is running
$onedriveProcess = Get-Process -Name "onedrive" -ErrorAction SilentlyContinue

# Script by Cavanite

if ($onedriveProcess -eq $null) {
    # If OneDrive is not running, start it with /background flag
    Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe" -ArgumentList "/background"
    Write-Host "OneDrive has been started with the /background flag."
} else {
    Write-Host "OneDrive is already running."
}
