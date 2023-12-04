param location string = 'westeurope'
param tag1 string = 'costmanagement'
param env string = 'prod'
param adminuser string = 'azadmin'

@secure()
param adminpassword string

param amountofvms int = 2
param vmnames array = ['vm1', 'vm2']

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${env}-${location}-01'
  location: location
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


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-${env}-${location}-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-${env}-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, amountofvms): {
  name: '${vmnames[i]}-nic-prod-${location}-01'
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

resource windowsVMs 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0, amountofvms): {
  name: '${vmnames[i]}-prod-${location}-01'
  tags: {
    tag:tag1
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
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmnames[i]}-osdisk-prod-${location}-01'
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
