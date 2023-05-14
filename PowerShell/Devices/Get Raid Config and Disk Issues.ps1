try {
    $volumes = "list volume" | diskpart | Where-Object { $_ -match "^  [^-]" } | Select-Object -skip 1
 
    $RAIDState = foreach ($row in $volumes) {
        if ($row -match "\s\s(Volume\s\d)\s+([A-Z])\s+(.*)\s\s(NTFS|FAT)\s+(Mirror|RAID-5|Stripe|Spanned)\s+(\d+)\s+(..)\s\s([A-Za-z]*\s?[A-Za-z]*)(\s\s)*.*") {
            $disk = $matches[2]         
            if ($row -match "OK|Healthy") { $status = "OK" }
            if ($row -match "Rebuild") { $Status = 'Rebuilding' }
            if ($row -match "Failed|At Risk") { $status = "CRITICAL" }
     
            [pscustomobject]@{
                Disk   = $Disk
                Status = $status
            }
        }
    }
    $RAIDState = $RAIDState | Where-Object { $_.Status -ne "OK" }
}
catch {
    write-output "Command has Failed: $($_.Exception.Message)"
 
}
 
if ($RAIDState) {
    write-ouput"Check Diagnostics. Possible RAID failure."
    write-ouput $RAIDState
}
else {
    write-output "Healthy - No RAID Mirror issues found"
}
try {
    $Disks = get-physicaldisk | Where-Object { $_.HealthStatus -ne "Healthy" }
}
catch {
    write-output "Command has Failed: $($_.Exception.Message)"
    exit 1
}
 
if ($disks) {
    write-output "Check Diagnostics. Possible disk failure."
    write-output $disks
    exit 1
}
else {
    write-output "Healthy - No Physical Disk issues found"
}