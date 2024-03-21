using '../../upstream-releases/v0.17.0/infra-as-code/bicep/orchestration/subPlacementAll/subPlacementAll.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parTopLevelManagementGroupSuffix = readEnvironmentVariable('TOP_LEVEL_MG_SUFFIX','')
param parIntRootMgSubs = []
param parPlatformMgSubs = []

// LunaviLab-Management-Sandbox
param parPlatformManagementMgSubs = [
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
]

// LunaviLab-Connectivity-Sandbox
param parPlatformConnectivityMgSubs = [
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
]

// LunaviLab-Identity-Sandbox
param parPlatformIdentityMgSubs = [
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
]

// LunaviLab-Prod-Sandbox
param parLandingZonesCorpMgSubs = [
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
]

param parLandingZonesOnlineMgSubs = [] 
param parLandingZonesConfidentialCorpMgSubs = []
param parLandingZonesConfidentialOnlineMgSubs = []
param parLandingZoneMgChildrenSubs = {}
param parPlatformMgChildrenSubs = {}
param parDecommissionedMgSubs = []
param parSandboxMgSubs = []
param parTelemetryOptOut = false


