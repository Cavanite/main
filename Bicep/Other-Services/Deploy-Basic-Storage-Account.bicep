@description('Create a storage account, names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only')
param storagename string

param location string = 'westeurope'
param sku string = 'Standard_LRS'
param tag1 string = 'costmanagement'
param env string = 'prod'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sa${env}${storagename}'
  location: location
  tags: {
    tag1: tag1
    env: env
  }
  kind: 'StorageV2'
  sku: {
    name: sku
  }
}
