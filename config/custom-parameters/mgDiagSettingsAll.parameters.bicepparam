using '../../upstream-releases/v0.17.0/infra-as-code/bicep/orchestration/mgDiagSettingsAll/mgDiagSettingsAll.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parTopLevelManagementGroupSuffix = readEnvironmentVariable('TOP_LEVEL_MG_SUFFIX','')
param parLogAnalyticsWorkspaceResourceId = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_ID','')
param parLandingZoneMgAlzDefaultsEnable = true
param parPlatformMgAlzDefaultsEnable = true
param parLandingZoneMgConfidentialEnable = false
param parDiagnosticSettingsName = 'toLAW'
param parLandingZoneMgChildren = []
param parPlatformMgChildren = []
param parTelemetryOptOut = false

