---
layout: post
title: Azure Network Security Perimeter - Centraliser la gestion de vos ACLs
date: 2024-11-28
categories: [ "Azure", "Network Security Perimeter" ]
comments_id: 193 
---

Durant cet ignite Microsoft a annoncé la sortie en public preview du produit Network Security Perimeter.
Il s'agit aujourd'hui d'une public preview, qui selon moi sera un game changer au niveau de la sécurité de votre Cloud public (bien entendu si toutes les fonctionnalités dont je rêve arrivent un jour)

Vu que le produit est assez complet, je pense que je vais en parler sur plusieurs articles.

Dans cet article on va se concentrer sur la gestion des ACLs de vos services, et plus particulièrement la gestion des IPs sources qui ont accès à vos service.

Commençons par voir comment créer un Network Security Perimeter en bicep:

```bicep
resource nsp 'Microsoft.Network/networkSecurityPerimeters@2023-08-01-preview' = {
  name: 'demo${uniqueString(resourceGroup().id)}'
  location: loc
}
```

Le service est donc créé, maintenant il faut créer des profiles. Et je vous conseille au minima 2 profiles un en mode Learning pour les tests et un en mode Enforce pour appliquer les règles. Selon le bicep il est possible d'avoir un mode Learning mais je creuserai celui ci dans un prochain article afin de bien l'exploiter, car ce mode ne bloque rien comme son nom l'indique.

```bicep
resource nsp_enforce 'Microsoft.Network/networkSecurityPerimeters/profiles@2023-08-01-preview' = {
  name: 'enforce_profile'
  parent: nsp
  location: loc
  properties: {}
}

resource nsp_enforce_accessrule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-08-01-preview' = {
  name: 'allowed_ip'
  parent: nsp_enforce
  location: loc
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '28.38.76.11/32'
      '52.51.0.0/24'
    ]
  }
}
```

Il est important de savoir que les IPs possible à mettre ici doivent absolument être publique.

Et pour finir vous devez associer votre profile à vos ressources Azure, et c'est ici que vous allez définir le mode d'accès à savoir : *Enforced*, *Learning*

```bicep
resource nsp_association_storage 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, sto.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: sto.id
    }
  }
}

resource nsp_association_keyvault 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, key.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode:'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: key.id
    }
  }
}

resource nsp_association_eventhub 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, eventhub.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: eventhub.id
    }
  }
}

```

Maintenant pourquoi je suis ultra fan de Network Security Perimeter, c'est tout simplement parce que je définis la liste des mes IPs qu'à un seul endroit, et je n'ai surtout pas à me soucier de l'appliquer à tous les types de ressources que je protège.
Pour rappel si je voulais faire la même chose en bicep pour mes services storage et keyvault je ferais le bicep suivant :

```bicep

resource sto_without_nsp 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stononsp${uniqueString(resourceGroup().id)}'
  location: loc
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'standard_lrs'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      ipRules: [
        {
          value: '28.38.76.11'
          action: 'Allow'
        }
        {
          value: '52.51.0.0/24'
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource key_without_nsp 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'keynonsp${uniqueString(resourceGroup().id)}'
  location: loc
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      ipRules: [
        {
          value: '28.38.76.11/32'
        }
        {
          value: '52.51.0.0/24'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource eventhub_without_nsp 'Microsoft.EventHub/namespaces@2024-05-01-preview' = {
  name: 'eventhubnonsp${uniqueString(resourceGroup().id)}'
  location: loc
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    isAutoInflateEnabled: false
    disableLocalAuth: true  
  }
}

resource eventhub_without_nspacl 'Microsoft.EventHub/namespaces/networkRuleSets@2024-05-01-preview' = {
  name: 'default'
  parent: eventhub_without_nsp
  properties: {
    defaultAction: 'Deny'
    ipRules: [
      {
        ipMask: '28.38.76.11/32'
        action: 'Allow'
      }
      {
        ipMask: '52.51.0.0/24'
        action: 'Allow'
      }
    ]
  }
}
```

J'ai donc pour mon Storage, KeyVault et EventHub 3 implémenations différentes pour mettre mes IPs rules.
Ici Azure Storage ne supporte pas les ranges en /32, on est donc obligé de mettre l'ip, et pour Event Hub il s"agit d'une sous ressource.

On voit donc que Network Security Perimeter nous aidera à simplifier nos infra as code sans plus se préoccuper de cette partie.
Ou même d'une gestion complexe de policy à mettre en place pour ajouter de manière automatique toutes les ips que l'on souhaite.

Maintenant il s'agit d'une preview, et donc j'espère que d'autres fonctionnalités vont arriver car pour le moment les gros bloqueurs que je vois à l'adoption aujourd'hui sont les suivants : 

- On ne voit pas les éléments de sécurité si on regarde le détail du service via le portail, ou via les commandes Powershell, par exemple:

```powershell
➜  (Get-AzKeyVault -name $keyVaultName -ResourceGroupName nsp).NetworkAcls

DefaultAction                 : Allow
Bypass                        : AzureServices
IpAddressRanges               :
IpAddressRangesText           :
VirtualNetworkResourceIds     :
VirtualNetworkResourceIdsText :
```

- Pas d'intégration dans Microsoft Defender for Cloud, mes ressources ont toujours l'air exposée. Et je suppose que c'est la même chose pour les autres CNAPP.

- Tous les services Azure ne sont pas supportés par exemple pour les IP Rules.

Mais pour moi il s'agit d'un service à surveiller car il sera un game changer pour l'avenir de la sécurité périmétrique dans le Cloud public.

Dîtes moi en commentaire si vous avez d'autres aspects du service que vous voulez que je creuse.