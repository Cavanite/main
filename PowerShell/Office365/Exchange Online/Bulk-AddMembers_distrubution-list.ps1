#Connect-ExchangeOnline
$Pathtocsv = C:\temp\Users.csv
$targetdistrubutionlist = 'xxx'

Connect-ExchangeOnline

#Import-csv
Import-Csv -path $Pathtocsv

#For each loop to add all the users to distrubution list

foreach ($user in $users) {
    #Grab Email adres from the CSV
    $email = $user.email
    #Add the user to the distrubution list
    Add-DistrubutionGroupMember -Identity $targetdistrubutionlist -Member $email

}