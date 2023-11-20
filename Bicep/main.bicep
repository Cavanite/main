param location string = 'westeurope'
param namePrefix string = 'SA-PROD-01'

var storageAccountName = '${namePrefix}${uniqueString(resourceGroup().id)}'
var storageAccountSku = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
