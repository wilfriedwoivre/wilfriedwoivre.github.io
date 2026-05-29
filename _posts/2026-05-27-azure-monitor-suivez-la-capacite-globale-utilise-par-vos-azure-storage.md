---
layout: post
title: Azure Monitor - Suivez la capacité globale utilisé par vos Azure Storage
date: 2026-05-27
categories: [ "Azure", "Monitoring" ]
comments_id: 215 
---

Dans une idée de gouvernance, il peut être utile de faire un inventaire de tout ce que vous utilisez dans le Cloud public.
Et il est souvent un peu compliqué de tout trouver sur la plateforme surtout quand il s'agit de métriques liés au service. 

Bien entendu, tout ce qui est inventaire classique pour répondre à des questions simples de types : 

- Combien de VM sont actuellement utilisées selon l'OS et le SKU ?
- Combien de bases de données sont actuellement en production ? 
- Combien de comptes de stockages sont disponibles ? 

Toutes ses questions d'inventaires sont très simplement disponible via Azure Resource Graph.

Maintenant prenons la question suivante : 

- Quel est la capacité globale de stockage dans tous les Azure Storages ? 

Et bien là ça devient un peu plus compliqué, car bien que la métrique soit disponible, elle est présente par Storage et par défaut non agrégée.

Il est possible de trouver cette réponse en regardant chaque stockage et en faisant la somme des résultats de la métrique "Used Capacity"

Sinon il y a un autre moyen via Azure Workbook que je vais vous montrer. 

On va donc commencer par en créer un nouveau (celui par défaut ne me convient dans ce contexte précis). Donc via le portail car la construction d'un workbook via de l'infrastructure as code relève plus d'une épopée que d'une promenade de santé. 

On va commencez par ajouter 2 filtres pour les souscriptions et pour les ressources comme ci-dessous: 

![alt text]({{ site.url }}/images/2026/05/27/azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage-img1.png)

Pour les différents resources picker, n'oubliez pas de sélectionner "Required" et "Allow multiple selection" pour les deux filtres et d'inclure le champ "All".

Ensuite il est possible de faire une requête Kusto pour faire le lien entre les ressources et les métriques.

On va donc commencez par générer une liste avec toutes les valeurs pour chaque storage: 

![alt text]({{ site.url }}/images/2026/05/27/azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage-img2.png)

Pour que ce soit lisible, allez dans les paramètres avancées et modifier la valeur *Value* pour changer le format vers *Bytes*

Et pour avoir un aggrégat de la capacité utilisée, il suffit de faire une somme de toutes les valeurs via la visualisation *Stat* et de sélectionner "Sum" dans les options d'agrégation.

![alt text]({{ site.url }}/images/2026/05/27/azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage-img3.png)

Voilà si vous voulez que je vous fasse d'autres articles liés aux workbooks, n'hésitez pas à me le faire savoir en commentaire.

Et bien entendu, voici un lien vers le workbook que j'ai créé pour ce cas d'usage : [Github link](https://github.com/wilfriedwoivre/azure-workbooks/tree/main/workbooks/storage/storage-size-monitoring)
