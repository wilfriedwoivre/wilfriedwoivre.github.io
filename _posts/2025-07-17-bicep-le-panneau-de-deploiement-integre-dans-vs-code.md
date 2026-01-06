---
layout: post
title: Bicep - Le panneau de déploiement intégré dans VS Code
date: 2025-07-17
categories: [ "Azure", "Bicep" ]
githubcommentIdtoreplace: 
---

Bon c'est sûrement un peu tardif comme article, je n'ai pas vérifié.
Mais je suis tombé dessus un peu par hasard. Dans VS Code il y a un panneau de configuration pour lancer vos déploiements Bicep.

Avant d'en parler un peu plus, je rappelle que déployer depuis votre VS Code par défaut c'est mal, il y a plein d'outils de CI/CD qui sont là pour ça, comme Github Actions. Mais bon pour des raisons de tests on va avouer que c'est quand même bien pratique.

Avant je faisais comme beaucoup avec la commande intégrée de *Bicep: Deploy Bicep file...*

Mais si vous créer un fichier de paramétrage de type bicepparam, il est possible d'afficher un panneau de déploiement qui ressemble à cela :

![alt text]({{ site.url }}/images/2025/07/17/bicep-le-panneau-de-deploiement-integre-dans-vs-code-img0.png)

Et dans celui là ce qui va vous changer la vie (en tout cas la mienne) c'est le fait de pouvoir sélectionner un scope et qu'il le retienne. Donc pas besoin de spammer la toucher entrée après avoir lancé la commande *Bicep: Deploy Bicep file...*

