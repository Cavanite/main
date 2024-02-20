#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################
#Bulk create sharedmailbox from CSV file
#Logging Section

#check the script directory exists.
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

#Check if Exchange Online module is installed
If (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    Log-Message -Message "Exchange Online Management module is already installed."
    Import-Module ExchangeOnlineManagement
}
Else {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    Log-Message -Message "Exchange Online Management module was not installed, installing now."
    Start-Sleep -5
    Import-Module ExchangeOnlineManagement
    Log-Message -Message "Exchange Online Management module installed."
    Start-Sleep -1
}


# Import CSV file
Log-Message -Message "Importing CSV file."
try {
    $Datas = Import-Csv "CSV path HERE"
    Log-Message -Message "CSV file imported successfully."
} catch {
    Log-Message -Message "Error importing CSV file, path not found or file is not in correct format."
    Log-Message -Message "Error: $_"
    Exit
}
# CSV examples:
# Name,DisplayName,User,AccessRights
# Testbox, Testbox 1,USER-EMAIL;USER-EMAIL2,FullAccess

# Get all recipients
$Recipients = Get-Recipient -ResultSize Unlimited | select Name

foreach ($Data in $Datas) {

    # Check if shared mailbox does not exist
    If (($Recipients | Where { $_.Name -eq $Data.Name }) -eq $Null) {

        # Create shared mailbox
        New-Mailbox -Name $Data.Name -DisplayName $Data.DisplayName -Shared
        Log-Message -f Green "Shared mailbox '$($Data.Name)' created successfully."
    }
    Else {
        Log-Message -f Red "Shared Mailbox '$($Data.Name)' already exists."
    }
    # Assign permissions on shared mailbox
    $Users = $Data.User -split ";"
    foreach ($User in $Users) {
        Log-Message -Message "Assigning permissions to $User on $Data.Name"
        Add-MailboxPermission -Identity $Data.Name -User $User.Trim() -AccessRights $Data.AccessRights
    }
}
Log-Message -Message "Script completed."