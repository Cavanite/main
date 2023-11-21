param location string = 'westeurope'
param storagename string = 'saprodbodstage01'
param sku string = 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storagename
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
}
