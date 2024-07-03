# Purpose: This script is an example of a starting script that can be used as a template for other scripts.
#Real world example of the script.
#this script will match the immutabible ID of the users in the csv file with the immutable ID of the users in the tenant and then update the user's immutable ID to the new one.

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
#######################################################################################################

#Making sure Msol module is installed
if (-not (Get-Module -Name MSOnline)) {
    Install-Module -Name MSOnline -Force -AllowClobber
    Import-Module -Name MSOnline
    Write-Host "MSOnline Module Installed" -ForegroundColor Green
    Start-Sleep -Seconds 2
}
else {
    Write-Host "MSOnline Module already installed" -ForegroundColor DarkMagenta
    Start-Sleep -Seconds 2
}

#Connect to MSOnline
Connect-MsolService
try {
    
    if ($SkipLogin) {
        Write-Verbose "Skipping Office 365 login"
    }
    else {

        Write-Verbose "Asking user for Office 365 credentials"
        Write-Host "Enter Office 365 Credentials" -BackgroundColor Yellow -ForegroundColor Black
        $Office365Credential = Get-Credential

        Write-Verbose "Connecting to Office 365"
        $Office365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365Credential -Authentication Basic -AllowRedirection
        Import-PSSession $Office365Session

        Connect-MsolService -Credential $Office365Credential
    }

    [GUID]$UserGuid = (Get-ADUser -Identity $ADUser).ObjectGUID

    $bytearray = $UserGuid.tobytearray()
    $immutableID = [system.convert]::ToBase64String($bytearray)

    Set-MsolUser -UserPrincipalName $O365Email -ImmutableId $immutableID

    Get-Mailbox -Identity $O365Email | ForEach-Object {
        $ADUserParams = @{
            'Identity'     = $ADUser;
            'EmailAddress' = $_.WindowsEmailAddress;
            'add'          = @{mailNickname = $_.Alias }
        }
        Set-ADUser @ADUserParams

        ForEach ($address in $_.EmailAddresses) {

            Write-Verbose "Adding $address to $_"
            Set-ADUser -Identity $ADUser -Add @{proxyAddresses = $address }
        }
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}


#######################################################################################################