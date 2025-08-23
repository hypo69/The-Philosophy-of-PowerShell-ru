![1](assets/cover.png)
# La Philosophie de PowerShell

&nbsp;&nbsp;&nbsp;&nbsp;L'objectif de cette série n'est pas de créer un autre manuel de cmdlets. 
L'idée clé que je développerai tout au long des chapitres est la transition de la pensée textuelle à la **pensée orientée objet**. 
Au lieu de travailler avec des chaînes non structurées, je vous apprendrai à manipuler des objets à part entière avec leurs propriétés et méthodes, 
en les transmettant via le pipeline, comme sur une chaîne de montage en usine.


&nbsp;&nbsp;&nbsp;&nbsp;Cette série vous aidera à dépasser la simple écriture de commandes et à acquérir une approche d'ingénierie consciente de PowerShell,
en tant qu'outil puissant pour disséquer le système d'exploitation.

---

## 🗺️ Table des matières

### **Section I : Fondations et bases**

*   **[Partie 0 : Qu'y avait-il avant PowerShell ?](./01.md)**
    *   Excursion historique : `COMMAND.COM`, `AUTOEXEC.BAT`, `CONFIG.SYS`.
    *   Comparaison avec le monde UNIX (`sh`, `csh`).
    *   Évolution de Windows : noyau NT et outils d'administration disparates.

*   **[Partie 1 : Premier lancement et concepts clés](./01.md)**
    *   Le projet Monad et la naissance de PowerShell.
    *   **Idée principale :** Les objets au lieu du texte.
    *   Syntaxe "Verbe-Nom".
    *   Votre assistant principal : `Get-Help`.

*   **[Partie 2 : Pipeline, variables et exploration d'objets](./02.md)**
    *   Principes de fonctionnement du pipeline (`|`).
    *   Travailler avec des variables (`$var`, `$_`).
    *   Analyse d'objets avec `Get-Member`.
    *   *Exemple de code : [system_monitor.ps1](./code/02/system_monitor.ps1)*


*   **[Partie 3 : Navigation et gestion du système de fichiers](./03.md)**
    *   Le concept des fournisseurs (`PSDrives`) : système de fichiers, registre, certificats.
    *   Opérateurs de comparaison et de logique.
    *   Introduction aux fonctions.
    *   *Exemples de code : [Find-DuplicateFiles.ps1](./code/03/Find-DuplicateFiles.ps1), [Backup-FolderToZip.ps1](./code/03/Backup-FolderToZip.ps1)*

*   **[Partie 4 : Travail interactif : `Out-ConsoleGridView`, `F7History` et `ConsoleGuiTools`**






    *   `Where-Object` : Un tamis pour les objets.
    *   `Sort-Object` : Ordonnancement des données.
    *   `Select-Object` : Sélection de propriétés et création de champs calculés.

*   **[Partie 5 : Variables et types de données de base](./05.md)**
    *   Variables en tant qu'objets `PSVariable`.
    *   Portées (Scope).
    *   Travailler avec des chaînes, des tableaux et des tables de hachage.

### **Section III : Des scripts aux outils professionnels**

*   **[Partie 6 : Bases du scripting. Fichiers `.ps1` et politique d'exécution](./06.md)**
    *   Transition de la console interactive aux fichiers `.ps1`.
    *   Politiques d'exécution (`Execution Policy`) : ce que c'est et comment les configurer.

*   **[Partie 7 : Constructions logiques et boucles](./07.md)**
    *   Prise de décision : `If / ElseIf / Else` et `Switch`.
    *   Répétition d'actions : boucles `ForEach`, `For`, `While`.

*   **[Partie 8 : Fonctions — créer vos propres cmdlets](./08.md)**
    *   Anatomie d'une fonction avancée : `[CmdletBinding()]`, `[Parameter()]`.
    *   Création d'aide (`Comment-Based Help`).
    *   Traitement du pipeline : blocs `begin`, `process`, `end`.

*   **[Partie 9 : Travailler avec les données : CSV, JSON, XML](./09.md)**
    *   Importation et exportation de données tabulaires avec `Import-Csv` et `Export-Csv`.
    *   Travailler avec les API : `ConvertTo-Json` et `ConvertFrom-Json`.
    *   Bases du travail avec XML.

*   **[Partie 10 : Modules et PowerShell Gallery](./10.md)**
    *   Organisation du code en modules : `.psm1` et `.psd1`.
    *   Importation de modules et exportation de fonctions.
    *   Utilisation de la bibliothèque globale `PowerShell Gallery`.

### **Section IV : Techniques avancées et projet final**

*   **[Partie 11 : Gestion à distance et tâches en arrière-plan](./11.md)**
    *   Bases de PowerShell Remoting (WinRM).
    *   Sessions interactives (`Enter-PSSession`).
    *   Gestion en masse avec `Invoke-Command`.
    *   Exécution d'opérations de longue durée en arrière-plan (`Start-Job`).

*   **[Partie 12 : Introduction à l'interface graphique dans PowerShell avec Windows Forms](./12.md)**
    *   Création de fenêtres, de boutons et d'étiquettes.
    *   Gestion des événements (clic sur un bouton).

*   **[Partie 13 : Projet "Moniteur CPU" — Conception de l'interface](./13.md)**
    *   Disposition de l'interface graphique.
    *   Configuration de l'élément `Chart` pour l'affichage des graphiques.

*   **[Partie 14 : Projet "Moniteur CPU" — Collecte de données et logique](./14.md)**
    *   Obtention des métriques de performance avec `Get-Counter`.
    *   Utilisation d'un minuteur pour mettre à jour les données en temps réel.

*   **[Partie 15 : Projet "Moniteur CPU" — Assemblage final et prochaines étapes](./15.md)**
    *   Ajout de la gestion des erreurs (`Try...Catch`).
    *   Résumé et idées pour un développement ultérieur.

---

## 🎯 À qui s'adresse cette série ?

*   **Aux débutants** qui souhaitent jeter des bases solides et correctes dans l'apprentissage de PowerShell, en évitant les erreurs courantes.
*   **Aux administrateurs Windows expérimentés** qui sont habitués à `cmd.exe` ou VBScript et qui souhaitent systématiser leurs connaissances en passant à un outil moderne et plus puissant.
*   **À tous** ceux qui veulent apprendre à penser non pas en commandes, mais en systèmes, et à créer des scripts d'automatisation élégants, fiables et faciles à maintenir.

## ✍️ Commentaires et participation

&nbsp;&nbsp;&nbsp;&nbsp;Si vous trouvez une erreur, une faute de frappe ou si vous avez une suggestion pour améliorer l'une des parties, n'hésitez pas à créer une **Issue** dans ce dépôt.

## 📜 Licence

&nbsp;&nbsp;&nbsp;&nbsp;Tout le code et les textes de ce dépôt sont distribués sous la **[licence MIT](./LICENSE)**. Vous êtes libre d'utiliser, de modifier et de distribuer les matériaux avec attribution.
