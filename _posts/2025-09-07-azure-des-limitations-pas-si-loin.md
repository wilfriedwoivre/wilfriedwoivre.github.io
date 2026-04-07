---
layout: post
title: Azure - Des limitations pas si loin
date: 2025-09-07
categories: [ "Azure" ]
comments_id: 209 
---

Le Cloud est infini, c'est ce que l'on entend souvent. Mais est-ce vraiment le cas ? En réalité, il existe des limitations dans le Cloud, et Azure ne fait pas exception. Ces limitations peuvent être liées à la capacité, à la performance, à la sécurité ou à d'autres aspects.


Alors c'est certes quelque chose de bien connue, mais je vois tellement de personnes qui l'oublie ou qui se disent qu'ils ne seront pas touchés par ces limitations.

Donc commençons par la documentation officielle d'Azure qui liste les différentes limitations : [https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits?WT.mc_id=AZ-MVP-4039694)

Ces limites peuvent vous paraître très lointaines par rapport à votre utilisation actuelle, mais vous pouvez les atteindre plus rapidement que vous ne le pensiez.

Par exemple mettre en place des bundles d'Azure Policy pour chaque type de resource et de risques, il y a une limite sur le nombre de définition custom par scope. Cela peut donc être un challenge au niveau de votre architecture de gouvernance, soit vous devez utiliser des initiatives, soit créer plusieurs scopes ou alors utilisez d'avantages de policy built-in.

Les custom role definition ont une limite au tenant aussi. Vous ne pouvez donc pas laisser tous vos utilisateurs créer des rôles personnalisés à tout va, sinon vous risquez d'atteindre cette limite plus rapidement que prévu, et de perdre la gouvernance sur les rôles qui existent.

Pour les gros utilisateurs d'Azure API Management, sachez entre autre qu'il y a des limites sur le nombre d'operations / instance. Et ce nombre comprend entre autre les opérations présente sur les révisions. Et par défaut le service n'offre pas de métrique simple pour vérifier si vous allez atteindre ou non cette limite, c'est donc à vous de la calculer et de bien gérer vos révisions non utilisées, ainsi que les API obsolètes.

De même pour Azure Firewall, il y a des limites sur le nombre de règles que vous pouvez créer. Et le calcul d'une règle correspond à 1 source, 1 destination, 1 port globalement. Donc si vous ajoutez la réglé **Allow TCP 9093 from 10.0.0.0/24 and 10.0.1.0/24 to 10.1.0.0/24** cela correspond à 2 règles. Pour limiter cela il est possible de faire des ip groups, ou d'ouvrir en plus large quand cela est possible. Mais cela peut vite devenir un challenge de gérer ces règles, surtout si vous avez plusieurs équipes qui gèrent le firewall.

Mon conseil est donc pour chaque nouveau service que vous ouvrez sur votre plateforme, ou de chaque nouvelle fonctionnalité que vous offrez en *self-service* à vos utilisateurs, posez vous la question des limites et s'il est possible de les atteindre.
Et n'oubliez pas que même si ces limites peuvent évoluer dans le temps, il est nécessaire d'appliquer tous vos processus régaliens autour de ces ressources comme l'inventaire et une gestion rigoureuse du cycle de vie.