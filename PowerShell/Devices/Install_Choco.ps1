# Check Choco is installed
if (-Not (Get-Command -Name Choco -ErrorAction SilentlyContinue)) {
    # Script by Cavanite
    # Choco is not installed
    # Script must a started with Administrator Privilages.
          $progressPreference = 'silentlyContinue'
Write-Information "Installing Chocolatey"
 

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
 
    # Install succesfull?
    if ($?) {
        Write-Host "Choco succesfully installed"
    } else {
        Write-Host "Choco failed to install"
    }
} else {
    Write-Host "Choco is already installed."
}