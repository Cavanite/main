# Purpose: This script will check the system his timezone and set it to the correct timezone

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
        $LogFile = Join-Path -Path $LogDir -ChildPath ("checktimezone.log")

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

$Timezone = Get-TimeZone
Log-Message "Current Timezone is $Timezone"

try {
    if ($Timezone.Id -ne "W. Europe Standard Time") {
        Log-Message "Timezone is not correct, changing timezone to W. Europe Standard Time"
        Set-TimeZone -Id "W. Europe Standard Time"
    }
    else {
        Log-Message "Timezone is correct"
        Log-Message "Script Completed"
        exit 0
    }
}
catch {
    Log-Message "Error: $_.Exception.Message"
    Write-Host -f Red "Error: $_.Exception.Message"
    Start-Sleep -Seconds 5
    Log-Message "Script Failed"
    exit 1 
}
