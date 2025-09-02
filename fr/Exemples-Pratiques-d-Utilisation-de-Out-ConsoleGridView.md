### **Exemples pratiques d'utilisation de Out-ConsoleGridView**

Dans le chapitre précédent, nous avons découvert `Out-ConsoleGridView` — un outil puissant pour le travail interactif avec les données directement dans le terminal. Si vous ne savez pas de quoi il s'agit, je vous recommande de le lire d'abord.
Cet article lui est entièrement dédié. Je ne répéterai pas la théorie, mais passerai immédiatement à la pratique et montrerai 10 scénarios dans lesquels ce cmdlet peut faire gagner beaucoup de temps à un administrateur système ou à un utilisateur avancé.

`Out-ConsoleGridView` n'est pas seulement un "visualiseur". C'est un **filtre d'objets interactif** au milieu de votre pipeline.

**Prérequis :**
*   PowerShell 7.2 ou plus récent.
*   Module `Microsoft.PowerShell.ConsoleGuiTools` installé. Si vous ne l'avez pas encore installé :
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```

---

### 10 exemples pratiques

#### Exemple 1 : Arrêt interactif des processus

Une tâche classique : trouver et terminer plusieurs processus "bloqués" ou inutiles.

```powershell
# Sélectionner les processus en mode interactif
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# Si quelque chose a été sélectionné, passer les objets pour l'arrêt
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

[1](https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` récupère tous les processus en cours d'exécution.
2.  `Sort-Object` les ordonne par utilisation du CPU, de sorte que les plus "gourmands en ressources" soient en haut.
3.  `Out-ConsoleGridView` affiche le tableau. Vous pouvez taper `chrome` ou `notepad` pour filtrer instantanément la liste, et sélectionner les processus souhaités avec la touche `Espace`.
4.  Après avoir appuyé sur `Entrée`, les **objets** de processus sélectionnés sont passés à la variable `$procsToStop` puis à `Stop-Process`.

#### Exemple 2 : Gestion des services Windows

Besoin de redémarrer rapidement plusieurs services liés à une application (par exemple, SQL Server).

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les services à redémarrer"

if ($services) {
    $services | Restart-Service -WhatIf
}
```

[1](https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Vous obtenez une liste de tous les services.
2.  Dans `Out-ConsoleGridView`, vous tapez `sql` dans le filtre et voyez immédiatement tous les services liés à SQL Server.
3.  Vous sélectionnez ceux souhaités et appuyez sur `Entrée`. Les objets de service sélectionnés sont passés pour redémarrage.

#### Exemple 3 : Nettoyage du dossier "Téléchargements" des fichiers volumineux

Avec le temps, le dossier "Téléchargements" se remplit de fichiers inutiles. Trouvons et supprimons les plus volumineux.

```powershell

# --- ÉTAPE 1 : Configurer le chemin du répertoire 'Downloads' 
$DownloadsPath = "E:\Users\user\Downloads" # <--- MODIFIEZ CETTE LIGNE AVEC VOTRE CHEMIN
===========================================================================

# Vérification : si le chemin n'est pas spécifié ou si le dossier n'existe pas - quitter.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "Le dossier 'Téléchargements' est introuvable au chemin spécifié : '$DownloadsPath'. Veuillez vérifier le chemin dans le bloc CONFIGURATION au début du script."
    return
}

# --- ÉTAPE 2 : Informer l'utilisateur et collecter les données ---
Write-Host "Démarrage de l'analyse du dossier '$DownloadsPath'. Cela peut prendre un certain temps..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | \
    Sort-Object -Property Length -Descending

# --- ÉTAPE 3 : Vérifier la présence de fichiers et appeler la fenêtre interactive ---
if ($files) {
    Write-Host "Analyse terminée. $($files.Count) fichiers trouvés. Ouverture de la fenêtre de sélection..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les fichiers à supprimer de '$DownloadsPath'"

    # --- ÉTAPE 4 : Traiter la sélection de l'utilisateur ---
    if ($filesToDelete) {
        Write-Host "Les fichiers suivants seront supprimés :" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Opération annulée. Aucun fichier sélectionné." -ForegroundColor Yellow
    }
} else {
    Write-Host "Aucun fichier trouvé dans le dossier '$DownloadsPath'." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[Contenu des Téléchargements](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Nous obtenons tous les fichiers, les trions par taille et utilisons `Select-Object` pour créer une colonne `SizeMB` pratique.
2.  Dans `Out-ConsoleGridView`, vous voyez une liste triée où vous pouvez facilement sélectionner les anciens et grands fichiers `.iso` ou `.zip`.
3.  Après la sélection, leurs chemins complets sont passés à `Remove-Item`.

#### Exemple 4 : Ajout d'utilisateurs à un groupe Active Directory

Un outil indispensable pour les administrateurs AD.

```powershell
# Obtenir les utilisateurs du département Marketing
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# Sélectionner interactivement qui ajouter
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```
Au lieu de saisir manuellement les noms d'utilisateur, vous obtenez une liste pratique où vous pouvez rapidement trouver et sélectionner les employés souhaités par nom de famille ou identifiant.

---

#### Exemple 5 : Savoir quels programmes utilisent Internet en ce moment

L'une des tâches courantes : "Quel programme ralentit Internet ?" ou "Qui envoie des données où ?". Avec `Out-ConsoleGridView`, vous pouvez obtenir une réponse claire et interactive.

**Dans le tableau :**
*   **Tapez `chrome` ou `msedge`** dans le champ de filtre pour voir toutes les connexions actives de votre navigateur.
*   **Saisissez une adresse IP** (par exemple, `151.101.1.69` de la colonne `RemoteAddress`) pour voir quels autres processus sont connectés au même serveur.

```powershell
# Obtenir toutes les connexions TCP actives
$connections = Get-NetTCPConnection -State Established | \
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# Afficher dans un tableau interactif pour analyse
$connections | Out-ConsoleGridView -Title "Connexions Internet actives"
```

1.  `Get-NetTCPConnection -State Established` collecte toutes les connexions réseau établies.
2.  À l'aide de `Select-Object`, nous formons un rapport pratique : nous ajoutons le nom du processus (`ProcessName`) à son ID (`OwningProcess`) pour qu'il soit clair quel programme a établi la connexion.
3.  `Out-ConsoleGridView` vous montre une image en direct de l'activité réseau.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

#### Exemple 6 : Analyse des installations de logiciels et des mises à jour

Nous rechercherons les événements de la source **"MsiInstaller"**. Il est responsable de l'installation, de la mise à jour et de la désinstallation de la plupart des programmes (au format `.msi`), ainsi que de nombreux composants des mises à jour Windows.

```powershell
# Rechercher les 100 derniers événements de l'installateur Windows (MsiInstaller)
# Ces événements sont présents sur n'importe quel système
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# Si des événements sont trouvés, les afficher dans un format pratique
if ($installEvents) {
    $installEvents |
        # Sélectionner uniquement les plus utiles : heure, message et ID d'événement
        # ID 11707 - installation réussie, ID 11708 - installation échouée
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "Journal d'installation de logiciels (MsiInstaller)"
} else {
    Write-Warning "Aucun événement trouvé de 'MsiInstaller'. C'est très inhabituel."
}
```

**Dans le tableau :**
*   Vous pouvez filtrer la liste par nom de programme (par exemple, `Edge` ou `Office`) pour voir tout son historique de mises à jour.
*   Vous pouvez trier par `Id` pour trouver les installations échouées (`11708`).

--- 

#### Exemple 7 : Désinstallation interactive de programmes

```powershell
# Chemins du registre où sont stockées les informations sur les programmes installés
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Collecter les données du registre, en supprimant les composants système qui n'ont pas de nom
$installedPrograms = Get-ItemProperty $registryPaths |
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# Si des programmes sont trouvés, les afficher dans un tableau interactif
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les programmes à désinstaller"
    
    if ($programsToUninstall) {
        Write-Host "Les programmes suivants seront désinstallés :" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # Ce bloc est plus complexe, car Uninstall-Package ne fonctionnera pas ici.
        # Nous lançons la commande de désinstallation à partir du registre.
        foreach ($program in $programsToUninstall) {
            # Trouver l'objet programme original avec la chaîne de désinstallation
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "Lancement du désinstallateur pour '$($program.DisplayName)'..."
                # ATTENTION : Cela lancera le désinstallateur GUI standard du programme.
                # WhatIf ne fonctionnera pas ici, soyez prudent.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "Pour réellement désinstaller les programmes, décommentez la ligne 'cmd.exe /c ...' dans le script."
    }
}
else {
    Write-Warning "Impossible de trouver les programmes installés dans le registre."
}
```

---


Vous avez absolument raison. L'exemple Active Directory ne convient pas à un utilisateur ordinaire et nécessite un environnement spécial.

Remplacez-le par un scénario beaucoup plus universel et compréhensible qui démontre parfaitement la puissance de l'enchaînement de `Out-ConsoleGridView` et sera utile à tout utilisateur.

---

#### Exemple 8 : Enchaînement de `Out-ConsoleGridView`

C'est la technique la plus puissante. La sortie d'une session interactive devient l'entrée d'une autre. **Tâche :** Sélectionner l'un de vos dossiers de projet, puis sélectionner des fichiers spécifiques à partir de celui-ci pour créer une archive ZIP.

```powershell
# --- ÉTAPE 1 : Trouver universellement le dossier "Documents" ---
$SearchPath = [System.Environment]::GetFolderPath('MyDocuments')

# --- ÉTAPE 2 : Sélectionner interactivement un dossier à partir de l'emplacement spécifié ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory |
    Out-ConsoleGridView -Title "Sélectionner le dossier à archiver"

if ($selectedFolder) {
    # --- ÉTAPE 3 : Si un dossier est sélectionné, obtenir ses fichiers et sélectionner ceux à archiver ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File |
        Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les fichiers à archiver de '$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- ÉTAPE 4 : Effectuer l'action avec des chemins universels ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        
        # MOYEN UNIVERSEL D'OBTENIR LE CHEMIN DU BUREAU
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $destinationPath = Join-Path -Path $desktopPath -ChildPath $archiveName
        
        # Créer l'archive
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "L'archive '$archiveName' sera créée sur votre bureau au chemin '$destinationPath'." -ForegroundColor Green
    }
}
```

1.  Le premier `Out-ConsoleGridView` vous montre une liste de dossiers dans vos "Documents". Vous pouvez rapidement trouver celui souhaité en tapant une partie de son nom et en sélectionnant **un** dossier.
2.  Si un dossier a été sélectionné, le script ouvre immédiatement un **deuxième** `Out-ConsoleGridView`, qui affiche maintenant les **fichiers à l'intérieur** de ce dossier.
3.  Vous sélectionnez **un ou plusieurs** fichiers avec la touche `Espace` et appuyez sur `Entrée`.
4.  Le script prend les fichiers sélectionnés et crée une archive ZIP à partir d'eux sur votre bureau.

Cela transforme une tâche complexe en plusieurs étapes (trouver un dossier, trouver des fichiers dedans, copier leurs chemins, exécuter la commande d'archivage) en un processus interactif intuitif en deux étapes.

#### Exemple 9 : Gestion des composants Windows facultatifs

```powershell
# --- Exemple 9 : Gestion des composants Windows facultatifs ---

# Obtenir uniquement les composants activés
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName |
    Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les composants à désactiver"

if ($featuresToDisable) {
    # AVERTIR L'UTILISATEUR DE L'IRRÉVERSIBILITÉ
    Write-Host "ATTENTION ! Les composants suivants seront immédiatement désactivés." -ForegroundColor Red
    Write-Host "Cette opération ne prend pas en charge le mode sécurisé -WhatIf."
    $featuresToDisable | Select-Object DisplayName

    # Demander une confirmation manuelle
    $confirmation = Read-Host "Continuer ? (o/n)"
    
    if ($confirmation -eq 'o') {
        foreach($feature in $featuresToDisable){
            Write-Host "Désactivation du composant '$($feature.DisplayName)'..." -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName
        }
        Write-Host "Opération terminée. Un redémarrage peut être nécessaire." -ForegroundColor Green
    } else {
        Write-Host "Opération annulée."
    }
}
```

Vous pouvez facilement trouver et désactiver les composants inutiles, tels que `Telnet-Client` ou `Windows-Sandbox`.

#### Exemple 10 : Gestion des machines virtuelles Hyper-V

Arrêter rapidement plusieurs machines virtuelles pour la maintenance de l'hôte.

```powershell
# Obtenir uniquement les VM en cours d'exécution
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime |
    Out-ConsoleGridView -OutputMode Multiple -Title "Sélectionner les VM à arrêter"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

Vous obtenez une liste des seules machines en cours d'exécution et pouvez sélectionner interactivement celles qui doivent être arrêtées en toute sécurité.

```