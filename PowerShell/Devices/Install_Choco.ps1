#############################################
#                                           #                       
#          Script by Bert de Zeeuw          #
#    visit https://github.com/Cavanite      # 
#                                           #                       
#############################################

# Check if Chocolatey is installed
if (-Not (Get-Command -Name choco -ErrorAction SilentlyContinue)) {
    # Chocolatey is not installed
    # Script must be started with Administrator Privileges.
    $ProgressPreference = 'SilentlyContinue'
    Write-Information "Installing Chocolatey..."

    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Verify installation
    if (Get-Command -Name choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey successfully installed."
    } else {
        Write-Host "Chocolatey installation failed."
    }
} else {
    # Chocolatey is installed, check version
    $installedChocoVersion = [version](choco -v)
    $requiredVersion = [version]"2.4.3"

    if ($installedChocoVersion -lt $requiredVersion) {
        Write-Host "Updating Chocolatey to version $requiredVersion..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey updated successfully."
    } else {
        Write-Host "Chocolatey is up to date (Version: $installedChocoVersion)."
    }
}