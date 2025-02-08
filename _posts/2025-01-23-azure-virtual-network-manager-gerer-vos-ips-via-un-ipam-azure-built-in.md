---
layout: post
title: Azure Virtual Network Manager - Gérer vos IPS via un IPAM Azure built in
date: 2025-01-23
categories: [ "Azure", "Network" ]
comments_id: 194 
---

Azure Virtual Manager est un outil pour vous aider à gérer la gouvernance dans le Cloud Public, et ici particulièrement la partie réseau.

Pour ceux qui manipulent des éléments réseaux au quotidien, vous savez que la gestion des ips est un point important afin d'éviter l'overlap, pour identifier vos composants ou vos environnements. Il faut donc à un moment avoir un mapping pour savoir quelle ip appartient à qui et où elle se trouve dans mon ecosystème.

Alors il est possible de gérer vos IPS via différents outils, en passant de la feuille Excel (car Excel peut tout faire, même être le pilier de la pire idée d'outil pour gérer vos outils) jusqu'à différents IP Address Manager (IPAM) du marché, et il y en a selon [Wikipedia](https://fr.wikipedia.org/wiki/Gestion_des_adresses_IP)

Pour moi les éléments essentiels d'un IPAM sont :

- La gestion des accès à celui ci pour ajouter de nouveaux ranges, et piocher dans ceux ci.
- Récupérer des IPs depuis notre Infrastructure as code, à savoir réserver un range pour mon virtual network, et conserver celui ci même si je lance 200 fois ma stack.
- Visualiser la place disponible dans mes ranges.
- La recherche pour savoir ou se trouve mon asset en une recherche et pas 2h d'investigation, à savoir je tape une IP de type 10.0.0.4, je veux trouver le pool d'ip qui correspond, si un range a été alloué et à qui.

On va donc regarder ce que nous fournis Microsoft, qui a l'avantage d'être intégré dans Azure, et donc aux APIs de celui-ci, cela veut dire que vous pouvez faire du bicep.

On va donc créer notre Network Manager et nos ranges d'adresses IPs.

```bicep
param location string = 'northeurope'

var cidr = '10.0.0.0/20'
var envPrefix = [for i in range(0, 2): cidrSubnet(cidr, 21, i)]

resource networkManager 'Microsoft.Network/networkManagers@2024-05-01' = {
  name: 'demo-networkmanager'
  location: location
  properties: {
    networkManagerScopes: {
      subscriptions: [
        subscription().id
      ]
    }
  }
}

resource globalPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-global'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      cidr
    ]
  }
}

resource prdPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-prd'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      envPrefix[0]
    ]
    parentPoolName: globalPrefix.name
  }
}

resource devPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-dev'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      envPrefix[1]
    ]
    parentPoolName: globalPrefix.name
  }
}
```

Bon point ici, la création est simple, on peut assez facilement ajouter des ranges, et même géré une notion d'héritage pour subdiviser nos ranges.

Maintenant pour l'allocation au sein d'un Virtual Network, il est possible de faire comme cela, ici je créé 10 Virtual Networks, pour m'assurer qu'il prend bien des ranges différents: 

```bicep
resource vnets 'Microsoft.Network/virtualNetworks@2024-05-01' = [
  for i in range(0, 8): {
    name: 'vnet-dev-${i}'
    location: location
    properties: {
      addressSpace: {
        ipamPoolPrefixAllocations: [
          {
            numberOfIpAddresses: '128'
            pool: {
              id: devPrefix.id
            }
          }
        ]
      }
    }
  }
]
```

Deuxième bon point, on peut facilement créer notre virtual network via du bicep pour qu'il puisse récupérer une ip de notre IPAM.

Pour la partie occupation de nos ranges, là encore on peut le voir simplement depuis Azure :

![alt text]({{ site.url }}/images/2025/01/23/azure-virtual-network-manager-gerer-vos-ips-via-un-ipam-azure-built-in-img0.png)

Encore donc un bon point pour cela.

Et maintenant pour la recherche, on va dire que c'est tout nouveau et que tous les outils s'améliore avec le temps. Mais à ce jour la fonctionnalité de recherche proposée est utile uniquement si on sait quoi chercher et où.

En conclusion, Microsoft offre avec cette fonctionnalité quelque chose qui était très attendu depuis plusieurs années, correctement intégré avec les apis et la gestion de nos stacks réseau, mais qui selon moi manque encore de quelques fonctionnalités pour me décider à changer d'IPAM à ce jour.
