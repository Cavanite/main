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
If (!(Test-Path -Path "C:\scripts\Temp-Cleanout-Log.txt")) {
    New-Item -Path "C:\scripts\Temp-Cleanout-Log.txt" -ItemType File
}
######################################################
$size = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
$files = (Get-ChildItem $templocation -Recurse -Force | Measure-Object -Property Length -ErrorAction SilentlyContinue).Count
$size = $size / 1MB

######################################################
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = "[$timestamp] Script started"
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value $entry
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Amount of files found: $files"
Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Total size of files found: $size MB"

######################################################
Write-Host "Searching for temp files older than $hours hours in $templocation" -ForegroundColor Green
######################################################

if ($files) {
    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    Write-Host "$files files found with a total size of $size bytes" -ForegroundColor Green
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value ""
}
else {
    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $entry = "[$timestamp] No files found"
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value $entry
    Write-Host "No files found" -ForegroundColor Green
    Add-Content -Path "C:\scripts\Temp-Cleanout-Log.txt" -Value "Script ended with no files found"
}
######################################################
foreach ($file in Get-ChildItem $templocation -Recurse -Force) {
    if ($file.LastWriteTime -lt $lastwritetime) {
        $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
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
Write-Host "Total size of files found after deletion: $size MB" -ForegroundColor Green

######################################################
if (!(Get-ScheduledTask -TaskName "CleanTempTask" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating scheduled task to run this script every 24 hours" -ForegroundColor Green

    $taskName = "CleanTempTask"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File 'C:\Github-Main-Cavanite\main\PowerShell\Dev\Temp-Folder-Cleanout\Clean-Temp.ps1'"
    $trigger = New-ScheduledTaskTrigger -Daily -At "00:00"
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings
}
else {
    write-host "Scheduled task already exists" -ForegroundColor Green
}
######################################################