param name string
param location string = resourceGroup().location
param tags object = {}

param api2ContainerAppName string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param keyVaultName string
param serviceName string = 'web3'

module app3 '../core/host/container-app3.bicep' = {
  name: '${serviceName}-container-app3-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    env: [
      {
        name: 'REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'REACT_APP_API_BASE_URL'
        value: 'https://${api2.properties.configuration.ingress.fqdn}'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    keyVaultName: keyVault.name
    targetPort: 81
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource api2 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: api2ContainerAppName
}


output SERVICE_WEB_IDENTITY_PRINCIPAL_ID string = app3.outputs.identityPrincipalId
output SERVICE_WEB_NAME string = app3.outputs.name
output SERVICE_WEB_URI string = app3.outputs.uri
output SERVICE_WEB_IMAGE_NAME string = app3.outputs.imageName
