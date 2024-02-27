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
        $LogDir = "C:\Scripts\"

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

# Load module from PowerShell Gallery
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate))
{
    Log-Message "PSWindowsUpdate Not Installed, Installing now..."
    Install-Module -Name PSWindowsUpdate -Force -Verbose
    $null = Install-PackageProvider -Name NuGet -Force
    Log-Message "NuGet Installed successfully"
    $null = Install-Module PSWindowsUpdate -Force
    Import-Module PSWindowsUpdate
    Log-Message "Module Installed successfully"
}
else {
    Log-Message "Module already installed"
}

try { 
        Log-Message "Installing Updates"
        Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose | Select-Object Title, KB, Result | Format-Table
        if ((Get-WURebootStatus -Silent).RebootRequired -eq $true) {
            Log-Message "Reboot Required"
        }
        Log-Message "Updates Installed, no reboot required"
        Set-Content -Path "C:\scripts\UpdateOS.ps1.tag" -Value "Installed"
        Log-Message "Tag has been created on C:\scripts\"

}
catch {
    Set-Content -Path "C:\scripts\UpdateOS-NotDone.ps1.tag" -Value "Error"
    Log-Message "Error: $_"
}
#######################################################################################################
#######################################################################################################
Log-Message "Script Completed"