using './solution.bicep'

param activeDirectorySolution = 'ActiveDirectoryDomainServices'
param artifactsContainerName = 'artifacts'
param artifactsStorageAccountResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/z-dev-base/providers/Microsoft.Storage/storageAccounts/sadevbase'
param avdAgentMsiName = 'Microsoft.RDInfra.RDAgent.Installer-x64-1.0.8431.2300.msi'
param avdAgentBootLoaderMsiName = 'Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-1.0.8925.0.msi'
param avdObjectId = '2d16a517-86ed-45ae-a1ce-d4b991776f9b'
param azurePowerShellModuleMsiName = 'Az-Cmdlets-10.2.0.37547-x64.msi'
param deployActivityLogDiagnosticSetting = false
param deployDefender = false
param deployNetworkWatcherControlPlane = false
param deployNetworkWatcherVirtualMachines = false
param deployPolicy = false
param emailSecurityContact = 'shjaquay@microsoft.com'
param hostPoolPublicNetworkAccess = 'Enabled'
param hubAzureFirewallResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-hub-prod-va/providers/Microsoft.Network/azureFirewalls/ccthis-afw-hub-prod-va'
//This will be your production hub Azure Firewall
param hubVirtualNetworkResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-hub-prod-va/providers/Microsoft.Network/virtualNetworks/ccthis-vnet-hub-prod-va'
param operationsLogAnalyticsWorkspaceResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-operations-prod-va/providers/Microsoft.OperationalInsights/workspaces/ccthis-log-operations-prod-va'
param securityPrincipals = [
  {
    name: 'AVD-Users-PersonalDesktops'
    objectId: '49f065f5-992a-4ffb-beac-aadb290a489a'
  }
]
param sharedServicesSubnetResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-sharedServices-prod-va/providers/Microsoft.Network/virtualNetworks/ccthis-vnet-sharedServices-prod-va'
param virtualMachineVirtualCpuCount = 2
param virtualMachinePassword = '!QAZXSW@1qazxsw2'
param virtualMachineUsername = 'localadmin'
param workspacePublicNetworkAccess = 'Enabled'
//Required in this config
param domainJoinPassword = '!QAZXSW@1qazxsw2'
param domainJoinUserPrincipalName = 'localadmin@ccthis.us'
param domainName = 'ccthis.us'
param hostPoolType = 'Personal Automatic'
param identifier = 'avd'
//3 character limit
param imageVersionResourceId = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-sharedServices-prod-va/providers/Microsoft.Compute/galleries/ccthis_cg_aib/images/ccthis-id-aib/versions/0.0.3'
//This is your custom image



//Optional Parameters
//param azureNetAppFilesSubnetAddressPrefix = null
param customRdpProperty = 'audiocapturemode:i:1;camerastoredirect:s:*;use multimon:i:0;drivestoredirect:s:;encode redirected video capture:i:1;redirected video capture encoding quality:i:1;audiomode:i:0;devicestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectlocation:i:1;redirectprinters:i:0;redirectsmartcards:i:1;redirectwebauthn:i:1;usbdevicestoredirect:s:;keyboardhook:i:2;'
//param deploymentNameSuffix = null
//param desktopFriendlyName = null
param diskSku = 'Standard_LRS'
//param drainMode = null
param environmentAbbreviation = 'prod'
param fslogixShareSizeInGB = 100
//param fslogixContainerType = null
param fslogixStorageService = 'None'
//param imageOffer = null
param imagePublisher = 'MicrosoftWindowsDesktop'
//param imageSku = null
param locationControlPlane = 'usgovvirginia'
param locationVirtualMachines = 'usgovvirginia'
param logAnalyticsWorkspaceRetention = 30
param logAnalyticsWorkspaceSku = 'PerGB2018'
//param monitoring = null
param organizationalUnitPath = 'OU=Devices,OU=AVD,DC=ccthis,DC=us'
//OU location for session hosts
//param policy = null
//param recoveryServices = null
param scalingBeginPeakTime = '09:00'
param scalingEndPeakTime = '17:00'
param scalingLimitSecondsToForceLogOffUser = '0'
param scalingMinimumNumberOfRdsh = '0'
param scalingSessionThresholdPerCPU = '1'
//param scalingTool = null
param sessionHostCount = 1
// param sessionHostIndex = null
// // param sharedServicesSubnetAddressPrefix = '/subscriptions/010ca3d8-1b48-4035-9750-dc6009796c51/resourceGroups/ccthis-rg-network-sharedServices-prod-va/providers/Microsoft.Network/virtualNetworks/ccthis-vnet-sharedServices-prod-va/subnets/ccthis-snet-sharedServices-prod-va'
// param stampIndex = null
// param storageCount = null
// param storageIndex = null
param subnetAddressPrefixes = [
                                '10.0.140.0/24'
                              ]
param tags = {
                costCenter: 'CC-1234'
                environment: 'prod'
                project: 'AVD'
                resourceType: 'AVD'
              }
param usersPerCore = 1
param validationEnvironment = false
param virtualMachineMonitoringAgent = 'AzureMonitorAgent'
//LogAnalytics is being depreciated on 8/31/24
param virtualMachineSize = 'Standard_D2s_v5'
param virtualNetworkAddressPrefixes = [
                                        '10.0.140.0/24'
                                      ]
//param workspaceFriendlyName = null


