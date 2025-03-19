---
layout: post
title: Azure Private Endpoint - Une amélioration utile pour la résolution DNS
date: 2025-02-19
categories: [ "Azure", "Network", "Private Endpoint" ]
comments_id: 199 
---

Dans un précédent [article](https://woivre.fr/blog/2024/03/azure-private-endpoint-et-si-on-jetait-un-oeil-a-la-resolution-dns), je vous ai parlé de la résolution DNS des private endpoint et comment cela peut être compliqué quand vous faîtes entrer plusieurs acteurs en jeu, ou que vous utilisiez des Managed Private Endpoint.

J'avais à l'époque proposé une solution basé sur Azure DNS Resolver pour rediriger le forward DNS vers un DNS publique comme Google.

Et bien sachez que depuis Microsoft a sorti une nouvelle fonctionnalité où il est possible de faire porter cette configuration au niveau de vos private DNS zone. Grâce à ce bicep là __resolutionPolicy: 'NxDomainRedirect'__:

```bicep
resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-to-vnet-${uniqueString(deployment().name)}'
  parent: privateDnsZone
  tags: tags
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
    resolutionPolicy: 'NxDomainRedirect'
  }
}
```

Cette option est très pratique, puisque dans notre lab on passe de ce résultat : 

```bash

[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net
Enable succeeded:
[stdout]
Server:         127.0.0.53
Address:        127.0.0.53#53

** server can't find labprivatelinkv5b65ik.blob.core.windows.net: NXDOMAIN


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net 8.8.8.8
Enable succeeded:
[stdout]
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]
```

à celui là :

```bash
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net
Enable succeeded:
[stdout]
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net 8.8.8.8
Enable succeeded:
[stdout]
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]

------------------------------------------
```

Donc plus besoin de mettre en place des forwarder unitairement, et vous pouvez laisser Azure gérer cette partie là pour vous. Un gain de temps surtout quand vous travaillez avec des outils comme Synapse ou Fabric qui propose de créer des Managed Private Endpoint pour beaucoup de vos services.

Je mettrais à jour le lab pour rajouter ce use case dans la liste.
