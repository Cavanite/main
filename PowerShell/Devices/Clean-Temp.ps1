#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

$templocation = "C:\Users\$env:USERNAME\AppData\Local\Temp"
$hours = 24
$now = Get-Date
$lastwritetime = $now.AddHours(-$hours)

######################################################
Write-Host "Starting script" -ForegroundColor White
Start-Sleep -s 2
Write-Host "Checking if C:\scripts exists" -ForegroundColor Yellow
Start-Sleep -s 2
######################################################
if (!(Test-Path -Path "C:\scripts")) {
    New-Item -Path "C:\scripts" -ItemType Directory
}

If (!(Test-Path -Path "C:\scripts\Temp-Cleanout-Log.txt")) {
    New-Item -Path "C:\scripts\Temp-Cleanout-Log.txt" -ItemType File
}
######################################################
$size = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
$files = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -ErrorAction SilentlyContinue).Count
$size = $size / 1MB

######################################################
$timestamp = Get-Date -Format "yyyy-MM-dd ss:mm:HH"
$entry = "[$timestamp] Script started"
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value $entry
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Amount of files found: $files"
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Total size of files found: $size MB"

######################################################
Write-Host "Searching for temp files older than $hours hours in $templocation" -ForegroundColor Green
Start-Sleep -s 2
######################################################

if ($files) {
    $timestamp = Get-Date -Format "dd-MM-yyyy ss:mm:HH"
    Write-Host "$files files found with a total size of $size bytes" -ForegroundColor Green
    Start-Sleep -s 2
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value ""
}
else {
    $timestamp = Get-Date -Format "dd-MM-yyyy ss:mm:HH"
    $entry = "[$timestamp] No files found"
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value $entry
    Write-Host "No files found" -ForegroundColor Green
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Script ended with no files found"
}
######################################################
foreach ($file in Get-ChildItem $templocation -Recurse -Force) {
    if ($file.LastWriteTime -lt $lastwritetime) {
        $timestamp = Get-Date -Format "dd-MM-yyyy ss:mm:HH"
        $entry = "[$timestamp] Deleting file $file"
        $size = $size + $file.Length
        Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value $entry
        Remove-Item -Path $file.FullName -Force -Recurse  -ErrorAction SilentlyContinue
    }
}

#get new file count and size after deletion
$size = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
$files = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -ErrorAction SilentlyContinue).Count
$size = $size / 1MB 

Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Amount of files found after deletion: $files"
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Total size of files found after deletion: $size MB"

Write-Host "Amount of files found after deletion: $files" -ForegroundColor Green
Start-Sleep -s 2
Write-Host "Total size of files found after deletion: $size MB" -ForegroundColor Green
Start-Sleep -s 2
Write-Host "Script ended" -ForegroundColor Green