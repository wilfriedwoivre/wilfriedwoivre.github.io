---
layout: post
title: Comment protéger les ressources PaaS avec Azure Network Security Perimeter
date: 2026-09-17
categories: [Azure, Network Security Perimeter]
githubcommentIdtoreplace:  
---

Les ressources Azure PaaS sont souvent au cœur des applications cloud modernes, mais elles peuvent aussi être difficiles à sécuriser, car elles sont fréquemment accessibles depuis différents services, pipelines et utilisateurs. Azure Network Security Perimeter offre un moyen pratique de définir une limite de sécurité plus stricte autour de ces ressources.

Lorsque vous protégez des ressources PaaS avec NSP, vous ne contrôlez pas uniquement les chemins réseau. Vous définissez également la manière dont la ressource peut être atteinte et par qui. Cela est particulièrement utile pour les services qui stockent des données sensibles ou exposent des API à des systèmes internes.

## Cas d'usage courants

NSP est particulièrement adapté lorsque vous souhaitez :

- Limiter l'accès aux comptes Azure Storage utilisés par des charges de travail critiques
- Protéger les instances Key Vault contre tout accès public inutile
- Réduire l'exposition des applications web et des autres services managés
- Appliquer des contrôles d'accès cohérents à plusieurs ressources d'un même environnement

## Approche recommandée

Un déploiement pratique commence généralement par l'identification des ressources qui nécessitent le niveau de protection le plus élevé. Vous définissez ensuite le périmètre et déterminez quelles identités ou quels services sont autorisés à se connecter. L'objectif est d'éviter des règles d'accès trop larges tout en maintenant l'environnement opérationnel.

Dans de nombreux cas, NSP est plus efficace lorsqu'il est associé à d'autres mécanismes de sécurité Azure tels que les points de terminaison privés, le contrôle d'accès en fonction du rôle et la supervision centralisée.

## Un squelette Bicep pour un périmètre PaaS protégé

Voici une manière simple de représenter le périmètre sous forme d'infrastructure as code :

```bicep
targetScope = 'resourceGroup'

@description('Name of the perimeter protecting shared PaaS resources')
param perimeterName string = 'shared-paas-prod-nsp'

@description('Storage account that should be protected by the perimeter')
param storageAccountId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod/providers/Microsoft.Storage/storageAccounts/stappprod001'

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: perimeterName
  location: 'global'
  tags: {
    Environment: 'prod'
    Workload: 'FinanceApp'
    SecurityBoundary: 'PaaS'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-shared-services'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow requests from the shared services subnet'
          addressPrefixes: [
            '10.10.20.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Link the protected resource and define any additional policy
    // associations as part of your deployment workflow.
  }
}

output perimeterResourceId string = perimeter.id
output protectedStorageAccountId string = storageAccountId
```

Cet exemple constitue le point d'ancrage de la limite autour de votre ressource protégée. L'étape suivante consiste à définir les règles spécifiques qui autorisent uniquement les identités et les services appropriés à se connecter.

## Points d'attention

L'un des principaux défis lors de la mise en œuvre de NSP consiste à conserver une stratégie compréhensible. Si un périmètre devient trop permissif, son intérêt diminue. Il est préférable de commencer avec un périmètre ciblé et de l'élargir progressivement à mesure que vous validez le modèle d'accès.

Cela rend NSP particulièrement intéressant pour les équipes qui souhaitent appliquer des contrôles réseau sans transformer chaque ressource en projet réseau personnalisé.

Dans le prochain article, je comparerai NSP aux points de terminaison privés et montrerai les domaines dans lesquels chaque approche est la plus pertinente.
