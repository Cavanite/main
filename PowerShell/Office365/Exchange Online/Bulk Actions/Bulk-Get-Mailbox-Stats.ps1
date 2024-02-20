# Purpose: This script will connect to Exchange Online and retrieve mailbox statistics for all mailboxes in the tenant. 
# The script will then export the mailbox statistics to a CSV file.

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
if (-not (Test-Path -Path "C:\Scripts\Mailboxsizereport" -PathType Container)) {
    New-Item -ItemType Directory -Path "C:\Scripts\Mailboxsizereport"
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
        $LogDir = "C:\Scripts\Mailboxsizereport"

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
}
Write-Host "#############################################################" -ForegroundColor DarkMagenta
Log-Message "Connecting to Exchange Online."
Connect-ExchangeOnline -ShowProgress $true
Write-Host "#############################################################" -ForegroundColor DarkMagenta
Log-Message "Connected to Exchange Online."

$Mailboxes = Get-Mailbox -Resultsize Unlimited

try {
    $MailboxStatsList = foreach ($Mailbox in $Mailboxes) {
        $MailboxStats = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName
        $MailboxStats | Select-Object DisplayName, TotalItemSize, ItemCount, LastLogonTime 
        Log-Message -Message "Mailbox statistics for $($Mailbox.UserPrincipalName) retrieved."

    }
}
catch {
    Log-Message -Message "Error retrieving mailbox statistics for $($Mailbox.UserPrincipalName)." -ForegroundColor Red
}

Write-Host "#############################################################" -ForegroundColor DarkMagenta
Log-Message "Exporting Mailbox Statistics to CSV file."
$MailboxStatsList | Export-Csv -Path "C:\Scripts\Mailboxsizereport\MailboxStats.csv" -NoTypeInformation
Log-Message "Mailbox Statistics exported to CSV file."
Log-Message "Script Completed"