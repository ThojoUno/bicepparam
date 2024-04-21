using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/logging/logging.bicep'

// Read in common environment variables for module.
param parLogAnalyticsWorkspaceName = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_NAME','alz-log-analytics')
param parLogAnalyticsWorkspaceLocation = readEnvironmentVariable('LOCATION','centralus')
param parAutomationAccountLocation = readEnvironmentVariable('LOCATION','centralus')

// Need location formatted without spaces for private DNS zone names.
var varLocationFormatted = toLower(replace(parLogAnalyticsWorkspaceLocation,' ', ''))

param parLogAnalyticsWorkspaceSkuName = 'PerGB2018'
param parLogAnalyticsWorkspaceCapacityReservationLevel = 100
param parLogAnalyticsWorkspaceLogRetentionInDays = 365

param parLogAnalyticsWorkspaceSolutions = [
  'AgentHealthAssessment'
  'AntiMalware'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'SQLAdvancedThreatProtection'
  'SQLVulnerabilityAssessment'
  'SQLAssessment'
  'Updates'
  'VMInsights'
]

param parLogAnalyticsWorkspaceLinkAutomationAccount = true

param parAutomationAccountName = 'aa-${varLocationFormatted}-management'

param parAutomationAccountUseManagedIdentity = true

param parAutomationAccountPublicNetworkAccess = true

param parTags = {
  DeployedBy: 'Lunavi'
  Environment: 'Management'
}

param parUseSentinelClassicPricingTiers = false

param parLogAnalyticsLinkedServiceAutomationAccountName = 'Automation'

param parTelemetryOptOut = false

param parGlobalResourceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parAutomationAccountLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parLogAnalyticsWorkspaceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parLogAnalyticsWorkspaceSolutionsLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}
