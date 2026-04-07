---
layout: post
title: Azure Network - Agrandir vos subnets, c'est possible !
date: 2025-10-17
categories: [ "Azure", "Network" ]
comments_id: 210 
---

Vous vous êtes déjà retrouvé dans le cas où vous avez été un peu trop radin (ou optimiste) sur la gestion de vos IPs, et que vous n'avez attribuez qu'un minuscule range /28 à une application sans vous doutez que demain elle ellait exploser et devoir demander un range plus grand pour fonctionner. 

Précédemment, la réponse était très souvent quelque chose du genre "Désolé, il n'est pas possible d'agrandir un subnet, il faut en créer un nouveau et migrer les ressources ou garder 2 subnets disjoints. Il faudra bien le spécifier à chaque fois que vous faîtes des ouvertures de routes, ou que l'on doit modifier des routes tables".

Bon maintenant, bonne nouvelle il est possible d'ajouter un deuxième address prefixe à votre subnet comme cela


```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName 'test-rg' -Name 'vnet-1'
Set-AzVirtualNetworkSubnetConfig -Name 'subnet-1' -VirtualNetwork $vnet -AddressPrefix '10.0.0.0/24', '10.0.1.0/24'
$vnet | Set-AzVirtualNetwork
```

L'avantage ici c'est que si vous avez la chance d'avoir des subnets joints comme dans l'exemple ci-dessus, vos ouvertures de routes passe simplement d'une 10.0.0.0/24 à un 10.0.0.0/23, et cela simplifie grandement vos opérations.

Mais aussi votre scale set à l'intérieur de votre subnet peut maintenant scale à 300 noeuds sans à avoir à déplacer votre workload dans un nouveau subnet. Mais aussi possible pour les GatewaySubnet si vous avez fait l'erreur de la créer en /29 pour mettre un simple Point to Site, et que vous voulez maintenant faire du VPN S2S ou du ExpressRoute.

