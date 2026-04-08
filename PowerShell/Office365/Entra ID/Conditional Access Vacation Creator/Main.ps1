#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
    [string]$LogLevel = 'Information',

    [Parameter()]
    [string]$ConfigPath
)

<#
Purpose: This script will create a Conditional Access policy in Entra ID (Azure AD) to block access for users who are on vacation.
the script will ask the following:
- Which users should be included in the policy (multi-select)
- Which Country the users will be traveling to (single select)
the inputs will be exported to a JSON file so the settings can be imported in Conditional Access policies.
#>

#Script information


#######################################################################################################

#######################################################################################################
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
    Title="Conditional Access Vacation Creator" Height="650" Width="900"
    WindowStartupLocation="CenterScreen" Topmost="True">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Header -->
        <TextBlock Grid.Row="0" Text="Conditional Access Vacation Creator" 
                   FontSize="24" FontWeight="Bold" 
                   HorizontalAlignment="Center" Margin="10"/>
        
        <!-- Main Content Area -->
        <Grid Grid.Row="1" Margin="10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            
            <!-- Left Panel - User Selection -->
            <GroupBox Grid.Column="0" Header="Select Users on Vacation" 
                      FontSize="14" FontWeight="Bold">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <!-- Manual Username Input -->
                    <GroupBox Grid.Row="0" Header="Add Username Manually" Margin="5">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            
                            <TextBlock Grid.Row="0" 
                                       Text="Paste or type username (e.g., user@domain.com):" 
                                       Margin="5,5,5,2" FontSize="11"/>
                            
                            <Grid Grid.Row="1">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                
                                <TextBox Grid.Column="0" Name="UsernameInputBox" 
                                         Height="25" Margin="5,0,5,5"
                                         VerticalContentAlignment="Center"/>
                                
                                <Button Grid.Column="1" Name="AddUsernameBtn" 
                                        Content="Add" Width="60" Height="25" 
                                        Margin="0,0,5,5"/>
                            </Grid>
                        </Grid>
                    </GroupBox>
                    
                    <TextBlock Grid.Row="1" Text="Or select from list:" 
                               Margin="5,5,5,2" FontSize="11"/>
                    
                    <ListBox Grid.Row="2" Name="UsersListBox" 
                             SelectionMode="Multiple"
                             Margin="5"
                             VerticalAlignment="Stretch"/>
                    
                    <Grid Grid.Row="3" Margin="5">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <StackPanel Grid.Row="0" Orientation="Horizontal">
                            <Button Name="RefreshUsersBtn" Content="Refresh Users" 
                                    Width="120" Height="30" Margin="5"/>
                            <Button Name="SelectAllUsersBtn" Content="Select All" 
                                    Width="100" Height="30" Margin="5"/>
                            <Button Name="ClearUsersBtn" Content="Clear Selection" 
                                    Width="120" Height="30" Margin="5"/>
                            <Border Name="ConnectionStatusBorder" 
                                    BorderBrush="Gray" BorderThickness="1" 
                                    CornerRadius="3" Padding="10,5" Margin="5,5,5,5"
                                    Background="#F0F0F0">
                                <TextBlock Name="ConnectionStatusText" 
                                           Text="Not Connected" 
                                           FontSize="11" FontWeight="Bold"
                                           Foreground="Gray" 
                                           VerticalAlignment="Center"/>
                            </Border>
                        </StackPanel>
                        
                        <Button Grid.Row="1" Name="SignInBtn" Content="Sign In to Microsoft Graph" 
                                Height="35" Margin="5" FontWeight="Bold"
                                Background="#0078D4" Foreground="White"/>
                        
                        <Button Grid.Row="1" Name="DisconnectBtn" Content="Disconnect" 
                                Height="35" Margin="5" FontWeight="Bold"
                                Background="#D13438" Foreground="White"
                                Visibility="Collapsed"/>
                    </Grid>
                </Grid>
            </GroupBox>
            
            <!-- Right Panel - Country and Policy Details -->
            <Grid Grid.Column="2">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                
                <!-- Country Selection -->
                <GroupBox Grid.Row="0" Header="Vacation Destination" 
                          FontSize="14" FontWeight="Bold" Margin="0,0,0,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Grid.Row="0" Text="Select the country the user(s) will be traveling to:" 
                                   Margin="5" TextWrapping="Wrap"/>
                        
                        <ComboBox Grid.Row="1" Name="CountryComboBox" 
                                  Margin="5" Height="30"
                                  IsEditable="True"
                                  IsTextSearchEnabled="True"/>
                    </Grid>
                </GroupBox>
                
                <!-- Existing Geofencing Policy -->
                <GroupBox Grid.Row="1" Header="Main Geofencing Policy" 
                          FontSize="14" FontWeight="Bold" Margin="0,0,0,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Grid.Row="0" Text="Select the main CA policy to exclude users from:" 
                                   Margin="5" TextWrapping="Wrap"/>
                        
                        <ComboBox Grid.Row="1" Name="ExistingPolicyComboBox" 
                                  Margin="5" Height="30"
                                  IsEditable="True"
                                  IsTextSearchEnabled="True"/>
                    </Grid>
                </GroupBox>
                
                <!-- Policy Details -->
                <GroupBox Grid.Row="2" Header="Policy Details" 
                          FontSize="14" FontWeight="Bold" Margin="0,0,0,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Grid.Row="0" Text="Ticket Number:" Margin="5,5,5,2"/>
                        <TextBox Grid.Row="1" Name="TicketNumberTextBox" 
                                 Margin="5,0,5,5" Height="25"/>
                        
                        <TextBlock Grid.Row="2" Text="End Date (dd-mm-yyyy):" Margin="5,5,5,2"/>
                        <TextBox Grid.Row="3" Name="EndDateTextBox" 
                                 Margin="5,0,5,5" Height="25"/>
                        
                        <TextBlock Grid.Row="4" Text="Policy Name:" Margin="5,5,5,2"/>
                        <TextBox Grid.Row="5" Name="PolicyNameTextBox" 
                                 Margin="5,0,5,5" Height="25" IsReadOnly="True"
                                 Background="#F0F0F0"/>
                    </Grid>
                </GroupBox>
                
                <!-- Output/Status Area -->
                <GroupBox Grid.Row="3" Header="Status" 
                          FontSize="14" FontWeight="Bold">
                    <TextBox Name="StatusTextBox" 
                             IsReadOnly="True" 
                             VerticalScrollBarVisibility="Auto"
                             HorizontalScrollBarVisibility="Auto"
                             FontFamily="Consolas" FontSize="12"
                             Margin="5"
                             TextWrapping="Wrap"
                             MinHeight="150"/>
                </GroupBox>
            </Grid>
        </Grid>
        
        <!-- Action Buttons and Contact Info -->
        <Grid Grid.Row="2" Margin="10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            
            <!-- Contact Information -->
            <StackPanel Grid.Column="0" VerticalAlignment="Center">
                <TextBlock Text="Written by: Bert de Zeeuw - Bizway BV" FontSize="11" FontWeight="Bold"/>
                <TextBlock Text="Email: b.dezeeuw@bizway.nl" FontSize="10" Foreground="Gray"/>
            </StackPanel>
            
            <!-- Action Buttons -->
            <StackPanel Grid.Column="1" Orientation="Horizontal">
                <Button Name="CreatePolicyBtn" Content="Create CA Policy" 
                        Width="140" Height="35" Margin="5"
                        FontWeight="Bold"/>
                <Button Name="CloseBtn" Content="Close" 
                        Width="100" Height="35" Margin="5"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

# Parse XAML and create window
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get references to UI elements
$UsersListBox = $window.FindName("UsersListBox")
$UsernameInputBox = $window.FindName("UsernameInputBox")
$AddUsernameBtn = $window.FindName("AddUsernameBtn")
$CountryComboBox = $window.FindName("CountryComboBox")
$ExistingPolicyComboBox = $window.FindName("ExistingPolicyComboBox")
$TicketNumberTextBox = $window.FindName("TicketNumberTextBox")
$EndDateTextBox = $window.FindName("EndDateTextBox")
$PolicyNameTextBox = $window.FindName("PolicyNameTextBox")
$PolicyDescriptionTextBox = $window.FindName("PolicyDescriptionTextBox")
$StatusTextBox = $window.FindName("StatusTextBox")
$RefreshUsersBtn = $window.FindName("RefreshUsersBtn")
$SelectAllUsersBtn = $window.FindName("SelectAllUsersBtn")
$ClearUsersBtn = $window.FindName("ClearUsersBtn")
$CreatePolicyBtn = $window.FindName("CreatePolicyBtn")
$CloseBtn = $window.FindName("CloseBtn")
$SignInBtn = $window.FindName("SignInBtn")
$DisconnectBtn = $window.FindName("DisconnectBtn")
$ConnectionStatusBorder = $window.FindName("ConnectionStatusBorder")
$ConnectionStatusText = $window.FindName("ConnectionStatusText")

# Global variable to track Graph connection status
$script:GraphConnected = $false
$script:UserCache = @{}
$script:NamedLocationsCache = @{}
$script:CAPoliciesCache = @{}

# Disable country combobox until signed in
$CountryComboBox.IsEnabled = $false
$ExistingPolicyComboBox.IsEnabled = $false

# Function to check and install Microsoft.Graph module
function Ensure-GraphModule {
    $requiredModules = @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Users', 'Microsoft.Graph.Identity.SignIns')
    
    foreach ($moduleName in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $moduleName)) {
            Add-StatusMessage "Installing $moduleName..."
            try {
                Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber
                Add-StatusMessage "Successfully installed $moduleName"
            } catch {
                Add-StatusMessage "ERROR: Failed to install $moduleName - $($_.Exception.Message)"
                throw
            }
        }
    }
}

# Add status message helper
function Add-StatusMessage {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $StatusTextBox.AppendText("[$timestamp] $Message`r`n")
    $StatusTextBox.ScrollToEnd()
}

# Function to update policy name based on selected users
function Update-PolicyName {
    $selectedUsers = $UsersListBox.SelectedItems
    $selectedCountry = $CountryComboBox.SelectedItem
    $ticketNumber = $TicketNumberTextBox.Text.Trim()
    $endDate = $EndDateTextBox.Text.Trim()
    
    # Set placeholders if empty
    if ([string]::IsNullOrWhiteSpace($ticketNumber)) { $ticketNumber = "TICKETNUMBER" }
    if ([string]::IsNullOrWhiteSpace($endDate)) { $endDate = "ENDDATE" }
    if ([string]::IsNullOrWhiteSpace($selectedCountry)) { $selectedCountry = "COUNTRY" }
    
    if ($selectedUsers.Count -eq 0) {
        $PolicyNameTextBox.Text = "GEO-USERNAME-$selectedCountry-$ticketNumber-$endDate-VACATIONMODE"
    }
    elseif ($selectedUsers.Count -eq 1) {
        # Extract username from display format "Name (upn)"
        $userText = $selectedUsers[0]
        if ($userText -match '\((.+?)\)') {
            $username = ($matches[1] -split '@')[0]
        } else {
            $username = ($userText -split '@')[0]
        }
        $PolicyNameTextBox.Text = "GEO-$username-$selectedCountry-$ticketNumber-$endDate-VACATIONMODE"
    }
    else {
        # Multiple users - use first username
        $userText = $selectedUsers[0]
        if ($userText -match '\((.+?)\)') {
            $username = ($matches[1] -split '@')[0]
        } else {
            $username = ($userText -split '@')[0]
        }
        $PolicyNameTextBox.Text = "GEO-$username-Plus$($selectedUsers.Count - 1)-$selectedCountry-$ticketNumber-$endDate-VACATIONMODE"
    }
}

Add-StatusMessage "Application started. Please select users and destination country."

# Set default policy name
$PolicyNameTextBox.Text = "GEO-USERNAME-COUNTRY-TICKETNUMBER-dd-mm-yyyy-VACATIONMODE"

# Disable Refresh Users button until signed in
$RefreshUsersBtn.IsEnabled = $false

# Button Event Handlers
$AddUsernameBtn.Add_Click({
    $username = $UsernameInputBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($username)) {
        Add-StatusMessage "Please enter a username."
        return
    }
    
    # Check if username already exists in the list
    if ($UsersListBox.Items -contains $username) {
        Add-StatusMessage "User '$username' is already in the list."
        $UsernameInputBox.Clear()
        return
    }
    
    # Try to fetch user from Graph to get their GUID
    if ($script:GraphConnected) {
        try {
            $user = Get-MgUser -Filter "userPrincipalName eq '$username'" -Property Id,DisplayName,UserPrincipalName
            if ($user) {
                $displayText = "$($user.DisplayName) ($($user.UserPrincipalName))"
                $script:UserCache[$displayText] = $user.Id
                $UsersListBox.Items.Add($displayText) | Out-Null
                Add-StatusMessage "Added user: $displayText"
            } else {
                $UsersListBox.Items.Add($username) | Out-Null
                Add-StatusMessage "WARNING: Added '$username' but user not found in Entra ID."
            }
        } catch {
            $UsersListBox.Items.Add($username) | Out-Null
            Add-StatusMessage "WARNING: Could not verify user: $($_.Exception.Message)"
        }
    } else {
        $UsersListBox.Items.Add($username) | Out-Null
        Add-StatusMessage "Added user: $username (not verified - please sign in to Graph)"
    }
    
    # Clear the input box
    $UsernameInputBox.Clear()
    $UsernameInputBox.Focus()
})

# Allow Enter key to add username
$UsernameInputBox.Add_KeyDown({
    if ($_.Key -eq 'Return') {
        $AddUsernameBtn.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    }
})

# Update policy name when selection changes
$UsersListBox.Add_SelectionChanged({
    Update-PolicyName
})

# Update policy name when country changes
$CountryComboBox.Add_SelectionChanged({
    Update-PolicyName
})

# Update policy name when ticket number changes
$TicketNumberTextBox.Add_TextChanged({
    Update-PolicyName
})

# Update policy name when end date changes
$EndDateTextBox.Add_TextChanged({
    Update-PolicyName
})

$SignInBtn.Add_Click({
    try {
        Add-StatusMessage "Checking Microsoft Graph modules..."
        Ensure-GraphModule
        
        Add-StatusMessage "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "User.Read.All", "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess" -NoWelcome
        
        $context = Get-MgContext
        if ($context) {
            $script:GraphConnected = $true
            Add-StatusMessage "SUCCESS: Connected as $($context.Account)"
            
            # Hide Sign In button and show Disconnect button
            $SignInBtn.Visibility = "Collapsed"
            $DisconnectBtn.Visibility = "Visible"
            
            # Update connection status
            $ConnectionStatusText.Text = "Connected"
            $ConnectionStatusText.Foreground = "White"
            $ConnectionStatusBorder.Background = "#107C10"
            $ConnectionStatusBorder.BorderBrush = "#107C10"
            
            $RefreshUsersBtn.IsEnabled = $true
            
            # Fetch Named Locations
            Add-StatusMessage "Loading named locations..."
            try {
                $namedLocations = Get-MgIdentityConditionalAccessNamedLocation -All
                
                # Clear the cache and repopulate
                $script:NamedLocationsCache = @{}
                
                $CountryComboBox.Items.Clear()
                foreach ($location in $namedLocations) {
                    # Store location ID in cache with display name as key
                    $script:NamedLocationsCache[$location.DisplayName] = $location.Id
                    $CountryComboBox.Items.Add($location.DisplayName) | Out-Null
                }
                
                $CountryComboBox.IsEnabled = $true
                Add-StatusMessage "SUCCESS: Loaded $($namedLocations.Count) named locations"
            } catch {
                Add-StatusMessage "ERROR: Failed to load named locations - $($_.Exception.Message)"
            }
            
            # Fetch Conditional Access Policies
            Add-StatusMessage "Loading Conditional Access policies..."
            try {
                $caPolicies = Get-MgIdentityConditionalAccessPolicy -All
                
                # Check for geofencing or country blocklist policies
                $geofencingPolicies = $caPolicies | Where-Object {
                    $_.DisplayName -like '*geofenc*' -or 
                    $_.DisplayName -like '*country*' -or 
                    $_.DisplayName -like '*blocklist*' -or
                    $_.DisplayName -like '*block*list*' -or
                    $_.DisplayName -like '*location*'
                }
                
                if ($geofencingPolicies.Count -eq 0) {
                    Add-StatusMessage "ERROR: No geofencing or country blocklist policy found!"
                    [System.Windows.MessageBox]::Show("No geofencing or country blocklist Conditional Access policy was found in your tenant.`n`nThis tool requires an existing main geofencing policy to function properly.`n`nPlease contact Bert de Zeeuw at b.dezeeuw@bizway.nl to set up the required infrastructure.", "Configuration Required", "OK", "Error")
                    
                    # Disable policy creation
                    $ExistingPolicyComboBox.IsEnabled = $false
                    $CreatePolicyBtn.IsEnabled = $false
                    return
                }
                
                # Clear the cache and repopulate
                $script:CAPoliciesCache = @{}
                
                $ExistingPolicyComboBox.Items.Clear()
                foreach ($policy in $caPolicies) {
                    # Store policy ID in cache with display name as key
                    $script:CAPoliciesCache[$policy.DisplayName] = $policy.Id
                    $ExistingPolicyComboBox.Items.Add($policy.DisplayName) | Out-Null
                }
                
                $ExistingPolicyComboBox.IsEnabled = $true
                Add-StatusMessage "SUCCESS: Loaded $($caPolicies.Count) CA policies ($($geofencingPolicies.Count) geofencing policies found)"
            } catch {
                Add-StatusMessage "ERROR: Failed to load CA policies - $($_.Exception.Message)"
            }
        }
    } catch {
        Add-StatusMessage "ERROR: Sign in failed - $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Failed to connect to Microsoft Graph: $($_.Exception.Message)", "Sign In Error", "OK", "Error")
    }
})

$RefreshUsersBtn.Add_Click({
    if (-not $script:GraphConnected) {
        Add-StatusMessage "ERROR: Please sign in to Microsoft Graph first."
        [System.Windows.MessageBox]::Show("Please sign in to Microsoft Graph first.", "Not Connected", "OK", "Warning")
        return
    }
    
    try {
        Add-StatusMessage "Fetching users from Entra ID..."
        $users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName | Select-Object Id,DisplayName,UserPrincipalName
        
        # Filter patterns for admin and breakglass accounts
        $excludePatterns = @(
            '*admin*',
            '*administrator*',
            '*breakglass*',
            '*break-glass*',
            '*break.glass*',
            '*emergency*',
            '*emerg*',
            '*privileged*',
            '*service*',
            '*svc*',
            '*system*'
        )
        
        # Clear and populate the cache as a hashtable
        $script:UserCache = @{}
        $UsersListBox.Items.Clear()
        
        $filteredCount = 0
        foreach ($user in $users) {
            # Check if user is external (contains #EXT# in UPN)
            $isExternal = $user.UserPrincipalName -like '*#EXT#*'
            
            # Check if user matches any exclusion pattern
            $shouldExclude = $false
            foreach ($pattern in $excludePatterns) {
                if (($user.DisplayName -like $pattern) -or ($user.UserPrincipalName -like $pattern)) {
                    $shouldExclude = $true
                    break
                }
            }
            
            # Exclude if external or matches exclusion pattern
            if ($isExternal -or $shouldExclude) {
                $filteredCount++
            }
            # Exclude if external or matches exclusion pattern
            if ($isExternal -or $shouldExclude) {
                $filteredCount++
            } else {
                # Only add internal, non-admin/non-breakglass users
                $displayText = "$($user.DisplayName) ($($user.UserPrincipalName))"
                # Store GUID with display text as key
                $script:UserCache[$displayText] = $user.Id
                $UsersListBox.Items.Add($displayText) | Out-Null
            }
        }
        
        Add-StatusMessage "SUCCESS: Loaded $($UsersListBox.Items.Count) users from Entra ID ($filteredCount admin/service/external accounts filtered)"
    } catch {
        Add-StatusMessage "ERROR: Failed to fetch users - $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Failed to fetch users: $($_.Exception.Message)", "Error", "OK", "Error")
    }
})

$SelectAllUsersBtn.Add_Click({
    $UsersListBox.SelectAll()
    Add-StatusMessage "All users selected."
})

$ClearUsersBtn.Add_Click({
    $UsersListBox.UnselectAll()
    Add-StatusMessage "Selection cleared."
})

$CreatePolicyBtn.Add_Click({
    try {
        # Validate required fields
        $selectedUsers = $UsersListBox.SelectedItems
        $selectedCountry = $CountryComboBox.SelectedItem
        $ticketNumber = $TicketNumberTextBox.Text.Trim()
        $endDate = $EndDateTextBox.Text.Trim()
        $policyName = $PolicyNameTextBox.Text.Trim()
        
        # Validate user selection
        if ($selectedUsers.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Please select at least one user.", "Validation Error", "OK", "Warning")
            return
        }
        
        # Validate country selection
        if ([string]::IsNullOrWhiteSpace($selectedCountry)) {
            [System.Windows.MessageBox]::Show("Please select a vacation destination (Named Location).", "Validation Error", "OK", "Warning")
            return
        }
        
        # Validate ticket number
        if ([string]::IsNullOrWhiteSpace($ticketNumber)) {
            [System.Windows.MessageBox]::Show("Please enter a ticket number.", "Validation Error", "OK", "Warning")
            return
        }
        
        # Validate end date
        if ([string]::IsNullOrWhiteSpace($endDate)) {
            [System.Windows.MessageBox]::Show("Please enter an end date (dd-mm-yyyy).", "Validation Error", "OK", "Warning")
            return
        }
        
        # Validate date format (dd-mm-yyyy)
        if ($endDate -notmatch '^\d{2}-\d{2}-\d{4}$') {
            [System.Windows.MessageBox]::Show("Invalid date format. Please use dd-mm-yyyy format (e.g., 31-12-2026).", "Validation Error", "OK", "Warning")
            return
        }
        
        # Validate existing policy selection
        $selectedExistingPolicy = $ExistingPolicyComboBox.SelectedItem
        if ([string]::IsNullOrWhiteSpace($selectedExistingPolicy)) {
            $result = [System.Windows.MessageBox]::Show("No main geofencing policy selected. Users will NOT be excluded from any existing policy.`n`nDo you want to continue?", "Warning", "YesNo", "Warning")
            if ($result -ne "Yes") {
                return
            }
        }
        
        # Check Graph connection
        if (-not $script:graphConnected) {
            [System.Windows.MessageBox]::Show("Please sign in to Microsoft Graph first.", "Authentication Required", "OK", "Warning")
            return
        }
        
        # Get location ID from cache
        $locationId = $null
        if ($script:namedLocationsCache.ContainsKey($selectedCountry)) {
            $locationId = $script:namedLocationsCache[$selectedCountry]
        }
        
        if ([string]::IsNullOrWhiteSpace($locationId)) {
            Add-StatusMessage "ERROR: Could not find location ID for: $selectedCountry"
            [System.Windows.MessageBox]::Show("Could not find location ID for selected country.", "Error", "OK", "Error")
            return
        }
        
        # Build confirmation message
        $userList = $selectedUsers -join "`n  - "
        $confirmMessage = @"
Are you sure you want to create this Conditional Access Policy?

Policy Name: $policyName
Ticket Number: $ticketNumber
End Date: $endDate

Users ($($selectedUsers.Count)):
  - $userList

Vacation Location: $selectedCountry

This policy will:
- BLOCK access from all locations EXCEPT the vacation destination
- Be created in DISABLED state for review
- Require manual enablement after verification

Do you want to proceed?
"@
        
        # Show confirmation dialog
        $result = [System.Windows.MessageBox]::Show($confirmMessage, "Confirm Policy Creation", "YesNo", "Question")
        
        if ($result -ne "Yes") {
            Add-StatusMessage "Policy creation cancelled by user."
            return
        }
        
        Add-StatusMessage "Creating Conditional Access policy..."
        
        # Map user display names to GUIDs
        $userGuids = @()
        foreach ($userDisplay in $selectedUsers) {
            if ($script:UserCache.ContainsKey($userDisplay)) {
                $userGuids += $script:UserCache[$userDisplay]
            } else {
                Add-StatusMessage "WARNING: Could not find GUID for user: $userDisplay"
            }
        }
        
        if ($userGuids.Count -eq 0) {
            Add-StatusMessage "ERROR: No valid user GUIDs found."
            [System.Windows.MessageBox]::Show("Could not find GUIDs for selected users. Please refresh the user list.", "Error", "OK", "Error")
            return
        }
        
        # Build the policy object
        $policyObject = @{
            "displayName" = $policyName
            "state" = "disabled"
            "conditions" = @{
                "applications" = @{
                    "includeApplications" = @("All")
                    "excludeApplications" = @()
                }
                "users" = @{
                    "includeUsers" = $userGuids
                    "excludeUsers" = @()
                    "includeGroups" = @()
                    "excludeGroups" = @()
                }
                "locations" = @{
                    "includeLocations" = @("All")
                    "excludeLocations" = @($locationId)
                }
            }
            "grantControls" = @{
                "operator" = "OR"
                "builtInControls" = @("block")
            }
        }
        
        # Create the policy using Microsoft Graph
        $policyJson = $policyObject | ConvertTo-Json -Depth 10
        
        Add-StatusMessage "Sending policy creation request to Microsoft Graph..."
        
        $newPolicy = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $policyJson -ContentType "application/json"
        
        Add-StatusMessage "SUCCESS: Conditional Access policy created!"
        Add-StatusMessage "Policy ID: $($newPolicy.id)"
        Add-StatusMessage "Policy Name: $($newPolicy.displayName)"
        Add-StatusMessage "State: $($newPolicy.state) (remember to enable after review)"
        
        # Update existing geofencing policy to exclude these users
        if (-not [string]::IsNullOrWhiteSpace($selectedExistingPolicy)) {
            try {
                Add-StatusMessage "Updating main geofencing policy to exclude vacation users..."
                
                # Get existing policy ID from cache
                $existingPolicyId = $null
                if ($script:CAPoliciesCache.ContainsKey($selectedExistingPolicy)) {
                    $existingPolicyId = $script:CAPoliciesCache[$selectedExistingPolicy]
                }
                
                if ($existingPolicyId) {
                    # Fetch current policy
                    $currentPolicy = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$existingPolicyId"
                    
                    # Get current excluded users
                    $currentExcludedUsers = @()
                    if ($currentPolicy.conditions.users.excludeUsers) {
                        $currentExcludedUsers = $currentPolicy.conditions.users.excludeUsers
                    }
                    
                    # Add new users to exclusion list (avoid duplicates)
                    $updatedExcludedUsers = @($currentExcludedUsers)
                    foreach ($guid in $userGuids) {
                        if ($guid -notin $updatedExcludedUsers) {
                            $updatedExcludedUsers += $guid
                        }
                    }
                    
                    # Update the policy
                    $updateBody = @{
                        "conditions" = @{
                            "users" = @{
                                "includeUsers" = $currentPolicy.conditions.users.includeUsers
                                "excludeUsers" = $updatedExcludedUsers
                                "includeGroups" = $currentPolicy.conditions.users.includeGroups
                                "excludeGroups" = $currentPolicy.conditions.users.excludeGroups
                            }
                            "applications" = $currentPolicy.conditions.applications
                            "locations" = $currentPolicy.conditions.locations
                            "platforms" = $currentPolicy.conditions.platforms
                            "signInRiskLevels" = $currentPolicy.conditions.signInRiskLevels
                            "userRiskLevels" = $currentPolicy.conditions.userRiskLevels
                            "clientAppTypes" = $currentPolicy.conditions.clientAppTypes
                        }
                        "grantControls" = $currentPolicy.grantControls
                        "sessionControls" = $currentPolicy.sessionControls
                        "state" = $currentPolicy.state
                    }
                    
                    $updateJson = $updateBody | ConvertTo-Json -Depth 10
                    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$existingPolicyId" -Body $updateJson -ContentType "application/json"
                    
                    Add-StatusMessage "SUCCESS: Updated '$selectedExistingPolicy' to exclude vacation users"
                } else {
                    Add-StatusMessage "WARNING: Could not find policy ID for '$selectedExistingPolicy'"
                }
            } catch {
                Add-StatusMessage "ERROR: Failed to update existing policy - $($_.Exception.Message)"
                [System.Windows.MessageBox]::Show("Vacation policy created but failed to update main policy:`n`n$($_.Exception.Message)", "Partial Success", "OK", "Warning")
            }
        }
        
        # Show success message
        $successMsg = "Conditional Access policy created successfully!`n`nPolicy Name: $policyName`nPolicy ID: $($newPolicy.id)`nState: disabled`n`n"
        
        if (-not [string]::IsNullOrWhiteSpace($selectedExistingPolicy)) {
            $successMsg += "Main policy '$selectedExistingPolicy' updated to exclude vacation users.`n`n"
        }
        
        $successMsg += "Please review and enable the policy in the Azure Portal."
        
        [System.Windows.MessageBox]::Show($successMsg, "Success", "OK", "Information")
        
    } catch {
        Add-StatusMessage "ERROR: Policy creation failed - $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Failed to create policy:`n`n$($_.Exception.Message)", "Creation Error", "OK", "Error")
    }
})

$DisconnectBtn.Add_Click({
    try {
        Add-StatusMessage "Disconnecting from Microsoft Graph..."
        
        # Disconnect from Graph
        Disconnect-MgGraph | Out-Null
        
        # Reset connection state
        $script:GraphConnected = $false
        
        # Clear all caches
        $script:UserCache = @{}
        $script:NamedLocationsCache = @{}
        $script:CAPoliciesCache = @{}
        
        # Clear UI elements
        $UsersListBox.Items.Clear()
        $CountryComboBox.Items.Clear()
        $ExistingPolicyComboBox.Items.Clear()
        
        # Reset UI state
        $SignInBtn.Visibility = "Visible"
        $DisconnectBtn.Visibility = "Collapsed"
        $RefreshUsersBtn.IsEnabled = $false
        $CountryComboBox.IsEnabled = $false
        $ExistingPolicyComboBox.IsEnabled = $false
        $CreatePolicyBtn.IsEnabled = $true
        
        # Update connection status
        $ConnectionStatusText.Text = "Not Connected"
        $ConnectionStatusText.Foreground = "Gray"
        $ConnectionStatusBorder.Background = "#F0F0F0"
        $ConnectionStatusBorder.BorderBrush = "Gray"
        
        Add-StatusMessage "SUCCESS: Disconnected from Microsoft Graph"
        Add-StatusMessage "You can now sign in with a different account."
        
    } catch {
        Add-StatusMessage "ERROR: Disconnect failed - $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Failed to disconnect: $($_.Exception.Message)", "Disconnect Error", "OK", "Error")
    }
})

$CloseBtn.Add_Click({
    # Disconnect from Microsoft Graph if connected
    if ($script:GraphConnected) {
        try {
            Disconnect-MgGraph | Out-Null
            Add-StatusMessage "Disconnected from Microsoft Graph"
        } catch {
            # Ignore errors during disconnect
        }
    }
    $window.Close()
})

# Show the window
Add-StatusMessage "Ready."
$window.ShowDialog() | Out-Null
