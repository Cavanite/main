param location string = resourceGroup().location
param vmName string = 'VM-AVD-01'
param adminUsername string = 'azadmin'
param adminPassword string = 'P@ssw0rd1234'



resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnet-avd'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
        ]

        }
    subnets: [
        {
            name: 'subnet-avd'
            properties: {
            addressPrefix: '10.0.1.0/24'
            }
        }
    ]
  }
}

resource vmnic1 'Microsoft.Network/networkInterfaces@2021-04-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-avd', 'subnet-avd')
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource avdVm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-10'
        sku: '20h2-pro'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}-nic')
        }
      ]
    }
  }
}

