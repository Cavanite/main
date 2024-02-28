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

#Your script here



Log-Message "Script Completed"