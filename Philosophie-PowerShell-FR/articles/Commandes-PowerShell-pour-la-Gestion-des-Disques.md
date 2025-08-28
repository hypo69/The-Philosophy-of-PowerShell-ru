### Diagnostic et récupération de disques avec PowerShell

PowerShell vous permet d'automatiser les vérifications, d'effectuer des diagnostics à distance et de créer des scripts flexibles pour la surveillance. Ce guide vous mènera des vérifications de base au diagnostic et à la récupération de disques en profondeur.

**Version :** Ce guide est pertinent pour **Windows 10/11** et **Windows Server 2016+**.

### Cmdlets clés pour la gestion des disques

| Cmdlet | Objectif |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Informations sur les disques physiques (modèle, état de santé). |
| **`Get-Disk`** | Informations sur les disques au niveau du périphérique (état en ligne/hors ligne, style de partition). |
| **`Get-Partition`** | Informations sur les partitions sur les disques. |
| **`Get-Volume`** | Informations sur les volumes logiques (lettres de lecteur, système de fichiers, espace libre). |
| **`Repair-Volume`** | Vérifier et réparer les volumes logiques (analogue à `chkdsk`). |
| **`Get-StoragePool`** | Utilisé pour travailler avec les espaces de stockage (Storage Spaces). |

---

### Étape 1 : Vérification de base de l'état du système

Commencez par une évaluation générale de l'état du sous-système de disque.

#### Affichage de tous les disques connectés

La commande `Get-Disk` fournit des informations récapitulatives sur tous les disques vus par le système d'exploitation.

```powershell
Get-Disk
```

Vous verrez un tableau avec les numéros de disque, leurs tailles, leur état (`Online` ou `Offline`) et leur style de partition (`MBR` ou `GPT`).

**Exemple :** Trouver tous les disques qui sont hors ligne.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Vérification de la « santé » physique des disques

Le cmdlet `Get-PhysicalDisk` accède à l'état du matériel.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Faites particulièrement attention au champ `HealthStatus`. Il peut prendre les valeurs suivantes :
*   **Healthy :** Le disque est en bon état.
*   **Warning :** Il y a des problèmes, une attention est requise (par exemple, dépassement des seuils S.M.A.R.T.).
*   **Unhealthy :** Le disque est dans un état critique et peut tomber en panne.

---

### Étape 2 : Analyse et récupération des volumes logiques

Après avoir vérifié l'état physique, nous passons à la structure logique — les volumes et le système de fichiers.

#### Informations sur les volumes logiques

La commande `Get-Volume` affiche tous les volumes montés dans le système.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Champs clés :
*   `DriveLetter` — Lettre du volume (C, D, etc.).
*   `FileSystem` — Type de système de fichiers (NTFS, ReFS, FAT32).
*   `HealthStatus` — État du volume.
*   `SizeRemaining` et `Size` — Espace libre et total.

#### Vérification et réparation d'un volume (analogue à `chkdsk`)

Le cmdlet `Repair-Volume` est un remplacement moderne de l'utilitaire `chkdsk`.

**1. Vérification d'un volume sans réparations (analyse uniquement)**

Ce mode est sûr à exécuter sur un système en fonctionnement ; il ne fait que rechercher les erreurs.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Analyse complète et correction des erreurs**

Ce mode est analogue à `chkdsk C: /f`. Il verrouille le volume pendant l'opération, de sorte qu'un redémarrage sera nécessaire pour le lecteur système.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Important :** Si vous exécutez cette commande pour le lecteur système (C:), PowerShell planifiera une vérification au prochain démarrage du système. Pour l'exécuter immédiatement, redémarrez votre ordinateur.

**Exemple :** Vérifier et réparer automatiquement tous les volumes dont l'état n'est pas `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Réparation du volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Étape 3 : Diagnostic approfondi et S.M.A.R.T.

Si les vérifications de base n'ont pas révélé de problèmes, mais que des soupçons subsistent, vous pouvez creuser plus profondément.

#### Analyse des journaux système

Les erreurs du sous-système de disque sont souvent enregistrées dans le journal système de Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Pour une recherche plus précise, vous pouvez filtrer par source d'événement :
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Vérification de l'état S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) est une technologie d'autodiagnostic des disques. PowerShell vous permet d'obtenir ces données.

**Méthode 1 : Utilisation de WMI (pour la compatibilité)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Si `PredictFailure = True`, le disque prédit une défaillance imminente. C'est un signal pour un remplacement immédiat.

**Méthode 2 : Approche moderne via les modules CIM et Storage**

Une méthode plus moderne et détaillée consiste à utiliser le cmdlet `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Ce cmdlet fournit des informations précieuses, telles que l'usure (pertinent pour les SSD), la température et le nombre d'erreurs de lecture/écriture.

---

### Scénarios pratiques pour un administrateur système

Voici quelques exemples prêts à l'emploi pour les tâches quotidiennes.

**1. Obtenir un rapport concis sur l'état de santé de tous les disques physiques.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Créer un rapport CSV sur l'espace libre sur tous les volumes.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Trouver toutes les partitions sur un disque spécifique (par exemple, disque 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Exécuter le diagnostic du disque système avec un redémarrage ultérieur.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```