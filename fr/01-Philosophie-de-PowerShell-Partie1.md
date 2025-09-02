# La Philosophie de PowerShell.
## Partie 0.
Qu'y avait-il avant PowerShell ?
En 1981, MS-DOS 1.0 est sorti avec l'interpréteur de commandes `COMMAND.COM`. Pour l'automatisation des tâches, on utilisait des **fichiers batch (`.bat`)** — de simples fichiers texte contenant une séquence de commandes de console. C'était un ascétisme surprenant pour la ligne de commande par rapport aux systèmes compatibles POSIX où le **shell Bourne (`sh`)** existait déjà depuis 1979.

### 📅 État du marché des shells au moment de la sortie de MS-DOS 1.0 (août 1981)

Voici un tableau récapitulatif des systèmes d'exploitation populaires de l'époque et de leur prise en charge des shells (`sh`, `csh`, etc.) :

| Système d'exploitation | Prise en charge des shells (`sh`, `csh`, etc.) | Commentaire |
|---|---|---|
| **UNIX Version 7 (V7)** | `sh` | Le dernier UNIX classique de Bell Labs, largement répandu |
| **UNIX/32V** | `sh`, `csh` | Version d'UNIX pour l'architecture VAX |
| **4BSD / 3BSD** | `sh`, `csh` | Branche universitaire d'UNIX de Berkeley |
| **UNIX System III** | `sh` | La première version commerciale d'AT&T, prédécesseur de System V |
| **Xenix (de Microsoft)** | `sh` | Une version sous licence d'UNIX, vendue par Microsoft depuis 1980 |
| **IDRIS** | `sh` | Un système d'exploitation de type UNIX pour PDP-11 et Intel |
| **Coherent (Mark Williams)** | `sh` (similaire) | Une alternative peu coûteuse à UNIX pour les PC |
| **CP/M (Digital Research)** | ❌ (Pas de `sh`, seulement une CLI très basique) | Pas UNIX, le système d'exploitation le plus populaire pour les PC 8 bits |
| **MS-DOS 1.0** | ❌ (seulement `COMMAND.COM`) | Shell de commande minimal, pas de scripts ni de pipes |

---

### 💡 Que sont `sh`, `csh`

* `sh` — **Bourne Shell**, le principal interpréteur de scripts pour UNIX depuis 1977.
* `csh` — **C Shell**, un shell amélioré avec une syntaxe de type C et des fonctionnalités pratiques pour le travail interactif.
* Ces shells **prenaient en charge les redirections, les pipes, les variables, les fonctions et les conditions** — tout ce qui a fait d'UNIX un outil d'automatisation puissant.

---

Microsoft ciblait les **PC IBM 16 bits bon marché**, qui avaient **peu de mémoire** (généralement 64 à 256 Ko), pas de multitâche et étaient destinés à un **usage domestique et de bureau**, et non à des serveurs. UNIX était payant, nécessitait une architecture complexe et de l'expertise, tandis que les comptables et les ingénieurs, qui n'étaient pas des administrateurs système, avaient besoin d'un système d'exploitation simple et rapide.

Au lieu du complexe `sh`, l'interface DOS fournissait un seul fichier, command.com, avec un maigre ensemble de commandes internes [ (dir, copy, del, etc.)](https://www.techgeekbuzz.com/blog/dos-commands/){:target="_blank"} sans fonctions, boucles ou modules.

Il y avait aussi des commandes externes — des fichiers exécutables distincts (.exe ou .com). Exemples : FORMAT.COM, XCOPY.EXE, CHKDSK.EXE, EDIT.COM.
Les scripts d'exécution étaient écrits dans un fichier texte avec l'extension .bat (fichier batch).

Exemples de fichiers de configuration :

- AUTOEXEC.BAT

```bash
:: ------------------------------------------------------------------------------
:: AUTOEXEC.BAT — Configuration et démarrage automatiques de Windows 3.11
:: Auteur : hypo69
:: Année : environ 1993
:: Objectif : Initialise l'environnement DOS, charge les pilotes réseau et démarre Windows 3.11
:: ------------------------------------------------------------------------------
@ECHO OFF

:: Définir l'invite de commande
PROMPT $p$g

:: Définir les variables d'environnement
SET TEMP=C:\TEMP
PATH=C:\DOS;C:\WINDOWS

:: Charger les pilotes et les utilitaires en mémoire haute
LH C:\DOS\SMARTDRV.EXE       :: Cache de disque
LH C:\DOS\MOUSE.COM          :: Pilote de la souris

:: Charger les services réseau (pertinent pour Windows for Workgroups 3.11)
IF EXIST C:\NET\NET.EXE LH C:\NET\NET START

:: Démarrer automatiquement Windows
WIN
```
- CONFIG.SYS
```bash
:: ------------------------------------------------------------------------------
:: CONFIG.SYS — Configuration de la mémoire et des pilotes DOS pour Windows 3.11
:: Auteur : hypo69
:: Année : environ 1993
:: Objectif : Initialise les pilotes de mémoire, configure les paramètres système
:: ------------------------------------------------------------------------------
DEVICE=C:\DOS\HIMEM.SYS
DEVICE=C:\DOS\EMM386.EXE NOEMS
DOS=HIGH,UMB
FILES=40
BUFFERS=30
DEVICEHIGH=C:\DOS\SETVER.EXE
```

Parallèlement à DOS, Microsoft a presque immédiatement commencé à développer un noyau fondamentalement nouveau.

Le noyau [**Windows NT**](https://www.wikiwand.com/ru/articles/Windows_NT){:target="_blank"} (New Technology) est apparu pour la première fois avec la sortie du système d'exploitation :

> **Windows NT 3.1 — 27 juillet 1993**

---

* **Le développement a commencé** : en **1988** sous la direction de **Dave Cutler** (un ancien ingénieur de DEC et créateur de VMS) dans le but de créer un système d'exploitation entièrement nouveau, sécurisé, portable et multitâche, non compatible avec MS-DOS au niveau du noyau.
* **NT 3.1** — a été nommé ainsi pour souligner la compatibilité avec **Windows 3.1** au niveau de l'interface, mais il s'agissait d'une **architecture complètement nouvelle**.

---

#### 🧠 Ce que le noyau NT a apporté :

| Fonctionnalité | Description |
|---|---|
| **Architecture 32 bits** | Contrairement à MS-DOS et Windows 3.x, qui étaient en 16 bits. |
| **Multitâche** | Véritable multitâche préemptif. |
| **Mémoire protégée** | Les programmes ne pouvaient pas corrompre la mémoire des autres. |
| **Modularité** | Architecture du noyau à plusieurs couches : HAL, Executive, Kernel, pilotes. |
| **Prise en charge multi-plateforme** | NT 3.1 fonctionnait sur x86, MIPS et Alpha. |
| **Compatibilité POSIX** | NT était livré avec un **sous-système POSIX**, certifié POSIX.1. |

---

#### 📜 La lignée NT :

| Version NT | Année | Commentaire |
|---|---|---|
| NT 3.1 | 1993 | Première version de NT |
| NT 3.5 / 3.51 | 1994–1995 | Améliorations, optimisation |
| NT 4.0 | 1996 | Interface de Windows 95, mais noyau NT |
| Windows 2000 | 2000 | NT 5.0 |
| Windows XP | 2001 | NT 5.1 |
| Windows Vista | 2007 | NT 6.0 |
| Windows 10 | 2015 | NT 10.0 |
| Windows 11 | 2021 | Également NT 10.0 (marketing 😊) |

---

Différence dans les capacités du système d'exploitation :

| Caractéristique | **MS-DOS** (1981) | **Windows NT** (1993) |
|---|---|---|
| **Type de système** | Monolithique, monotâche | Micro-noyau/hybride, multitâche |
| **Nombre de bits** | 16 bits | 32 bits (avec prise en charge 64 bits depuis NT 5.2 / XP x64) |
| **Multitâche** | ❌ Absent (un processus à la fois) | ✅ Multitâche préemptif |
| **Mémoire protégée** | ❌ Non | ✅ Oui (chaque processus dans son propre espace d'adressage) |
| **Mode multi-utilisateur** | ❌ Non | ✅ Partiellement (dans NT Workstation/Server) |
| **Compatibilité POSIX** | ❌ Non | ✅ Sous-système POSIX intégré dans NT 3.1–5.2 |
| **Portabilité du noyau** | ❌ x86 uniquement | ✅ x86, MIPS, Alpha, PowerPC |
| **Pilotes** | Accès direct au matériel | Via HAL et pilotes en mode noyau |
| **Niveau d'accès des applications** | Applications = niveau système | Niveaux utilisateur/noyau séparés |
| **Sécurité** | ❌ Absente | ✅ Modèle de sécurité : SID, ACL, jetons d'accès |
| **Stabilité** | ❌ La dépendance d'un programme = crash de l'OS | ✅ Isolation des processus, protection du noyau |

---

Mais il y avait un gros MAIS ! Les outils d'automatisation et d'administration n'ont pas reçu l'attention voulue avant 2002.

---
 
Microsoft a utilisé des approches, des stratégies et des outils complètement différents pour l'administration. Tout cela était **disparate**, souvent orienté GUI, et pas toujours automatisable.

---

##### 📌 Liste de quelques outils :

| Outil | Objectif |
|---|---|
| `cmd.exe` | Interpréteur de commandes amélioré (remplacement de `COMMAND.COM`) |
| `.bat`, `.cmd` | Scripts de ligne de commande |
| **Windows Script Host (WSH)** | Prise en charge de VBScript et JScript pour l'automatisation |
| `reg.exe` | Gérer le registre depuis la ligne de commande |
| `net.exe` | Travailler avec les utilisateurs, le réseau, les imprimantes |
| `sc.exe` | Gérer les services |
| `tasklist`, `taskkill` | Gérer les processus |
| `gpedit.msc` | Stratégie de groupe (locale) |
| `MMC` | Console avec des composants logiciels enfichables pour la gestion |
| `WMI` | Accéder aux informations système (via `wmic`, VBScript ou COM) |
| `WbemTest.exe` | GUI pour tester les requêtes WMI |
| `eventvwr` | Afficher les journaux d'événements |
| `perfmon` | Surveiller les ressources |

##### 🛠 Exemples d'automatisation :

* Fichiers VBScript (`*.vbs`) pour l'administration des utilisateurs, des réseaux, des imprimantes et des services.
* `WMIC` — interface de ligne de commande pour WMI (par exemple : `wmic process list brief`).
* Scripts `.cmd` avec des appels à `net`, `sc`, `reg`, `wmic`, etc.

---

### ⚙️ Windows Scripting Host (WSH)

* Apparu pour la première fois dans **Windows 98**, activement utilisé dans **Windows 2000 et XP**.
* Permettait d'exécuter des fichiers VBScript et JScript depuis la ligne de commande :

  ```vbscript
  Set objShell = WScript.CreateObject("WScript.Shell")
  objShell.Run "notepad.exe"
  ```

---
## Partie 1.

Ce n'est qu'en 2002 que l'entreprise a formulé le projet <a href="https://learn.microsoft.com/en-us/powershell/scripting/developer/monad-manifesto?view=powershell-7.5" target="_blank">Monad</a>, qui a ensuite évolué pour devenir PowerShell :

Début du développement : environ 2002

Annonce publique : 2003, sous le nom de "Monad Shell"

Premières versions bêta : apparues en 2005

Version finale (PowerShell 1.0) : novembre 2006

 L'auteur et architecte en chef du projet Monad / PowerShell est Jeffrey Snover
 <a href="https://www.wikiwand.com/en/articles/Jeffrey_Snover" target="_blank"> (Jeffrey Snover)</a>
 
Aujourd'hui, PowerShell Core fonctionne sur
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/windows-core.md" target="_blank">Windows</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/macos.md" target="_blank">macOS</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/linux.md" target="_blank">Linux</a>

 
En parallèle, le framework .NET était en cours de développement, et PowerShell y était profondément intégré. Dans les chapitres suivants, je montrerai des exemples.

Et maintenant — le plus important !

Le principal avantage de PowerShell par rapport aux shells de commande classiques est qu'il fonctionne avec des *objets*, et non avec du texte. Lorsque vous exécutez une commande, elle ne renvoie pas seulement du texte, mais un objet structuré (ou une collection d'objets) avec des propriétés et des méthodes clairement définies.

Voyez comment PowerShell surpasse les shells classiques grâce au **travail avec des objets**

### 📁 L'ancienne méthode : `dir` et l'analyse manuelle

Dans **CMD** (à la fois dans l'ancien `COMMAND.COM` et dans `cmd.exe`), la commande `dir` renvoie le résultat sous forme de texte brut. Exemple de sortie :

```
24.07.2025  21:15         1 428  my_script.js
25.07.2025  08:01         3 980  report.html
```

Supposons que vous souhaitiez extraire le **nom de fichier** et la **taille** de chaque fichier. Vous devriez analyser les chaînes manuellement :
```cmd
for /f "tokens=5,6" %a in ('dir ^| findstr /R "[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]"') do @echo %a %b
```

* C'est terriblement difficile à lire, cela dépend des paramètres régionaux, du format de la date et de la police. Et cela ne fonctionne pas avec les espaces dans les noms.

---

### ✅ PowerShell : des objets au lieu du texte

#### ✔ Exemple simple et lisible :

```powershell
Get-ChildItem | Select-Object Name, Length
```

**Résultat :**

```
Name          Length
----          ------
my_script.js   1428
report.html    3980
```

* `Get-ChildItem` renvoie un **tableau d'objets fichier/dossier**
* `Select-Object` vous permet d'obtenir facilement les **propriétés** requises

---

### 🔍 Que renvoie réellement `Get-ChildItem` ?

```powershell
$item = Get-ChildItem -Path .\my_script.js
$item | Get-Member
```

**Résultat :**

```
TypeName: System.IO.FileInfo

Name         MemberType     Definition
----         ---------      ----------
Length       Property       long Length {get;}
Name         Property       string Name {get;}
CreationTime Property       datetime CreationTime {get;set;}
Delete       Method         void Delete()
...
```

PowerShell renvoie des **objets `System.IO.FileInfo`**, qui ont :

* 🧱 Propriétés (`Name`, `Length`, `CreationTime`, `Extension`, …)
* 🛠 Méthodes (`Delete()`, `CopyTo()`, `MoveTo()`, etc.)

Vous travaillez **avec des objets à part entière**, et non avec des chaînes de caractères.

---

### Syntaxe "Verbe-Nom" :

PowerShell utilise une **syntaxe de commande stricte et logique** :
`Verbe-Nom`

| Verbe | Ce qu'il fait |
|---|---|
| `Get-` | Obtenir |
| `Set-` | Définir |
| `New-` | Créer |
| `Remove-` | Supprimer |
| `Start-` | Démarrer |
| `Stop-` | Arrêter |

| Nom | Sur quoi il travaille |
|---|---|
| `Process` | Processus |
| `Service` | Service |
| `Item` | Fichier/dossier |
| `EventLog` | Journaux d'événements |
| `Computer` | Ordinateur |

#### 🔄 Exemples :

| Ce qu'il faut faire | Commande |
|---|---|
| Obtenir les processus | `Get-Process` |
| Arrêter un service | `Stop-Service` |
| Créer un nouveau fichier | `New-Item` |
| Obtenir le contenu d'un dossier | `Get-ChildItem` |
| Supprimer un fichier | `Remove-Item` |

➡ Même si vous **ne connaissez pas la commande exacte**, vous pouvez la **deviner** à partir du sens — et vous aurez presque toujours raison.

---

Le cmdlet `Get-Help` est votre principal assistant.

1.  **Obtenir de l'aide sur l'aide elle-même :**
    ```powershell
    Get-Help Get-Help
    ```
2.  **Obtenir de l'aide de base sur la commande pour travailler avec les processus :**
    ```powershell
    Get-Help Get-Process
    ```
3.  **Voir des exemples d'utilisation de cette commande :**
    ```powershell
    Get-Help Get-Process -Examples
    ```
    C'est un paramètre incroyablement utile qui fournit souvent des solutions prêtes à l'emploi pour vos tâches.
4.  **Obtenir les informations les plus détaillées sur la commande :**
    ```powershell
    Get-Help Get-Process -Full
    ```
Dans la partie suivante : le pipeline ou la chaîne de commandes (PipeLines)
