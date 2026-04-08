function GatherUpdates {
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        return "Administrator privileges required to check Windows Updates.`n`nPlease run this application as Administrator to view Windows Update information."
    }
    
    try {
        # Check if PSWindowsUpdate module is installed
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            return "PSWindowsUpdate module not installed.`n`nTo view Windows Updates, please install the module by running:`nInstall-Module -Name PSWindowsUpdate -Force -Scope CurrentUser"
        }
        
        # Import the module if not already imported
        if (-not (Get-Module -Name PSWindowsUpdate)) {
            Import-Module PSWindowsUpdate -ErrorAction Stop
        }
        
        $updates = Get-WindowsUpdate -ErrorAction Stop
        
        if ($updates) {
            return $updates | Select-Object Title, KB, Size, Status | Format-Table -AutoSize | Out-String
        }
        else {
            return "No pending Windows Updates found."
        }
    }
    catch {
        return "Error gathering Windows Updates: $($_.Exception.Message)"
    }
}

function Install-MissingUpdates {
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        return "Administrator privileges required to install Windows Updates.`n`nPlease run this application as Administrator."
    }
    
    try {
        # Check if PSWindowsUpdate module is installed
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            return "PSWindowsUpdate module not installed.`n`nTo install updates, please install the module by running:`nInstall-Module -Name PSWindowsUpdate -Force -Scope CurrentUser"
        }
        
        # Import the module if not already imported
        if (-not (Get-Module -Name PSWindowsUpdate)) {
            Import-Module PSWindowsUpdate -ErrorAction Stop
        }
        
        $output = @()
        $output += "Starting Windows Update installation...`n`n"
        
        # Install all available updates
        $updates = Get-WindowsUpdate -Verbose -AcceptAll -Install
        
        if ($updates) {
            $output += "Installation completed. Results:`n`n"
            $output += $updates | Select-Object Title, KB, Result, Size | Format-Table -AutoSize | Out-String
        }
        else {
            $output += "No updates available to install."
        }
        
        return ($output -join "")
    }
    catch {
        return "Error installing Windows Updates: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function GatherUpdates, Install-MissingUpdates
