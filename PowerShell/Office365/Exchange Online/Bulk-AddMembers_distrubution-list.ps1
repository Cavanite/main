$GroupEmailID = "xxxxxxx"
$CSVFile = "C:\Temp\Users.txt"
 
#Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner:$False
 
#Get Existing Members of the Distribution List
$DLMembers =  Get-DistributionGroupMember -Identity $GroupEmailID -ResultSize Unlimited | Select -Expand PrimarySmtpAddress
 
#Import Distribution List Members from CSV
Import-CSV $CSVFile -Header "UPN" | ForEach {
    #Check if the Distribution List contains the particular user
    If ($DLMembers -contains $_.UPN)
    {
        Write-host -f Yellow "User is already member of the Distribution List:"$_.UPN
    }
    Else
    {        
        Add-DistributionGroupMember -Identity $GroupEmailID -Member $_.UPN
        Write-host -f Green "Added User to Distribution List:"$_.UPN
    }
}
