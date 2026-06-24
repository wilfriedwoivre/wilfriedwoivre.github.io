---
layout: post
title: Azure KeyVault - Comment restaurer vos keyvaults lorsque vous avez des Azure Policies
date: 2026-06-24
categories: [ "Azure", "KeyVault", "Policy" ]
githubcommentIdtoreplace: 
---

Pour des enjeux de gouvernance, il est possible que vous ayez mis en place des Azure Policies sur vos KeyVaults. 
Par exemple : 

- Activer la purge protection de vos keyvaults
- Activer la soft delete de vos keyvaults
- Enforcer les Networks rules sur vos keyvaults
- Interdire la création de keyvaults dans certaines régions
- Enforcer l'utilisation des private endpoints sur vos keyvaults

Vous êtes généralement très content de ces policies. Mais maintenant prenons le use case suivant : vous avez un KeyVault qui a été supprimé par erreur et vous souhaitez le restaurer.

Il est fort possible que lorsque vous voulez le restaurer vous ayez une erreur de ce type : 

```powershell
➜  $removeKeyvault | Undo-AzKeyVaultRemoval
Undo-AzKeyVaultRemoval: Resource 'kvipbd7f00' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"Deny Key Vaults without IP rules","id":"/subscriptions/subId/resourcegroups/rg-kv-iprules-lab-20260624/providers/Microsoft.Authorization/policyAssignments/assign-keyvault-ip-rule-deny"},"policyDefinition":{"name":"Key Vaults must define at least one IP rule","id":"/subscriptions/subId/providers/Microsoft.Authorization/policyDefinitions/deny-keyvault-without-ip-rules","version":"1.0.0"}}]'.
```

Vous avez donc suivez la documentation de Microsoft pour restaurer votre Keyvault et rien n'y fait à cause d'une policy. Ici dans ce cas elle vérifie qu'il y a au moins une IP configurée dans les network rule du Keyvault. 

Pour contourner ce problème, la solution la plus simple est de désactiver la policy qui bloque la restauration du KeyVault, de restaurer le KeyVault et de réactiver la policy. Mais bien entendu cela fonctionne si vous avez les droits pour désactiver la policy, et la désactivation d'une policy peut avoir des impacts sur votre gouvernance surtout si elle impacte un grande nombre de ressources et une plateforme fortement utilisée.

Il y a une autre solution beaucoup moins simple, mais plus élégante et qui ne nécessite pas de désactiver la policy. Il s'agit de recréer le Keyvault via un template ARM ou bicep. Ici je vais le faire en ARM, mais vous pouvez le convertir en bicep si vous le souhaitez.

Commençons par voir à quoi ressemble un keyvault supprimé en json.

```json
{
  "Id": "/subscriptions/subId/providers/Microsoft.KeyVault/locations/westeurope/deletedVaults/kvipbd7f00",
  "DeletionDate": "2026-06-24T12:07:06Z",
  "ScheduledPurgeDate": "2026-09-22T12:07:06Z",
  "PublicNetworkAccess": null,
  "VaultUri": null,
  "TenantId": "00000000-0000-0000-0000-000000000000",
  "TenantName": null,
  "Sku": null,
  "EnabledForDeployment": false,
  "EnabledForTemplateDeployment": null,
  "EnabledForDiskEncryption": null,
  "EnableSoftDelete": null,
  "EnablePurgeProtection": true,
  "EnableRbacAuthorization": null,
  "SoftDeleteRetentionInDays": null,
  "AccessPolicies": null,
  "AccessPoliciesText": "",
  "NetworkAcls": null,
  "NetworkAclsText": "",
  "OriginalVault": null,
  "ResourceId": "/subscriptions/subId/resourceGroups/rg-kv-iprules-lab-20260624/providers/Microsoft.KeyVault/vaults/kvipbd7f00",
  "VaultName": "kvipbd7f00",
  "ResourceGroupName": null,
  "Location": "westeurope",
  "Tags": {},
  "TagsTable": null
}
```

Comme on peut le voir, il n'y a pas beaucoup d'informations sur le KeyVault supprimé. Il n'y a pas de networkAcls, pas de networkrules. Et clairement beaucoup d'informations sont manquantes pour recréer le Keyvault.

On comprend mieux pourquoi il créé le keyvault en mode public lors d'une restauration, cat il a tout perdu. Maintenant, si on creuse un peu la doc API, on trouve l'option [createMode](https://learn.microsoft.com/en-us/rest/api/keyvault/vaults/create-or-update#vaultcreateorupdateparameters) qui permet de créer un KeyVault en mode "Recover".

On va donc pouvoir créer un keyvault via l'ARM suivant : 

```json
{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"keyVaultName": {
			"type": "string",
			"metadata": {
				"description": "Name of the Azure Key Vault to create or recover."
			}
		},
		"location": {
			"type": "string",
			"defaultValue": "[resourceGroup().location]",
			"metadata": {
				"description": "Location for the Key Vault resource."
			}
		},
		"tenantId": {
			"type": "string",
			"defaultValue": "[subscription().tenantId]",
			"metadata": {
				"description": "Azure AD tenant ID for the Key Vault."
			}
		},
		"skuName": {
			"type": "string",
			"defaultValue": "standard",
			"allowedValues": [
				"standard",
				"premium"
			],
			"metadata": {
				"description": "SKU for the Key Vault."
			}
		},
		"ipRules": {
			"type": "array",
			"defaultValue": [],
			"metadata": {
				"description": "Array of public IPv4 CIDR strings allowed to access the Key Vault (for example: 203.0.113.10/32)."
			}
		},
		"defaultAction": {
			"type": "string",
			"defaultValue": "Deny",
			"allowedValues": [
				"Allow",
				"Deny"
			],
			"metadata": {
				"description": "Default network ACL action."
			}
		},
		"bypass": {
			"type": "string",
			"defaultValue": "AzureServices",
			"allowedValues": [
				"AzureServices",
				"None"
			],
			"metadata": {
				"description": "Traffic that can bypass network ACLs."
			}
		}
	},
	"variables": {
		"ipRuleObjects": "[map(parameters('ipRules'), lambda('ip', createObject('value', lambdaVariables('ip'))))]"
	},
	"resources": [
		{
			"type": "Microsoft.KeyVault/vaults",
			"apiVersion": "2023-07-01",
			"name": "[parameters('keyVaultName')]",
			"location": "[parameters('location')]",
			"properties": {
                "createMode": "recover",
				"tenantId": "[parameters('tenantId')]",
				"sku": {
					"family": "A",
					"name": "[parameters('skuName')]"
				},
				"enabledForDeployment": false,
				"enabledForDiskEncryption": false,
				"enabledForTemplateDeployment": false,
				"publicNetworkAccess": "Enabled",
				"networkAcls": {
					"bypass": "[parameters('bypass')]",
					"defaultAction": "[parameters('defaultAction')]",
					"ipRules": "[variables('ipRuleObjects')]",
				}
			}
		}
	],
	"outputs": {
		"keyVaultResourceId": {
			"type": "string",
			"value": "[resourceId('Microsoft.KeyVault/vaults', parameters('keyVaultName'))]"
		}
	}
}

```

Ce template on va pourvoir l'appeler comme cela : 


```powershell
New-AzResourceGroupDeployment -name "recover-keyvault" -ResourceGroupName $removekeyvault.ResourceId.split('/')[4] -TemplateFile .\recover-keyvault.json -keyvaultName $removeKeyVault.VaultName  -ipRules @("1.1.1.1/32")
```

De manière un peu magique, votre keyvault est correctement restauré sans changer les policies.
Bien entendu, ce template est à adapter selon les policies que vous utilisez.

Voilà plus d'excuse pour désactiver la gouvernance de vos environnements en production. 
Bien entendu, je vous conseille de tester ce template dans un environnement de test avant de l'utiliser en production, et encore moins en urgence en pleine nuit.

