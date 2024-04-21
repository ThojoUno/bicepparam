using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/policy/definitions/customPolicyDefinitions.bicep' 

param parTargetManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

param parTelemetryOptOut = false
