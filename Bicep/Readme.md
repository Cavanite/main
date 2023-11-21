<body>

  <h1>Azure Bicep README</h1>

  <h2>Overview</h2>

  <p>Welcome to the Azure Bicep repository! This project leverages Azure Bicep, a Domain Specific Language (DSL) for deploying Azure resources declaratively. Bicep simplifies the Azure Resource Manager (ARM) template language, making it more readable and maintainable.</p>

  <h2>Select Azure Subscription</h2>

  <p>Before you start, ensure you have selected the correct Azure subscription using Azure PowerShell:</p>

  <pre><code>Connect-AzAccount -SubscriptionId YourSubscriptionID</code></pre>
  <p>Replace <code>YourSubscriptionID</code> with the desired Azure subscription ID.</p>

  <h2>Getting Started</h2>

  <h3>Prerequisites</h3>

  <p>Before you begin, ensure you have the following tools installed:</p>

  <ul>
    <li><a href="https://docs.microsoft.com/en-us/cli/azure/install-azure-cli">Azure CLI</a></li>
    <li><a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install">Azure Bicep</a></li>
    <li><a href="https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell">Azure PowerShell Module</a></li>
  </ul>

  <h3>Quick Start Azure CLI</h3>

  <ol>
    <li>Edit the <code>main.bicep</code> file to define your Azure resources.</li>
    <li>Deploy the Bicep file using the Azure CLI:
      <pre><code>az deployment group create --resource-group YourResourceGroup --template-file main.bicep</code></pre>
      Replace <code>YourResourceGroup</code> with the desired resource group name.
    </li>
  </ol>

  <h3>Quick Start Azure PowerShell</h3>

  <ol>
    <li>Edit the <code>main.bicep</code> file to define your Azure resources.</li>
    <li>Deploy the Bicep file using Azure PowerShell:
      <pre><code>New-AzResourceGroupDeployment -ResourceGroupName YourResourceGroup -TemplateFile .\main.bicep</code></pre>
      Replace <code>YourResourceGroup</code> with the desired resource group name.
    </li>
  </ol>

</body>

</html>
