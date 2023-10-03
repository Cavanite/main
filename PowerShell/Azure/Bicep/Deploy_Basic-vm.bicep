param location string = 'westeurope'
param vmName string = 'VM-01'
param adminUsername string = 'Random User'
param adminPassword string = 'Random Password'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
    name: 'myVNet'
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'default'
                properties: {
                    addressPrefix: '10.0.0.0/24'
                }
            }
        ]
    }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
    name: 'myPublicIP'
    location: location
    properties: {
        publicIPAllocationMethod: 'Dynamic'
    }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
    name: '${vmName}-nic'
    location: location
    dependsOn: [
        vnet
        publicIP
    ]
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig'
                properties: {
                    subnet: {
                        id: vnet.subnets[0].id
                    }
                    publicIPAddress: {
                        id: publicIP.id
                    }
                }
            }
        ]
    }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
    name: vmName
    location: location
    dependsOn: [
        nic
    ]
    properties: {
        hardwareProfile: {
            vmSize: 'Standard_B1s'
        }
        storageProfile: {
            imageReference: {
                publisher: 'Canonical'
                offer: 'UbuntuServer'
                sku: '18.04-LTS'
                version: 'latest'
            }
            osDisk: {
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: 'Standard_LRS'
                }
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
                    id: nic.id
                }
            ]
        }
    }
}
