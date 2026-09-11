---
layout: post
title: Azure Network Security Perimeter ou Private Endpoint - lequel utiliser ?
date: 2026-09-24
categories: [Azure, Network Security Perimeter]
comments_id: 220 
---

Azure Network Security Perimeter et les Private Endpoints sont deux mécanismes puissants pour renforcer la protection des ressources, mais ils ne sont pas interchangeables. Comprendre leurs différences est essentiel lors de la conception d'architectures Azure sécurisées.

Les Private Endpoints se concentrent principalement sur la création d'un chemin réseau privé vers un service Azure spécifique. Ils sont souvent utilisés pour garantir que le trafic reste au sein d'un réseau virtuel et évite Internet public. À l'inverse, NSP se concentre sur la limite de sécurité autour d'une ressource et fournit un modèle de contrôle d'accès plus large pour protéger des groupes de ressources.

## Quand les Private Endpoints sont un choix pertinent

Les Private Endpoints sont idéaux lorsque vous souhaitez :

- Garantir qu'une ressource est accessible uniquement via un chemin réseau privé
- Réduire l'exposition au point de terminaison public
- Mettre en place une isolation réseau forte pour un service spécifique

## Quand NSP est plus adapté

NSP est généralement plus pertinent lorsque vous souhaitez :

- Protéger un ensemble de ressources liées avec des règles d'accès communes
- Appliquer de manière cohérente des stratégies de sécurité centrées sur les ressources
- Améliorer la gouvernance dans un environnement Azure plus vaste

## Une manière concrète de les distinguer

Une manière utile de comprendre leur relation est la suivante : les Private Endpoints se concentrent sur la connectivité, tandis que NSP se concentre sur le contrôle d'accès fondé sur un périmètre. Dans de nombreuses architectures, ils sont complémentaires plutôt que concurrents.

Vous pouvez utiliser des Private Endpoints pour isoler un service critique et NSP pour imposer une limite de sécurité cohérente autour d'un ensemble de ressources qui partagent les mêmes exigences de protection.

## Un exemple de comparaison en Bicep

Voici un petit exemple qui présente les deux modèles à haut niveau :

```bicep
targetScope = 'resourceGroup'

@description('Storage account that should be reachable through a private path')
param storageAccountId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-prod/providers/Microsoft.Storage/storageAccounts/stdataprod001'

@description('Subnet used for the private endpoint')
param privateSubnetId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/snet-private-endpoints'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-11-01' = {
  name: 'pe-stdataprod001'
  location: resourceGroup().location
  tags: {
    Environment: 'prod'
    Purpose: 'Private access'
  }
  properties: {
    subnet: {
      id: privateSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-stdataprod001-blob'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [ 'blob' ]
        }
      }
    ]
  }
}

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: 'app-prod-nsp'
  location: 'global'
  tags: {
    Environment: 'prod'
    SecurityBoundary: 'Shared services'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-app-subnet'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow application workloads to reach protected services'
          addressPrefixes: [
            '10.15.40.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Use this when you need a resource-centric access control model
    // for a group of protected services.
  }
}
```

Le point de terminaison privé crée un chemin privé, tandis que le périmètre se concentre sur la stratégie d'accès autour des ressources protégées. Dans de nombreuses architectures, les deux sont utiles, mais pour des raisons différentes.

## Recommandation finale

Si vous hésitez encore entre les deux, commencez par vous demander quel problème vous cherchez à résoudre. Si vous avez besoin d'une connectivité privée, les Private Endpoints sont la réponse naturelle. Si vous avez besoin d'un contrôle d'accès plus fort et plus centralisé pour les ressources protégées, NSP mérite d'être sérieusement envisagé.

Dans le prochain article, je montrerai comment appliquer ces concepts dans une architecture Azure réaliste.
