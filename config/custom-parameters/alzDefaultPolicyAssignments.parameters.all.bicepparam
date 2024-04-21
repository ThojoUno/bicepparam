using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep'

// Default is true, set to false in "Platform only" subscription scenario.
param parPlatformMgAlzDefaultsEnable = true

// Default is true for Alz-Bicep implementations, creates corp and online child Mgs under landingzone mg..
param parLandingZoneChildrenMgAlzDefaultsEnable = true

// Default is false for Alz-Bicep implementations.
param parLandingZoneMgConfidentialEnable = false

// Read in common environment variables for module.
param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parLogAnalyticsWorkSpaceAndAutomationAccountLocation = readEnvironmentVariable('LOCATION','centralus')
var varLocation = readEnvironmentVariable('LOCATION','centralus')
var varLogAnalyticsWorkspaceName = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_NAME','alz-log-analytics')
// Read environment variables for subscription IDs and resource group names
var varConnectivitySubscriptionId = readEnvironmentVariable('CONNECTIVITY_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varConnectivityResourceGroupName = readEnvironmentVariable('CONNECTIVITY_RESOURCE_GROUP','rg-lab-connectivity')
var varLoggingSubscriptionId = readEnvironmentVariable('MANAGEMENT_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varLoggingResourceGroupName = readEnvironmentVariable('LOGGING_RESOURCE_GROUP','rg-lab-logging')

// Convert location to lowercase and remove spaces for resource naming.
var varLocationFormatted = toLower(replace(varLocation, ' ', ''))

// Use the logging subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
var varLoggingSubId = !empty(varLoggingSubscriptionId) ? varLoggingSubscriptionId : varConnectivitySubscriptionId

// This is typcally blank in default Alz-Bicep implementation.
param parTopLevelManagementGroupSuffix = ''

// This is typcally false in default Alz-Bicep implementation.
param parTopLevelPolicyAssignmentSovereigntyGlobal = {
  parTopLevelSovereigntyGlobalPoliciesEnable: false
  parListOfAllowedLocations: []
  parPolicyEffect: 'Deny'
}

// Typically false in default Alz-Bicep implementation.
param parPolicyAssignmentSovereigntyConfidential = {
  parAllowedResourceTypes: []
  parListOfAllowedLocations: []
  parAllowedVirtualMachineSKUs: []
  parPolicyEffect: 'Deny'
}

param parLogAnalyticsWorkspaceResourceId = '/subscriptions/${varLoggingSubId}/resourcegroups/${varLoggingResourceGroupName}/providers/microsoft.operationalinsights/workspaces/${varLogAnalyticsWorkspaceName}'

param parLogAnalyticsWorkspaceLogRetentionInDays = '365'

param parAutomationAccountName = 'aa-${varLocationFormatted}-management'

param parMsDefenderForCloudEmailSecurityContact = 'jthompson@lunavi.com'

param parDdosProtectionPlanId = '/subscriptions/${varConnectivitySubscriptionId}/resourceGroups/${varConnectivityResourceGroupName}/providers/Microsoft.Network/ddosProtectionPlans/alz-ddos-plan'

param parPrivateDnsResourceGroupId = '/subscriptions/${varConnectivitySubscriptionId}/resourceGroups/${varConnectivityResourceGroupName}'

param parPrivateDnsZonesNamesToAuditInCorp = []

param parDisableAlzDefaultPolicies = false

param parVmBackupExclusionTagName = ''

param parVmBackupExclusionTagValue = []

param parExcludedPolicyAssignments = [
  'Enable-DDoS-VNET'
]

param parTelemetryOptOut = false
