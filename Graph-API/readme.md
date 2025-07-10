<h1>Welcome to my Microsoft Graph API Repository!</h1>

<p>This repository is dedicated to my exciting Microsoft Graph API projects, where I utilize the power of <a href="https://docs.microsoft.com/en-us/graph/">Microsoft Graph</a> alongside PowerShell and modern development tools. Get ready to dive into the world of Microsoft 365 automation and integration!</p>

<h2>Technologies Used</h2>

<ul>
  <li><a href="https://docs.microsoft.com/en-us/graph/">Microsoft Graph API</a>: The unified API endpoint for accessing Microsoft 365, Windows 10, and Enterprise Mobility + Security services.</li>
  <li><a href="https://docs.microsoft.com/en-us/powershell/microsoftgraph/">Microsoft Graph PowerShell SDK</a>: The official PowerShell module for interacting with Microsoft Graph.</li>
  <li><a href="https://code.visualstudio.com/">Visual Studio Code</a>: A highly extensible, feature-rich code editor that provides an exceptional development environment.</li>
  <li><a href="https://aka.ms/terminal">Windows Terminal</a>: The modern, fast, efficient, and powerful terminal application for Windows.</li>
  <li><a href="https://github.com/Cavanite/main/blob/main/.vscode/VScode-Extensions.ps1">Installed Extensions</a>: These are my installed extensions for Graph API development.</li>
</ul>

<h2>Why Microsoft Graph API?</h2>

<p>Microsoft Graph has revolutionized how I interact with Microsoft 365 services by providing a single endpoint to access data across the entire Microsoft ecosystem. With its comprehensive REST API and powerful PowerShell SDK, Microsoft Graph makes automation and integration projects more efficient and scalable.</p>
<p>The primary focus areas include <a href="https://docs.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy?view=graph-rest-1.0">Conditional Access</a>, <a href="https://docs.microsoft.com/en-us/graph/api/resources/intune-graph-overview?view=graph-rest-1.0">Intune Management</a>, and <a href="https://docs.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0">Azure AD User Management</a>.</p>

<h2>Getting Started with Microsoft Graph PowerShell</h2>

<p>To start using Microsoft Graph PowerShell SDK, follow these steps:</p>

<ol>
  <li>Install the Microsoft Graph PowerShell module from the <a href="https://www.powershellgallery.com/packages/Microsoft.Graph">PowerShell Gallery</a>.</li>
  <li>Open Windows Terminal or PowerShell and run the installation command:</li>
</ol>

<pre><code>Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.DeviceManagement
</code></pre>

<ol start="3">
  <li>Connect to your Microsoft 365 tenant:</li>
</ol>

<pre><code>Connect-MgGraph -Scopes "Policy.Read.All", "DeviceManagementConfiguration.Read.All", "User.Read.All"
</code></pre>

<p>Now you can start exploring and automating your Microsoft 365 environment using Graph API!</p>

<h2>Visual Studio Code Setup for Graph Development</h2>

<p>To optimize Visual Studio Code for Microsoft Graph development, perform the following steps:</p>

<ol>
  <li>Install the <a href="https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell">PowerShell extension</a> from the Visual Studio Code Marketplace.</li>
  <li>Install the <a href="https://marketplace.visualstudio.com/items?itemName=humao.rest-client">REST Client extension</a> for testing Graph API endpoints directly in VS Code.</li>
  <li>Open Visual Studio Code and press <kbd>Ctrl+Shift+P</kbd> (or <kbd>Cmd+Shift+P</kbd> on macOS) to open the command palette.</li>
  <li>Configure your workspace settings for optimal PowerShell and Graph development experience.</li>
</ol>

<p>Perfect! Your Visual Studio Code is now optimized for Microsoft Graph API development and automation.</p>

<h2>Repository Contents</h2>

<p>This repository contains a collection of Microsoft Graph API projects focusing on:</p>
<ul>
  <li><strong>Conditional Access Automation</strong>: Scripts for managing and documenting conditional access policies</li>
  <li><strong>Intune Device Management</strong>: Automated device enrollment, compliance, and configuration</li>
  <li><strong>Azure AD User Management</strong>: User provisioning, group management, and reporting scripts</li>
  <li><strong>Microsoft 365 Security</strong>: Security posture assessment and improvement automation</li>
</ul>

<p>Happy Graph API Development!!</p>