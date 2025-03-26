---
layout: post
title: Azure Policy - Enfin des versions pour les définitions built-in
date: 2025-03-25
categories: [ "Azure", "Policy" ]
comments_id: 200 
---

Lors de la dernière Ignite, Microsoft a annoncé une fonctionnalité que j'attendais beaucoup autour des Azure Policy, elles sont versionnées.

Si comme moi, vous utilisez les Azure Policy depuis longtemps, vous avez du vous apercevoir que la définition des policy fournies par Microsoft peut varier d'une release à l'autre. Techniquement ces versions apportent que des nouvelles fonctionnalités utiles, mais bon je n'aime pas trop avoir des éléments de sécurité déployés sans que je n'ai pu y jeter un oeil.

Donc maintenant ces policies ont des versions, et pour les utiliser c'est très simple il vous suffit de faire cette commande pour lister les versions d'une policy:

```powershell
get-azpolicyDefinition -Name '36fd7371-8eb7-4321-9c30-a7100022d048' | Select DisplayName, Versions

DisplayName                                    Versions
-----------                                    --------
Requires resources to not have a specific tag. {2.0.0, 1.1.1, 1.0.1, 1.0.0}

```

Et pour assigner celle que vous voulez il suffit de faire cette commande:

```powershell
# Sélectionner votre defintion
$definition = get-azpolicyDefinition -Name '36fd7371-8eb7-4321-9c30-a7100022d048' -Version 1.1.1

# Assigner votre policy
$policyparams = @{
    Name = 'test-policy-version'
    DisplayName = 'Test policy version'
    Scope = $rg.ResourceId
    PolicyDefinition = $definition
    Description = 'Test policy version'
}

New-AzPolicyAssignment @policyparams
```

Et bonne nouvelle, cela respecte la gestion des versions sémantiques, et pas des versions avec des dates plus ou moins obscures comme les ressources providers Azure.
