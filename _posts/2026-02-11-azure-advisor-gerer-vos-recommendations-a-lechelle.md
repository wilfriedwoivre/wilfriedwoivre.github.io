---
layout: post
title: Azure Advisor - Gérer vos recommendations à l'échelle
date: 2026-02-11
categories: [ "Azure", "Azure Advisor" ]
githubcommentIdtoreplace: 
---

Azure Advisor est un service Azure qui vous fournit pleins de recommandations sur vos environnements que ce soit en terme de sécurité, de coûts, ou de résilience. Cet outil est très bien, mais je sais qu'il peut être assez fastidieux de devoir le gérer et de prendre en compte toutes les recommandations qui sont proposées à l'échelle d'une entreprise.

Si vous avez un environnement Azure que je qualifierais de standardisé et qui s'étend à plusieurs souscriptions. Il peut être tentant de vouloir refuser des recommandations ou du moins les reporter à plus tard.

Vous pouvez le faire rapidement via un script PowerShell ou autre.
Pour cela, vous pouvez commencer par lister les différentes recommandations qui sont proposées via la commande suivante :

```powershell
Get-AzAdvisorRecommendation -SubscriptionId <SubscriptionId>
```

Ensuite, vous pouvez filtrer les recommandations que vous souhaitez refuser ou reporter à plus tard. Par exemple, si vous souhaitez reporter une recommandation pour 90 jours, vous pouvez utiliser la commande suivante :

```powershell
Disable-AzAdvisorRecommendation -RecommendationName e33855d4-7579-e4d0-c459-23fad3665bd6 -Day 90
```

Et si vous voulez simplement reporter un type de recommandation globalement , vous pouvez utiliser la commande suivante :

```powershell
get-azAdvisorRecommendation | Where { $_.RecommendationTypeId -eq $recommendationId } | % { $_ | Disable-AzAdvisorRecommendation -Day 120 }
```

Allez objectif 2026, on gère les recommandations à l'échelle ! Et plus aucune active sans action planifiée !
