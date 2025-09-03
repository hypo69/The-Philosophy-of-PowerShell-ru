# Outils de chimie pour PowerShell (avec Gemini AI)

**Outils de chimie** est un module PowerShell qui fournit la commande `Start-ChemistryExplorer` pour l'exploration interactive des éléments chimiques à l'aide de Google Gemini AI.

Cet outil transforme votre console en une référence intelligente, vous permettant de rechercher des listes d'éléments par catégorie, de les visualiser dans un tableau filtrable pratique (`Out-ConsoleGridView`) et d'obtenir des informations supplémentaires sur chacun d'eux.

 *(Recommandé de remplacer par une animation GIF réelle du fonctionnement du script)*

## 🚀 Installation et configuration

### Prérequis

1.  **PowerShell 7.2+**.
2.  **Node.js (LTS) :** [Installer ici](https://nodejs.org/).
3.  **Google Gemini CLI :** Assurez-vous que le CLI est installé et authentifié.
    ```powershell
    # 1. Installation de Gemini CLI
    npm install -g @google/gemini-cli

    # 2. Première exécution pour se connecter au compte Google
    gemini
    ```

### Guide d'installation étape par étape

#### Étape 1 : Créez la structure de dossiers correcte (Obligatoire !)

C'est l'étape la plus importante. Pour que PowerShell puisse trouver votre module, il doit se trouver dans un dossier portant **exactement le même nom** que le module lui-même.

1.  Trouvez votre dossier de modules PowerShell personnels.
    ```powershell
    # Cette commande affichera le chemin, généralement C:\Users\VotreNom\Documents\PowerShell\Modules
    $moduleBasePath = Split-Path $PROFILE.CurrentUserAllHosts
    $moduleBasePath
    ```2.  Créez-y un dossier pour notre module nommé `Chemistry`.
    ```powershell
    $modulePath = Join-Path $moduleBasePath "Chemistry"
    if (-not (Test-Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    ```
3.  Téléchargez et placez les fichiers suivants du référentiel dans ce dossier (`Chemistry`) :
    *   `Chemistry.psm1` (code principal du module)
    *   `Chemistry.GEMINI.md` (fichier d'instructions AI)
    *   `Chemistry.psd1` (fichier manifeste, facultatif mais recommandé)

Votre structure de fichiers finale devrait ressembler à ceci :
```
...\Documents\PowerShell\Modules\
└── Chemistry\                <-- Dossier du module
    ├── Chemistry.psd1        <-- Manifeste (facultatif)
    ├── Chemistry.psm1        <-- Code principal
    └── Chemistry.GEMINI.md   <-- Instructions AI
```

#### Étape 2 : Débloquez les fichiers

Si vous avez téléchargé des fichiers depuis Internet, Windows peut les bloquer. Exécutez cette commande pour résoudre le problème :
```powershell
Get-ChildItem -Path $modulePath | Unblock-File
```

#### Étape 3 : Importez et testez le module

Redémarrez PowerShell. Le module devrait se charger automatiquement. Pour vous assurer que la commande est disponible, exécutez :
```powershell
Get-Command -Module Chemistry
```
La sortie devrait être :
```
CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Function        Start-ChemistryExplorer 1.0.0      Chemistry
```

## 💡 Utilisation

Après l'installation, exécutez simplement la commande dans votre console :
```powershell
Start-ChemistryExplorer
```
Le script vous accueillera et vous invitera à saisir une catégorie d'éléments chimiques.
> `Démarrage de la référence interactive du chimiste...`
> `Entrez la catégorie d'éléments (par exemple, 'gaz nobles') ou 'quitter'`
> `> gaz nobles`

Après cela, une fenêtre interactive `Out-ConsoleGridView` apparaîtra avec une liste d'éléments. Sélectionnez l'un d'eux, et Gemini vous donnera des faits intéressants à son sujet.

## 🛠️ Dépannage

*   **Erreur "module non trouvé"** :
    1.  **Redémarrez PowerShell.** Cela résout le problème dans 90 % des cas.
    2.  Vérifiez à nouveau l'**Étape 1**. Le nom du dossier (`Chemistry`) et le nom du fichier (`Chemistry.psm1` ou `Chemistry.psd1`) doivent être corrects.

*   **Commande `Start-ChemistryExplorer` introuvable après l'importation** :
    1.  Assurez-vous que votre `Chemistry.psm1` file has the line `Export-ModuleMember -Function Start-ChemistryExplorer` at the end.
    2.  If you are using a manifest (`.psd1`), ensure that the `FunctionsToExport = 'Start-ChemistryExplorer'` field is populated in it.
