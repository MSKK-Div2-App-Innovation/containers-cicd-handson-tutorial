targetScope = 'resourceGroup'

param name string
param envName string
param imageName string
param location string = resourceGroup().location
param env array = []
param daprAppId string =''
param ingressEnabled bool = false
param ingressTargetPort int = 8000
param externalIngressEnabled bool = false
param daprAppPort int = 3500

param secretName string = 'reg-pswd-${newGuid()}'

resource containerenv 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: envName
}

resource containerapp 'Microsoft.App/containerApps@2022-03-01' = {
  location: location
  name: name
  properties: {
    configuration: {
      dapr: empty(daprAppId) ? {} : {
        enabled: true
        appId: daprAppId
        appPort: daprAppPort
      }
      ingress: ingressEnabled ? {
        external: externalIngressEnabled
        targetPort: ingressTargetPort
      } : null
    }
    managedEnvironmentId: containerenv.id
    template: {
      containers: [
        {
          name: '${name}-container'
          env: env
          image: imageName
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}

var url = ingressEnabled ? '${containerapp.name}${externalIngressEnabled ? '.internal' : ''}.${containerenv.properties.defaultDomain}' : ''
output appuri string = url