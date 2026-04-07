---
layout: post
title: Azure - Mettez à jour vos boot diagnostics pour vos VM
date: 2026-01-27
categories: [ "Azure", "Virtual Machines" ]
comments_id: 207 
---

Comme vous le savez tous les logs c'est important, il y en a un qu'on sous estime pas mal c'est le boot diagnostics, au moins pour savoir si la VM a bien démarré.
Précédemment dans Azure, on avait la possibilité de configurer le boot diagnostics en s'appuyant sur un storage pour stocker les différentes informations. 

Depuis un moment, Microsoft a mis à jour la configuration du boot diagnostics pour les machines virtuelles Azure. Désormais, il est possible de configurer le boot diagnostics sans avoir besoin de créer un compte de stockage dédié. Ou du moins il est maintenant entièrement managé par Microsoft.

Voici une requête Graph pour détecter toutes vos VMs qui ne sont pas encore passé sur ce nouveau mode de boot diagnostics :

```kql
resources
| where type =~ "microsoft.compute/virtualMachines"
| where properties.diagnosticsProfile.bootDiagnostics.enabled == true
| where isnotnull(properties.diagnosticsProfile.bootDiagnostics.storageUri)
```

Si cela peut vous éviter des storages dédiés au boot diagnostics, c'est toujours une ressource de moins à gérer et à sécuriser, et cela simplifie la configuration de vos machines virtuelles.
