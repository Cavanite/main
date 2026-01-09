# Purpose: This script is an example of a starting script that can be used as a template for other scripts.
#Real world example of the script.


#Script information
#This Script will create a mailbox in Exchange Online and assign a license to the user, using the Microsoft Graph API.

#######################################################################################################
#######################################################################################################

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Write-Host "###             Written By Bert de Zeeuw                  ###" -ForegroundColor DarkMagenta
Write-Host "###        visit https://github.com/Cavanite              ###" -ForegroundColor DarkMagenta
Write-Host "###                                                       ###" -ForegroundColor DarkMagenta
Write-Host "#############################################################" -ForegroundColor DarkMagenta


############################################################################
function Initialize-Scriptlogging {
    $Logpath = "C:\scripts\"
    if (-not (Test-Path -Path $Logpath -PathType Container)) {
        New-Item -ItemType Directory -Path $Logpath
        write-host -f Green "Log Directory Created"
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
        Start-Sleep -Seconds 2
    }
}
Initialize-Scriptlogging 
############################################################################

############################################################################
$ClientId = ""
$TenantId = ""
$ClientSecret = ""
############################################################################
function function Initialize-GraphModules {

    Write-Host "Checking if Microsoft.Graph module is installed" -ForegroundColor Yellow
    if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
    Write-Host "Microsoft.Graph module is not installed, installing now" -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph
}
    Start-sleep -Seconds 2
    Write-Host "Microsoft.Graph module is installed, let's continue." -ForegroundColor Green


}
Initialize-GraphModules
############################################################################
Start-Transcript -Path "C:\Scripts\$scriptname.log" -Append
Write-Host "Starting Script" -ForegroundColor Green
############################################################################
function Initialize-Graphconnection {

    Write-Host "Connecting to Microsoft Graph API..." -ForegroundColor Green
    Start-Sleep -Seconds 2

    try {
        $ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
        $ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass

        Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential       
        Write-Host "Successfully connected to Microsoft Graph API." -ForegroundColor Green 
        Start-Sleep -Seconds 2
    }
    catch {
        Write-Host "Error connecting to Microsoft Graph API: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
Initialize-Graphconnection
############################################################################
function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int] $length
    )
    #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
    $rng.GetBytes($bytes)
    $result = New-Object char[]($length)
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
    return (-join $result)
}

$RandomPassword = Get-RandomPassword 12
############################################################################
try {
    Write-Host "Trying to import a csv file" -ForegroundColor Green
    Start-Sleep -Seconds 2
    $Users = Import-Csv -Path "C:\Scripts\NewMailbox.csv"
    Write-Host "Imported csv file" -ForegroundColor Green
    Start-Sleep -Seconds 1
    foreach ($User in $Users) {
        $UserExists = Get-MgUser -Filter "UserPrincipalName eq '$($User.UserPrincipalName)'"
        if ($UserExists) {
            Write-Host "User $($User.UserPrincipalName) already exists, skipping" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            continue
        }
        else {
            #Get a random password for every user.
            $RandomPassword = Get-RandomPassword 16
            
            $UserAttributes = @{
                UserPrincipalName = $User.UserPrincipalName
                DisplayName = $User.DisplayName
                MailNickname = $User.MailNickname
                GivenName = $User.FirstName
                SurName = $User.LastName
                JobTitle = $User.Title
                Department = $User.Department
                PasswordProfile = @{
                    Password = $RandomPassword
                    ForceChangePasswordNextSignIn = $false
                }
                AccountEnabled = $true
            }
            Write-Host "User $($User.UserPrincipalName) does not exist, creating new mailbox" -ForegroundColor Green
            Start-Sleep -Seconds 2

            #Create the mailbox
                New-MgUser @UserAttributes


            Write-Host "Mailbox for $($User.UserPrincipalName) created" -ForegroundColor Green
            Start-Sleep -Seconds 2
        #Exporting the user and password to a csv file.
            $User | Select-Object UserPrincipalName, @{Name='Password';Expression={$RandomPassword}} | Export-Csv -Path "C:\Scripts\NewMailboxPasswords.csv" -NoTypeInformation
        }
    }
}
catch {
    Write-Host "Failed to import csv file, exiting script." -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}

Write-Host "Script completed" -ForegroundColor Green
Write-Host "Log file created at C:\Scripts\$scriptname.log" -ForegroundColor Green
Start-Sleep -Seconds 2
Write-Host "#############################################################" -ForegroundColor DarkMagenta
Stop-Transcript
