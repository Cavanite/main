$pathOK = "C:\scripts\UpdateOS.ps1.tag"
$pathNOTOK = "C:\scripts\UpdateOS-NotDone.ps1.tag"

if ((Test-Path $pathOK)) {
    Write-Host "Microsoft Updates have been applied"
    exit 0
}
else {
    (Test-Path $pathNOTOK)
    Write-Host "Microsoft Updates have not been applied"
    exit 1
}
