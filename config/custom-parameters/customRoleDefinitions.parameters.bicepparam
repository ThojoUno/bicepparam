using '../../upstream-releases/v0.17.0/infra-as-code/bicep/modules/customRoleDefinitions/customRoleDefinitions.bicep'

param parAssignableScopeManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parTelemetryOptOut = false
