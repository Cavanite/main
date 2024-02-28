# Purpose: 
# This script will gather file share permissions and write them to a CSV file.

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
write-host "Checking if scripts Directory Exists" -ForegroundColor DarkMagenta
if (-not (Test-Path -Path "C:\Scripts" -PathType Container)) {
    New-Item -ItemType Directory -Path "C:\Scripts"
    write-host -f Green "Log Directory Created"
    Start-Sleep -Seconds 2
}
else {
    Start-Sleep -Seconds 2
    Write-Host "Script folder already exists" -ForegroundColor DarkMagenta
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
Start-Sleep -Seconds 2
Log-Message "Script Started"

Read-Host "Press Enter to continue"
$FolderPath = Read-Host "Please enter the path to the file share you want to gather permissions for"
$Depth = Read-Host "Please enter the maximum depth of folders to search in"
Log-Message "Path to file share is $Path"
Start-Sleep -Seconds 2

try {
    # Gather all the folders in the path, with a max depth of 5 folders
    $folders = Get-ChildItem -Path $FolderPath -Directory -Recurse -Depth $Depth

    # Initialize an array to store the permissions data
    $permissionsData = @()

    # Loop through each folder
    foreach ($folder in $folders) {
        # Get the permissions for the folder
        $permissions = Get-Acl -Path $folder.FullName | Select-Object -ExpandProperty Access

        # Loop through each permission
        foreach ($permission in $permissions) {
            # Exclude specific identities
            if ($permission.IdentityReference.Value -notin ("NT AUTHORITY\SYSTEM", "everyone" ,"Iedereen" , "INGEBOUWD\Administrators")) {
                # Create a custom object to store the permission data
                $permissionData = [PSCustomObject]@{
                    Folder = $folder.FullName
                    Identity = $permission.IdentityReference
                    AccessControlType = $permission.AccessControlType
                    FileSystemRights = $permission.FileSystemRights
                }

                # Add the permission data to the array
                $permissionsData += $permissionData
            }
        }
    }


    # Export the permissions data to a CSV file
    $csvPath = "C:\Scripts\permissions.csv"
    $permissionsData | Export-Csv -Path $csvPath -NoTypeInformation

    Log-Message "Permissions data exported to $csvPath"
    }
    
catch {
    Log-Message "Error: $_"
    Write-Host "Error: $_"
}
Start-Sleep -Seconds 2
Log-Message "Log file is located at C:\Scripts\"
Start-Sleep -Seconds 2
Log-Message "Script Completed"