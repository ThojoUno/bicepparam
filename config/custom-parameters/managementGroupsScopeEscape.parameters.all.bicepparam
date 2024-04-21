/* 
  managementGroupsScopeEscape.parameters.bicepparam
  Author: JThompson
  Date: 2024-02-24
  Version: 1.0
  
  This file contains the parameters for the managementGroups.bicep file, and replaces the json version
  used in the original ALZ-Bicep implementation. Commonly used parameters are read from the .env file 
  which is parsed during pipeline deployment.

*/

using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/managementGroups/managementGroupsScopeEscape.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')
param parTopLevelManagementGroupSuffix = readEnvironmentVariable('TOP_LEVEL_MG_SUFFIX','')
param parTopLevelManagementGroupDisplayName = readEnvironmentVariable('TOP_LEVEL_MG_DISPLAY_NAME','Lunavi Lab ALZ')
param parTopLevelManagementGroupParentId = ''
param parLandingZoneMgAlzDefaultsEnable = true
param parPlatformMgAlzDefaultsEnable = true
param parLandingZoneMgConfidentialEnable = false
param parLandingZoneMgChildren = {}
param parPlatformMgChildren = {}
param parTelemetryOptOut = false
