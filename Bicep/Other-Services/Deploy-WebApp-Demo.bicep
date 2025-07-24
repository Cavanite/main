param webappName string = uniqueString(resourceGroup().id)
param sku string = 'B1'
param LinuxFxVersion string =  'php|7.4'
param location string = resourceGroup().location

var AppServicePlanName = toLower('${webappName}-asp')
var websiteName = toLower('webappx-${webappName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: AppServicePlanName
  location: location
  sku: {
    name: sku
  }
kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApplication 'Microsoft.Web/sites@2023-12-01' = {
  name: websiteName
  location: location
  kind:'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: LinuxFxVersion
    }
  }
}

output siteUrl string = webApplication.properties.hostNames[0]
