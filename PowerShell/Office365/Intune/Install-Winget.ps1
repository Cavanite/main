# Check if winget is installed
if (Get-Command "winget" -ErrorAction SilentlyContinue) {
    # Get the version of winget
    $wingetVersionOutput = winget -v
    $wingetVersion = $null

    if ($wingetVersionOutput -match 'v(\d+\.\d+\.\d+)') {
        $wingetVersion = [Version]$matches[1]
        Write-Host "Winget is up to date."
    }

    $requiredVersion = [Version]"1.6.2771"

    # Compare the version with the required version
    if ($wingetVersion -lt $requiredVersion) {
        # Download the latest version of winget
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "winget-latest.appxbundle"
        # Install the latest version of winget
        Add-AppxPackage winget-latest.appxbundle
    }
} else {
    Write-Output "winget is not installed."
    #Install Winget
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "winget-latest.appxbundle"
    # Install the latest version of winget
    Add-AppxPackage winget-latest.appxbundle
}
