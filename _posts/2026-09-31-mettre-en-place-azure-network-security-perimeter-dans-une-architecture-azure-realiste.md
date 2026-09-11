---
layout: post
title: Mettre en place Azure Network Security Perimeter dans une architecture Azure réaliste
date: 2026-09-31
categories: [Azure, Network Security Perimeter]
githubcommentIdtoreplace: 
---

Lorsque vous atteignez l'étape de mise en œuvre, Azure Network Security Perimeter devient beaucoup plus concret. Sa véritable valeur apparaît lorsque vous l'appliquez à une architecture qui comprend déjà des services partagés, des charges de travail et plusieurs équipes.

Un scénario courant est celui d'une landing zone dans laquelle plusieurs applications utilisent des services Azure PaaS tels que Storage, Key Vault et App Service. Dans ce type d'environnement, NSP peut vous aider à définir la limite de confiance autour des ressources sensibles et à clarifier les attentes en matière d'accès.

## Un modèle d'architecture

Un modèle pratique peut ressembler à ceci :

- Une couche de plateforme partagée comprenant l'identité, la supervision et les services partagés
- Des charges de travail applicatives déployées dans différents espaces de travail ou abonnements
- Des services protégés qui ne doivent être accessibles que depuis des chemins internes approuvés
- Des stratégies d'accès alignées sur les exigences métier et de sécurité

Dans ce type de configuration, NSP permet d'imposer la limite sans obliger à repenser chaque ressource depuis zéro.

## Considérations relatives à la mise en œuvre

Lorsque vous mettez en œuvre NSP dans un environnement réel, il est utile de commencer avec un périmètre limité. Choisissez quelques ressources critiques, définissez leur modèle d'accès attendu et validez la stratégie avant de l'étendre davantage. Cette approche est généralement plus facile à gérer que de tenter de tout sécuriser en même temps.

Vous devez également impliquer les équipes responsables des ressources. Elles connaissent souvent mieux que quiconque les flux d'accès légitimes, et ce contexte est essentiel pour élaborer des stratégies précises.

## Un exemple Bicep plus réaliste

Dans une landing zone, vous pouvez commencer par une définition simple du périmètre, puis l'étendre à mesure que vos règles d'accès deviennent plus claires :

```bicep
targetScope = 'resourceGroup'

@description('Name of the perimeter used in the landing zone')
param perimeterName string = 'landingzone-prod-nsp'

@description('Key Vault instance to protect within the perimeter')
param keyVaultId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.KeyVault/vaults/kv-platform-prod'

@description('App Service that shares the same trust boundary')
param appServiceId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod/providers/Microsoft.Web/sites/app-prod-api'

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: perimeterName
  location: 'global'
  tags: {
    Environment: 'prod'
    Platform: 'LandingZone'
    Owner: 'Platform Engineering'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-platform-operations'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow platform operations and automation services'
          addressPrefixes: [
            '10.30.10.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Link protected resources and define approved inbound sources here.
  }
}

output perimeterId string = perimeter.id
output protectedResources array = [
  keyVaultId
  appServiceId
]
```

Ce squelette constitue un bon point de départ pour un environnement de plateforme partagée. À partir de là, vous pouvez affiner les règles afin que seules les applications, identités et services prévus soient autorisés à accéder à la limite protégée.

## Le bénéfice à long terme

Le principal avantage de NSP n'est pas uniquement de renforcer la sécurité. Il permet également d'améliorer la cohérence. Lorsque le contrôle d'accès est exprimé de manière claire et réutilisable, il devient plus facile à maintenir dans le temps et beaucoup plus simple à expliquer aux autres équipes.

Si vous prévoyez de renforcer votre posture réseau Azure, NSP mérite d'être étudié dans le cadre d'une stratégie plus large incluant la connectivité privée, les contrôles d'identité et la supervision.
