param location string = 'westeurope'
param tag1 string = 'bicepdemo'
param tag2 string = 'dev'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet01'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}
resource networkinterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm01 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm01'
  location: location
  tags: {
    rg : tag1
    env : tag2
  }
  properties: {
    osProfile: {
      adminUsername: 'bicepadmin'
      adminPassword: 'Password1234!'
      computerName: 'vm01'
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'vm01-osdisk01'
        diskSizeGB: 30
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
  }
}

