La vérification et la gestion des mises à jour Windows — importante tâche pour maintenir la sécurité et la stabilité du système.
Malheureusement, PowerShell standard ne dispose pas de cmdlets intégrées pour cela. Mais il existe un excellent module tiers appelé **`PSWindowsUpdate`**, qui est devenu une sorte de standard.

Avec l'aide de Gemini CLI, nous pouvons générer un script qui utilise ce module pour effectuer toutes les opérations nécessaires.

### **Étape 1 : Installation du module `PSWindowsUpdate`**

Avant d'exécuter le script, vous devez installer ce module. Cela se fait une seule fois.

Ouvrez PowerShell en tant qu'administrateur et exécutez la commande suivante :

```powershell
Install-Module -Name PSWindowsUpdate
```

Si vous voyez une erreur indiquant que "PowerShellGet" est obsolète, ou un avertissement concernant un "trusted repository", suivez simplement les instructions dans la console. Très probablement, vous devrez confirmer l'installation.

### **Étape 2 : Script pour vérifier et installer les mises à jour**

Après avoir installé le module, vous pouvez utiliser ce script pour vérifier la présence de mises à jour et, si nécessaire, les installer.

**Scénario :** Vous souhaitez vérifier rapidement s'il y a de nouvelles mises à jour Windows et obtenir un rapport.

**Commande que vous pouvez utiliser dans Gemini CLI :**

```powershell
gemini-cli "Écrivez un script PowerShell qui utilise le module PSWindowsUpdate. Le script doit vérifier la présence de mises à jour Windows disponibles, afficher une liste de celles-ci, puis, si des mises à jour sont trouvées, inviter l'utilisateur à les installer."
```

**Exemple de script généré :**

```powershell
# Requires -Module PSWindowsUpdate

Write-Host "--- Vérification et installation des mises à jour Windows ---" -ForegroundColor Green

# 1. Vérification de la présence de mises à jour disponibles
Write-Host "`nRecherche de mises à jour disponibles..." -ForegroundColor Yellow
$availableUpdates = Get-WUList

if ($availableUpdates.Count -eq 0) {
    Write-Host "`nAucune mise à jour trouvée. Votre système est à jour." -ForegroundColor Green
} else {
    Write-Host "`nMises à jour suivantes trouvées :" -ForegroundColor Yellow
    $availableUpdates | Format-Table -AutoSize

    # 2. Proposition d'installer les mises à jour
    $installChoice = Read-Host "`nInstaller les mises à jour trouvées ? (O/N)"

    if ($installChoice -eq 'O' -or $installChoice -eq 'o') {
        Write-Host "`nLancement de l'installation des mises à jour..." -ForegroundColor Yellow
        
        # Téléchargement et installation des mises à jour
        Install-WindowsUpdate -AcceptAll -AutoReboot
        
        Write-Host "`nProcessus d'installation terminé. Un redémarrage peut être nécessaire." -ForegroundColor Green
    } else {
        Write-Host "`nInstallation annulée. Les mises à jour ne seront pas installées." -ForegroundColor Red
    }
}

Write-Host "`n--- Terminé ---" -ForegroundColor Green
```

### Comment ça marche ?

  * **`Get-WUList`** : C'est une cmdlet clé du module `PSWindowsUpdate`. Elle recherche les mises à jour disponibles de la même manière que le Centre de mise à jour Windows standard.
  * **`Read-Host`** : Cette commande permet au script d'interagir avec vous, en demandant une confirmation avant d'installer les mises à jour.
  * **`Install-WindowsUpdate -AcceptAll -AutoReboot`** : Si vous acceptez, cette cmdlet lance le processus d'installation.
      * `-AcceptAll` : Accepte automatiquement les contrats de licence.
      * `-AutoReboot` : Redémarre automatiquement l'ordinateur si nécessaire pour terminer l'installation. Vous pouvez supprimer cet indicateur si vous souhaitez redémarrer manuellement.

Ce script vous donne un contrôle total sur le processus de mise à jour de Windows, ce qui en fait un excellent outil pour l'administration système.
