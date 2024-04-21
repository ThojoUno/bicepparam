using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('LOCATION','centralus')

param parResourceGroupName = readEnvironmentVariable('LOGGING_RESOURCE_GROUP','rg-lab-management')

param parTags = {
  Environment: 'Management'
  DeployedBy: 'Lunavi'
  // 'Expiry Date': '2024-04-30'
  // 'Business Unit': 'Cloud Enablement'
  // Owner: 'Joe Thompson'
}

param parTelemetryOptOut = false

param parResourceLockConfig = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep resourceGroup Module'
}
