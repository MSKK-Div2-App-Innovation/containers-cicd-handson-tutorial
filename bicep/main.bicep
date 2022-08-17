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
  name: 'containerregistry-deploy'
  params: {
    location: location
    acrName: acrName
  }
  scope: rg
}

module loganalytics 'loganalytics.bicep' = {
  name: 'loganalytics-deploy'
  params: {
    location: location
    name: 'la-demo-containerapp'
  }
  scope: rg
}

module containerenv 'containerenv.bicep' = {
  name: 'containerenv-deploy'
  params: {
    name: 'ce-demo-containerapp'
    location: location
    logAnalyticsName: loganalytics.outputs.name
  }
  scope: rg
}

module containerAppApi 'containerapp.bicep' = {
  name: 'containerapp-api-deploy'
  params: {
    name: 'ca-demo-apiapp'
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
  name: 'containerapp-ui-deploy'
  params: {
    name: 'ca-demo-uiapp'
    location: location
    envName: containerenv.outputs.name
    ingressEnabled: true
    ingressTargetPort: 80
    externalIngressEnabled: true
    imageName: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
  }
  scope: rg
}