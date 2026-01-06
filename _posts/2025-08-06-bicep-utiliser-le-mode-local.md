---
layout: post
title: Bicep - Utiliser le mode Local
date: 2025-08-06
categories: [ "Azure", "Bicep" ]
comments_id: 204 
---


Il peut être frustant de devoir toujours lancer un déploiement Bicep vers Azure lorsque vous êtes en cours d'écriture de votre script. Et bien entendu vous ne voulez pas lancer votre déploiement après avoir construit à l'aveugle votre Landing Zone après 1 semBicaine de travail acharné. (ou 2h si vous utilisez AVM.)

Heureusement, Bicep propose un mode "local" qui vous permet de valider votre code Bicep sans avoir à déployer dans Azure. Cela peut être particulièrement utile pour vérifier la syntaxe, les types de ressources, et les dépendances entre les ressources.

Mais attention, cependant cela ne prend pas tout en compte, vu que vous ne déployez pas réellement les ressources.

Cela peut ppar contre être bien utile lorsque vous voulez vérifier rapidement la syntaxe, ou lorsque vous travaillez sur des fonctions personnalisées qui peuvent être complexes.

Pour cela il faut éditer votre fichier de configuration Bicep: bicepconfig.json

```json
{
   "experimentalFeaturesEnabled": {
    "localDeploy": true
  }
}
```

Et vous pouvez ensuite éditer votre fichier bicep avec le targetscope à local :

```bicep
targetScope = 'local'


var test = 'Hello, Bicep!'


output greeting string = test

```

ET franchement cela est bien pratique lorsque vous travaillez sur des fonctions un peu complexes ou vous pouvez calculer en local (et en mobilité sans une connexion internet)