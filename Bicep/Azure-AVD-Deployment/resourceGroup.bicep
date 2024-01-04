targetScope = 'subscription'
param location string = 'westeurope'
param env string = 'prod'

param AVDResourceGroup string = '${env}-${location}-AVD-rg'
param vmResourceGroup string = '${env}-${location}-VM-rg'

resource vmResourceGroup_resource 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: vmResourceGroup
  location: location
}

resource AVDResourceGroup_resource 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: AVDResourceGroup
  location: location
}
