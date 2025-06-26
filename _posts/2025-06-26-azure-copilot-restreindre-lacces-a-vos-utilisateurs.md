---
layout: post
title: Azure Copilot - Restreindre l'accès à vos utilisateurs
date: 2025-06-26
categories: [ "Azure", "Copilot" ]
comments_id: 203 
---


Azure Copilot est un outil puissant qui peut transformer la manière dont vos utilisateurs interagissent avec le Cloud public de Microsoft.

Cependant, il est essentiel de mettre en place des contrôles d'accès appropriés pour garantir que seules les personnes autorisées puissent utiliser cet outil.

Pour cela, dans le portail Azure, avec un compte qui dispose des droits global Admin sur votre tenant, et des droits User Access Administrator sur votre Root Managament Group, vous pouvez restreindre l'accès à Azure Copilot en suivant ces étapes :

- Aller sur le portail Azure.
- Naviguer vers **Copilot in Azure Admin Center**
- Cliquer sur **Access Management**.
- Changer le paramètre **Available to all users** à **Not available to all users**
- Donner les droits d'accès aux utilisateurs éligibles en ajoutant un rôle sur le tenant root Group **Copilot in Azure User**

Maintenant il peut y avoir plusieurs raisons pour effectuer cette action:

- Vous souhaitez empêcher Microsoft de collecter des données sur vos prompts. [FAQ Azure Copilot](https://learn.microsoft.com/en-us/azure/copilot/responsible-ai-faq?WT.mc_id=AZ-MVP-4039694#what-data-does-microsoft-copilot-in-azure-collect) _Les prompts fournis par les utilisateurs et les réponses de Microsoft Azure Copilot ne sont collectés et utilisés pour améliorer les produits et services Microsoft que lorsque les utilisateurs ont donné leur consentement explicite à l’inclusion de ces informations aux commentaires_
- Vous souhaitez mettre en place une gouvernance stricte sur l'utilisation de l'IA dans votre organisation.
- Pour les grandes entreprises, vous souhaitez vous prémunir d'un délai d'attente sur l'usage de Copilot en ne le fournissant qu'à un nombre restreint d'utilisateurs. [Current limitations](https://learn.microsoft.com/en-us/azure/copilot/capabilities?WT.mc_id=AZ-MVP-4039694#current-limitations)

Et pour finir, il faut être conscient que bloquer cette fonctionnalité peut avoir un impact sur la productivité de vos utilisateurs, car ils ne pourront pas bénéficier des avantages de l'IA dans leurs tâches quotidiennes.
En effet, Azure Copilot peut aider les utilisateurs à automatiser des tâches, à trouver des informations plus rapidement et à améliorer leur efficacité globale. Aujourd'hui le service contient beaucoup de fonctionnalités et s'enrichit de semaines en semaines.

[Copilot Capabilities](https://learn.microsoft.com/en-us/azure/copilot/capabilities?WT.mc_id=AZ-MVP-4039694#perform-tasks), dont à ce jour :

- Comprendre votre environnement Azure :

    - Obtenir des informations sur les ressources via des requêtes Azure Resource Graph
    - Comprendre les événements et l’état d’intégrité du service
    - Analyser, estimer et optimiser les coûts
    - Rechercher des recommandations Azure Advisor
    - Visualiser la topologie du réseau
    - Analysez votre surface d’attaque
    - Examiner les attaques IDPS du Pare-feu Azure

- Travaillez plus intelligemment avec les services Azure :

    - Exécuter des commandes
    - Déployer et gérer des machines virtuelles
    - Découvrir et déployer des modèles de charge de travail
    - Utiliser efficacement des clusters AKS
    - Obtenir des informations sur les métriques et les journaux Azure Monitor

- Travailler plus intelligemment avec Azure Local
    
    - Gérer et résoudre les problèmes des comptes de stockage
    - Résoudre les problèmes de performance de disque
    - Concevoir, dépanner et sécuriser des réseaux
    - Résoudre les problèmes d’extension Azure Arc
    - Améliorer les applications basées sur Azure SQL Database

- Écrivez et optimisez le code :

    - Générer des scripts Azure CLI
    - Générer des scripts PowerShell
    - Générer des configurations Terraform et Bicep
    - Créer des stratégies de gestion des API
    - Générer des fichiers YAML Kubernetes
    - Résoudre les problèmes d’applications plus rapidement avec App Service

Selon mon avis, en 2025, avoir une politique d'entreprise qui interdit l'utilisation de l'IA est contre-productif. Les entreprises qui ne tirent pas parti de l'IA risquent de se retrouver en retard par rapport à leurs concurrents qui l'adoptent. Il est essentiel de trouver un équilibre entre la gouvernance et l'innovation pour rester compétitif sur le marché.

Azure Copilot est un outil essentiel pour tous les profils qui utilisent le Cloud que ce soit en tant que développeur, architecte, infrastructure, SRE, Expert Cyber, FinOps, et j'en passe. Donc peser bien le pour et le contre avant de limiter l'usage de Copilot en entreprise.
