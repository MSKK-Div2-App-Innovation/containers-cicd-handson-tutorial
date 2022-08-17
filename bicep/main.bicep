targetScope = 'subscription'

@description('リソース グループ名')
param resourceGroupName string
@minLength(5)
@maxLength(37)
@description('Azure Container Registry リソース名のプレフィックス')
param acrNamePrefix string
param location string = deployment().location

var acrName = '${acrNamePrefix}${uniqueString(rg.id)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module containerRegistry 'containerregistry.bicep' = {
  name: 'containerregistry-deployment'
  params: {
    location: location
    acrName: acrName
  }
  scope: rg
}

module loganalytics 'loganalytics.bicep' = {
  name: 'loganalytics-deployment'
  params: {
    location: location
    name: 'log-demo-containerapp'
  }
  scope: rg
}

module containerenv 'containerenv.bicep' = {
  name: 'containerappsenvironment-deployment'
  params: {
    name: 'cae-demo-containerapp'
    location: location
    logAnalyticsName: loganalytics.outputs.name
  }
  scope: rg
}

module containerAppApi 'containerapp.bicep' = {
  name: 'containerapp-api-deployment'
  params: {
    name: 'ctapp-demo-api'
    location: location
    envName: containerenv.outputs.name
    ingressEnabled: true
    ingressTargetPort: 80
    externalIngressEnabled: true
    imageName: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
  }
  scope: rg
}

module containerAppUi 'containerapp.bicep' = {
  name: 'containerapp-ui-deployment'
  params: {
    name: 'ctapp-demo-ui'
    location: location
    envName: containerenv.outputs.name
    ingressEnabled: true
    ingressTargetPort: 80
    externalIngressEnabled: true
    imageName: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
  }
  scope: rg
}