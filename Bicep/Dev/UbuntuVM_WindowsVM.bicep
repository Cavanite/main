param location string = 'westeurope'
param tag1 string = 'bicepdemo'
param tag2 string = 'dev'
param adminusername string = 'bicepadmin'
@secure()
param password string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-prod-westeu-01'
  tags: {
    rg : tag1
    env : tag2
  }
  location: location
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
}

resource networkInterface1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'vm-nic-prod-westeu-01'
  tags: {
    rg : tag1
    env : tag2
  }
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource networkInterface2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'vm-nic-prod-westeu-02'
  tags: {
    rg : tag1
    env : tag2
  }
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vm-ubuntu-prod-westeu-01'
  tags: {
    rg : tag1
    env : tag2
  }
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'vm-ubuntu-01'
      adminUsername: adminusername
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'vm-ubuntu-osdisk-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
        }
      ]
    }
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vm-windows-prod-westeu-01'
  tags: {
    rg : tag1
    env : tag2
  }
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'vm-windows-01'
      adminUsername: adminusername
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'vm-windows-osdisk-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface2.id
        }
      ]
    }
  }
}

