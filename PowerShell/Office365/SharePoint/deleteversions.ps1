#Config Variables
$SiteURL = ""
$ListName="Documents"
$VersionsToKeep = 50
$ErrorActionPreference = "Stop"

#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials (Get-Credential)

#Get the Context
$Ctx= Get-PnPContext

#Get All Items from the List - Exclude 'Folder' List Items
$ListItems = Get-PnPListItem -List $ListName -PageSize 2000 | Where-object {$_.FileSystemObjectType -eq "File"}



ForEach ($Item in $ListItems)
{   
    $wait = 1
    $runs = 0
    while($true){
        try {
        #Get File Versions
        $File = $Item.File
        $Versions = $File.Versions
        $Ctx.Load($File)
        $Ctx.Load($Versions)
        $Ctx.ExecuteQuery()
        $randomnumber = get-random -Minimum 0 -Maximum 2
        start-sleep -seconds $randomnumber
        Write-host -f Yellow "Scanning File:"$File.Name
        $VersionsCount = $Versions.Count
        $VersionsToDelete = $VersionsCount - $VersionsToKeep
        break
        }
        catch {
            if ($runs -ge 10){
                Write-host -f Red "Terminating Error: Unable to get Versions for File:"$File.Name
                break
            }
            else {
                Write-host -f Yellow "Error: Unable to get Versions for File:"$File.Name
                $runs += 1
                $wait = $wait * 2
                start-sleep -seconds $wait
                continue
            }
        }
    }

    If($VersionsToDelete -gt 0)
    {
        write-host -f Cyan "`t Total Number of Versions of the File:" $VersionsCount
        #Delete versions
        For($i=0; $i -lt $VersionsToDelete; $i++)
        {   
            $wait = 1
            $runs = 0
            while ($true) {
                try {
                    write-host -f Cyan "`t Deleting Version:" $Versions[0].VersionLabel
                    $Versions[0].DeleteObject()
                    break
                }
                catch {
                    if ($runs -ge 10){
                        Write-host -f Red "Terminating Error: Unable to delete versions for File:"$Versions[0].VersionLabel
                        break
                    }
                    else {
                        Write-host -f Yellow "Error: Unable to get versions delete File:"$Versions[0].VersionLabel
                        $runs += 1
                        $wait = $wait * 2
                        start-sleep -seconds $wait
                        continue
                    }
                }
            }
        }
        $Ctx.ExecuteQuery()
        Write-Host -f Green "`t Version History is cleaned for the File:"$File.Name
    }
}