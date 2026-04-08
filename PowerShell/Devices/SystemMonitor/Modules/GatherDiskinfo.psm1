function GatherDiskinfo {
    
    $output = @()
    
    # Logical Disks
    $output += "=== Logical Disks ==="
    $output += Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | 
    Select-Object DeviceID, VolumeName, 
    @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } },
    @{Name = "FreeSpaceGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
    @{Name = "UsedSpaceGB"; Expression = { [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2) } },
    @{Name = "PercentFree"; Expression = { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } } | 
    Format-Table -AutoSize | Out-String
    
    # Physical Disks
    $output += "=== Physical Disks ==="
    $output += Get-CimInstance -ClassName Win32_DiskDrive | 
    Select-Object Model, 
    @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } },
    MediaType, Status | 
    Format-Table -AutoSize | Out-String
    
    return $output -join "`n"
}

Export-ModuleMember -Function GatherDiskinfo


