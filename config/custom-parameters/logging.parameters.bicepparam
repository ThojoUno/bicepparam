using '../../upstream-releases/v0.17.0/infra-as-code/bicep/modules/logging/logging.bicep'

param parLogAnalyticsWorkspaceLocation = readEnvironmentVariable('LOCATION','')

param parLogAnalyticsWorkspaceName = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_NAME','')

param parLogAnalyticsWorkspaceLinkAutomationAccount = true
param parAutomationAccountName = 'aa-eastus-management'
param parAutomationAccountLocation = 'eastus'
param parAutomationAccountUseManagedIdentity = true
param parAutomationAccountPublicNetworkAccess = true

param parLogAnalyticsWorkspaceSkuName = 'PerGB2018'
param parLogAnalyticsWorkspaceCapacityReservationLevel = 100
param parLogAnalyticsWorkspaceLogRetentionInDays = 30
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

param parUseSentinelClassicPricingTiers = false
param parLogAnalyticsLinkedServiceAutomationAccountName = 'Automation'
param parTelemetryOptOut = false




