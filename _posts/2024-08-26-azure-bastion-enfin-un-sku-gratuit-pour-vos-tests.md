---
layout: post
title: Azure Bastion - Enfin un SKU gratuit pour vos tests
date: 2024-08-26
categories: [ "Azure", "Bastion" ]
comments_id: 196 
---

Sécuriser l'accès à vos VMs Azure est très important, et cela fait partie du bon sens de ne pas mettre un accès RDP (ou SSH) disponible sur internet, surtout avec un mot de passe disponible dans Github ou autre ...

Microsoft a sorti un service nommé Azure Bastion qui permet de sécuriser l'accès à vos VMs par ce point unique

![](https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/Bastion-Image-Resized?resMode=sharp2&op_usm=1.5,0.65,15,0&wid=1800&qlt=100&fmt=png-alpha&fit=constrain)

Si vous n'avez pas vu la news il y a quelques semaines de cela, il est possible d'avoir un SKU Developer sans SLA, mais gratuit, cependant il y a beaucoup de fonctionnalités qui ne seront pas disponible.

Les plus grosses fonctionnalités qui pourront vous manquer sont les suivantes :

- Copier/coller de fichier
- Pas de support des peerings (RIP votre démo hub & spoke favorite)
- Pas de port custom, donc il faut rester sur le 3389/22

Après il y en a d'autres qui peuvent être genante comme le nom support du kerberos, mais disons que c'est gratuit, et que c'est une fonctionnalité dont on peut se passer pour des tests, il est toujours possible de faire un double jump. 

