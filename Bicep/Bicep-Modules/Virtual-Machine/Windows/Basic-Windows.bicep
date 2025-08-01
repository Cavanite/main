@description('The name of the virtual machine')
param vmName string

@description('The location where resources will be deployed')
param location string = resourceGroup().location

@description('The size of the virtual machine')
param vmSize string = 'Standard_B2s'

@description('The admin username for the virtual machine')
param adminUsername string

@description('The admin password for the virtual machine')
@secure()
param adminPassword string

@description('Tags to apply to resources')
param tags object = {
  env: 'dev'
  owner: 'bert'
}

@description('Windows OS version')
@allowed([
  '2019-Datacenter'
  '2022-Datacenter'
  '2022-datacenter-azure-edition'
])
param windowsOSVersion string = '2022-Datacenter'

@description('Storage account type for OS disk')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param osDiskType string = 'Standard_LRS'

// Network Interface
resource networkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${vmName}-nic-${location}-${tags.env}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork1.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

// VirtualNetwork
resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-${location}-${tags.env}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-${location}-${tags.env}'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}


// Virtual Machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: '${vmName}-${location}-${tags.env}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk-${location}-${tags.env}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
// Public IP Address
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-${vmName}-${location}-${tags.env}'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${vmName}-${uniqueString(resourceGroup().id)}-${tags.env}')
      domainNameLabelScope: 'TenantReuse'
    }
    idleTimeoutInMinutes: 4
    deleteOption: 'Delete'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
