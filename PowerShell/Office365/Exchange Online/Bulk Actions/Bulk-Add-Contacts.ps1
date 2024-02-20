# Purpose: 
# This script is used to bulk add contacts to Office 365 Exchange Online. 
# The script will import a CSV file with the following columns: Name, ExternalEmailAddress. 
# The script will then check if the contact already exists and if not, create the contact in Office 365. 
# The script will also log all actions to a log file.

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
}

Function Log-Message()
{
 param
    (
    [Parameter(Mandatory=$true)] [string] $Message
    )

    Try {
        #Get the current date
        $LogDate = (Get-Date).tostring("dd-MM-yyyy")

        #Set the log directory
        $LogDir = "C:\Scripts"

        #Frame Log File with Log Directory, Current Directory, and date
        $LogFile = Join-Path -Path $LogDir -ChildPath ($LogDate + ".log")

        #Add Content to the Log File
        $TimeStamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss tt")
        $Line = "$TimeStamp - $Message"
        Add-content -Path $LogFile -Value $Line

        Write-host -f Green "$Message"
    }
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message 
    }
}
#######################################################################################################
#######################################################################################################
Log-Message "Script Started"

If (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    Log-Message -Message "Exchange Online Management module is already installed."
    Start-Sleep 1
    Import-Module ExchangeOnlineManagement
}
Else {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    Log-Message -Message "Exchange Online Management module was not installed, installing now."
    Start-Sleep 1
    Import-Module ExchangeOnlineManagement
    Log-Message -Message "Exchange Online Management module installed."
    Start-Sleep 1
}


Log-Message -Message "Importing CSV file."
try {
    $contacts = Import-Csv "C:\scripts\contact.csv"
    Start-Sleep 1
    Log-Message -Message "CSV file imported successfully."
} catch {
    Log-Message -Message "Error importing CSV file, path not found or file is not in correct format."
    Start-Sleep 1
    Exit
}

Write-Host "############################################################" -ForegroundColor DarkMagenta
Log-Message -Message "Connecting to Exchange Online."
Connect-ExchangeOnline -ShowProgress $true
Write-Host "############################################################" -ForegroundColor DarkMagenta
Start-Sleep 2
Log-Message -Message "Connected to Exchange Online."
Write-Host "#############################################################" -ForegroundColor DarkMagenta

foreach ( $contact in $contacts ) {
    try {
        if ($null -ne (Get-MailContact -Filter "DisplayName -eq '$($contacts.Name)' -or ExternalEmailAddress -eq '$($contacts.ExternalEmailAddress)'" -ErrorAction SilentlyContinue)) {
            Log-Message "Contact $($Contact.ExternalEmailAddress) already exists"
            Write-Host "#############################################################" -ForegroundColor DarkMagenta
            Start-Sleep 1
        }
        else {
            Log-Message "Creating contact $ExternalEmailAddress in Office 365..."   
            New-MailContact –Name $contacts.Name –ExternalEmailAddress $contacts.ExternalEmailAddress | Out-Null
            Log-Message "$Contacts.ExternalEmailAddress Successfully created" -ForegroundColor Green  
            Write-Host "#############################################################" -ForegroundColor DarkMagenta  
            Start-Sleep 1
        }
    }
    catch {
        Log-Message "Error creating contact $contacts.ExternalEmailAddress, File might be open or in use." 
    }      
}          
Write-Host "#############################################################" -ForegroundColor DarkMagenta
Log-Message "Script Completed"