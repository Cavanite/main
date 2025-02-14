# This script will download the latest version of the C++ redistributable from Microsoft's website and install it on the local machine.
$URL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$ProgressPreference = 'SilentlyContinue'

try {
    Invoke-WebRequest -Uri $URL -OutFile .\vc_redist.x64.exe -ErrorAction Stop
    Start-Process -FilePath .\vc_redist.x64.exe -ArgumentList '/s' -Wait -ErrorAction Stop
    Write-Output "C++ Redistributable installed successfully."
    exit 0
} catch {
    Write-Error "An error occurred: $_"
    exit 1
}