

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
  name: 'avd-0-vdpool-avd-prod-va'
  scope: resourceGroup('010ca3d8-1b48-4035-9750-dc6009796c51', 'avd-0-rg-controlPlane-avd-prod-va')
}

output token string = hostPool.listRegistrationTokens().value[0].token
