param location = westeurope
param hostpoolName = hp-westeurope


resource hostpool 'Microsoft.DesktopVirtualization/hostPools@2024-04-03' = {
  name: hostpoolName
  location: location
  properties: {
    friendlyName: 'Host Pool'
    description: 'Host Pool Description'
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    personalDesktopAssignmentType: 'Automatic'
    preferredAppGroupType: 'Desktop'
  }
}
