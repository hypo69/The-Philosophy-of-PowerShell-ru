# Philosophie de PowerShell.
## Partie 2 : Le pipeline, les variables, Get-Member, les fichiers *.ps1* et l'exportation des résultats
**❗ Important :**
J'écris sur PS7 (PowerShell 7). Il est différent de PS5 (PowerShell 5). À partir de la version 7, PS est devenu multiplateforme. Pour cette raison, le comportement de certaines commandes a changé.

Dans la première partie, nous avons établi un principe clé : PowerShell fonctionne avec des **objets**, et non avec du texte. Cet article est consacré à certains outils importants de PowerShell : nous apprendrons à passer des objets dans le **pipeline**, à les analyser avec **`Get-Member`**, à enregistrer les résultats dans des **variables** et à automatiser tout cela dans des **fichiers de script (`.ps1`)** avec **l'exportation** des résultats dans des formats pratiques.

### 1. Qu'est-ce que le pipeline (`|`) ?
Le pipeline dans PowerShell est un mécanisme permettant de transmettre des objets .NET complets (et pas seulement du texte) d'une commande à une autre, où chaque cmdlet suivante reçoit des objets structurés avec toutes leurs propriétés et méthodes.

Le symbole `|` (barre verticale) est l'opérateur de pipeline. Son travail consiste à prendre le résultat (sortie) de la commande située à sa gauche et à le transmettre en entrée à la commande située à sa droite.

`Commande 1 (crée des objets)` → `|` → `Commande 2 (reçoit et traite des objets)` → `|` → `Commande 3 (reçoit des objets traités)` → | ...

#### Le pipeline UNIX classique : un flux de texte

Dans `bash`, un **flux d'octets** est transmis par le pipeline, qui est généralement interprété comme du texte.

```bash
# Trouver tous les processus 'nginx' et les compter
ps -ef | grep 'nginx' | wc -l
```
Ici, `ps` affiche du texte, `grep` filtre ce texte et `wc` compte les lignes. Chaque utilitaire ne sait rien des "processus" ; il ne fonctionne qu'avec des chaînes de caractères.

#### Le pipeline PowerShell : un flux d'objets
**Exemple :** Obtenons tous les processus, trions-les par utilisation du processeur et sélectionnons les 5 plus "gourmands".

```powershell
Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
```
![1](assets/02/1.png)

Ici, `Get-Process` crée des **objets** de processus. `Sort-Object` reçoit ces **objets** et les trie par la propriété `CPU`. `Select-Object` reçoit les **objets** triés et sélectionne les 5 premiers.

Vous avez probablement remarqué des mots dans la commande qui commencent par un trait d'union (-) : -Property, -Descending, -First. Ce sont des paramètres.
Les paramètres sont des paramètres, des commutateurs et des instructions pour un cmdlet. Ils vous permettent de contrôler **COMMENT** une commande effectuera son travail. Sans paramètres, une commande fonctionne dans son mode par défaut, mais avec des paramètres, vous lui donnez des instructions spécifiques.

Principaux types de paramètres :

- Paramètre avec une valeur : nécessite des informations supplémentaires.

    `-Property CPU` : nous indiquons à Sort-Object la propriété par laquelle trier. CPU est la valeur du paramètre.
    
    `-First 5` : nous indiquons à Select-Object le nombre d'objets à sélectionner. 5 est la valeur du paramètre.

- Paramètre de commutation (indicateur) : ne nécessite pas de valeur. Sa simple présence dans la commande active ou désactive un certain comportement.

   `-Descending` : cet indicateur indique à Sort-Object d'inverser l'ordre de tri (du plus grand au plus petit). Il n'a pas besoin de valeur supplémentaire, c'est une instruction en soi.

```powershell
Get-Process -Name 'svchost' | Measure-Object
```
![1](assets/02/2.png)
Cette commande répond à une question très simple :
**"Combien de processus nommés `svchost.exe` sont actuellement en cours d'exécution sur mon système ?"**

#### Répartition étape par étape

##### **Étape 1 : `Get-Process -Name 'svchost'`**

Cette partie de la commande interroge le système d'exploitation et lui demande de trouver **tous** les processus en cours d'exécution dont le nom de fichier exécutable est `svchost.exe`.
Contrairement aux processus comme `notepad` (dont il y en a généralement un ou deux), il y a toujours **beaucoup** de processus `svchost` dans le système. La commande renverra un **tableau (collection) d'objets**, où chaque objet est un processus `svchost` distinct et complet avec son propre ID unique, son utilisation de la mémoire, etc.
PowerShell a trouvé, par exemple, 90 processus `svchost` dans le système et détient maintenant une collection de 90 objets.

##### **Étape 2 : `|` (opérateur de pipeline)**

Ce symbole prend la collection de 90 objets `svchost` obtenue à la première étape et commence à les transmettre **un par un** à l'entrée de la commande suivante.

##### **Étape 3 : `Measure-Object`**

Comme nous avons appelé `Measure-Object` sans paramètres (tels que `-Property`, `-Sum`, etc.), il effectue son opération **par défaut** : il compte simplement le nombre d'"éléments" qui lui sont transmis.
Un, deux, trois... Une fois que tous les objets ont été comptés, `Measure-Object` crée son **propre objet de résultat**, qui a une propriété `Count` égale au nombre final.


**`Count: 90`** — c'est la réponse à notre question. 90 processus `svchost` sont en cours d'exécution.
Les autres champs sont vides car nous n'avons pas demandé à `Measure-Object` d'effectuer des calculs plus complexes.


#### Exemple avec `svchost` et des paramètres

Changeons notre tâche. Maintenant, nous ne voulons pas seulement compter les processus `svchost`, mais savoir **quelle quantité totale de RAM (en mégaoctets) ils consomment ensemble**.

Pour ce faire, nous aurons besoin de paramètres :
*   `-Property WorkingSet64` : cette instruction indique à `Measure-Object` : "De chaque objet `svchost` qui vous parvient, prenez la valeur numérique de la propriété `WorkingSet64` (c'est l'utilisation de la mémoire en octets)".
*   `-Sum` : cette instruction d'indicateur dit : "Additionnez toutes ces valeurs que vous avez prises de la propriété `WorkingSet64`".

Notre nouvelle commande ressemblera à ceci :
```powershell
Get-Process -Name 'svchost' | Measure-Object -Property WorkingSet64 -Sum
```
![3](assets/02/3.png)

1.  `Get-Process` trouvera le nombre d'objets `svchost`.
2.  Le pipeline `|` les transmettra à `Measure-Object`.
3.  Mais maintenant, `Measure-Object` fonctionne différemment :
    *   Il prend le premier objet `svchost`, examine sa propriété `.WorkingSet64` (par exemple, `25000000` octets) et mémorise ce nombre.
    *   Il prend le deuxième objet, examine son `.WorkingSet64` (par exemple, `15000000` octets) et l'ajoute au précédent.
    *   ...et ainsi de suite pour tous les objets.
4.  En conséquence, `Measure-Object` créera un objet de résultat, mais il sera maintenant différent.


*   **`Count: 92`** : le nombre d'objets.
*   **`Sum: 1661890560`** : c'est la somme totale de toutes les valeurs `WorkingSet64` en octets.
*   **`Property: WorkingSet64`** : ce champ est maintenant également rempli ; il nous informe de la propriété qui a été utilisée pour les calculs.




### 2. Les variables (ordinaires et la spéciale `$_`)

Une variable est un stockage nommé en mémoire qui contient une valeur.

Cette valeur peut être n'importe quoi : du texte, un nombre, une date ou, plus important encore pour PowerShell, un objet entier ou même une collection d'objets. Un nom de variable dans PowerShell commence toujours par un signe dollar ($).
Exemples : $name, $counter, $processList.

La variable spéciale $_ ?

$_ est un raccourci pour "l'objet actuel" ou "cette chose ici".
Imaginez un tapis roulant dans une usine. Différentes pièces (objets) se déplacent dessus.

$_ est la pièce même qui se trouve juste devant vous (ou devant le robot de traitement).

La source (Get-Process) déverse une boîte entière de pièces (tous les processus) sur le tapis roulant.

Le pipeline (|) fait avancer ces pièces sur le tapis une par une.

Le gestionnaire (Where-Object ou ForEach-Object) est un robot qui examine chaque pièce.

La variable $_ est la pièce même qui se trouve actuellement dans les "mains" du robot.

Lorsque le robot a terminé avec une pièce, le tapis roulant lui en fournit la suivante, et $_ pointera maintenant vers elle.



Calculons la quantité totale de mémoire utilisée par les processus `svchost` et affichons le résultat sur le moniteur.
```powershell
# 1. Exécutez la commande et enregistrez son objet de résultat complexe dans la variable $svchostMemory
$svchostMemory = Get-Process -Name svchost | Measure-Object -Property WorkingSet64 -Sum

# 2. Nous pouvons maintenant travailler avec l'objet enregistré. Extrayons-en la propriété Sum
$memoryInMB = $svchostMemory.Sum / 1MB

# 3. Affichez le résultat à l'écran à l'aide de la nouvelle variable
Write-Host "Tous les processus svchost utilisent $memoryInMB Mo de mémoire."
```
![3](assets/02/4.png)

*   `Write-Host` est un cmdlet spécialisé dont le seul but est d'**afficher du texte directement à l'utilisateur dans la console**.

*   Une chaîne entre guillemets doubles : `"..."` est une chaîne de texte que nous passons au cmdlet `Write-Host` en tant qu'argument. Pourquoi des guillemets doubles et non des guillemets simples ?
    
    Dans PowerShell, il existe deux types de guillemets :
    
    *   **Simples (`'...'`) :** créent une **chaîne littérale**. Tout ce qui se trouve à l'intérieur est traité comme du texte brut, sans exception.
    *   **Doubles (`"..."`) :** créent une **chaîne extensible (ou substituable)**. PowerShell "analyse" une telle chaîne à la recherche de variables (commençant par `$`) et substitue leurs valeurs à leur place.

* `$memoryInMB`. C'est la variable dans laquelle nous avons mis **à l'étape précédente** de notre script le résultat des calculs. Lorsque `Write-Host` reçoit une chaîne entre guillemets doubles, un processus appelé **"Expansion de chaîne"** se produit :
    1.  PowerShell voit le texte `"Tous les processus svchost utilisent "`.
    2.  Ensuite, il rencontre la construction `$memoryInMB`. Il comprend que ce n'est pas seulement du texte, mais une variable.
    3.  Il regarde dans la mémoire, trouve la valeur stockée dans `$memoryInMB` (par exemple, `1585.52`).
    4.  Il **substitue cette valeur** directement dans la chaîne.
    5.  Ensuite, il ajoute le reste du texte : `" Mo de mémoire."`.
    6.  En conséquence, la chaîne déjà assemblée est transmise à `Write-Host` : `"Tous les processus svchost utilisent 1585.52 Mo de mémoire."`.



Démarrez le Bloc-notes :
 1. Trouvez le processus du Bloc-notes et enregistrez-le dans la variable $notepadProcess
 ```powershell
$notepadProcess = Get-Process -Name notepad
```

 2. Accédez à la propriété 'Id' de cet objet via le point et affichez-la
 ```powershell
Write-Host "L'ID du processus 'Bloc-notes' est : $($notepadProcess.Id)"
```
![5](assets/02/5.png)

**❗ Important :**
    Write-Host "casse" le pipeline. Le texte qu'il affiche ne peut pas être transmis plus loin dans le pipeline pour être traité. Il est uniquement destiné à l'affichage.

### 3. Get-Member (l'inspecteur d'objets)

Nous savons que des objets "circulent" dans le pipeline. Mais comment savoir de quoi ils sont composés ? Quelles propriétés ont-ils et quelles actions (méthodes) peut-on effectuer sur eux ?

Le cmdlet **`Get-Member`** (alias : `gm`) est le principal outil d'investigation.
Avant de travailler avec un objet, passez-le dans `Get-Member` pour voir toutes ses fonctionnalités.

Analysons les objets que `Get-Process` crée :
```powershell
Get-Process | Get-Member
```
![6](assets/02/6.png)

*Décomposons chaque partie de la sortie de Get-Member.*

`TypeName: System.Diagnostics.Process` - C'est le "nom de type" complet et officiel de l'objet de la bibliothèque .NET. C'est son "passeport".
Cette ligne vous indique que tous les objets renvoyés par Get-Process sont des objets de type System.Diagnostics.Process.
Cela garantit qu'ils auront tous le même ensemble de propriétés et de méthodes.
Vous pouvez [rechercher sur Google](https://www.google.com/search?q=System.Diagnostics.Process+site%3Amicrosoft.com) "System.Diagnostics.Process" pour trouver la documentation officielle de Microsoft avec des informations encore plus détaillées.



- Colonne 1 : `Name`

C'est un **nom** simple et lisible par l'homme d'une propriété, d'une méthode ou d'un autre "membre" d'un objet. C'est ce nom que vous utiliserez dans votre code pour accéder aux données ou effectuer des actions.



- Colonne 2 : `MemberType` (type de membre)

C'est la colonne la plus importante à comprendre. Elle classifie **ce qu'est** chaque membre. C'est son "titre de poste" qui vous indique **COMMENT** l'utiliser.

*   **`Property` (propriété) :** une **caractéristique** ou une **partie de données** stockée à l'intérieur d'un objet. Vous pouvez "lire" sa valeur.
    *   *Exemples de la capture d'écran :* `BasePriority`, `HandleCount`, `ExitCode`. Ce ne sont que des données qui peuvent être consultées.

*   **`Method` (méthode) :** une **ACTION** qui peut être effectuée sur un objet. Les méthodes sont toujours appelées avec des parenthèses `()`.
    *   *Exemples de la capture d'écran :* `Kill`, `Refresh`, `WaitForExit`. Vous écririez `$process.Kill()` ou `$process.Refresh()`.

*   **`AliasProperty` (propriété d'alias) :** un **alias convivial** pour une autre propriété plus longue. PowerShell les ajoute pour plus de commodité et de brièveté.
    *   *Exemples de la capture d'écran :* `WS` est un alias court pour `WorkingSet64`. `Name` est pour `ProcessName`. `VM` est pour `VirtualMemorySize64`.

*   **`Event` (événement) :** une **NOTIFICATION** que quelque chose s'est produit, à laquelle vous pouvez vous "abonner".
    *   *Exemple de la capture d'écran :* `Exited`. Votre script peut "écouter" cet événement pour effectuer une action immédiatement après la fin du processus.

*   **`CodeProperty` et `NoteProperty` :** des types spéciaux de propriétés, souvent ajoutés par PowerShell lui-même pour plus de commodité. Une `CodeProperty` calcule sa valeur "à la volée", et une `NoteProperty` est une simple propriété de note ajoutée à l'objet.

- Colonne 3 : `Definition` (définition)

C'est la **définition technique** ou la "signature" du membre. Elle vous donne les détails exacts pour son utilisation. Son contenu dépend du `MemberType` :

*   **Pour `AliasProperty` :** indique **à quoi l'alias est égal**. C'est incroyablement utile !
    *   *Exemple de la capture d'écran :* `WS = WorkingSet64`. Vous pouvez voir immédiatement que `WS` n'est qu'une notation abrégée pour `WorkingSet64`.

*   **Pour `Property` :** indique le **type de données** stocké dans la propriété (par exemple, `int` pour un entier, `string` pour du texte, `datetime` pour une date et une heure), et ce que vous pouvez en faire (`{get;}` - lecture seule, `{get;set;}` - lecture et écriture).
    *   *Exemple de la capture d'écran :* `int BasePriority {get;}`. C'est une propriété entière qui ne peut être que lue.

*   **Pour `Method` :** indique ce que la méthode renvoie (par exemple, `void` - rien, `bool` - vrai/faux) et quels **paramètres** (données d'entrée) elle accepte entre parenthèses.
    *   *Exemple de la capture d'écran :* `void Kill()`. Cela signifie que la méthode `Kill` ne renvoie rien et peut être appelée sans paramètres. Il existe également une deuxième version `void Kill(bool entireProcessTree)` qui accepte une valeur booléenne (vrai/faux).

#### Sous forme de tableau

| Colonne | Qu'est-ce que c'est ? | Exemple de la capture d'écran | À quoi ça sert ? |
|---|---|---|---|
| **Name** | Le nom que vous utilisez dans votre code. | `Kill`, `WS`, `Name` | pour accéder à une propriété ou à une méthode (`$process.WS`, `$process.Kill()`). |
| **MemberType**| Le type de membre (données, action, etc.). | `Method`, `Property`, `AliasProperty` | **comment** l'utiliser (lire une valeur ou appeler avec `()`). |
| **Definition** | Détails techniques. | `WS = WorkingSet64`, `void Kill()` | ce qui se cache derrière un alias et quels paramètres une méthode nécessite. |



#### Exemple : Travailler avec les fenêtres de processus

##### 1. Le problème :
"J'ai ouvert de nombreuses fenêtres du Bloc-notes. Comment puis-je réduire par programme toutes les fenêtres sauf la principale, puis ne fermer que celle qui a le mot 'Sans titre' dans son titre ?"

##### 2. Investigation avec `Get-Member` :
Nous devons trouver des propriétés liées à la fenêtre et à son titre.

```powershell
Get-Process -Name notepad | Get-Member
```
**Analyse du résultat de `Get-Member` :**
*   En parcourant les propriétés, nous trouvons `MainWindowTitle`. Le type est `string`. Parfait, c'est le titre de la fenêtre principale !
*   Dans les méthodes, nous voyons `CloseMainWindow()`. C'est une façon plus "douce" de fermer une fenêtre que `Kill()`.
*   Toujours dans les méthodes, il y a `WaitForInputIdle()`. Cela semble intéressant ; peut-être que cela aidera à attendre que le processus soit prêt pour l'interaction.

![7](assets/02/7.png)

`Get-Member` nous a montré la propriété `MainWindowTitle`, qui est la clé pour résoudre le problème et nous permet d'interagir avec les processus en fonction de l'état de leurs fenêtres, et pas seulement par leur nom.

##### 3. La solution :
Nous pouvons maintenant construire une logique basée sur le titre de la fenêtre.

```powershell
# 1. Trouver tous les processus du Bloc-notes
$notepads = Get-Process -Name notepad

# 2. Parcourir chacun d'eux et vérifier le titre
foreach ($pad in $notepads) {
    # Pour chaque processus ($pad), vérifier sa propriété MainWindowTitle
    if ($pad.MainWindowTitle -like '*Untitled*') {
        Write-Host "Bloc-notes non enregistré trouvé (ID : $($pad.Id)). Fermeture de sa fenêtre..."
        # $pad.CloseMainWindow() # Décommentez pour fermer réellement
        Write-Host "La fenêtre '$($pad.MainWindowTitle)' aurait été fermée." -ForegroundColor Yellow
    } else {
        Write-Host "Ignorer le Bloc-notes avec le titre : $($pad.MainWindowTitle)"
    }
}
```

![8](assets/02/8.png)

![9](assets/02/9.png)


---

#### Exemple : Trouver le processus parent

##### 1. Le problème :
"Parfois, je vois beaucoup de processus enfants `chrome.exe` dans le système. Comment puis-je savoir lequel est le processus principal, le processus "parent" qui les a tous lancés ?"

##### 2. Investigation avec `Get-Member` :
Nous devons trouver quelque chose qui lie un processus à un autre.

```powershell
Get-Process -Name chrome | Select-Object -First 1 | Get-Member
```
![10](assets/02/10.png)

**Analyse du résultat de `Get-Member` :**
*   En examinant attentivement la liste, nous trouvons une propriété de type `CodeProperty` nommée `Parent`.
*   Sa `Definition` est `System.Diagnostics.Process Parent{get=GetParentProcess;}`.
C'est une propriété calculée qui, lorsqu'on y accède, renvoie l'**objet du processus parent**.

##### 3. La solution :
Nous pouvons maintenant écrire un script qui, pour chaque processus `chrome`, affichera des informations sur son parent.

```powershell
# 1. Obtenir tous les processus chrome
$chromeProcesses = Get-Process -Name chrome

# 2. Pour chacun d'eux, afficher des informations sur lui et son parent
$chromeProcesses | Select-Object -First 5 | ForEach-Object {
    # Obtenir le processus parent
    $parent = $_.Parent
    
    # Formater une belle sortie
    Write-Host "Processus :" -ForegroundColor Green
    Write-Host "  - Nom : $($_.ProcessName), ID : $($_.Id)"
    Write-Host "Son parent :" -ForegroundColor Yellow
    Write-Host "  - Nom : $($parent.ProcessName), ID : $($parent.Id)"
    Write-Host "-----------------------------"
}
```
![11](assets/02/11.png)

![12](assets/02/12.png)

Nous pouvons voir immédiatement que les processus avec les ID 4756, 7936, 8268 et 9752 ont été lancés par le processus avec l'ID 14908. Nous pouvons également remarquer un cas intéressant avec l'ID de processus : 7252, dont le processus parent n'a pas été déterminé (peut-être que le parent s'était déjà terminé au moment de la vérification). La modification du script avec une vérification if ($parent) gère proprement ce cas sans provoquer d'erreur.
Get-Member nous a aidés à découvrir la propriété "cachée" Parent, qui offre de puissantes fonctionnalités pour analyser la hiérarchie des processus.

#### 4. Le fichier *.ps1* (création de scripts)

Lorsque votre chaîne de commandes devient utile, vous voudrez l'enregistrer pour une utilisation répétée. C'est à cela que servent les **scripts** : des fichiers texte avec l'extension **`.ps1`**.

##### Autorisation d'exécuter des scripts
Par défaut, Windows interdit l'exécution de scripts locaux. Pour corriger cela **pour l'utilisateur actuel**, exécutez ce qui suit une fois dans PowerShell **en tant qu'administrateur** :
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
C'est un paramètre sûr qui vous permet d'exécuter vos propres scripts et des scripts signés par un éditeur de confiance.

##### Exemple de script `system_monitor.ps1`
Créez un fichier avec ce nom et collez-y le code ci-dessous. Ce script collecte des informations système et génère des rapports.

```powershell
# system_monitor.ps1
#requires -Version 5.1

<#
.SYNOPSIS
    Un script pour créer un rapport d'état du système.
.DESCRIPTION
    Collecte des informations sur les processus, les services et l'espace disque et génère des rapports.
.PARAMETER OutputPath
    Le chemin pour enregistrer les rapports. La valeur par défaut est 'C:\Temp'.
.EXAMPLE
    .\system_monitor.ps1 -OutputPath "C:\Reports"
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Temp"
)

# --- Bloc 1 : Préparation ---
Write-Host "Préparation de la création du rapport..." -ForegroundColor Cyan
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- Bloc 2 : Collecte de données ---
Write-Host "Collecte d'informations..." -ForegroundColor Green
$processes = Get-Process | Sort-Object CPU -Descending
$services = Get-Service | Group-Object Status | Select-Object Name, Count

# --- Bloc 3 : Appel de la fonction d'exportation (voir la section suivante) ---
Export-Results -Processes $processes -Services $services -OutputPath $OutputPath

Write-Host "Rapports enregistrés avec succès dans le dossier $OutputPath" -ForegroundColor Magenta
```
*Remarque : la fonction `Export-Results` sera définie dans la section suivante comme un exemple de bonne pratique.*

#### 5. Exporter les résultats

Les données brutes, c'est bien, mais il faut souvent les présenter sous une forme pratique pour une personne ou un autre programme. PowerShell propose de nombreux cmdlets pour l'exportation.

| Méthode | Commande | Description |
|---|---|---|
| **Texte brut** | `... \| Out-File C:\Temp\data.txt` | Redirige la représentation textuelle vers un fichier. |
| **CSV (pour Excel)** | `... \| Export-Csv C:\Temp\data.csv -NoTypeInfo` | Exporte des objets au format CSV. `-NoTypeInfo` supprime la première ligne de service. |
| **Rapport HTML** | `... \| ConvertTo-Html -Title "Rapport"` | Crée du code HTML à partir d'objets. |
| **JSON (pour API, web)** | `... \| ConvertTo-Json` | Convertit des objets au format JSON. |
| **XML (format natif de PowerShell)** | `... \| Export-Clixml C:\Temp\data.xml` | Enregistre des objets avec tous les types de données. Ils peuvent être parfaitement restaurés via `Import-Clixml`. |

##### Ajout au script : fonction d'exportation
Ajoutons une fonction à notre script `system_monitor.ps1` qui se chargera de l'exportation. Placez ce code **avant** l'appel de `Export-Results`.

```powershell
function Export-Results {
    param(
        $Processes,
        $Services,
        $OutputPath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

    # Exporter au format CSV
    $Processes | Select-Object -First 20 | Export-Csv (Join-Path $OutputPath "processes_$timestamp.csv") -NoTypeInformation
    $Services | Export-Csv (Join-Path $OutputPath "services_$timestamp.csv") -NoTypeInformation

    # Créer un joli rapport HTML
    $htmlReportPath = Join-Path $OutputPath "report_$timestamp.html"
    $processesHtml = $Processes | Select-Object -First 10 Name, Id, CPU | ConvertTo-Html -Fragment -PreContent "<h2>Top 10 des processus par processeur</h2>"
    $servicesHtml = $Services | ConvertTo-Html -Fragment -PreContent "<h2>Statistiques des services</h2>"

    ConvertTo-Html -Head "<title>Rapport système</title>" -Body "<h1>Rapport système du $(Get-Date)</h1> $($processesHtml) $($servicesHtml)" | Out-File $htmlReportPath
}
```
Maintenant, notre script ne se contente pas de collecter des données, il les enregistre également proprement dans deux formats : CSV pour l'analyse et HTML pour une visualisation rapide.

#### Conclusion

1.  **Le pipeline (`|`)** est l'outil principal pour combiner des commandes et traiter des objets.
2.  **`Get-Member`** est un analyseur d'objets qui montre de quoi ils sont composés.
3.  **Les variables (`$var`, `$_`)** vous permettent d'enregistrer des données et de vous référer à l'objet actuel dans le pipeline.
4.  **Les fichiers `.ps1`** transforment les commandes en outils d'automatisation réutilisables.
5.  **Les cmdlets d'exportation** (`Export-Csv`, `ConvertTo-Html`) exportent les données dans le format approprié.

**Dans la partie suivante, nous appliquerons ces connaissances pour naviguer et gérer le système de fichiers, en explorant les objets `System.IO.DirectoryInfo` et `System.IO.FileInfo`.**
