### Script d'audit du registre

Ce script effectue quatre vérifications clés :

1.  **Démarrage automatique :** Recherche les programmes qui se lancent avec le système dans les clés de registre les plus populaires.
2.  **Paramètres de sécurité :** Vérifie l'état de l'UAC (Contrôle de compte d'utilisateur).
3.  **Informations système :** Affiche la version de Windows et d'autres informations importantes.
4.  **Historique des périphériques USB :** Affiche des informations sur tous les périphériques USB qui ont déjà été connectés.

**Important :** Ce script peut nécessiter des droits d'administrateur pour s'exécuter.

**Commande que vous pouvez utiliser dans Gemini CLI :**

```powershell
gemini-cli "Écrivez un script PowerShell pour un audit complet du registre. Le script doit vérifier le démarrage automatique pour HKLM et HKCU, l'état de l'UAC, la version de Windows et l'historique des périphériques USB connectés. La sortie doit être structurée et facile à lire."
```

**Exemple de script généré :**

```powershell
Write-Host "--- Audit complet du registre Windows ---" -ForegroundColor Green
Write-Host "Le script vérifie les zones clés du registre pour obtenir des informations sur le système et la sécurité." -ForegroundColor Cyan

# 1. Vérification des programmes au démarrage automatique
Write-Host "`n[1] Vérification des programmes au démarrage automatique" -ForegroundColor Yellow
$autoRunPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $autoRunPaths) {
    if (Test-Path -Path $path) {
        Write-Host "  - Vérification de la clé : $path" -ForegroundColor Cyan
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            $name = $_.PSChildName
            $value = $_.$name
            if ($value) {
                Write-Host "    - Nom : $name" -ForegroundColor Magenta
                Write-Host "      Chemin :   $value" -ForegroundColor Magenta
            }
        }
    }
}


# 2. Vérification des paramètres de sécurité (UAC)
Write-Host "`n[2] Vérification des paramètres de sécurité" -ForegroundColor Yellow
$uacStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").EnableLUA
if ($uacStatus -eq 1) {
    Write-Host "  - UAC (Contrôle de compte d'utilisateur) : ACTIVÉ" -ForegroundColor Green
} else {
    Write-Host "  - UAC (Contrôle de compte d'utilisateur) : DÉSACTIVÉ" -ForegroundColor Red
}


# 3. Obtention des informations sur la version de Windows
Write-Host "`n[3] Informations système" -ForegroundColor Yellow
$osInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
Write-Host "  - Version du système d'exploitation : $($osInfo.ProductName) $($osInfo.CurrentVersion)" -ForegroundColor Cyan
Write-Host "  - Build du système d'exploitation : $($osInfo.BuildLabEx)" -ForegroundColor Cyan


# 4. Audit de l'historique des connexions des périphériques USB
Write-Host "`n[4] Historique des connexions des périphériques USB" -ForegroundColor Yellow
Write-Host "  (Nécessite des droits d'administrateur)" -ForegroundColor Red
try {
    $usbDevices = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*"
    if ($usbDevices.Count -gt 0) {
        $usbDevices | ForEach-Object {
            Write-Host "  - Périphérique : $($_.PSChildName)" -ForegroundColor Magenta
            Write-Host "    Description : $($_.FriendlyName)" -ForegroundColor Magenta
        }
    } else {
        Write-Host "  - Aucun périphérique USB trouvé dans le registre." -ForegroundColor Green
    }
} catch {
    Write-Host "  - Erreur : Impossible d'accéder à la clé des périphériques USB. Exécutez le script avec des droits d'administrateur." -ForegroundColor Red
}


Write-Host "`n--- Audit terminé ---" -ForegroundColor Green
```

### Comment ça marche ?

  * **`Test-Path`** : Avant de lire les données, le script vérifie si la clé de registre existe. Cela permet d'éviter les erreurs.
  * **`Get-ItemProperty`** : La cmdlet principale pour lire les valeurs des clés de registre.
  * **Itération des chemins** : Le script utilise le tableau `$autoRunPaths` pour parcourir tous les emplacements de démarrage automatique principaux, y compris les programmes 32 bits sur un système 64 bits (`WOW6432Node`).
  * **Gestion des erreurs** : Le bloc `try...catch` est utilisé pour gérer correctement les situations où l'utilisateur n'a pas les droits d'accès à certaines clés de registre, telles que l'historique des périphériques USB.
  * **Sortie formatée** : En utilisant `Write-Host` et différentes couleurs, le script rend le rapport plus visuel et facile à lire.

Ce script est un excellent point de départ pour un audit plus approfondi. Vous pouvez y ajouter de nouvelles vérifications ou enregistrer les résultats dans un fichier pour une analyse ultérieure.
