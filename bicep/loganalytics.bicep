targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
}

output workspaceId string = loganalytics.properties.customerId
output name string = loganalytics.name