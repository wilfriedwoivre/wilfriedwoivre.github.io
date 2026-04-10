---
layout: post
title: Azure - Trouver la zone qui correspond à votre souscription
date: 2026-04-10
categories: [ "Azure" ]
comments_id: 213 
---

Il est parfois nécessaire de trouver la zone physique qui correspond à la zone logique attachée à votre souscription Azure.

Pourquoi me direz-vous ? Et bien pour des raisons de conformité, de performance ou de latence, il peut être crucial de savoir où se trouvent physiquement vos ressources Azure. Mais aussi pour des problèmes de capacités, il peut être nécessaire de savoir si les zones concernées ont assez de ressources pour héberger vos infrastructures.

Et cela vous permet aussi de gérer vos paramètres pour votre CI/CD pour s'assurer que les ressources se déploient dans les zones où les ressources sont disponibles. 

Par exemple sur le firewall Azure, il y a en ce moment des contraintes sur les capacités comme le montre ce lien : [Azure Documentation](https://learn.microsoft.com/en-us/azure/firewall/firewall-known-issues?WT.mc_id=AZ-MVP-4039694#current-capacity-constraints)

Vous pouvez donc savoir quelle est la zone que vous utilisez pour votre souscription en utilisant la commande suivante :

```bash
az account list-locations --query "[?availabilityZoneMappings].{availabilityZoneMappings: availabilityZoneMappings, displayName: displayName, name: name}"
```

Cette commande vous donnera une liste de toutes les zones disponibles pour votre souscription, ainsi que les zones de disponibilité associées à chaque zone. Vous pourrez ainsi identifier la zone physique qui correspond à la zone logique que vous utilisez pour vos ressources Azure.

Et si vous préférez une interface graphique je vous recommande le site [App Scout](https://app.az-scout.com/) qui vous permettra de visualiser les différentes zones et leurs capacités en temps réel. C'est un outil très pratique pour gérer vos ressources Azure de manière efficace. Voici ce que cela donne pour la zone West Europe : 

![alt text]({{ site.url }}/images/2026/04/10/azure-trouver-la-zone-qui-correspond-a-votre-souscription-img0.png)
