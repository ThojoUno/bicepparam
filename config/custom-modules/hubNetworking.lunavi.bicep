/* 
  hubNetworking.lunavi.bicep
  This is modified version of the original file from Azure/ALZ-Bicep, and fixes an issue with active/active mode for the Azure VPN gateway.
  This template uses several modules from upstream-release v0.17.0, if you update the upstream-release version, you may need to update the path
  to several modules used in this file.
  Author: JThompson@lunavi.com
  Date: 2024-02-15

  2024/03/15 - jt, added modules to create vpn local network gateway and default s2s connection.

*/


metadata name = 'ALZ Bicep - Hub Networking Module'
metadata description = 'ALZ Bicep Module used to set up Hub Networking'

type subnetOptionsType = ({
  @description('Name of subnet.')
  name: string

  @description('IP-address range for subnet.')
  ipAddressRange: string

  @description('Id of Network Security Group to associate with subnet.')
  networkSecurityGroupId: string?

  @description('Id of Route Table to associate with subnet.')
  routeTableId: string?

  @description('Name of the delegation to create for the subnet.')
  delegation: string?
})[]

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@sys.description('Name for Hub Network.')
param parHubNetworkName string = '${parCompanyPrefix}-hub-${parLocation}'

@sys.description('The IP address range for Hub Network.')
param parHubNetworkAddressPrefix string = '10.10.0.0/16'

@sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.10.15.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.10.252.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.10.254.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.10.253.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@sys.description('Public IP Address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIpSku string = 'Standard'

@sys.description('Optional Prefix for Public IPs. Include a succedent dash if required. Example: prefix-')
param parPublicIpPrefix string = ''

@sys.description('Optional Suffix for Public IPs. Include a preceding dash if required. Example: -suffix')
param parPublicIpSuffix string = '-PublicIP'

@sys.description('Switch to enable/disable Azure Bastion deployment.')
param parAzBastionEnabled bool = true

@sys.description('Name Associated with Bastion Service.')
param parAzBastionName string = '${parCompanyPrefix}-bastion-${parLocation}'

@sys.description('Azure Bastion SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parAzBastionSku string = 'Standard'

@sys.description('Switch to enable/disable Bastion native client support. This is only supported when the Standard SKU is used for Bastion as documented here: https://learn.microsoft.com/azure/bastion/native-client')
param parAzBastionTunneling bool = false

@sys.description('Name for Azure Bastion Subnet NSG.')
param parAzBastionNsgName string = 'nsg-AzureBastionSubnet'

@sys.description('Switch to enable/disable DDoS Network Protection deployment.')
param parDdosEnabled bool = true

@sys.description('DDoS Plan Name.')
param parDdosPlanName string = '${parCompanyPrefix}-ddos-plan'

@sys.description('Switch to enable/disable Azure Firewall deployment.')
param parAzFirewallEnabled bool = true

@sys.description('Azure Firewall Name.')
param parAzFirewallName string = '${parCompanyPrefix}-azfw-${parLocation}'

@sys.description('Azure Firewall Policies Name.')
param parAzFirewallPoliciesName string = '${parCompanyPrefix}-azfwpolicy-${parLocation}'

@sys.description('Azure Firewall Tier associated with the Firewall to deploy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param parAzFirewallTier string = 'Standard'

@sys.description('The Azure Firewall Threat Intelligence Mode. If not set, the default value is Alert.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parAzFirewallIntelMode string = 'Alert'

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAzFirewallAvailabilityZones array = []

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the VPN/ER PIP across. Region must support Availability Zones to use. If it does not then leave empty. Ensure that you select a zonal SKU for the ER/VPN Gateway if using Availability Zones for the PIP.')
param parAzErGatewayAvailabilityZones array = []

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the VPN/ER PIP across. Region must support Availability Zones to use. If it does not then leave empty. Ensure that you select a zonal SKU for the ER/VPN Gateway if using Availability Zones for the PIP.')
param parAzVpnGatewayAvailabilityZones array = []

@sys.description('Switch to enable/disable Azure Firewall DNS Proxy.')
param parAzFirewallDnsProxyEnabled bool = true

@sys.description('Array of custom DNS servers used by Azure Firewall')
param parAzFirewallDnsServers array = []

@sys.description('Name of Route table to create for the default route of Hub.')
param parHubRouteTableName string = '${parCompanyPrefix}-hub-routetable'

@sys.description('Switch to enable/disable BGP Propagation on route table.')
param parDisableBgpRoutePropagation bool = false

@sys.description('Switch to enable/disable Private DNS Zones deployment.')
param parPrivateDnsZonesEnabled bool = true

@sys.description('Resource Group Name for Private DNS Zones.')
param parPrivateDnsZonesResourceGroup string = resourceGroup().name

@sys.description('Array of DNS Zones to provision in Hub Virtual Network. Default: All known Azure Private DNS Zones')
param parPrivateDnsZones array = [
  'privatelink.${toLower(parLocation)}.azmk8s.io'
  'privatelink.${toLower(parLocation)}.batch.azure.com'
  'privatelink.${toLower(parLocation)}.kusto.windows.net'
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

@sys.description('Set Parameter to false to skip the addition of a Private DNS Zone for Azure Backup.')
param parPrivateDnsZoneAutoMergeAzureBackupZone bool = true

@sys.description('Resource ID of Failover VNet for Private DNS Zone VNet Failover Links')
param parVirtualNetworkIdToLinkFailover string = ''

//ASN must be 65515 if deploying VPN & ER for co-existence to work: https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager#limits-and-limitations
@sys.description('''Configuration for VPN virtual network gateway to be deployed. If a VPN virtual network gateway is not desired an empty object should be used as the input parameter in the parameter file, i.e.
"parVpnGatewayConfig": {
  "value": {}
}''')
param parVpnGatewayConfig object = {
  name: '${parCompanyPrefix}-Vpn-Gateway'
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
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
  vpnClientConfiguration: {}
}

@sys.description('''Configuration for ExpressRoute virtual network gateway to be deployed. If a ExpressRoute virtual network gateway is not desired an empty object should be used as the input parameter in the parameter file, i.e.
"parExpressRouteGatewayConfig": {
  "value": {}
}''')
param parExpressRouteGatewayConfig object = {
  name: '${parCompanyPrefix}-ExpressRoute-Gateway'
  gatewayType: 'ExpressRoute'
  sku: 'ErGw1AZ'
  vpnType: 'RouteBased'
  vpnGatewayGeneration: 'None'
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

// added 2024/03/15 - jt
@sys.description('Custom IPsec/IKE policy object, if ipsecEncryption is not set, connection will use default values. ')
param parVpnGatewayCustomIPSecPolicy object = {
  saLifeTimeSeconds: 27000
  saDataSizeKilobytes: 102400000
  ipsecEncryption: ''
  ipsecIntegrity: 'SHA256'
  ikeEncryption: 'AES256'
  ikeIntegrity: 'SHA256'
  dhGroup: 'DHGroup24'
  pfsGroup: 'PFS24'
}


@sys.description('Configuration for Local Network Gateway to be deployed if VPN Gateway is configured.')
param parVpnGatewayLocalNetworkGateway object = {
  enableLocalGateway:false
  name: 'lng-${parLocation}-datacentername'
  localGatewayPublicIpAddress: '1.1.1.1'
  localAddressPrefixes: [
    '192.168.0.0/16'
    '172.16.0.0/12'
  ]
}

@sys.description('Configuration for VPN Gateway Connection to be deployed if VPN Gateway is configured.')
param parVpnGatewayConnection object = {
  enableConnection: false
  name: 'con-${parLocation}-datacentername'
  connectionType: 'IPsec'
  vpnSharedKey: 'A1b2C3d4E5f6G7h8I9j0KlMnOpQrStUvWxYz' 
}


@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

@sys.description('Define outbound destination ports or ranges for SSH or RDP that you want to access from Azure Bastion.')
param parBastionOutboundSshRdpPorts array = [ '22', '3389' ]

// Build the list of public IP addresses for the VPN Gateway (added 2024-02-15)
var varVpnPublicIpName = '${parPublicIpPrefix}${parVpnGatewayConfig.name}${parPublicIpSuffix}'
var varVpnActivePublicIpName = '${parPublicIpPrefix}${parVpnGatewayConfig.name}-2${parPublicIpSuffix}'
var virtualGatewayPipNameVar = parVpnGatewayConfig.activeActive ? [
  varVpnPublicIpName
  varVpnActivePublicIpName
] : [
  varVpnPublicIpName
]

// Potential VPN gateway configurations (active-active vs active-passive, added 2024-02-15)
var vpnIpConfiguration = parVpnGatewayConfig.activeActive ? [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${resHubVnet.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: az.resourceId('Microsoft.Network/publicIPAddresses', varVpnPublicIpName)
      }
    }
    name: 'vNetGatewayConfig1'
  }
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${resHubVnet.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: parVpnGatewayConfig.activeActive ? az.resourceId('Microsoft.Network/publicIPAddresses', varVpnActivePublicIpName) : az.resourceId('Microsoft.Network/publicIPAddresses', varVpnPublicIpName)
      }
    }
    name: 'vNetGatewayConfig2'
  }
] : [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${resHubVnet.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: az.resourceId('Microsoft.Network/publicIPAddresses', varVpnPublicIpName)
      }
    }
    name: 'vNetGatewayConfig1'
  }
]

var varSubnetMap = map(range(0, length(parSubnets)), i => {
    name: parSubnets[i].name
    ipAddressRange: parSubnets[i].ipAddressRange
    networkSecurityGroupId: contains(parSubnets[i], 'networkSecurityGroupId') ? parSubnets[i].networkSecurityGroupId : ''
    routeTableId: contains(parSubnets[i], 'routeTableId') ? parSubnets[i].routeTableId : ''
    delegation: contains(parSubnets[i], 'delegation') ? parSubnets[i].delegation : ''
  })

var varSubnetProperties = [for subnet in varSubnetMap: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange

    delegations: (empty(subnet.delegation)) ? null : [
      {
        name: subnet.delegation
        properties: {
          serviceName: subnet.delegation
        }
      }
    ]

    networkSecurityGroup: (subnet.name == 'AzureBastionSubnet' && parAzBastionEnabled) ? {
      id: '${resourceGroup().id}/providers/Microsoft.Network/networkSecurityGroups/${parAzBastionNsgName}'
    } : (empty(subnet.networkSecurityGroupId)) ? null : {
      id: subnet.networkSecurityGroupId
    }

    routeTable: (empty(subnet.routeTableId)) ? null : {
      id: subnet.routeTableId
    }
  }
}]

var varVpnGwConfig = ((!empty(parVpnGatewayConfig)) ? parVpnGatewayConfig : json('{"name": "noconfigVpn"}'))

var varErGwConfig = ((!empty(parExpressRouteGatewayConfig)) ? parExpressRouteGatewayConfig : json('{"name": "noconfigEr"}'))

var varGwConfig = [
  varVpnGwConfig
  varErGwConfig
]

// Customer Usage Attribution Id Telemetry
var varCuaid = '2686e846-5fdc-4d4f-b533-16dcb09d6e6c'

// ZTN Telemetry
var varZtnP1CuaId = '3ab23b1e-c5c5-42d4-b163-1402384ba2db'
var varZtnP1Trigger = (parDdosEnabled && parAzFirewallEnabled && (parAzFirewallTier == 'Premium')) ? true : false

//DDos Protection plan will only be enabled if parDdosEnabled is true.
resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-02-01' = if (parDdosEnabled) {
  name: parDdosPlanName
  location: parLocation
  tags: parTags
}

resource resHubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  dependsOn: [
    resBastionNsg
  ]
  name: parHubNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: parDnsServerIps
    }
    subnets: varSubnetProperties
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan: (parDdosEnabled) ? {
      id: resDdosProtectionPlan.id
    } : null
  }
}

// Replaced ALZ-Bicep public IP module with Azure Verified Module, 2024-02-15
module modBastionPublicIp 'br/public:avm/res/network/public-ip-address:0.2.3' = {
  name: '${uniqueString(deployment().name, parLocation)}-deploy-Bastion-Public-IP'
  params: {
    name: '${parPublicIpPrefix}${parAzBastionName}${parPublicIpSuffix}'
    location: parLocation
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    skuName: parPublicIpSku
  }
}

// module modBastionPublicIp '../publicIp/publicIp.bicep' = if (parAzBastionEnabled) {
//   name: 'deploy-Bastion-Public-IP'
//   params: {
//     parLocation: parLocation
//     parPublicIpName: '${parPublicIpPrefix}${parAzBastionName}${parPublicIpSuffix}'
//     parPublicIpSku: {
//       name: parPublicIpSku
//     }
//     parPublicIpProperties: {
//       publicIpAddressVersion: 'IPv4'
//       publicIpAllocationMethod: 'Static'
//     }
//     parTags: parTags
//     parTelemetryOptOut: parTelemetryOptOut
//   }
// }

resource resBastionSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  parent: resHubVnet
  name: 'AzureBastionSubnet'
}

resource resBastionNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = if (parAzBastionEnabled) {
  name: parAzBastionNsgName
  location: parLocation
  tags: parTags

  properties: {
    securityRules: [
      // Inbound Rules
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 130
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 140
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 150
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          priority: 4096
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
        }
      }
      // Outbound Rules
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 100
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: parBastionOutboundSshRdpPorts
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 110
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 120
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 130
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 4096
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// AzureBastionSubnet is required to deploy Bastion service. This subnet must exist in the parsubnets array if you enable Bastion Service.
// There is a minimum subnet requirement of /27 prefix.
// If you are deploying standard this needs to be larger. https://docs.microsoft.com/en-us/azure/bastion/configuration-settings#subnet
resource resBastion 'Microsoft.Network/bastionHosts@2023-02-01' = if (parAzBastionEnabled) {
  location: parLocation
  name: parAzBastionName
  tags: parTags
  sku: {
    name: parAzBastionSku
  }
  properties: {
    dnsName: uniqueString(resourceGroup().id)
    enableTunneling: (parAzBastionSku == 'Standard' && parAzBastionTunneling) ? parAzBastionTunneling : false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${resHubVnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: parAzBastionEnabled ? modBastionPublicIp.outputs.resourceId : ''
          }
        }
      }
    ]
  }
}

//            id: resBastionSubnetRef.id
// resource resGatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
//   parent: resHubVnet
//   name: 'GatewaySubnet'
// }


// Replaced ALZ-Bicep public IP module with Azure Verified Module, 2024-02-15
// splitting out Vpn and ER public IPs to separate modules for simplicity
@batchSize(1)
module modGatewayPublicIp 'br/public:avm/res/network/public-ip-address:0.2.3' = [for (virtualGatewayPublicIpName, index) in virtualGatewayPipNameVar: if(varVpnGwConfig.name != 'noconfigVpn') {
  name: '${uniqueString(deployment().name, parLocation)}-deploy-Vpn-Public-IP-${index}'
  params: {
    name: virtualGatewayPublicIpName
    location: parLocation
    skuName: parPublicIpSku
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    zones: parPublicIpSku != 'Basic' ? parAzVpnGatewayAvailabilityZones : []
  }
}]

// module modGatewayPublicIp '../publicIp/publicIp.bicep' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
//   name: 'deploy-Gateway-Public-IP-${i}'
//   params: {
//     parLocation: parLocation
//     parAvailabilityZones: toLower(gateway.gatewayType) == 'expressroute' ? parAzErGatewayAvailabilityZones : toLower(gateway.gatewayType) == 'vpn' ? parAzVpnGatewayAvailabilityZones : []
//     parPublicIpName: '${parPublicIpPrefix}${gateway.name}${parPublicIpSuffix}'
//     parPublicIpProperties: {
//       publicIpAddressVersion: 'IPv4'
//       publicIpAllocationMethod: 'Static'
//     }
//     parPublicIpSku: {
//       name: parPublicIpSku
//     }
//     parTags: parTags
//     parTelemetryOptOut: parTelemetryOptOut
//   }
// }]

//Minumum subnet size is /27 supporting documentation https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub
resource resGateway 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
  name: gateway.name
  location: parLocation
  tags: parTags
  dependsOn: [
    modGatewayPublicIp
  ]
  properties: {
    activeActive: gateway.activeActive
    enableBgp: gateway.enableBgp
    enableBgpRouteTranslationForNat: gateway.enableBgpRouteTranslationForNat
    enableDnsForwarding: gateway.enableDnsForwarding
    bgpSettings: (gateway.enableBgp) ? gateway.bgpSettings : null
    gatewayType: gateway.gatewayType
    vpnGatewayGeneration: (toLower(gateway.gatewayType) == 'vpn') ? gateway.generation : 'None'
    vpnType: gateway.vpnType
    sku: {
      name: gateway.sku
      tier: gateway.sku
    }
    vpnClientConfiguration: (toLower(gateway.gatewayType) == 'vpn') ? {
      vpnClientAddressPool: contains(gateway.vpnClientConfiguration, 'vpnClientAddressPool') ? gateway.vpnClientConfiguration.vpnClientAddressPool : ''
      vpnClientProtocols: contains(gateway.vpnClientConfiguration, 'vpnClientProtocols') ? gateway.vpnClientConfiguration.vpnClientProtocols : ''
      vpnAuthenticationTypes: contains(gateway.vpnClientConfiguration, 'vpnAuthenticationTypes') ? gateway.vpnClientConfiguration.vpnAuthenticationTypes : ''
      aadTenant: contains(gateway.vpnClientConfiguration, 'aadTenant') ? gateway.vpnClientConfiguration.aadTenant : ''
      aadAudience: contains(gateway.vpnClientConfiguration, 'aadAudience') ? gateway.vpnClientConfiguration.aadAudience : ''
      aadIssuer: contains(gateway.vpnClientConfiguration, 'aadIssuer') ? gateway.vpnClientConfiguration.aadIssuer : ''
      vpnClientRootCertificates: contains(gateway.vpnClientConfiguration, 'vpnClientRootCertificates') ? gateway.vpnClientConfiguration.vpnClientRootCertificates : ''
      radiusServerAddress: contains(gateway.vpnClientConfiguration, 'radiusServerAddress') ? gateway.vpnClientConfiguration.radiusServerAddress : ''
      radiusServerSecret: contains(gateway.vpnClientConfiguration, 'radiusServerSecret') ? gateway.vpnClientConfiguration.radiusServerSecret : ''
    } : null
    ipConfigurations: (toLower(gateway.gatewayType) == 'vpn') ? vpnIpConfiguration : []
  }
}]

module modVpnLocalNetworkGateway 'br/public:avm/res/network/local-network-gateway:0.1.1' = if(parVpnGatewayLocalNetworkGateway.enableLocalGateway) {
  name: 'modVpnLocalNetworkGateway'
  params: {
    location: parLocation
    localAddressPrefixes: parVpnGatewayLocalNetworkGateway.localAddressPrefixes
    localGatewayPublicIpAddress: parVpnGatewayLocalNetworkGateway.localGatewayPublicIpAddress
    name: parVpnGatewayLocalNetworkGateway.name
  }
} 

module modVpnGatewayConnection 'br/public:avm/res/network/connection:0.1.1' = if(parVpnGatewayConnection.enableConnection) {
  name: 'modVpnGatewayConnection'
  params: {
    location: parLocation
    name: parVpnGatewayConnection.name
    connectionType: parVpnGatewayConnection.connectionType
    vpnSharedKey: parVpnGatewayConnection.vpnSharedKey
    customIPSecPolicy: parVpnGatewayCustomIPSecPolicy
    virtualNetworkGateway1: resGateway[0]
    localNetworkGateway2: modVpnLocalNetworkGateway
  }
}

resource resAzureFirewallSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  parent: resHubVnet
  name: 'AzureFirewallSubnet'
}

resource resAzureFirewallMgmtSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureFirewallManagementSubnet'))) {
  parent: resHubVnet
  name: 'AzureFirewallManagementSubnet'
}

// Replaced ALZ-Bicep public IP module with Azure Verified Module, 2024-02-15
module modAzureFirewallPublicIp 'br/public:avm/res/network/public-ip-address:0.2.3' = if (parAzFirewallEnabled) {
  name: '${uniqueString(deployment().name, parLocation)}-deploy-Firewall-Public-IP'
  params: {
    name: '${parPublicIpPrefix}${parAzFirewallName}${parPublicIpSuffix}'
    location: parLocation
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    zones: parAzFirewallAvailabilityZones
    skuName: parPublicIpSku
    tags: parTags
  }
}

// module modAzureFirewallPublicIp '../publicIp/publicIp.bicep' = if (parAzFirewallEnabled) {
//   name: 'deploy-Firewall-Public-IP'
//   params: {
//     parLocation: parLocation
//     parAvailabilityZones: parAzFirewallAvailabilityZones
//     parPublicIpName: '${parPublicIpPrefix}${parAzFirewallName}${parPublicIpSuffix}'
//     parPublicIpProperties: {
//       publicIpAddressVersion: 'IPv4'
//       publicIpAllocationMethod: 'Static'
//     }
//     parPublicIpSku: {
//       name: parPublicIpSku
//     }
//     parTags: parTags
//     parTelemetryOptOut: parTelemetryOptOut
//   }
// }

// Replaced ALZ-Bicep public IP module with Azure Verified Module, 2024-02-15
module modAzureFirewallMgmtPublicIp 'br/public:avm/res/network/public-ip-address:0.2.3' = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureFirewallManagementSubnet')))  {
  name: '${uniqueString(deployment().name, parLocation)}-deploy-Firewall-mgmt-Public-IP'
  params: {
    name: '${parPublicIpPrefix}${parAzFirewallName}-mgmt${parPublicIpSuffix}'
    location: parLocation
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    zones: parAzFirewallAvailabilityZones
    skuName: parPublicIpSku
    tags: parTags
  }
}

// module modAzureFirewallMgmtPublicIp '../publicIp/publicIp.bicep' = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureFirewallManagementSubnet'))) {
//   name: 'deploy-Firewall-mgmt-Public-IP'
//   params: {
//     parLocation: parLocation
//     parAvailabilityZones: parAzFirewallAvailabilityZones
//     parPublicIpName: '${parPublicIpPrefix}${parAzFirewallName}-mgmt${parPublicIpSuffix}'
//     parPublicIpProperties: {
//       publicIpAddressVersion: 'IPv4'
//       publicIpAllocationMethod: 'Static'
//     }
//     parPublicIpSku: {
//       name: 'Standard'
//     }
//     parTags: parTags
//     parTelemetryOptOut: parTelemetryOptOut
//   }
// }

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2023-02-01' = if (parAzFirewallEnabled) {
  name: parAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: (parAzFirewallTier == 'Basic') ? {
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: 'Alert'
  } : {
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
      servers: parAzFirewallDnsServers
    }
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: parAzFirewallIntelMode
  }
}

// AzureFirewallSubnet is required to deploy Azure Firewall . This subnet must exist in the parsubnets array if you deploy.
// There is a minimum subnet requirement of /26 prefix.
resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2023-02-01' = if (parAzFirewallEnabled) {
  dependsOn: [
    resGateway
  ]
  name: parAzFirewallName
  location: parLocation
  tags: parTags
  zones: (!empty(parAzFirewallAvailabilityZones) ? parAzFirewallAvailabilityZones : [])
  properties: parAzFirewallTier == 'Basic' ? {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resAzureFirewallSubnetRef.id
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? modAzureFirewallPublicIp.outputs.resourceId : ''
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'mgmtIpConfig'
      properties: {
        publicIPAddress: {
          id: parAzFirewallEnabled ? modAzureFirewallMgmtPublicIp.outputs.resourceId : ''
        }
        subnet: {
          id: resAzureFirewallMgmtSubnetRef.id
        }
      }
    }
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  } : {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resAzureFirewallSubnetRef.id
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? modAzureFirewallPublicIp.outputs.resourceId : ''
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  }
}

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
resource resHubRouteTable 'Microsoft.Network/routeTables@2023-02-01' = if (parAzFirewallEnabled) {
  name: parHubRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    routes: [
      {
        name: 'udr-default-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parAzFirewallEnabled ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
}

module modPrivateDnsZones '../../upstream-releases/v0.17.0/infra-as-code/bicep/modules/privateDnsZones/privateDnsZones.bicep' = if (parPrivateDnsZonesEnabled) {
  name: 'deploy-Private-DNS-Zones'
  scope: resourceGroup(parPrivateDnsZonesResourceGroup)
  params: {
    parLocation: parLocation
    parTags: parTags
    parVirtualNetworkIdToLink: resHubVnet.id
    parVirtualNetworkIdToLinkFailover: parVirtualNetworkIdToLinkFailover
    parPrivateDnsZones: parPrivateDnsZones
    parPrivateDnsZoneAutoMergeAzureBackupZone: parPrivateDnsZoneAutoMergeAzureBackupZone
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Optional Deployments for Customer Usage Attribution
module modCustomerUsageAttribution '../../upstream-releases/v0.17.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}

module modCustomerUsageAttributionZtnP1 '../../upstream-releases/v0.17.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut && varZtnP1Trigger) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varZtnP1CuaId}-${uniqueString(resourceGroup().location)}'
  params: {}
}

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallPrivateIp string = parAzFirewallEnabled ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallName string = parAzFirewallEnabled ? parAzFirewallName : ''

output outPrivateDnsZones array = (parPrivateDnsZonesEnabled ? modPrivateDnsZones.outputs.outPrivateDnsZones : [])
output outPrivateDnsZonesNames array = (parPrivateDnsZonesEnabled ? modPrivateDnsZones.outputs.outPrivateDnsZonesNames : [])

output outDdosPlanResourceId string = resDdosProtectionPlan.id
output outHubVirtualNetworkName string = resHubVnet.name
output outHubVirtualNetworkId string = resHubVnet.id
