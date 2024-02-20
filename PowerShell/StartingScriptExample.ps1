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
