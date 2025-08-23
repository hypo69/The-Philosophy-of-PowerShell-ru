Au revoir, PowerShell 2.0.

### Microsoft dit enfin adieu à PowerShell 2.0 dans Windows

**Microsoft a annoncé la suppression complète du composant obsolète Windows PowerShell 2.0 des systèmes d'exploitation Windows 11 et Windows Server 2025, à compter d'août 2025. Cette étape fait partie d'une stratégie globale visant à renforcer la sécurité, à simplifier l'écosystème PowerShell et à éliminer le code hérité.**

Windows PowerShell 2.0, introduit pour la première fois dans Windows 7, a été officiellement déprécié en 2017, mais est resté disponible en tant que composant facultatif pour assurer la rétrocompatibilité. Aujourd'hui, Microsoft franchit une étape décisive en l'excluant complètement des futures versions.

**Chronologie des changements**

Le processus de suppression se déroulera en plusieurs étapes :

*   **Juillet 2025 :** PowerShell 2.0 a déjà été supprimé des versions préliminaires de Windows Insider.
*   **Août 2025 :** Le composant sera supprimé de Windows 11, version 24H2.
*   **Septembre 2025 :** PowerShell 2.0 sera exclu de Windows Server 2025.

Toutes les versions ultérieures de ces systèmes d'exploitation seront livrées sans PowerShell 2.0.

**Pourquoi PowerShell 2.0 est-il abandonné ?**

La principale raison de sa suppression est la sécurité. PowerShell 2.0 ne dispose pas de fonctionnalités de sécurité clés introduites dans les versions ultérieures, telles que :

*   Intégration avec l'interface d'analyse des logiciels malveillants (AMSI).
*   Journalisation améliorée des blocs de script.
*   Mode de langage contraint (Constrained Language Mode).

Ces omissions ont fait de PowerShell 2.0 une cible attrayante pour les attaquants qui pouvaient l'utiliser pour contourner les systèmes de sécurité modernes. De plus, la suppression du composant obsolète permettra à Microsoft de réduire la complexité de la base de code et de simplifier le support de l'écosystème PowerShell.

**Qu'est-ce que cela signifie pour les utilisateurs et les administrateurs ?**

Pour la plupart des utilisateurs, ce changement passera inaperçu, car les versions modernes de PowerShell, telles que PowerShell 5.1 et PowerShell 7.x, restent disponibles et entièrement prises en charge. Cependant, les organisations et les développeurs utilisant des scripts ou des logiciels hérités qui dépendent explicitement de PowerShell 2.0 doivent prendre des mesures.

**Recommandations de migration**

Microsoft recommande fortement :

*   **Migrer les scripts et les outils vers des versions plus récentes de PowerShell.** PowerShell 5.1 offre une compatibilité ascendante élevée avec presque toutes les commandes et modules. PowerShell 7.x offre des capacités multiplateformes et de nombreuses fonctionnalités modernes.
*   **Mettre à jour ou remplacer les logiciels obsolètes.** Si une ancienne application ou un programme d'installation nécessite PowerShell 2.0, il est nécessaire de trouver une version plus récente du produit. Cela s'applique également à certains produits serveur Microsoft (Exchange, SharePoint, SQL) pour lesquels des versions mises à jour sont disponibles qui fonctionnent avec PowerShell moderne.

**Versions de Windows concernées**

La suppression de PowerShell 2.0 affectera les versions suivantes des systèmes d'exploitation :

*   Windows 11 (Home, Pro, Enterprise, Education, SE, Multi-Session, IoT Enterprise) version 24H2.
*   Windows Server 2025.

Les versions antérieures de Windows 11, telles que 23H2, conserveront apparemment PowerShell 2.0 en tant que composant facultatif.

Cette étape de Microsoft marque la fin d'une ère dans l'administration de Windows, soulignant l'engagement de l'entreprise envers un environnement informatique plus sécurisé et moderne.
