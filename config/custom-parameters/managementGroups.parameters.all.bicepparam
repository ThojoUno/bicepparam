using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/managementGroups/managementGroups.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

// Typically blank in default Alz-Bicep deployments
param parTopLevelManagementGroupSuffix = ''

param parTopLevelManagementGroupDisplayName = 'Trapeze Azure Landing Zone'

// To deploy to existing intermediate management group, set the parent ID here, otherwise leave blank for default Alz-Bicep deployment.
param parTopLevelManagementGroupParentId = ''

// True for default Alz-Bicep deployments.
param parLandingZoneMgAlzDefaultsEnable = true

// True for default Alz-Bicep deployments. 
// Default is true for Alz-Bicep default deployment, set to false for "Platform only" scenarios. (no separate connectivity, identity, or management subscriptions.)
param parPlatformMgAlzDefaultsEnable = true

// Typically false in default Alz-Bicep deployments.
param parLandingZoneMgConfidentialEnable = false

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Landing Zone mg.
param parLandingZoneMgChildren = {}

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Platform mg.
param parPlatformMgChildren = {}

param parTelemetryOptOut = false
