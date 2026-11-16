---
layout: post
title: Azure Service Endpoint - Standard vs Basic
date: 2026-11-16
categories: [ "Azure", "Network", "Network Security Perimeter" ]
githubcommentIdtoreplace: 
---

Les service endpoints sont la plus vieille astuce du manuel de la sécurité réseau Azure. Ils sont gratuits, simples, et cela fait des années qu'ils se heurtent discrètement à un mur dès que l'échelle augmente. Le 15 octobre 2026, Microsoft a rendu le service endpoint Standard généralement disponible, et la question intéressante est de savoir s'il vaut la peine de payer pour quelque chose qui était gratuit jusque-là.

Spoiler : cela dépend du nombre de subnets que vous avez, et de votre degré d'aversion pour la maintenance des ACLs.

Un service endpoint *Basic* s'active par subnet et par type de service. Le trafic vers le service PaaS quitte alors votre subnet avec l'identité du subnet, via le backbone Microsoft. Le service PaaS utilise toujours son endpoint public, et vous indiquez à son firewall d'accepter ce subnet :

```bicep
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'snet-app'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      { service: 'Microsoft.Storage' }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stbasicse001'
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        { id: subnet.id, action: 'Allow' }
      ]
    }
  }
}
```

Ça fonctionne, et ça ne coûte rien. Le problème, c'est le modèle : chaque subnet doit être listé sur chaque ressource PaaS. Dans une landing zone avec une douzaine de spokes, quelques subnets chacun et une poignée de storage accounts et de Key Vaults, vous maintenez des centaines d'entrées d'ACL. Chaque nouveau subnet implique de toucher au côté PaaS. À grande échelle, vous commencez aussi à atteindre les limites du resource provider et le throttling.

**Qu'est-ce que le service endpoint Standard ?**

Standard introduit un network identifier : une adresse IP publique que vous attachez au service endpoint sur vos subnets. Cette IP n'est pas utilisée pour le routage. C'est seulement une étiquette qui identifie votre trafic.

Le côté PaaS ne se soucie alors plus des subnets. Vous placez vos ressources dans un Network Security Perimeter et vous ajoutez une seule règle inbound IP correspondant au network identifier. Comme la même IP publique peut être partagée par de nombreux subnets, VNets et même subscriptions (même tenant, même région), une seule règle couvre tout le parc.

L'identifier a des prérequis stricts : une IP publique IPv4 en SKU Standard, statique, qui existe déjà et est en état Succeeded avant de l'associer.

Services supportés à la GA : Storage, Key Vault, SQL Database et Cosmos DB.

Une comparaison rapide des deux services :

|Fonctionnalité|Basic service endpoint|Standard service endpoint|Private Link
|---|---|---|---|
|Connectivité privée (pas d'endpoint public exposé)|Non|Non|Oui
|Accès depuis l'on-premises|Non|Non|Oui
|Protection contre l'exfiltration de données|Non|Non|Oui
|Effort de mise en place|Simple|Simple|Complexe (DNS, approbations)
|Passe à l'échelle avec de nombreux subnets|Non|Oui|Oui
|Services supportés|~10|4|70+
|Tarification|Gratuit|Payant|Payant

Notez que Standard ne comble aucune des lacunes que Private Link comble. Cela reste un endpoint public. Ce qu'il corrige, c'est la facilité de gestion et le passage à l'échelle. Côté avantages, il n'y a pas de zone private DNS à gérer, ce qui, si vous avez lu mon [article détaillé sur le DNS](https://woivre.com/blog/2024/03/azure-private-endpoint-deep-dive-on-dns-resolution), n'est pas un petit avantage.

_**Coût**_

- **Basic** : gratuit.
- **Standard** : un tarif horaire fixe par virtual network, sans compteur par subnet ni par endpoint. La documentation de l'époque de la preview mentionnait une période sans facturation, mais la documentation GA est claire : c'est une fonctionnalité payante. Vous payez aussi l'IP publique Standard utilisée comme identifier, comme n'importe quelle autre IPv4 publique Standard.
- **Private endpoint** (pour comparaison) : un tarif horaire par endpoint, plus les données traitées au Go.

Le tarif exact varie selon la région, utilisez donc la calculatrice de prix Azure. La formule est simple :

- coût mensuel ≈ tarif horaire × 730 h × nombre de VNets avec Standard activé

Pour 12 VNets spoke, cela fait 12 × 730 = 8 760 heures facturées par mois, multipliées par votre tarif régional. Comparez cela au coût d'un private endpoint par ressource PaaS et par VNet qui a besoin d'y accéder, et au coût des heures d'ingénierie passées à maintenir des ACLs.

**Exemple** : 12 spokes accédant à un storage account et un Key Vault

Supposons 12 VNets spoke avec 2 subnets chacun, appelant tous les deux mêmes ressources PaaS.

| \ | Basic | Standard |
|---|---|---|
|Entrées d'ACL côté PaaS|24 subnets × 2 ressources = 48|1 règle NSP (la plage de l'identifier)|
|Nouveau subnet|Mettre à jour chaque ressource PaaS|Attacher l'identifier, rien d'autre|
|Coût|Gratuit|12 VNets × tarif horaire|

Voici la mise en place du Standard Service Endpoint en CLI :

```bash
# 1. Network identifier: Standard, static IPv4, taken from a prefix
az network public-ip prefix create -g rg-network -n pipprefix-se --length 31 -l westeurope
az network public-ip create -g rg-network -n pip-se-identifier \
  --public-ip-prefix pipprefix-se --sku Standard --allocation-method Static

# 2. Attach it to the service endpoint on each subnet
az network vnet subnet update -g rg-spoke01 --vnet-name vnet-spoke01 -n snet-app \
  --add serviceEndpoints '{"service":"Microsoft.Storage","networkIdentifier":{"id":"/subscriptions/<sub-id>/resourceGroups/rg-network/providers/Microsoft.Network/publicIPAddresses/pip-se-identifier"}}'

# 3. Perimeter + profile
az network perimeter create -n nsp-paas -g rg-network -l westeurope
az network perimeter profile create --perimeter-name nsp-paas -g rg-network -n profile-spokes

# 4. Associate the PaaS resource in Learning mode first
az network perimeter association create --perimeter-name nsp-paas -g rg-network \
  --association-name assoc-storage --access-mode Learning \
  --profile "{id:/subscriptions/<sub-id>/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityPerimeters/nsp-paas/profiles/profile-spokes}" \
  --private-link-resource "{id:/subscriptions/<sub-id>/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/<storage-name>}"

# 5. One inbound rule for the whole estate
az network perimeter profile access-rule create --perimeter-name nsp-paas -g rg-network \
  --profile-name profile-spokes --access-rule-name allow-se-standard \
  --direction Inbound --address-prefixes "<prefix-range>"
```

La même chose en Bicep pour le côté subnet. La forme de la propriété vient du payload CLI ci-dessus, utilisez donc la dernière version d'API qui expose networkIdentifier :

```bicep
resource networkIdentifier 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-se-identifier'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'snet-app'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        networkIdentifier: { id: networkIdentifier.id }
      }
    ]
  }
}
```

Le mode Learning n'est pas optionnel à mes yeux. Comme dans mon article sur la [migration NSP](https://woivre.com/blog/2026/09/azure-storage-migrate-your-acls-to-nsp-without-downtime), surveillez les logs de diagnostic du périmètre pendant une à deux semaines avant de passer en Enforced. Microsoft recommande la même chose.

**Basic Service endpoint**

| Avantages | Inconvénients |
| -- | -- | 
| Gratuit | Chaque subnet doit être listé sur chaque ressource PaaS |
| Très simple, aucun changement DNS | Prolifération des ACLs et limites du resource provider à grande échelle |
| Une dizaine de services supportés | Les changements de cycle de vie des subnets se répercutent sur la configuration PaaS |
| Aucun périmètre ni IP publique à concevoir | Pas de modèle d'accès centralisé basé sur un périmètre |


**Standard Service endpoint**

| Avantages | Inconvénients |
| -- | -- |
| Une IP publique identifie de nombreux subnets, VNets et subscriptions | Payant, par VNet et par heure |
| Une règle NSP au lieu de N×M entrées d'ACL | Seulement 4 services à la GA |
| Les changements de subnets ne touchent pas aux règles PaaS | Toujours un endpoint public, sans protection contre l'exfiltration ni accès on-premises |
| Logs du périmètre et mode Learning | Nécessite NSP et une IP publique Standard |
| Toujours simple : pas de zone private DNS, pas de flux d'approbation | |

Mon conseil : 

- Restez sur Basic si vous avez une poignée de subnets, une ou deux ressources PaaS et un budget serré. Gratuit et simple, c'est difficile à battre.
- Passez à Standard quand la maintenance des ACLs devient une vraie corvée : beaucoup de spokes, beaucoup de subscriptions, des subnets créés par d'autres équipes. C'est aussi le choix naturel si vous adoptez déjà NSP.
- Allez vers Private Link quand vous avez besoin d'une vraie connectivité privée, d'un accès on-premises ou d'une protection contre l'exfiltration. Standard ne le remplace pas. Il se situe entre Basic et Private Link.
- Restez sur Basic si vous avez déjà une automatisation robuste pour gérer les ACLs à grande échelle sur toutes vos ressources PaaS.

Le gratuit, c'était bien, mais un tarif horaire fixe par VNet est un prix honnête pour supprimer quelques centaines d'entrées d'ACL.

