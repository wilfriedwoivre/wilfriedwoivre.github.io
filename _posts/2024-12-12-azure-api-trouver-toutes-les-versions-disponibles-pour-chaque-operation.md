---
layout: post
title: Azure API - Trouver toutes les versions disponibles pour chaque opération
date: 2024-12-12
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

L'année dernière je vous ai évoqué l'enfer des APIs pour la gestion des Azure Policies.

Maintenant si vous voulez automatiser des tests pour vérifier toutes les versions des APIs, il est nécessaire de les connaitre tous.

Pour connaître les différentes versions d'API il y a plusieurs moyens, le premier est d'aller sur la documentation des REST APIs Azure fournie par Microsoft, mais cela peut être fastidieux.

La deuxième (et sûrement la plus utilisée à ce jour) est de provoquer une erreur, et de voir la liste des APIs disponible via le message d'erreur comme suit :

```powershell
$header = @{ 'Content-Type' = 'application/json'; 'Authorization' = 'Bearer ' + (Get-AzAccessToken).Token }
$url = "https://management.azure.com/subscriptions/$((Get-AzContext).Subscription.Id)/providers/Microsoft.Authorization/roleAssignments?api-version=dummyapi"
Invoke-WebRequest -headers $header $url

--- 
Invoke-WebRequest:
{
  "error": {
    "code": "InvalidResourceType",
    "message": "The resource type \u0027roleAssignments\u0027 could not be found in the namespace \u0027Microsoft.Authorization\u0027 for api version \u0027dummyapi\u0027. The supported api-versions are \u00272014-04-01-preview,2014-07-01-preview,2014-10-01-preview,2015-05-01-preview,2015-06-01,2015-07-01,2016-07-01,2017-05-01,2017-09-01,2017-10-01-preview,2018-01-01-preview,2018-07-01,2018-09-01-preview,2018-12-01-preview,2019-04-01-preview,2020-03-01-preview,2020-04-01-preview,2020-08-01-preview,2020-10-01-preview,2021-04-01-preview,2022-01-01-preview,2022-04-01\u0027."
  }
}

```

Cependant vous en conviendrez, il y a mieux pour trouver toutes les versons disponibles.

Il est donc possible de récupérer les différentes APIs via la commande suivante :

```powershell
(Get-AzResourceProvider -ProviderNamespace "Microsoft.Authorization" | Where-Object { $_.ResourceTypes.ResourceTypeName -eq "roleAssignments" } | Select-Object ResourceTypes).ResourceTypes.ApiVersions

--- 
2022-04-01
2022-01-01-preview
2021-04-01-preview
2020-10-01-preview
2020-08-01-preview
2020-04-01-preview
2020-03-01-preview
2019-04-01-preview
2018-12-01-preview
2018-09-01-preview
2018-07-01
2018-01-01-preview
2017-10-01-preview
2017-09-01
2017-05-01
2016-07-01
2015-07-01
2015-06-01
2015-05-01-preview
2014-10-01-preview
2014-07-01-preview
2014-04-01-preview
```

Et voilà plus qu'à intégrer cela dans une CI de test digne de son nom.