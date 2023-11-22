param location string = 'westeurope'
param tag1 string = 'costmanagement'
param env string = 'prod'
param adminuser string = 'azadmin'

@secure()
param adminpassword string

resource networkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${env}-${location}-01'
  tags: {
    tag1: tag1
  }
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          description: 'allow RDP'
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
resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-${env}-${location}-01'
  tags: {
    tag1: tag1
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
        name: 'snet-${env}-${location}'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
resource networkInterface1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'nic-${env}-${location}-01'
  location: location
  properties: {
    networkSecurityGroup: {
      id: networkSecurityGroup1.id
    }
    ipConfigurations: [
      {
        name: 'ip1-${env}-${location}-01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork1.properties.subnets[0].id
          }
        }
      }
    ]
  }
}


resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vm-${env}-${location}-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'vm-01'
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
        name: 'osdisk-${env}-${location}-01'
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


resource hostPool 'Microsoft.DesktopVirtualization/hostpools@2021-07-12' = {
  name: 'hp-${env}-${location}-01'
  location: location
  properties: {
    friendlyName: 'hostpoolFriendlyName'
    hostPoolType: 'Personal'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}


