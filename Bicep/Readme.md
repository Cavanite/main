<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Azure Bicep README</title>
</head>

<body>

  <h1>Azure Bicep README</h1>

  <h2>Overview</h2>

  <p>Welcome to the Azure Bicep repository! This project leverages Azure Bicep, a Domain Specific Language (DSL) for deploying Azure resources declaratively. Bicep simplifies the Azure Resource Manager (ARM) template language, making it more readable and maintainable.</p>

  <h2>Getting Started</h2>

  <h3>Prerequisites</h3>

  <p>Before you begin, ensure you have the following tools installed:</p>

  <ul>
    <li><a href="https://docs.microsoft.com/en-us/cli/azure/install-azure-cli">Azure CLI</a></li>
    <li><a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install">Azure Bicep</a></li>
  </ul>

  <h3>Quick Start</h3>

  <ol>
    <li>Edit the <code>main.bicep</code> file to define your Azure resources.</li>
    <li>Deploy the Bicep file using the Azure CLI:
      <pre><code>az deployment group create --resource-group YourResourceGroup --template-file main.bicep</code></pre>
      Replace <code>YourResourceGroup</code> with the desired resource group name.
    </li>
  </ol>

</body>

</html>
