---
layout: post
title: Azure VM - La permission RunCommand
date: 2025-11-04
categories: [ "Azure", "Virtual Machines" ]
comments_id: 212 
---

Juste un rapide article pour vous parler de la permission RunCommand sur les machines virtuelles.

Celle ci est très pratique, j'en conviens et je l'utilise régulièrement, mais elle peut aussi être dangereuse si elle est donnée à des personnes qui ne devraient pas l'avoir.

En effet la permission sur Windows tourne en temps que SYSTEM, et peut donc faire n'importe quoi sur la machine virtuelle, y compris installer des logiciels malveillants ou voler des données sensibles, ou désactiver des services de sécurité.
Et sur Linux, ce n'est pas mieux elle tourne en tant que sudo, et peut aussi faire n'importe quoi.

Et pour couronner le tout, une fois que vous avez fait run, il n'est pas possible de stopper la commande, donc ne copiez pas des commandes que vous ne comprenez pas, ou que vous n'avez pas vérifiées, et ne les faites pas tourner sur des machines de production sans les avoir testées au préalable dans un environnement de test.

Donc ne donnez pas cette permission *Microsoft.Compute/virtualMachines/runCommand/action* à n'importe qui, et assurez vous que les personnes qui l'ont sont de confiance et savent ce qu'elles font. Où alors donnez le sur des machines dans des sandbox qui n'ont pas accès à vos environnements de production.

