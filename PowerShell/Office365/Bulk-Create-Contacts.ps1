#Import the CSV file
$CsvPath = "C:\temp\contacts.csv"
$contacts = Import-Csv -Path $CsvPath

foreach ($contact in $contacts) {
    $displayname = $contact.Displayname
    $email = $contact.$email
    $phoneNumber = $contact.PhoneNumber

    $newContact = New-MailContact -Name $displayName -ExternalEmailAddress $email -PhoneNumber $phoneNumber

    if ($newContact) {
        Write-Host "Contact created successfully: $displayName ($email)"
    } else {
        Write-Host "Failed to create contact: $displayName ($email)"
    }
}