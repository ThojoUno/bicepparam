using '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/hubNetworking/hubNetworking.bicep'

param parLocation = readEnvironmentVariable('LOCATION','centralus')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

// Need location formatted without spaces for private DNS zone names.
var varLocationFormatted = toLower(replace(parLocation, ' ', ''))

// Hub networking parameters.
param parHubNetworkName = 'vnet-${varLocationFormatted}-hub'
param parHubNetworkAddressPrefix = '10.0.0.0/21'
param parDnsServerIps = []
param parDdosEnabled = false
param parDdosPlanName = 'alz-ddos-plan'

param parSubnets = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.0.0.192/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.0.0.128/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.0.0.0/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.0.0.64/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'snet-${varLocationFormatted}-identity'
    ipAddressRange: '10.0.1.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

// Default public IP parameters.
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = ''
param parPublicIpSuffix = '-pip'

// Azure Bastion host parameters.
param parAzBastionEnabled = true
param parAzBastionName = 'bastion-${varLocationFormatted}-hub'
param parAzBastionSku = 'Standard'
param parAzBastionTunneling = false
param parAzBastionNsgName = 'nsg-AzureBastionSubnet'
param parBastionOutboundSshRdpPorts = [
  '22'
  '3389'
]

// Azure Firewall parameters.
param parAzFirewallEnabled = true
param parAzFirewallName = 'azfw-${varLocationFormatted}-hub'
param parAzFirewallPoliciesName = 'azfwpolicy-${varLocationFormatted}-hub'
param parAzFirewallTier = 'Basic'
param parAzFirewallIntelMode = 'Alert'
param parAzFirewallAvailabilityZones = null
param parAzFirewallDnsProxyEnabled = true
param parAzFirewallDnsServers = []

// Routing table parameters.
param parHubRouteTableName = 'rtb-${varLocationFormatted}-hub'
param parDisableBgpRoutePropagation = false

// Private DNS zone parameters.
param parPrivateDnsZonesEnabled = true
param parPrivateDnsZones = [
  'privatelink.${varLocationFormatted}.azmk8s.io'
  'privatelink.${varLocationFormatted}.batch.azure.com'
  'privatelink.${varLocationFormatted}.kusto.windows.net'
  'privatelink.${varLocationFormatted}.backup.windowsazure.com'
  'privatelink.adf.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.analysis.windows.net'
  'privatelink.api.azureml.ms'
  'privatelink.azconfig.io'
  'privatelink.azure-api.net'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azure-devices.net'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.azuredatabricks.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.azurestaticapps.net'
  'privatelink.azuresynapse.net'
  'privatelink.azurewebsites.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.directline.botframework.com'
  'privatelink.documents.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.file.core.windows.net'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.kubernetesconfiguration.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.mariadb.database.azure.com'
  'privatelink.media.azure.net'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.notebooks.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.postgres.database.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.servicebus.windows.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.token.botframework.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.webpubsub.azure.com'
]

param parPrivateDnsZoneAutoMergeAzureBackupZone = true

param parVpnGatewayEnabled = false
param parAzVpnGatewayAvailabilityZones = null
param parVpnGatewayConfig = {
  name: 'vpngw-${varLocationFormatted}-hub'
  gatewayType: 'Vpn'
  sku: 'VpnGw1'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
  vpnClientConfiguration: {}
}

param parExpressRouteGatewayEnabled = false
param parAzErGatewayAvailabilityZones = null
param parExpressRouteGatewayConfig = {
  name: 'ergw-${varLocationFormatted}-hub'
  gatewayType: 'ExpressRoute'
  sku: 'Standard'
  vpnType: 'RouteBased'
  generation: 'None'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
}

param parTags = {
  DeployedBy: 'Lunavi'
  Environment: 'Hub'
}

param parTelemetryOptOut = false


param parGlobalResourceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parVirtualNetworkLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parBastionLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parDdosLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parAzureFirewallLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parHubRouteTableLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parPrivateDNSZonesLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parVirtualNetworkGatewayLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
