using '../../upstream-releases/v0.17.0/infra-as-code/bicep/modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parTopLevelManagementGroupSuffix = readEnvironmentVariable('TOP_LEVEL_MG_SUFFIX','')
param parLogAnalyticsWorkspaceResourceId = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_ID','')
param parLandingZoneChildrenMgAlzDefaultsEnable = true
param parPlatformMgAlzDefaultsEnable = true
param parLandingZoneMgConfidentialEnable = false
param parLogAnalyticsWorkSpaceAndAutomationAccountLocation = readEnvironmentVariable('LOCATION','eastus2')
param parLogAnalyticsWorkspaceLogRetentionInDays = '30'
param parAutomationAccountName = readEnvironmentVariable('AUTOMATION_ACCOUNT_NAME','aa-eastus2-management')
param parMsDefenderForCloudEmailSecurityContact = readEnvironmentVariable('EMAIL_SECURITY_CONTACT','')
param parDdosProtectionPlanId = readEnvironmentVariable('DDOS_PLAN_ID','')
param parPrivateDnsResourceGroupId = readEnvironmentVariable('PRIVATE_DNS_RESOURCE_GROUP_ID','')
param parPrivateDnsZonesNamesToAuditInCorp = []
param parDisableAlzDefaultPolicies = false
param parVmBackupExclusionTagName = ''
param parVmBackupExclusionTagValue = []
param parExcludedPolicyAssignments = [
  'Enable-DDos-VNET'
]
param parTelemetryOptOut = false



