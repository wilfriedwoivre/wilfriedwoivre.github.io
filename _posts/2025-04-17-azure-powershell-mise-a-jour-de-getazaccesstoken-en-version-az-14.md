---
layout: post
title: Azure Powershell - Mise à jour de Get-AzAccessToken en version Az 14
date: 2025-04-17
categories: [ "Azure", "Powershell" ]
comments_id: 201 
---

Dans la prochaine version majeure du module Az pour powershell, il y a un breaking change important qui peut potentiellement impactés tous vos scripts d'automatisation.

Il s'agit de Get-AzAccessToken une méthode très pratique pour récupérer un token pour intérarger avec des API Azure.

Comme on peut le voir ci-dessous:

```powershell
get-azaccesstoken
WARNING: Upcoming breaking changes in the cmdlet 'Get-AzAccessToken' :
The Token property of the output type will be changed from String to SecureString. Add the [-AsSecureString] switch to avoid the impact of this upcoming breaking change.
- The change is expected to take effect in Az version : '14.0.0'
- The change is expected to take effect in Az.Accounts version : '5.0.0'
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
```

Pour faire le changement, il faut passer -AsSecuredString pour avoir le résultat qu'on aura dans la version 14.

```powershell
$token = Get-AzAccessToken  -AsSecureString

$token.Token
System.Security.SecureString
```

Le problème c'est que le token n'est maintenant plus utilisable tel quel pour intéragir avec les API Azure.

Il faut faire une manipulation supplémentaire qui est celle-ci

```powershell
ConvertFrom-SecureString $token.Token -AsPlainText

eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDSDJYRSIsImtpZCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDS...
```

Et là vous retrouverez votre token à utiliser dans vos appels REST.

Donc pensez bien à faire la modification avant d'update vos modules Az.
