---
layout: post
title: Azure Tags - Utiliser des hidden tags
date: 2025-05-03
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

Les tags sur Azure sont très utiles d'un point de vue gouvernance. Ils vous permettent d'organiser vos ressources que ce soit cross resource groups ou cross souscriptions. Ou même pour filtrer simplement au sein d'un resource group un peu *fourre tout*.

Maintenant sur Azure, comme vous le savez, le nom d'une ressource sert à identifier celle ci au sein d'Azure et ne peut donc pas être modifiée.
Vous avez donc trois choix principaux pour bien nommer vos ressources :

- Une convention de nommage bien définie et respectée par tous.
- Un naming basé sur vos uses cases.
- Le _cat naming convention_ qui consiste à nommer n'importe comment vos ressources en tapant n'importe quoi sur votre clavier. Ma méthode préférée pour les démonstrations.  

Maintenant dans la vie d'une entreprise, il est souvent amené à changer le nom des équipes, des projets, des applications, etc. Et on se retrouve donc avec des ressources avec des noms obsolètes.

Il est possible d'ajouter un tags qui s'appelle `hidden-title` qui permet de rajouter un nom supplémentaire à votre resource comme ci dessous: 

![alt text]({{ site.url }}/images/2025/05/03/azure-tags-utiliser-des-hidden-tags-img0.png)

Et comme vous pouvez le voir, on ne voit pas le tag depuis le portail. mais on le voit quand vous récupérer les informations de votre ressource en powershell par exemple.

```powershell
Get-AzResource -ResourceGroupName $rgName

Name              : jhyblmpw
ResourceGroupName : tags-rg
ResourceType      : Microsoft.Storage/storageAccounts
Location          : westeurope
ResourceId        : /subscriptions/c4dc16cad0f/resourceGroups/tags-rg/providers/Microsoft.Storage/storageAccounts/jhyblmpw
Tags              :
                    Name          Value
                    ============  ========================
                    hidden-title  Awesome storage for demo

```

Il est bien entendu possible de supprimer le tags via le portail en créant un nouveau tag avec le même nom et une valeur vide.

Vous pouvez utiliser d'autre tags cachée en respectant bien entendu la limite des 50 tags par ressource.
