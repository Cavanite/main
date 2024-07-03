CLS
#########################################################################


# Functions
#########################################################################
function isGUID ($data) { 
    try { 
        $guid = [GUID]$data 
        return 1 
    }
    catch { 
        #$notguid = 1 
        return 0 
    } 
} 
function isBase64 ($data) { 
    try { 
        $decodedII = [system.convert]::frombase64string($data) 
        return 1 
    }
    catch { 
        return 0 
    } 
} 
function Convert($ObjectGUID) {
    if (isGUID($ObjectGUID)) { 
        $guid = [GUID]$ObjectGUID 
        $bytearray = $guid.tobytearray() 
        $immutableID = [system.convert]::ToBase64String($bytearray) 
        return $immutableID
        $immutableID 
    }
    elseif (isBase64($ObjectGUID)) { 
        $decodedII = [system.convert]::frombase64string($valuetoconvert) 
        if (isGUID($decodedII)) { 
            $decode = [GUID]$decodedii 
            return $decode
        }
        else { 
            Write-Host "Value provided not in GUID or ImmutableID format." 
            DisplayHelp 
        } 
    }
    else { 
        Write-Host "Value provided not in GUID or ImmutableID format." 
        DisplayHelp 
    } 
}
function Get-TimeStamp { 
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date) 
}
#########################################################################





#Variable
#########################################################################
$O365SyncGroupName = "SEC-AAD-SYNC ENABLED"
#########################################################################


# Script:
#########################################################################
try { Get-Module AzureAD } Catch { install-module -name AzureAD -Force }
Write-Host "Import-Module AzureAD" -ForegroundColor Cyan
Import-Module AzureAD
try { Get-Module AzureAD } Catch { install-module -name MSOnline -Force }
Import-Module MSOnline
Write-Host "Import-Module MSOnline" -ForegroundColor Cyan

Write-Host "Connecting to MsolService.."
Connect-MsolService


$MembersToSync = Get-ADGroupMember -Identity "SEC-AAD-SYNC ENABLED" -ErrorAction SilentlyContinue


ForEach ($Member in $MembersToSync) {
    $User = Get-ADUser $Member -Properties *
    $ObjGUID = $User.ObjectGUID
    $TableID = Convert $ObjGUID

    Write-Host "Updating $($User.UserPrincipalName) immutableID to $($TableID) (GUID: $($ObjGUID))"
    Set-MsolUser -UserPrincipalName $User.UserPrincipalName -ImmutableId  $TableID
    $UpdatedTableID = Get-MsolUser -UserPrincipalName $User.UserPrincipalName | Select -ExpandProperty ImmutableId

    if ($UpdatedTableID -eq $TableID) {
        Write-Host "ImmutableId has been sucessfully updated" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to update ImmutableId! (MsolUser ImmutableId: $($UpdatedTableID))" -ForegroundColor Red
    }
}
Write-Host "##############################################################"



Write-Host "Finished.." -ForegroundColor Green
#########################################################################