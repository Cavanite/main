#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

$CSVPath = "C:\Temp\AllGroupMembers.csv"
 
If(Test-Path $CSVPath) { Remove-Item $CSVPath}
 
$O365Groups=Get-UnifiedGroup
ForEach ($Group in $O365Groups) 
{ 
    Write-Host "Group Name:" $Group.DisplayName -ForegroundColor Green
    Get-UnifiedGroupLinks -Identity $Group.Id -LinkType Members | Select DisplayName,PrimarySmtpAddress
 
    
    Get-UnifiedGroupLinks -Identity $Group.Id -LinkType Members | Select-Object @{Name="Group Name";Expression={$Group.DisplayName}},`
         @{Name="User Name";Expression={$_.DisplayName}}, PrimarySmtpAddress | Export-CSV $CSVPath -NoTypeInformation -Append
}

$Csvfile = "C:\temp\ExportDGs.csv"

$Groups = Get-DistributionGroup -ResultSize Unlimited

$Groups | ForEach-Object {

    $GroupDN = $_.DistinguishedName
    $DisplayName = $_.DisplayName
    $PrimarySmtpAddress = $_.PrimarySmtpAddress
    $SecondarySmtpAddress = $_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}
    $GroupType = $_.GroupType
    $RecipientType = $_.RecipientType
    $Members = Get-DistributionGroupMember $GroupDN -ResultSize Unlimited
    $ManagedBy = $_.ManagedBy
    $Alias = $_.Alias
    $HiddenFromAddressLists = $_.HiddenFromAddressListsEnabled
    $MemberJoinRestriction = $_.MemberJoinRestriction 
    $MemberDepartRestriction = $_.MemberDepartRestriction
    $RequireSenderAuthenticationEnabled = $_.RequireSenderAuthenticationEnabled
    $AcceptMessagesOnlyFrom = $_.AcceptMessagesOnlyFrom
    $GrantSendOnBehalfTo = $_.GrantSendOnBehalfTo

    # Create objects
    [PSCustomObject]@{
        DisplayName                        = $DisplayName
        PrimarySmtpAddress                 = $PrimarySmtpAddress
        SecondaryStmpAddress               = ($SecondarySmtpAddress -join ',')
        Alias                              = $Alias
        GroupType                          = $GroupType
        RecipientType                      = $RecipientType
        Members                            = ($Members.Name -join ',')
        MembersPrimarySmtpAddress          = ($Members.PrimarySmtpAddress -join ',')
        ManagedBy                          = $ManagedBy.Name
        HiddenFromAddressLists             = $HiddenFromAddressLists
        MemberJoinRestriction              = $MemberJoinRestriction 
        MemberDepartRestriction            = $MemberDepartRestriction
        RequireSenderAuthenticationEnabled = $RequireSenderAuthenticationEnabled
        AcceptMessagesOnlyFrom             = ($AcceptMessagesOnlyFrom.Name -join ',')
        GrantSendOnBehalfTo                = $GrantSendOnBehalfTo.Name
    }


} | Sort-Object DisplayName | Export-CSV -Path $Csvfile -NoTypeInformation -Encoding UTF8 #-Delimiter ";"