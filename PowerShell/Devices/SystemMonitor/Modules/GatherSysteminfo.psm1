
function GatherSysteminfo {
    
    $output = @()
    
    # Computer System
    $output += "=== Computer System ==="
    $output += Get-CimInstance -ClassName Win32_ComputerSystem | 
    Select-Object Name, Manufacturer, Model, @{Name = "MemoryGB"; Expression = { [math]::Round($_.TotalPhysicalMemory / 1GB, 2) } } | 
    Format-Table -AutoSize | Out-String
    
    # Operating System
    $output += "=== Operating System ==="
    $output += Get-CimInstance -ClassName Win32_OperatingSystem | 
    Select-Object Caption, Version, OSArchitecture, BuildNumber | 
    Format-Table -AutoSize | Out-String
    
    # Processor
    $output += "=== Processor ==="
    $output += Get-CimInstance -ClassName Win32_Processor | 
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | 
    Format-Table -AutoSize | Out-String
    
    return $output -join "`n"
}

Export-ModuleMember -Function GatherSysteminfo

