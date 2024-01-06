targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention, the name of the resource group for your application will use this name, prefixed with rg-')
param environmentName string

@minLength(1)
@description('The location used for all deployed resources')
param location string

@secure()
@metadata({azd: {type: 'inputs' }})
param inputs object

var tags = {
  'azd-env-name': environmentName
}

var abbrs = {
  managedIdentityUserAssignedIdentities: 'id-'
}

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module serviceBusResources './app/servicebus.bicep' = {
  name: 'sb-resources'
  scope: rg
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    skuName: 'Standard'
  }
}

module serviceBusAccess './app/access.bicep' = {
  name: 'sb-access'
  scope: rg
  params: {
    location: location
    serviceBusName: serviceBusResources.outputs.serviceBusName
    managedIdentityName: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
  }
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    tags: tags
    inputs: inputs
    daprEnabled: true
    serviceBusName: serviceBusResources.outputs.serviceBusName
    managedIdentityClientId: serviceBusAccess.outputs.managedIdentityClientlId
  }
}

output MANAGED_IDENTITY_CLIENT_ID string = resources.outputs.MANAGED_IDENTITY_CLIENT_ID
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = resources.outputs.AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID
output AZURE_CONTAINER_APPS_ENVIRONMENT_ID string = resources.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_ID
output AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN string = resources.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN
