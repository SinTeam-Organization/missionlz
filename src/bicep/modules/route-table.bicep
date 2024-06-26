/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

param location string
param name string
param routeAddressPrefix string
param routeName string
param routeNextHopIpAddress string
param routeNextHopType string
param tags object

resource routeTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    routes: [
      {
        name: routeName
        properties: {
          addressPrefix: routeAddressPrefix
          nextHopIpAddress: routeNextHopIpAddress
          nextHopType: routeNextHopType
        }
      }
    ]
  }
}

output id string = routeTable.id
output name string = routeTable.name
