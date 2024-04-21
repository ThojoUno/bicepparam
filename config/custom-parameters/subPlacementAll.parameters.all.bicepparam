using '../../upstream-releases/v0.17.2/infra-as-code/bicep/orchestration/subPlacementAll/subPlacementAll.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

param parTopLevelManagementGroupSuffix = ''
param parIntRootMgSubs = []
param parLandingZonesMgSubs = []

// Read in the subscription ids from the environment file (.env) and set them to the variables
var varManagementSubId = readEnvironmentVariable('MANAGEMENT_SUBSCRIPTION_ID','')
var varConnectivitySubId = readEnvironmentVariable('CONNECTIVITY_SUBSCRIPTION_ID','')
var varIdentitySubId = readEnvironmentVariable('IDENTITY_SUBSCRIPTION_ID','')
var varLzOnlineSubIds = readEnvironmentVariable('LZ_ONLINE_SUBSCRIPTION_IDS','')
var varLzCorpSubIds = readEnvironmentVariable('LZ_CORP_SUBSCRIPTION_IDS','')
var varLzConfidentialCorpSubIds = readEnvironmentVariable('LZ_CONF_CORP_SUBSCRIPTION_IDS','')
var varLzConfidentialOnlineSubIds = readEnvironmentVariable('LZ_CONF_ONLINE_SUBSCRIPTION_IDS','')
var varSandboxSubIds = readEnvironmentVariable('SANDBOX_SUBSCRIPTION_IDS','')

// If there is no management or identity subscription, then the connectivity subscription is placed at the root of the Platform Management Group. ("Platform only" scenario)
param parPlatformMgSubs = ((varConnectivitySubId == varIdentitySubId) && (varConnectivitySubId == varManagementSubId)) ? [varConnectivitySubId] : []

// If management subscription matches connectivity subscription, we are in an Platform only scenario, and we do not have a management subscription to place.
param parPlatformManagementMgSubs = contains(varConnectivitySubId,varManagementSubId) ? [] : [varManagementSubId]

// if connectivity subscription id matches management subscription id, then we do not have a connectivity subscription to place.
param parPlatformConnectivityMgSubs = contains(varConnectivitySubId,varIdentitySubId) ? [] : [varConnectivitySubId] 

// if identity subscription id matches connectivity subscription id, then we do not have a identity subscription to place.
param parPlatformIdentityMgSubs = contains(varConnectivitySubId,varIdentitySubId) ? [] : [varIdentitySubId] 

param parLandingZonesCorpMgSubs = !empty(varLzCorpSubIds) ? [varLzCorpSubIds] : []

param parLandingZonesOnlineMgSubs = !empty(varLzOnlineSubIds) ? [varLzOnlineSubIds] : []

param parLandingZonesConfidentialCorpMgSubs = !empty(varLzConfidentialCorpSubIds) ? [varLzConfidentialCorpSubIds] : []

param parLandingZonesConfidentialOnlineMgSubs = !empty(varLzConfidentialOnlineSubIds) ? [varLzConfidentialOnlineSubIds] : []

param parLandingZoneMgChildrenSubs = {}

param parPlatformMgChildrenSubs = {}

param parDecommissionedMgSubs = []

param parSandboxMgSubs = !empty(varSandboxSubIds) ? [varSandboxSubIds] : []

param parTelemetryOptOut = false
