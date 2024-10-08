param activeDirectorySolution string
param artifactsUri string
param automationAccountName string
param availability string
param azureFilesPrivateDnsZoneResourceId string
param deploymentNameSuffix string
param deploymentUserAssignedIdentityClientId string
@secure()
param domainJoinPassword string
param domainJoinUserPrincipalName string
param enableRecoveryServices bool
param encryptionUserAssignedIdentityResourceId string
param environmentAbbreviation string
param fileShares array
param fslogixShareSizeInGB int
param fslogixContainerType string
param fslogixStorageService string
param hostPoolType string
param identifier string
param keyVaultUri string
param location string
param managementVirtualMachineName string
param netbios string
param organizationalUnitPath string
param recoveryServicesVaultName string
param resourceGroupManagement string
param resourceGroupStorage string
param securityPrincipalObjectIds array
param securityPrincipalNames array
param serviceName string
@minLength(3)
param storageAccountNamePrefix string
param storageAccountNetworkInterfaceNamePrefix string
param storageAccountPrivateEndpointNamePrefix string
param storageCount int
param storageEncryptionKeyName string
param storageIndex int
param storageSku string
param storageService string
param subnetResourceId string
param tagsAutomationAccounts object
param tagsPrivateEndpoints object
param tagsRecoveryServicesVault object
param tagsStorageAccounts object
param tagsVirtualMachines object
param timeZone string

var roleDefinitionId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb' // Storage File Data SMB Share Contributor 
var smbMultiChannel = {
  multichannel: {
    enabled: true
  }
}
var smbSettings = {
  versions: 'SMB3.1.1;'
  authenticationMethods: 'NTLMv2;Kerberos;'
  kerberosTicketEncryption: 'AES-256;'
  channelEncryption: 'AES-128-GCM;AES-256-GCM;'
}
var storageRedundancy = availability == 'availabilityZones' ? '_ZRS' : '_LRS'
var uniqueToken = uniqueString(identifier, environmentAbbreviation, subscription().subscriptionId)

resource storageAccounts 'Microsoft.Storage/storageAccounts@2022-09-01' = [for i in range(0, storageCount): {
  name: take('${storageAccountNamePrefix}${padLeft(i + storageIndex, 2, '0')}${uniqueToken}', 24)
  location: location
  tags: tagsStorageAccounts
  sku: {
    name: '${storageSku}${storageRedundancy}'
  }
  kind: storageSku == 'Standard' ? 'StorageV2' : 'FileStorage'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${encryptionUserAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'PrivateLink'
    allowSharedKeyAccess: true
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: activeDirectorySolution == 'MicrosoftEntraDomainServices' ? 'AADDS' : 'None'
    }
    defaultToOAuthAuthentication: false
    dnsEndpointType: 'Standard'
    encryption: {
      identity: {
        userAssignedIdentity: encryptionUserAssignedIdentityResourceId
      }
      requireInfrastructureEncryption: true
      keyvaultproperties: {
          keyvaulturi: keyVaultUri
          keyname: storageEncryptionKeyName
      }
      services: storageSku == 'Standard' ? {
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
            keyType: 'Account'
            enabled: true
        }
        blob: {
            keyType: 'Account'
            enabled: true
        }
      } : {
        file: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.KeyVault'
    }
    largeFileSharesState: storageSku == 'Standard' ? 'Enabled' : null
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
  }
}]

// Assigns the SMB Contributor role to the Storage Account so users can save their profiles to the file share using FSLogix
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(0, storageCount): {
  scope: storageAccounts[i]
  name: guid(securityPrincipalObjectIds[i], roleDefinitionId, storageAccounts[i].id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: securityPrincipalObjectIds[i]
  }
}]

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = [for i in range(0, storageCount): {
  parent: storageAccounts[i]
  name: 'default'
  properties: {
    protocolSettings: {
      smb: storageSku == 'Standard' ? smbSettings : union(smbSettings, smbMultiChannel)
    }
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
}]

module shares 'shares.bicep' = [for i in range(0, storageCount): {
  name: 'deploy-file-shares-${i}-${deploymentNameSuffix}'
  params: {
    fileShares: fileShares
    fslogixShareSizeInGB: fslogixShareSizeInGB
    storageAccountName: storageAccounts[i].name
    storageSku: storageSku
  }
  dependsOn: [
    roleAssignment
  ]
}]

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2023-04-01' = [for i in range(0, storageCount): {
  name: '${replace(storageAccountPrivateEndpointNamePrefix, serviceName, 'file')}-${padLeft(i + storageIndex, 2, '0')}'
  location: location
  tags: tagsPrivateEndpoints
  properties: {
    customNetworkInterfaceName: '${replace(storageAccountNetworkInterfaceNamePrefix, serviceName, 'file')}-${padLeft(i + storageIndex, 2, '0')}'
    privateLinkServiceConnections: [
      {
        name: '${replace(storageAccountPrivateEndpointNamePrefix, serviceName, 'file')}-${padLeft(i + storageIndex, 2, '0')}'
        properties: {
          privateLinkServiceId: storageAccounts[i].id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: subnetResourceId
    }
  }
}]

resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = [for i in range(0, storageCount): {
  parent: privateEndpoints[i]
  name: '${storageAccountNamePrefix}-${padLeft(i + storageIndex, 2, '0')}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'ipconfig1'
        properties: {
          privateDnsZoneId: azureFilesPrivateDnsZoneResourceId
        }
      }
    ]
  }
  dependsOn: [
    storageAccounts
  ]
}]

module ntfsPermissions '../../common/customScriptExtensions.bicep' = if (contains(activeDirectorySolution, 'DomainServices')) {
  name: 'deploy-fslogix-ntfs-permissions-${deploymentNameSuffix}'
  scope: resourceGroup(resourceGroupManagement)
  params: {
    fileUris: [
      '${artifactsUri}Set-NtfsPermissions.ps1'
    ]
    location: location
    parameters: '-domainJoinPassword "${domainJoinPassword}" -domainJoinUserPrincipalName ${domainJoinUserPrincipalName} -activeDirectorySolution ${activeDirectorySolution} -Environment ${environment().name} -fslogixContainerType ${fslogixContainerType} -netbios ${netbios} -organizationalUnitPath "${organizationalUnitPath}" -securityPrincipalNames "${securityPrincipalNames}" -StorageAccountPrefix ${storageAccountNamePrefix} -StorageAccountResourceGroupName ${resourceGroupStorage} -storageCount ${storageCount} -storageIndex ${storageIndex} -storageService ${storageService} -StorageSuffix ${environment().suffixes.storage} -SubscriptionId ${subscription().subscriptionId} -TenantId ${subscription().tenantId} -UniqueToken ${uniqueToken} -UserAssignedIdentityClientId ${deploymentUserAssignedIdentityClientId}'
    scriptFileName: 'Set-NtfsPermissions.ps1'
    tags: tagsVirtualMachines
    userAssignedIdentityClientId: deploymentUserAssignedIdentityClientId
    virtualMachineName: managementVirtualMachineName
  }
  dependsOn: [
    privateDnsZoneGroups
    privateEndpoints
    shares
  ]
}

module recoveryServices 'recoveryServices.bicep' = if (enableRecoveryServices && contains(hostPoolType, 'Pooled')) {
  name: 'deploy-backup-azure-files-${deploymentNameSuffix}'
  scope: resourceGroup(resourceGroupManagement)
  params: {
    deploymentNameSuffix: deploymentNameSuffix
    fileShares: fileShares
    location: location
    recoveryServicesVaultName: recoveryServicesVaultName
    resourceGroupStorage: resourceGroupStorage
    storageAccountNamePrefix: storageAccountNamePrefix
    storageCount: storageCount
    storageIndex: storageIndex
    tagsRecoveryServicesVault: tagsRecoveryServicesVault
  }
  dependsOn: [
    shares
  ]
}

module autoIncreasePremiumFileShareQuota '../../management/autoIncreasePremiumFileShareQuota.bicep' = if (fslogixStorageService == 'AzureFiles Premium' && storageCount > 0) {
  name: 'deploy-file-share-scaling-${deploymentNameSuffix}'
  scope: resourceGroup(resourceGroupManagement)
  params: {
    artifactsUri: artifactsUri
    automationAccountName: automationAccountName
    deploymentNameSuffix: deploymentNameSuffix
    deploymentUserAssignedIdentityClientId: deploymentUserAssignedIdentityClientId
    fslogixContainerType: fslogixContainerType
    location: location
    managementVirtualMachineName: managementVirtualMachineName
    storageAccountNamePrefix: storageAccountNamePrefix
    storageCount: storageCount
    storageIndex: storageIndex
    storageResourceGroupName: resourceGroupStorage
    tags: tagsAutomationAccounts
    timeZone: timeZone
  }
  dependsOn: [
    ntfsPermissions
  ]
}
