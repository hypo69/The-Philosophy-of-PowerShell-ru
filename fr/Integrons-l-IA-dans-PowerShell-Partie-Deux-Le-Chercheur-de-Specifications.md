# Intégrons l'IA dans PowerShell. Partie Deux : Le Chercheur de Spécifications

La dernière fois, nous avons vu comment interagir avec le modèle Gemini via l'interface de ligne de commande en utilisant PowerShell. Dans cet article, je vais vous montrer comment tirer parti de nos connaissances. Nous transformerons notre console en un guide de référence interactif qui prendra un identifiant de composant (marque, modèle, catégorie, numéro de pièce, etc.) en entrée et renverra un tableau interactif avec les spécifications obtenues du modèle Gemini.

Les ingénieurs, développeurs et autres spécialistes sont souvent confrontés à la nécessité de connaître les paramètres exacts, par exemple, d'une carte mère, d'un disjoncteur dans un tableau électrique ou d'un commutateur réseau. Notre guide de référence sera toujours à portée de main et, sur demande, recueillera des informations, clarifiera les paramètres sur Internet et renverra le tableau souhaité. Dans le tableau, vous pourrez sélectionner le ou les paramètres nécessaires et, si besoin, poursuivre une recherche plus approfondie. Plus tard, nous apprendrons à transmettre le résultat via le pipeline pour un traitement ultérieur : exportation vers une feuille de calcul Excel ou Google, stockage dans une base de données ou transfert vers un autre programme. En cas d'échec, le modèle conseillera quels paramètres doivent être clarifiés. Mais voyez par vous-même :

[vidéo](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Comment fonctionne le Chercheur de Spécifications alimenté par l'IA : du lancement au résultat

Traçons le cycle de vie complet de notre script – ce qui se passe depuis le moment de son lancement jusqu'à l'obtention des résultats.

## Initialisation : Préparation au travail

Le script accepte un paramètre `$Model` avec validation – vous pouvez choisir 'gemini-2.5-flash' (le modèle rapide par défaut) ou 'gemini-2.5-pro' (plus puissant). Au lancement, le script configure d'abord l'environnement de travail. Il définit la clé API pour l'accès à Gemini AI, définit le dossier actuel comme répertoire de base et crée une structure pour le stockage des fichiers. Pour chaque session, un fichier avec un horodatage est créé, par exemple, `ai_session_2025-08-26_14-30-15.jsonl`. C'est l'historique du dialogue.

Ensuite, le système vérifie que tous les outils nécessaires sont installés. Il recherche le CLI Gemini dans le système et vérifie les fichiers de configuration dans le dossier `.gemini/`. Le fichier `GEMINI.md` est particulièrement important – il contient le prompt système pour le modèle et est automatiquement chargé par le CLI Gemini au démarrage. C'est l'emplacement standard pour les instructions système. Le fichier `ShowHelp.md`, qui contient des informations d'aide, est également vérifié. Si quelque chose de critique est manquant, le script avertit l'utilisateur ou se termine.

## Démarrage du mode interactif

Après une initialisation réussie, le script affiche un message de bienvenue indiquant le modèle sélectionné ("Chercheur de Spécifications AI. Modèle : 'gemini-2.5-flash'."), le chemin vers le fichier de session et les instructions pour les commandes. Il entre ensuite en mode interactif – il affiche une invite et attend la saisie de l'utilisateur. L'invite ressemble à `🤖AI :) > ` et change en `🤖AI [Sélection active] :) > ` lorsque le système a des données à analyser.

## Traitement de la saisie utilisateur

Chaque saisie utilisateur est d'abord vérifiée pour les commandes de service par la fonction `Command-Handler`. Cette fonction reconnaît les commandes comme `?` (aide du fichier ShowHelp.md), `history` (afficher l'historique de session), `clear` et `clear-history` (effacer le fichier d'historique), `gemini help` (aide CLI), et `exit` et `quit` (quitter). S'il s'agit d'une commande de service, elle est exécutée immédiatement sans contacter l'IA, et la boucle continue.

S'il s'agit d'une requête régulière, le système commence à construire le contexte à envoyer à Gemini. Il lit l'historique complet de la session actuelle à partir du fichier JSONL (s'il existe), ajoute un bloc avec des données de la sélection précédente (s'il y a une sélection active), et combine tout cela avec la nouvelle requête utilisateur dans un prompt structuré avec les sections "HISTORIQUE DU DIALOGUE", "DONNÉES DE LA SÉLECTION" et "NOUVELLE TÂCHE". Après utilisation, les données de sélection sont effacées.

## Interaction avec l'Intelligence Artificielle

Le prompt formé est envoyé à Gemini via la ligne de commande avec l'appel `& gemini -m $Model -p $Prompt 2>&1`. Le système capture toutes les sorties (y compris les erreurs via `2>&1`), vérifie le code de retour et nettoie le résultat des messages de service CLI ("La collecte de données est désactivée" et "Identifiants mis en cache chargés"). Si une erreur se produit à ce stade, l'utilisateur reçoit un avertissement, mais le script continue de s'exécuter.

## Traitement de la réponse de l'IA

Le système tente d'interpréter la réponse reçue de l'IA comme du JSON. D'abord, il recherche un bloc de code au format ```json...```, extrait le contenu et essaie de le parser. S'il n'y a pas un tel bloc, il parse la réponse entière. Si le parsing est réussi, les données sont affichées dans un tableau interactif `Out-ConsoleGridView` avec le titre "Sélectionner les lignes pour la prochaine requête (OK) ou fermer (Annuler)" et la sélection multiple activée. Si le JSON n'est pas reconnu (erreur de parsing), la réponse est affichée en texte brut en bleu.

## Travailler avec la sélection de données

Lorsque l'utilisateur sélectionne des lignes dans le tableau et clique sur OK, le système effectue plusieurs actions. Tout d'abord, la fonction `Show-SelectionTable` est appelée, qui analyse la structure des données sélectionnées : s'il s'agit d'objets avec des propriétés, elle identifie tous les champs uniques et affiche les données à l'aide de `Format-Table` avec ajustement automatique de la taille et retour à la ligne. S'il s'agit de valeurs simples, elle les affiche sous forme de liste numérotée. Elle affiche ensuite un compteur des éléments sélectionnés et le message "Sélection enregistrée. Ajoutez votre prochaine requête (par exemple, 'comparez-les')."

Les données sélectionnées sont converties en JSON compressé avec une profondeur d'imbrication de 10 niveaux et enregistrées dans la variable `$selectionContextJson` pour être utilisées dans les requêtes ultérieures à l'IA.

## Maintien de l'historique

Chaque paire "requête utilisateur - réponse IA" est enregistrée dans le fichier d'historique au format JSONL. Cela assure la continuité du dialogue – l'IA "se souvient" de toute la conversation précédente et peut se référer à des sujets précédemment discutés.

## Le cycle continue

Après avoir traité la requête, le système revient à l'attente d'une nouvelle saisie. Si l'utilisateur a une sélection active, cela se reflète dans l'invite de la ligne de commande. Le cycle continue jusqu'à ce que l'utilisateur entre une commande de sortie.

## Exemple pratique de fonctionnement

Imaginez qu'un utilisateur exécute le script et entre "RTX 4070 Ti Super" :

1.  **Préparation du contexte :** Le système prend le prompt système du fichier, ajoute l'historique (actuellement vide) et la nouvelle requête.
2.  **Requête IA :** Le prompt complet est envoyé à Gemini avec une demande de trouver les spécifications des cartes graphiques.
3.  **Récupération des données :** L'IA renvoie un JSON avec un tableau d'objets contenant des informations sur différents modèles de RTX 4070 Ti Super.
4.  **Tableau interactif :** L'utilisateur voit un tableau avec les fabricants, les spécifications et les prix, et sélectionne 2-3 modèles intéressants.
5.  **Affichage de la sélection :** Un tableau avec les modèles sélectionnés apparaît dans la console, et l'invite passe à `[Sélection active]`.
6.  **Affiner la requête :** L'utilisateur tape "comparez leurs performances de jeu".
7.  **Analyse contextuelle :** L'IA reçoit la requête initiale, les modèles sélectionnés et la nouvelle question, fournissant une comparaison détaillée de ces cartes spécifiques.

## Arrêt

Lorsque `exit` ou `quit` est saisi, le script se termine correctement, après avoir enregistré tout l'historique de la session dans un fichier. L'utilisateur peut revenir à ce dialogue à tout moment en consultant le contenu du fichier correspondant dans le dossier `.chat_history`.

Toute cette logique complexe est cachée à l'utilisateur derrière une interface de ligne de commande simple. La personne pose simplement des questions et reçoit des réponses structurées, tandis que le système prend en charge tout le travail de maintien du contexte, d'analyse des données et de gestion de l'état du dialogue.

---

## Étape 1 : Configuration

```powershell
# --- Étape 1 : Configuration ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- CHANGEMENT : Variable renommée ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- FIN DU CHANGEMENT ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**Objectif des lignes :**

- `$env:GEMINI_API_KEY = "..."` - définit la clé API pour l'accès à Gemini AI.
- `if (-not $env:GEMINI_API_KEY)` - vérifie la présence de la clé et termine le script si elle est manquante.
- `$scriptRoot = Get-Location` - obtient le répertoire de travail actuel.
- `$HistoryDir = Join-Path...` - forme le chemin vers le dossier de stockage de l'historique des dialogues (`.gemini/.chat_history`).
- `$timestamp = Get-Date...` - crée un horodatage au format `2025-08-26_14-30-15`.
- `$historyFileName = "ai_session_$timestamp.jsonl"` - génère un nom de fichier de session unique.
- `$historyFilePath = Join-Path...` - crée le chemin complet vers le fichier d'historique de la session actuelle.

## Vérification de l'environnement - Ce qui doit être installé

```powershell
# --- Étape 2 : Vérification de l'environnement ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "La commande 'gemini' est introuvable..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "Le fichier de prompt système .gemini/GEMINI.md est introuvable..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "Le fichier d'aide .gemini/ShowHelp.md est introuvable..." 
}
```

**Ce qui est vérifié :**

- La présence de **Gemini CLI** dans le système - le script ne fonctionnera pas sans lui.
- Le fichier **GEMINI.md** - contient le prompt système (instructions pour l'IA).
- Le fichier **ShowHelp.md** - aide utilisateur (la commande `?`).

## Fonction principale pour interagir avec l'IA

```powershell
function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        $output = & gemini -m $Model -p $Prompt 2>&1
        if (-not $?) { $output | ForEach-Object { Write-Warning $_.ToString() }; return $null }
        
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        
        return $cleanedOutput.Trim()
    }
    catch { Write-Error "Erreur critique lors de l'appel de Gemini CLI : $_"; return $null }
}
```

**Tâches de la fonction :**
- Appelle le CLI Gemini avec le modèle et le prompt spécifiés.
- Capture toutes les sorties (y compris les erreurs).
- Nettoie le résultat des messages de service CLI.
- Renvoie la réponse IA propre ou `$null` en cas d'erreur.

## Fonctions de gestion de l'historique

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "L'historique de la session actuelle est vide." -ForegroundColor Yellow; return }
    Write-Host "`n--- Historique de la session actuelle ---" -ForegroundColor Cyan
    Get-Content -Path $historyFilePath
    Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
        Write-Host "L'historique de la session actuelle ($historyFileName) a été supprimé." -ForegroundColor Yellow
    }
}
```

**Objectif :**
- `Add-History` - enregistre les paires "question-réponse" au format JSONL.
- `Show-History` - affiche le contenu du fichier d'historique.
- `Clear-History` - supprime le fichier d'historique de la session actuelle.

## Fonction d'affichage des données sélectionnées

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) { return }
    
    Write-Host "`n--- DONNÉES SÉLECTIONNÉES ---" -ForegroundColor Yellow
    
    # Obtenir toutes les propriétés uniques des objets sélectionnés
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Afficher un tableau ou une liste
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Éléments sélectionnés : $($SelectedData.Count)" -ForegroundColor Magenta
}
```

**Tâche de la fonction :** Après avoir sélectionné des éléments dans `Out-ConsoleGridView`, elle les affiche dans la console sous forme de tableau soigné, afin que l'utilisateur puisse voir exactement ce qui a été choisi.

## Boucle de travail principale

```powershell
while ($true) {
    # Afficher l'invite avec l'indicateur d'état
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Sélection active] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    $UserPrompt = Read-Host
    
    # Gérer les commandes de service
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # Former le prompt complet avec le contexte
    $fullPrompt = @"
### HISTORIQUE DU DIALOGUE (CONTEXTE)
$historyContent

### DONNÉES DE LA SÉLECTION (POUR ANALYSE)
$selectionContextJson

### NOUVELLE TÂCHE
$UserPrompt
"@
    
    # Appeler l'IA et traiter la réponse
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # Essayer de parser le JSON et afficher le tableau interactif
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Sélectionner les lignes..." -OutputMode Multiple
        
        if ($null -ne $gridSelection) {
            Show-SelectionTable -SelectedData $gridSelection
            $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
        }
    }
    catch {
        Write-Host $ModelResponse -ForegroundColor Cyan
    }
    
    Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
}
```

**Caractéristiques clés :**
- L'indicateur `[Sélection active]` montre qu'il y a des données à analyser.
- Chaque requête inclut l'historique complet du dialogue pour maintenir le contexte.
- L'IA reçoit à la fois l'historique et les données sélectionnées par l'utilisateur.
- Le résultat est tenté d'être affiché sous forme de tableau interactif.
- Si le parsing JSON échoue, le texte brut est affiché.

## Structure des fichiers de travail

Le script crée la structure suivante :
```
├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # Prompt système pour l'IA
│   ├── ShowHelp.md            # Aide utilisateur
│   └── .chat_history/         # Dossier avec l'historique des sessions
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
```

Le fichier `GEMINI.md` dans le dossier `.gemini/` est l'emplacement standard pour le prompt système pour le CLI Gemini. À chaque exécution, le modèle charge automatiquement les instructions de ce fichier, ce qui définit son comportement et le format de ses réponses.

Dans la partie suivante, nous examinerons le contenu des fichiers de configuration et des exemples d'utilisation pratique.