#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

#Parameter for AD Security Group
$GroupName = "Group Creators"
 
#Connect to Azure AD
Connect-AzureAD
 
#Get the ID of Allowed AD Group
$GroupID = (Get-AzureADGroup -SearchString $GroupName).ObjectId
 
#Get the Office 365 Group Creation Settings ID
$GroupCreationSettingsID = (Get-AzureADDirectorySetting | Where-object {$_.Displayname -Eq "Group.Unified"}).Id
 
#Create Group Creation Settings, If it doesn't exist
If(!$GroupCreationSettingsID)
{
    #Create Settings from Template
    $Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq "Group.Unified"}
    $DirectorySettings = $Template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $DirectorySettings
    $GroupCreationSettingsID = (Get-AzureADDirectorySetting | Where-object {$_.Displayname -Eq "Group.Unified"}).Id
}
 
#Apply Settings
$GroupCreationSettings = Get-AzureADDirectorySetting -Id $GroupCreationSettingsID
$GroupCreationSettings["EnableGroupCreation"] = "True"
$GroupCreationSettings["GroupCreationAllowedGroupId"] = $GroupID
 
#Commit Settings
Set-AzureADDirectorySetting -Id $GroupCreationSettingsID -DirectorySetting $GroupCreationSettings
 
#Verify Settings
(Get-AzureADDirectorySetting -Id $GroupCreationSettingsID).Values

