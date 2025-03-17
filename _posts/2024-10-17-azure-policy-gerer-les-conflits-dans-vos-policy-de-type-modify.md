---
layout: post
title: Azure Policy - Gérer les conflits dans vos policy de type Modify
date: 2024-10-17
categories: [ "Azure", "Policy" ]
githubcommentIdtoreplace: 
---

Les policies de type de Modify sont très pratique pour imposer une règle, et prévenir des modifications automatiques issues d'une vieille infrastructure as code de type changer le TLS de 1.2 à 1.0.

Cependant si vous avez plusieurs policies qui modifient le même champs. Ce qui peut arriver si vous assignez deux fois la même policy sur des scopes différents avec des paramètres différents, ou si vous avez un problème de gouvernance, il peut être compliqué de savoir laquelle primo sur l'autre

Il y a l'option __conflicteffect__ qui existe celle ci permet de choisir qui remporte la victoire sur la modification ou non du champs. Ce champs a plusieurs valeurs qui sont les suivantes : __audit__, __deny__ ou __disabled__.

Et bonne nouvelle, par défaut la valeur est en __deny__ qui est la valeur que je vous conseille de prime abord.

En effet, si on a un conflit de policy, on aura une erreur lors de la mise à jour de la ressource, alors qu'une policy avec un effet à audit va simplement ne pas jouer les opérations de Modify en cas de conflit.

Voici un exemple de policy avec un conflict effect de configuré.

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
          "equals": "false"
        }
      ]
    },
    "then": {
      "effect": "[parameters('effect')]",
      "details": {
        "conflictEffect": "deny",
        "roleDefinitionIds": [
          "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab"
        ],
        "operations": [
          {
            "condition": "[greaterOrEquals(requestContext().apiVersion, '2019-04-01')]",
            "operation": "addOrReplace",
            "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
            "value": true
          }
        ]
      }
    }
  },
  "parameters": {
    "effect": {
      "type": "String",
      "metadata": {
        "displayName": "Effect",
        "description": "The effect determines what happens when the policy rule is evaluated to match"
      },
      "allowedValues": [
        "Modify",
        "Disabled"
      ],
      "defaultValue": "Modify"
    }
  }
}
```
