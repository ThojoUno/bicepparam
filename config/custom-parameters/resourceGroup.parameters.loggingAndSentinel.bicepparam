using '../../upstream-releases/v0.17.0/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('LOCATION','')

param parResourceGroupName = readEnvironmentVariable('LOGGING_RESOURCE_GROUP','')

param parTelemetryOptOut = false

param parTags = {
  DeployDate: '2024-02-14'
  Owner: 'Joe Thompson'
  Environment:'Lab-management'
  DeployedBy: 'Lunavi'
}
