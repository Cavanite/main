# Purpose: This script will check if there are updates available using winget and install them if available.
# It will also send Toast Notifications to the user.


#Script information


#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta

#Logging Section
#######################################################################################################
#######################################################################################################
if (-not (Test-Path -Path "C:\Scripts" -PathType Container)) {
    New-Item -ItemType Directory -Path "C:\Scripts"
    write-host -f Green "Log Directory Created"
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
}

#######################################################################################################
Start-Transcript -Path "C:\Scripts\WingetUpdater.log" -Append
#######################################################################################################
Write-Host "Script Started" -ForegroundColor DarkMagenta
#######################################################################################################
if (Get-Command "winget" -ErrorAction SilentlyContinue) {
    # Get the version of winget
    $wingetVersionOutput = winget -v
    $wingetVersion = $null

    if ($wingetVersionOutput -match 'v(\d+\.\d+\.\d+)') {
        $wingetVersion = [Version]$matches[1]
        Write-Host "Winget is up to date."
    }

    $requiredVersion = [Version]"1.7.10582"

    # Compare the version with the required version
    if ($wingetVersion -lt $requiredVersion) {
        # Download the latest version of winget
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "winget-latest.appxbundle"
        # Install the latest version of winget
        Add-AppxPackage winget-latest.appxbundle
        Write-Host "Winget has been updated to the latest version."
        Start-Sleep -Seconds 2
    }
} else {
    Write-Host "Winget is already installed and up to date"
    Start-Sleep -Seconds 2
}



#######################################################################################################
$wingetUpdates = winget upgrade

try {
    foreach ($wingetupdate in $wingetUpdates) {
        if ($wingetupdate -eq "No updates found.") {
            Write-Host "No updates found" -ForegroundColor DarkMagenta
            Start-Sleep -Seconds 2
            exit 0
        }
        else {
            $updateName = $wingetupdate.Name
            Write-Host "Updating $updateName" -ForegroundColor DarkMagenta
            Start-Sleep -Seconds 2
        }
    }
}
catch {
    Write-Host "Error Updating Application" -ForegroundColor Red
    Start-Sleep -Seconds 2
}

        $ApplicationName = $wingetupdate

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$APP_ID = 'Application Updater'

$template = @"
<toast>
    <visual>
        <binding template="ToastText02">

            <text id="2">$($ApplicationName) has been updated.</text>
        </binding>
    </visual>
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
        Start-Sleep -Seconds 2
        
        

catch {
    Write-Host "Error Updating Application" -ForegroundColor Red
    Start-Sleep -Seconds 2
}



#######################################################################################################



Write-Host "Script completed" -ForegroundColor DarkMagenta