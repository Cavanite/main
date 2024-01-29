#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

Function Measure-NetworkSpeed{
    param(
        [Parameter(Mandatory=$false)]
        [string]$continues
    )
    # The test file has to be a 10MB file for the math to work. If you want to change sizes, modify the math to match
    $TestFile  = 'https://ftp.sunet.se/mirror/parrotsec.org/parrot/misc/10MB.bin'
    $TempFile  = Join-Path -Path $env:TEMP -ChildPath 'testfile.tmp'
    $WebClient = New-Object Net.WebClient
    $TimeTaken = Measure-Command { $WebClient.DownloadFile($TestFile,$TempFile) } | Select-Object -ExpandProperty TotalSeconds
    $SpeedMbps = (10 / $TimeTaken) * 8
    $Message = "{0:N2} Mbit/sec" -f ($SpeedMbps)
    $Message

    if ($continues -eq "true") {
        while ($true) {
           Measure-NetworkSpeed
        }
    }
    else {
        Write-Host "Measuring network speed once..."
        Measure-NetworkSpeed
    }
}

