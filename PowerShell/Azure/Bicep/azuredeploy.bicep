param sku string = 'Standard_LRS'
param location string = resourceGroup().location
param name string 
@allowed([
  'Standard_LRS'
  'Standard_GRS'
])

param sku string = 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${name}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '
