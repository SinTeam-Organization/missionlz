param artifactsUri string
param automationAccountName string
param deploymentNameSuffix string
param deploymentUserAssignedIdentityClientId string
param fslogixContainerType string
param location string
param managementVirtualMachineName string
param storageAccountNamePrefix string
param storageCount int
param storageIndex int
param storageResourceGroupName string
param tags object
param timeZone string

var runbookFileName = 'Set-FileShareScaling.ps1'
var scriptFileName = 'Set-AutomationRunbook.ps1'
var subscriptionId = subscription().subscriptionId

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

module runbook '../common/customScriptExtensions.bicep' = {
  name: 'deploy-runbook-${deploymentNameSuffix}'
  params: {
    fileUris: [
      '${artifactsUri}${runbookFileName}'
      '${artifactsUri}${scriptFileName}'
    ]
    location: location
    parameters: '-AutomationAccountName ${automationAccountName} -Environment ${environment().name} -ResourceGroupName ${resourceGroup().name} -RunbookFileName ${runbookFileName} -SubscriptionId ${subscription().subscriptionId} -TenantId ${tenant().tenantId} -UserAssignedIdentityClientId ${deploymentUserAssignedIdentityClientId}'
    scriptFileName: scriptFileName
    tags: tags
    userAssignedIdentityClientId: deploymentUserAssignedIdentityClientId
    virtualMachineName: managementVirtualMachineName
  }
}

module schedules 'schedules.bicep' = [for i in range(storageIndex, storageCount): {
  name: 'deploy-schedules-${i}-${deploymentNameSuffix}'
  params: {
    automationAccountName: automationAccount.name
    fslogixContainerType: fslogixContainerType
    storageAccountName: '${storageAccountNamePrefix}${padLeft(i, 2, '0')}'
    timeZone: timeZone
  }
}]

module jobSchedules 'jobSchedules.bicep' = [for i in range(storageIndex, storageCount): {
  name: 'deploy-job-schedules-${i}-${deploymentNameSuffix}'
  params: {
    automationAccountName: automationAccount.name
    environment: environment().name
    fslogixContainerType: fslogixContainerType
    runbookName: replace(runbookFileName, '.ps1', '')
    resourceGroupName: storageResourceGroupName
    storageAccountName: '${storageAccountNamePrefix}${padLeft(i, 2, '0')}'
    subscriptionId: subscriptionId
  }
  dependsOn: [
    runbook
    schedules
  ]
}]

module roleAssignment '../common/roleAssignment.bicep' = {
  name: 'deploy-role-assignment-storage-${deploymentNameSuffix}'
  scope: resourceGroup(storageResourceGroupName)
  params: {
    principalId: automationAccount.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '17d1049b-9a84-46fb-8f53-869881c3d3ab' // Storage Account Contributor
  }
}
