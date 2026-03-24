---
layout: post
title: Azure Sandbox - Une petite évolution pour les utilisateurs de Copilot dans VSCode
date: 2026-03-24
categories: [ "Azure" ]
comments_id: 208 
---

Comme tout le monde, vous n'avez pas pu rater le virage de l'IA. Maintenant je suppose que vous l'utilisez de plus en plus comme nous tous.

Il y a quelques années j'avais créé un système de Sandbox Azure qui me permet simplement de créer des resources group éphémères. Avec un simple script, je pouvais créer un resource group, faire mes tests, et ensuite la suppression est automatique en fonction de la date ajouté dans un tag. Rien de plus simple.

Maintenant pour faire cela, j'utilise principalement une fonction dans mon profil Powershell pour créer des resources groups. La fameuse fonction *New-AzTestResourceGroup* que certains d'entre vous l'ont peut être déja aperçu dans des démos que je fais.

Maintenant avec l'IA, c'est tellement plus rapide de dire à copilot "Créer moi un resource group *demo-rg* en *France Central* et ajoute moi un compte de stockage. Top au niveau de gain de temps, car en plus il va vous générer votre fichier de déploiement qui va bien. Cependant le resource group n'a pas toujours les bons tags. 

Il y a une manière très simple de rajouter cela, il suffit de demander à Copilot de rajouter les différents tags que vous souhaitez à chaque fois que vous créer un resource group. Vous pouvez lui demander de scoper ce rajout à votre workspace. Mais aussi en global en ajoutant un fichier dans votre répertoire utilisateur.

Voici un exemple de fichier que vous pouvez ajouter dans votre répertoire utilisateur pour que Copilot puisse ajouter les tags automatiquement à chaque fois que vous créer un resource group.

```markdown
# Azure Resource Group Tagging Convention

## Mandatory Tags for Resource Groups
When creating Azure resource groups, always add the following tags:

- **AutoDelete**: `true`
- **ExpirationDate**: Current date in format `YYYY-MM-DD` (e.g., 2026-03-05)

## Implementation
- Apply these tags when using Bicep, Terraform, ARM templates, or Azure CLI
- Use `resourceGroup()` function in Bicep or equivalent in other IaC tools
- Set tags at resource group creation time, not as an afterthought
```

Et pour le chemin il s'agit de celui ci : *C:\Users\YourUserName\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\memory-tool\memories*

Et pouv finir voici de lien de l'aricle pour la sandbox : https://woivre.fr/blog/2018/11/sandbox-azure-pour-tout-le-monde

Voilà une petite astuce pour ne pas oublier de clean vos rsources après vos tests.