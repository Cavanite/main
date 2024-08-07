
# Check if Winget is installed

if (Get-Command winget -ErrorAction SilentlyContinue) { 
    Write-Host "Winget is installed" -ForegroundColor DarkMagenta
    # Checking Version of Winget
    $wingetVersionOutput = winget -v
    $requiredVersion = "v1.8.19"
    Start-Sleep -Seconds 2
    if ($wingetVersionOutput -lt $requiredVersion) {
        Write-Host "Winget is not up to date" -ForegroundColor DarkMagenta
        Start-Sleep -Seconds 2
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "winget-latest.appxbundle"
        # Install the latest version of winget
        Add-AppxPackage winget-latest.appxbundle
    }
    else {
        Write-Host "Winget is up to date" -ForegroundColor DarkMagenta
        Start-Sleep -Seconds 2
    }
}
else {
    Write-Host "Winget is not installed" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "winget-latest.appxbundle"
    # Install the latest version of winget
    Add-AppxPackage winget-latest.appxbundle
}

# Gather the updates using Winget uprade
$wingetUpdates = winget update

foreach ($wingetUpdates in $wingetUpdates) {
    if ($wingetUpdates -eq "No updates found.") {
        Write-Host "No updates found" -ForegroundColor DarkMagenta
        Start-Sleep -Seconds 2
        exit 0
    }
    else {
        $updateName = $wingetUpdates.Name
        $updateVersion = $wingetUpdates.Version
        Write-Host "Updating $updateName to $updateVersion" -ForegroundColor DarkMagenta
        Start-Sleep -Seconds 2
    }
}
