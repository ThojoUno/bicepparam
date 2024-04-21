using '../../upstream-releases/v0.17.2/infra-as-code/bicep/orchestration/mgDiagSettingsAll/mgDiagSettingsAll.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

// Read in common environment variables for module.
var varConnectivitySubscriptionId = readEnvironmentVariable('CONNECTIVITY_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varLoggingSubscriptionId = readEnvironmentVariable('MANAGEMENT_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varLoggingResourceGroupName = readEnvironmentVariable('LOGGING_RESOURCE_GROUP','rg-lab-logging')
var varLogAnalyticsWorkspaceName = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_NAME','alz-log-analytics')

// Use the logging subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
var varLoggingSubId = !empty(varLoggingSubscriptionId) ? varLoggingSubscriptionId : varConnectivitySubscriptionId

param parTopLevelManagementGroupSuffix = ''

// Set to true by default to deploy diagnostic settings to corp and online child management groups.
param parLandingZoneMgAlzDefaultsEnable = true

// Set to true by default, set to False if using "Platform only" scenario.
param parPlatformMgAlzDefaultsEnable = true

param parLandingZoneMgConfidentialEnable = false

param parLogAnalyticsWorkspaceResourceId = '/subscriptions/${varLoggingSubId}/resourcegroups/${varLoggingResourceGroupName}/providers/microsoft.operationalinsights/workspaces/${varLogAnalyticsWorkspaceName}'

param parDiagnosticSettingsName = 'toLaws'

param parLandingZoneMgChildren = []

param parPlatformMgChildren = []

param parTelemetryOptOut = false
