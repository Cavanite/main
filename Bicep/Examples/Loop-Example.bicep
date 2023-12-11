param location string = 'westeurope'
param tag1 string = 'bicepdemo'
param tag2 string = 'dev'
param amountofnics int = 6

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2019-11-01' = [for i in range(0, amountofnics): {
  name: 'vnet-${tag2}-${location}-${i}'
  location: location
  tags: {
    tag1: tag1
    tag2: tag2
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}]


