---
layout: post
title: Azure Network - Fini les subnets publiques
date: 2025-12-15
categories: [ "Azure", "Network" ]
comments_id: 211 
---

Fin mars 2026, Microsoft a annoncé une mise à jour importante concernant les subnets publics dans Azure. Désormais, les subnets seront privés par défaut, ce qui signifie que les ressources déployées dans ces subnets n'auront pas d'accès direct à Internet. Cette décision a été prise pour renforcer la sécurité des environnements Azure et encourager les bonnes pratiques en matière de réseau.

Alors concrétement que'est ce que cela change pour vous ? Et bien, si vous êtes en entreprise avec du Zero Trust, du hub & Spoke, cela ne change concrétement rien que pour vous. Car les subnets dans vos spokes sont par nature déjà privés, vu qu'ils passent par votre hub pour accéder à internet.

Par contre, pour les plus petits environnements, il faudra bien penser soit à remettre vos subnets en public, soit expliciter l'accès à internet via une NAT Gateway, un Firewall, ou un Load balancer avec une outbound rule ou une IP statique sur vos VMS.

Concrètement, votre route table que ce soit implicite ou explicite vers Internet est désactivée, il faut donc la remplacer par une route directe.
Le plus simple est de mettre en place une NAT Gateway, mais attention au coût de cette dernière car le coût est aussi basé sur les datas qui transitent par celle ci.

Microsoft fourni des exemples pour le private subnet, je vous conseille d'y jeter un oeil : [GitHub - Azure Networking Private Subnet Routing](https://github.com/Azure-Samples/azure-networking_private-subnet-routing)
