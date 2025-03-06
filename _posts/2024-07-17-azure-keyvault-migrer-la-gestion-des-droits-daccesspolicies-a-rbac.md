---
layout: post
title: Azure KeyVault - Migrer la gestion des droits d'AccessPolicies à RBAC
date: 2024-07-17
categories: [ "Azure", "KeyVault" ]
githubcommentIdtoreplace: 
---

Sur Azure, on peut créer et utiliser des KeyVault avec deux modes, soit via des AccessPolicies comme historiquement, ou avec le mode RBAC. Et bonne nouvelle avec ce droit on peut mettre des droits fins sur chaque secret de votre keyvault, et plus une permission globale.

Comme toute nouvelle fonctionnalité sur Azure, et des changements sur des produits existants, il y a souvent le fait que l'ancien mode devient _legacy_. On peut donc se poser des questions autour de la migration.

Il est très simple de passer d'un KeyVault en AccessPolicy à RBAC via cette commande powershell

```powershell
Update-AzKeyVault -VaultName $name -ResourceGroupName $rg -EnableRbacAuthorization $true 
```

Cependant attention à la gestion des droits existants sur vos keyvaults qui seront perdus, et qu'il va falloir migrer au préalable.

Microsoft fourni des custom role contenant les droits par défaut, mais vous n'avez pas le même niveau de granularité que via les Access Policies en terme de droit.

J'ai écrit un script qui va créer des custom role pour chaque opération disponible sur le provider via les commandes suivantes :

```powershell
$keyVaultDataOperations = Get-AzproviderOperation -OperationSearchString 'Microsoft.keyvault/vaults/*' | Where { $_.IsDataAction } 

foreach ($operation in $keyVaultDataOperations) {
    Write-Host "Create keyvault rbac role for operation: $($operation.Operation)"

    $roleDefinitionName = "$BaseRoleDefinitionName - $($operation.OperationName)"
    if ($null -eq (Get-AzRoleDefinition -Name $roleDefinitionName -ErrorAction SilentlyContinue)) {
        $role = New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition 
        $role.Name = $roleDefinitionName
        $role.Description = "Custom role definition for fine grained RBAC KeyVault operation $($operation.Operation) - $($operation.Description)"
        $role.IsCustom = $true
        $role.AssignableScopes = @("/subscriptions/$((Get-AzContext).Subscription.Id)")
        $role.Actions = @()
        $role.NotActions = @()
        $role.NotDataActions = @()
        $role.DataActions = @($operation.Operation)
        New-AzRoleDefinition -Role $role
    } 
}
```

Et ensuite on va créer des role assignement pour chacun des droits déclaré dans les accesspolicies de nos keyvaults.

Par exemple pour les secrets, cela nous donnera quelque chose de ce type :

```powershell
foreach ($permission in $accessPolicy.PermissionsToSecrets) {
    if ($permission.ToLowerInvariant() -eq "all") {
        $roleDefinitions = Get-AzRoleDefinition | Where-Object { $_.IsCustom -and $_.Description.ToLowerInvariant().Contains('microsoft.keyvault/vaults/secrets') }
        $roleDefinitions | ForEach-Object { 
            if ($null -eq (Get-AzRoleAssignment -RoleDefinitionId $_.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId -ErrorAction SilentlyContinue)) {
                New-AzRoleAssignment -RoleDefinitionId $_.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId
            }
        }
    }
    else {
        if ($permission.ToLowerInvariant() -eq "get" -or $permission.ToLowerInvariant() -eq "list") {
            $permission = "read"
        }

        $roleDefinition = Get-AzRoleDefinition | Where-Object { $_.IsCustom -and $_.Description.ToLowerInvariant().Contains("microsoft.keyvault/vaults/secrets/$($permission.ToLowerInvariant())") }
        if ($null -eq $roleDefinition) {
            Write-Error "Role definition not found for permission $($permission)"
            exit
        }
        else {
            if ($null -eq (Get-AzRoleAssignment -RoleDefinitionId $roleDefinition.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId -ErrorAction SilentlyContinue)) {
                New-AzRoleAssignment -RoleDefinitionId $roleDefinition.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId
            }
        }
    }
}
```

Il est donc possible via ce script de migrer nos droits d'AccessPolicies à RBAC.

Cependant à mon humble avis, même s'il est possible de migrer via un script en one shot, je vous conseille fortement de réaliser votre migration avec les étapes suivantes :

- Identifier les keyvaults à migrer
- Identifier les droits nécessaires et le scope attendu
- Mettre en place le rbac
- Migrer vos keyvaults
- Appliquer les droits fins au niveau du secret si besoin.

