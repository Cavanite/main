#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

#Open Azure Cloud Shell
$sharename = "xxxx"
$subscriptionid = "xxxx-xxxx-xxxx-xxxx"

#Select Subscription
Select-AzSubscription -subscriptionid $subscriptionid

$Context = New-AzStorageContext -StorageAccountName "xxxx" -StorageAccountKey "xxxx"

#Now retrieve the file handles
Get-AzStorageFileHandle -Context $Context -ShareName $sharename -Recursive

#Search the path of the file handle you want to close

Close-AzStorageFileHandle -Context $Context -ShareName "xxxx" -Path 'Path to file handle' -CloseAll

