# Purpose: This script is an example of a starting script that can be used as a template for other scripts.
#Real world example of the script.


#Script information


#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta
#######################################################################################################
#Making sure the script is running in PowerShell 7.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or later" -ForegroundColor Red
    Exit 
}
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

Start-Transcript -Path "C:\Scripts\Get-Signinlogs-Outside-NL.log" -Append
#######################################################################################################
Write-Host "Checking if Graph module is installed" -ForegroundColor Green
if(-not (Get-Module -Name "Microsoft.Graph.Beta.Reports")) {
    Write-Host "Microsoft.Graph.Beta.Reports module is not installed, installing now" -ForegroundColor Green
    Install-Module -Name "Microsoft.Graph.Beta.Reports" -Force -AllowClobber -Scope CurrentUser
}
else {
    Write-Host "Microsoft.Graph.Beta.Reports module is already installed" -ForegroundColor Green
}
#######################################################################################################
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "UserAuthenticationMethod.Read.All", "AuditLog.Read.All" -NoWelcome
#######################################################################################################
#Gathering the SigninLogs
Write-Host "Gathering SigninLogs" -ForegroundColor DarkMagenta
$SignInLogs = Get-MgAuditLogSignIn -Top 5000

try {
    foreach ($Signin in $SigninLogs) {
        if ($Signin.Location.CountryOrRegion -ne "Netherlands") {
            $Signin | Select-Object -Property AppDisplayName, ConditionalAccessStatus, UserDisplayName, IPAddress , Location, RiskDetail      | Export-Csv -Path "C:\scripts\SigninsOutsideNL.csv" -NoTypeInformation -Append
        }
    } 
}
catch {
    Write-Host "No signins from outside The Netherlands found." -ForegroundColor Yellow
}

Write-Host "Successfully exported to CSV, at location C:\scripts\SigninsOutsideNL.csv" -ForegroundColor Green




Stop-Transcript