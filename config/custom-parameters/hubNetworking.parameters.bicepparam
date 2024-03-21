using '../custom-modules/hubNetworking.lunavi.bicep'

param parLocation = readEnvironmentVariable('LOCATION','')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','alz')

param parHubNetworkName = readEnvironmentVariable('HUB_VIRTUAL_NETWORK_NAME','vnet-${parLocation}-hub')

param parHubNetworkAddressPrefix = '10.200.0.0/22'

param parDnsServerIps = []

param parDdosEnabled = false

param parSubnets = [
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.200.0.0/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.200.0.64/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.200.0.128/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.200.0.192/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'snet-${parLocation}-mgmt'
    ipAddressRange: '10.200.1.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]    

// Public IP parameters
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = 'pip-'
param parPublicIpSuffix = ''

// Azure Bastion host parameters
param parAzBastionEnabled = true
param parAzBastionName = 'bastion-${parLocation}-connectivity'
param parAzBastionSku = 'Standard'
param parAzBastionTunneling = false
param parAzBastionNsgName = 'nsg-AzureBastionSubnet'
param parBastionOutboundSshRdpPorts = [
  '22'
  '3389'
]

// Azure Firewall parameters
param parAzFirewallEnabled = true
param parAzFirewallName = 'azfw-${parLocation}-connectivity'
param parAzFirewallPoliciesName = 'azfwpolicy-${parLocation}-connectivity'
param parAzFirewallTier = 'Basic'
param parAzFirewallIntelMode = 'Alert'
param parAzFirewallDnsProxyEnabled = true
param parAzFirewallDnsServers = []
param parAzFirewallAvailabilityZones = [
  '1'
  '2'
  '3'
]

param parHubRouteTableName = 'rtb-${parLocation}-connectivity'

param parDisableBgpRoutePropagation = false

param parPrivateDnsZonesEnabled = true

param parPrivateDnsZones = [
  'privatelink.${parLocation}.backup.windowsazure.com'
  'privatelink.azure-automation.net'
  'privatelink.azurewebsites.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.database.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
]

param parPrivateDnsZoneAutoMergeAzureBackupZone = true

// VPN Gateway parameters
param parVpnGatewayConfig = {
  name: 'vpn-${parLocation}-connectivity'
  gatewayType: 'Vpn'
  sku: 'VpnGw1AZ'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: true
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
  vpnClientConfiguration: {}
}

param parAzVpnGatewayAvailabilityZones = [
  '1'
  '2'
  '3'
]

// added 2024/03/15 - jt
param parVpnGatewayLocalNetworkGateway = {
  enableLocalGateway: false
  name: 'lng-${parLocation}-datacentername'
  localGatewayPublicIpAddress: '1.1.1.1'
  localAddressPrefixes: [
    '192.168.0.0/16'
    '172.16.0.0/12'
  ]
}

// added 2024/03/15 - jt
param parVpnGatewayConnection = {
  enableConnection: false
  name: 'con-${parLocation}-datacentername'
  connectionName: 'con-${parLocation}-datacentername'
  connectionType: 'IPsec'
  vpnSharedKey: 'A1b2C3d4E5f6G7h8I9j0KlMnOpQrStUvWxYz' 
}

// added 2024/03/15 - jt
// If ipsecEncryption is null, the connection will use default IPsec/IKE policy.
param parVpnGatewayCustomIPSecPolicy = {
  ipsecEncryption: ''
  saLifeTimeSeconds: 27000
  saDataSizeKilobytes: 102400000
  ipsecIntegrity: 'SHA256'
  ikeEncryption: 'AES256'
  ikeIntegrity: 'SHA256'
  dhGroup: 'DHGroup24'
  pfsGroup: 'PFS24'
}


// ExpressRoute Gateway parameters
param parExpressRouteGatewayConfig = {}
param parAzErGatewayAvailabilityZones = []

param parTelemetryOptOut = false

param parTags = {
  DeployDate: '2024-02-14'
  Owner: 'Joe Thompson'
  Environment:'Lab-management'
  DeployedBy: 'Lunavi'
}





