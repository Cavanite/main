
function GatherEnrollmentstate {

    $dsregStatus = dsregcmd /status | Out-String
    return $dsregStatus
}

function Invoke-MdmRefresh {
    $output = @()
    
    try {
        # Leave current workplace join
        $output += "Leaving current workplace enrollment...`n"
        $leaveResult = dsregcmd /leave 2>&1
        $output += "Leave result: $leaveResult`n`n"
        
        # Wait a moment for the leave operation to complete
        Start-Sleep -Seconds 3
        
        # Rejoin workplace
        $output += "Rejoining workplace...`n"
        $joinResult = dsregcmd /join 2>&1
        $output += "Join result: $joinResult`n`n"
        
        # Wait for enrollment to complete
        Start-Sleep -Seconds 5
        
        $output += "MDM Refresh completed.`n`n"
        
        # Get updated enrollment state
        $dsregStatus = dsregcmd /status | Out-String
        $output += $dsregStatus
    }
    catch {
        $output += "Error executing MDM Refresh: $_`n"
    }
    
    return ($output -join "")
}

Export-ModuleMember -Function GatherEnrollmentstate, Invoke-MdmRefresh