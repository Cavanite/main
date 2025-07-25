param location string =  resourceGroup().location
param tag1 string = 'dev'
param tag2 string = 'bert'
param adminuser string = 'azadmin'

@secure()
param adminpassword string

param amountofvms int = 2
param vmnames array = ['vm1', 'vm2']

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-${tag1}-${location}-01'
  location: location
        tags: {
    env: tag1
    owner: tag2
  }
  properties: {
    securityRules: [
      {
        name: 'allow-rdp'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'vnet-${tag1}-${location}-01'
    tags: {
    env: tag1
    owner: tag2
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
        name: 'snet-${tag1}-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2024-03-01' = [for i in range(0, amountofvms): {
  name: '${vmnames[i]}-nic-dev-${location}-01'
    tags: {
    env: tag1
    owner: tag2
  }
  location: location
  properties: {
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
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
}]

resource windowsVMs 'Microsoft.Compute/virtualMachines@2024-03-01' = [for i in range(0, amountofvms): {
  name: '${vmnames[i]}-${tag1}-${location}-01'
  tags: {
    env: tag1
    owner: tag2
  }
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: '${vmnames[i]}'
      adminUsername: adminuser
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmnames[i]}-osdisk-${tag1}-${location}-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
  }
  }
}]
