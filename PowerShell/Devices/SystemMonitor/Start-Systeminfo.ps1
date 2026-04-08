#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
    [string]$LogLevel = 'Information',

    [Parameter()]
    [string]$ConfigPath
)

# Check if running as administrator, if not, restart with UAC prompt
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Restart the script with administrator privileges
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($LogLevel) { $arguments += " -LogLevel $LogLevel" }
    if ($ConfigPath) { $arguments += " -ConfigPath `"$ConfigPath`"" }
    
    Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
    exit
}

# Hide PowerShell console window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) | Out-Null

# Set up PowerShell runspace for MSAL (required for MSAL.NET to work properly)
if (-not [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace) {
    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $runspace.ApartmentState = 'STA'
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.Open()
    [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace = $runspace
}

$ErrorActionPreference = 'Stop'

#region Script Initialization
$ScriptRoot = $PSScriptRoot
$ModulesPath = Join-Path -Path $ScriptRoot -ChildPath 'Modules'
$ResourcesPath = Join-Path -Path $ScriptRoot -ChildPath 'Resources'

# Add required assemblies for WPF
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms


# Import modules
$modules = @(
    'GatherSysteminfo',
    'GatherDiskinfo',
    'GatherEnrollmentstate',
    'GatherUpdates',
    'GatherCPUGraph'
)

foreach ($module in $modules) {
    $modulePath = Join-Path -Path $ModulesPath -ChildPath "$module.psm1"
    if (Test-Path -Path $modulePath) {
        Import-Module $modulePath -Force -DisableNameChecking
        Write-Verbose "Imported module: $module"
    }
    else {
        throw "Required module not found: $modulePath"
    }
}

# Create the main window
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="System Monitor" Height="600" Width="800"
    WindowStartupLocation="CenterScreen">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        
        <TextBlock Grid.Row="0" Text="System Monitor" 
               FontSize="24" FontWeight="Bold" 
               HorizontalAlignment="Center" Margin="10"/>
        
        <TabControl Grid.Row="1" Name="MainTabControl" Margin="10">
            <TabItem Header="System Information" Name="SystemInfoTab">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Grid.Row="0" Name="SystemInfoTextBox" 
                         IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="12"
                         Margin="5"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="5">
                        <Button Name="ClearSystemBtn" Content="Clear Output" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="RefreshSystemBtn" Content="Refresh" 
                            Width="120" Height="30" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            
            <TabItem Header="CPU Graph" Name="CPUGraphTab">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Grid.Row="0" Name="CPUGraphTextBox" 
                         IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="12"
                         Margin="5"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="5">
                        <Button Name="ClearCPUBtn" Content="Clear Output" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="RefreshCPUBtn" Content="Refresh" 
                            Width="120" Height="30" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            
            <TabItem Header="Disk Information" Name="DiskInfoTab">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Grid.Row="0" Name="DiskInfoTextBox" 
                         IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="12"
                         Margin="5"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="5">
                        <Button Name="ClearDiskBtn" Content="Clear Output" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="RefreshDiskBtn" Content="Refresh" 
                            Width="120" Height="30" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            
            <TabItem Header="Enrollment State" Name="EnrollmentTab">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Grid.Row="0" Name="EnrollmentTextBox" 
                         IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="12"
                         Margin="5"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="5">
                        <Button Name="ClearEnrollmentBtn" Content="Clear Output" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="MdmRefreshBtn" Content="MDM Refresh" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="RefreshEnrollmentBtn" Content="Refresh" 
                            Width="120" Height="30" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            
            <TabItem Header="Windows Updates" Name="UpdatesTab">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Grid.Row="0" Name="UpdatesTextBox" 
                         IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="12"
                         Margin="5"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="5">
                        <Button Name="ClearUpdatesBtn" Content="Clear Output" 
                            Width="120" Height="30" Margin="5"/>
                        <Button Name="InstallUpdatesBtn" Content="Install Missing Updates" 
                            Width="150" Height="30" Margin="5"/>
                        <Button Name="RefreshUpdatesBtn" Content="Refresh" 
                            Width="120" Height="30" Margin="5"/>
                    </StackPanel>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

# Create window from XAML
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get controls
$mainTabControl = $window.FindName("MainTabControl")
$systemInfoTextBox = $window.FindName("SystemInfoTextBox")
$diskInfoTextBox = $window.FindName("DiskInfoTextBox")
$enrollmentTextBox = $window.FindName("EnrollmentTextBox")
$updatesTextBox = $window.FindName("UpdatesTextBox")
$cpuGraphTextBox = $window.FindName("CPUGraphTextBox")

$refreshSystemBtn = $window.FindName("RefreshSystemBtn")
$refreshDiskBtn = $window.FindName("RefreshDiskBtn")
$refreshEnrollmentBtn = $window.FindName("RefreshEnrollmentBtn")
$refreshUpdatesBtn = $window.FindName("RefreshUpdatesBtn")
$mdmRefreshBtn = $window.FindName("MdmRefreshBtn")
$installUpdatesBtn = $window.FindName("InstallUpdatesBtn")
$refreshCPUBtn = $window.FindName("RefreshCPUBtn")

$clearSystemBtn = $window.FindName("ClearSystemBtn")
$clearDiskBtn = $window.FindName("ClearDiskBtn")
$clearEnrollmentBtn = $window.FindName("ClearEnrollmentBtn")
$clearUpdatesBtn = $window.FindName("ClearUpdatesBtn")
$clearCPUBtn = $window.FindName("ClearCPUBtn")

# Track which tabs have been loaded
$script:tabsLoaded = @{
    'SystemInfoTab' = $false
    'DiskInfoTab'   = $false
    'EnrollmentTab' = $false
    'UpdatesTab'    = $false
    'CPUGraphTab'   = $false
}

# Tab selection changed event - auto-load data when tab is clicked
$mainTabControl.Add_SelectionChanged({
        $selectedTab = $mainTabControl.SelectedItem
        if ($selectedTab -eq $null) { return }
    
        $tabName = $selectedTab.Name
    
        # Only load data if tab hasn't been loaded yet
        if (-not $script:tabsLoaded[$tabName]) {
            switch ($tabName) {
                "SystemInfoTab" {
                    $systemInfoTextBox.Clear()
                    $systemInfo = GatherSysteminfo
                    $systemInfoTextBox.AppendText($systemInfo)
                    $script:tabsLoaded[$tabName] = $true
                }
                "DiskInfoTab" {
                    $diskInfoTextBox.Clear()
                    $diskInfo = GatherDiskinfo
                    $diskInfoTextBox.AppendText($diskInfo)
                    $script:tabsLoaded[$tabName] = $true
                }
                "EnrollmentTab" {
                    $enrollmentTextBox.Clear()
                    $enrollmentState = GatherEnrollmentstate
                    $enrollmentTextBox.AppendText($enrollmentState)
                    $script:tabsLoaded[$tabName] = $true
                }
                "UpdatesTab" {
                    $updatesTextBox.Clear()
                    $updatesTextBox.AppendText("Gathering Windows Updates, please be patient...`n`n")
                
                    # Force UI to update immediately
                    $window.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
                
                    try {
                        $updates = GatherUpdates
                        $updatesTextBox.Clear()
                        if ($updates) {
                            $updatesString = $updates | Out-String
                            $updatesTextBox.AppendText($updatesString)
                        }
                        else {
                            $updatesTextBox.AppendText("No updates found.`n")
                        }
                    }
                    catch {
                        $updatesTextBox.Clear()
                        $updatesTextBox.AppendText("Error gathering updates: $_`n")
                    }
                    $script:tabsLoaded[$tabName] = $true
                }
                "CPUGraphTab" {
                    $cpuGraphTextBox.Clear()
                    $cpuGraph = GatherCPUGraph
                    $cpuGraphTextBox.AppendText($cpuGraph)
                    $script:tabsLoaded[$tabName] = $true
                }
            }
        }
    })

# Event handlers for refresh buttons - reset loaded flag and reload
$refreshSystemBtn.Add_Click({
        $systemInfoTextBox.Clear()
        $systemInfo = GatherSysteminfo
        $systemInfoTextBox.AppendText($systemInfo)
        $script:tabsLoaded['SystemInfoTab'] = $true
    })

$refreshDiskBtn.Add_Click({
        $diskInfoTextBox.Clear()
        $diskInfo = GatherDiskinfo
        $diskInfoTextBox.AppendText($diskInfo)
        $script:tabsLoaded['DiskInfoTab'] = $true
    })

$refreshEnrollmentBtn.Add_Click({
        $enrollmentTextBox.Clear()
        $enrollmentState = GatherEnrollmentstate
        $enrollmentTextBox.AppendText($enrollmentState)
        $script:tabsLoaded['EnrollmentTab'] = $true
    })

$mdmRefreshBtn.Add_Click({
        $enrollmentTextBox.Clear()
        $enrollmentTextBox.AppendText("Executing MDM Refresh, please wait...`n`n")
        
        # Force UI to update immediately
        $window.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
        
        try {
            # Execute MDM sync
            $result = & "C:\Windows\System32\DeviceEnroller.exe" /o /c
            
            $enrollmentTextBox.AppendText("MDM Refresh completed.`n`n")
            
            # Refresh enrollment state after MDM sync
            Start-Sleep -Seconds 2
            $enrollmentState = GatherEnrollmentstate
            $enrollmentTextBox.AppendText($enrollmentState)
        }
        catch {
            $enrollmentTextBox.Clear()
            $enrollmentTextBox.AppendText("Error executing MDM Refresh: $_`n")
        }
    })

$refreshUpdatesBtn.Add_Click({
        $updatesTextBox.Clear()
        $updatesTextBox.AppendText("Gathering Windows Updates, please be patient...`n`n")
    
        # Force UI to update immediately
        $window.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
    
        try {
            $updates = GatherUpdates
            $updatesTextBox.Clear()
            if ($updates) {
                $updatesString = $updates | Out-String
                $updatesTextBox.AppendText($updatesString)
            }
            else {
                $updatesTextBox.AppendText("No updates found.`n")
            }
        }
        catch {
            $updatesTextBox.Clear()
            $updatesTextBox.AppendText("Error gathering updates: $_`n")
        }
        $script:tabsLoaded['UpdatesTab'] = $true
    })

$installUpdatesBtn.Add_Click({
        $updatesTextBox.Clear()
        $updatesTextBox.AppendText("Installing Windows Updates, please be patient...`n`n")
        $updatesTextBox.AppendText("This may take several minutes depending on the number of updates.`n`n")
        
        # Force UI to update immediately
        $window.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
        
        $result = Install-MissingUpdates
        $updatesTextBox.Clear()
        $updatesTextBox.AppendText($result)
        
        # Mark tab as needing refresh
        $script:tabsLoaded['UpdatesTab'] = $false
    })

$refreshCPUBtn.Add_Click({
        $cpuGraphTextBox.Clear()
        $cpuGraph = GatherCPUGraph
        $cpuGraphTextBox.AppendText($cpuGraph)
        $script:tabsLoaded['CPUGraphTab'] = $true
    })

# Clear Output button event handlers
$clearSystemBtn.Add_Click({
        $systemInfoTextBox.Clear()
    })

$clearDiskBtn.Add_Click({
        $diskInfoTextBox.Clear()
    })

$clearEnrollmentBtn.Add_Click({
        $enrollmentTextBox.Clear()
    })

$clearUpdatesBtn.Add_Click({
        $updatesTextBox.Clear()
    })

$clearCPUBtn.Add_Click({
        $cpuGraphTextBox.Clear()
    })

# Load initial data for System Information tab
$systemInfo = GatherSysteminfo
$systemInfoTextBox.AppendText($systemInfo)
$script:tabsLoaded['SystemInfoTab'] = $true

# Show the window
$window.ShowDialog() | Out-Null

