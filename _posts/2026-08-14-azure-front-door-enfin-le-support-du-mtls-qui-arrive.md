---
layout: post
title: Azure Front Door - Enfin le support du mTLS qui arrive
date: 2026-08-14
categories: [ "Azure", "Front Door" ]
comments_id: 217 
---

C'est encore en preview, mais le support du mTLS arrive enfin sur Azure Front Door.

Avant tout voilà le lien de la [documentation](https://learn.microsoft.com/en-us/azure/frontdoor/mutual-tls?WT.mc_id=AZ-MVP-4039694).

Petit rappel sur le mTLS, c'est une sécurité accrue qui permet d'authentifier le client et le serveur. Le client doit donc présenter un certificat valide pour pouvoir accéder à l'asset exposé par le serveur.

Pour faire clair via un schéma, voici ce que cela donne (merci cloudflare pour le schéma) :
![alt text]({{ site.url }}/images/2026/08/14/azure-front-door-enfin-le-support-du-mtls-qui-arrive-img1.png)


Pourquoi c'est une bonne nouvelle, parce qu'il est maintenant possible d'exposer un asset Global comme Front Door et d'y ajouter une sécurité accrue avec l'usage du mTLS. 
Les solutions à ce jour disponible sur Azure en PaaS sont limiter à Azure Application Gateway et Azure API Management. Et comme vous le savez ces deux composants sont régionaux, et demande donc un travail conséquent sur les sujets de résilience et de haute disponibilité.


Pour les limitations de la preview que je vois, et qui j'espère seront corrigées ou améliorées avant une probable mise à disposition en GA.

- La rotation de certificat qui n'est pas opérationnelle.
- Un seul certificat autorisé, ce qui impacte le rollover surtout sur un asset global comme le Front Door. Pas de délai annoncé sur les mise à jour de ce type de configuration. 


