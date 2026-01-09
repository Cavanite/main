function GatherCPUGraph {
    $output = @()
    
    # Get CPU usage samples over time
    $output += "=== CPU Performance Monitor ===`n`n"
    $output += "Gathering CPU usage data (5 samples over 2.5 seconds)...`n`n"
    
    $cpuSamples = @()
    for ($i = 1; $i -le 5; $i++) {
        $cpu = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
        $cpuValue = [math]::Round($cpu.CounterSamples[0].CookedValue, 2)
        $cpuSamples += [PSCustomObject]@{
            Sample   = $i
            Time     = Get-Date -Format "HH:mm:ss"
            CPUUsage = $cpuValue
        }
        Start-Sleep -Milliseconds 500
    }
    
    # Display results in table format
    $output += $cpuSamples | Format-Table -AutoSize | Out-String
    
    # Calculate statistics
    $avgCPU = [math]::Round(($cpuSamples | Measure-Object -Property CPUUsage -Average).Average, 2)
    $maxCPU = [math]::Round(($cpuSamples | Measure-Object -Property CPUUsage -Maximum).Maximum, 2)
    $minCPU = [math]::Round(($cpuSamples | Measure-Object -Property CPUUsage -Minimum).Minimum, 2)
    
    $output += "`n=== CPU Statistics ===`n"
    $output += "Average CPU Usage: $avgCPU%`n"
    $output += "Maximum CPU Usage: $maxCPU%`n"
    $output += "Minimum CPU Usage: $minCPU%`n"
    
    # Get processor information
    $output += "`n=== Processor Information ===`n"
    $processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    $output += "Name: $($processor.Name)`n"
    $output += "Cores: $($processor.NumberOfCores)`n"
    $output += "Logical Processors: $($processor.NumberOfLogicalProcessors)`n"
    $output += "Max Clock Speed: $($processor.MaxClockSpeed) MHz`n"
    
    return ($output -join "")
}

Export-ModuleMember -Function GatherCPUGraph


